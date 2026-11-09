#!/usr/bin/env bash
# claude_autocompact.sh <self | mark:<string> | pane-id> [message] [at]: types /compact, then the optional message
# (boot = "boot.", go = "continue.", stop or none = no message, else the text itself), into a Claude Code session in a
# WezTerm pane. self = $WEZTERM_PANE, the caller's own pane (WezTerm passes it into WSL via WSLENV, ~/.wezterm.lua);
# mark:<string> = the pane whose screen shows <string> (fallback; only the visible rows count).
# Another session's pane id needs AC_SESSION=<its session id>. Run it with run_in_background so it acts after your turn.
# at = now (default) | reset (2 min after the 5h reset in ~/.claude/rate_limits.json) | HH:MM (next occurrence).
# /compact typed into a busy session waits in its queue until the turn ends; a queued message would be absorbed at the
# next tool result, so the message goes in only after the compaction (and at <at>). State comes from the session
# transcript: each typed line must show up there (else retried: a scrolled pane eats keys), then a compact_boundary.
# Typing refuses an input box holding text (the user's draft). Without a message (stop) it detaches and returns at
# once; nothing of it reaches the compacted session. Prints ok or why; the log /tmp/claude_autocompact.log has every run.
w=wezterm.exe; t=$1; msg=$2; at=${3:-now}; log=/tmp/claude_autocompact.log
case $msg in boot) msg=boot. ;; go) msg=continue. ;; stop) msg= ;; esac
[ -n "$AC_DETACHED" ] || { echo "$(date '+%F %T') $*" >>$log; exec > >(tee -a $log) 2>&1; }
if [ "$t" = self ]; then
  [ -n "$WEZTERM_PANE" ] || { echo "WEZTERM_PANE unset (pane opened before the WezTerm config change): use mark:<id>"; exit 1; }
  t=$WEZTERM_PANE
elif [[ $t != mark:* ]] && [ -z "$AC_SESSION" ] && [ "$t" != "$WEZTERM_PANE" ]; then
  echo "pane $t is not yours: set AC_SESSION=<its session id>"; exit 1
fi
s=${AC_SESSION:-$CLAUDE_CODE_SESSION_ID}; j=$(ls ~/.claude/projects/*/"$s".jsonl 2>/dev/null | head -1)
[ -n "$s" ] && [ -f "$j" ] || { echo "no transcript for session '$s'"; exit 1; }
case $at in
  now) when=0 ;;
  reset) when=$(( $(jq -r '.five_hour.resets_at // 0' ~/.claude/rate_limits.json) + 120 )) ;;
  [0-9]*:[0-9]*) when=$(date -d "$at" +%s) || exit 1; [ "$when" -gt "$(date +%s)" ] || when=$((when + 86400)) ;;
  *) echo "bad at: $at"; exit 1 ;;
esac
if [[ $t == mark:* ]]; then
  p=$(for i in $($w cli list --format json | jq '.[].pane_id'); do
    $w cli get-text --pane-id "$i" | grep -qF "${t#mark:}" && echo "$i"; done | head -1)
  [ -n "$p" ] || { echo "no pane shows ${t#mark:}"; exit 1; }
else
  p=$t
fi
# no message: a task of the session still running at the compaction shows as such afterwards, and its notice lands
# in the compacted context; a detached copy leaves the session clean
[ -z "$msg" ] && [ -z "$AC_DETACHED" ] && { AC_DETACHED=1 setsid nohup "$(realpath "$0")" "$@" >>$log 2>&1 </dev/null &
  echo detached; exit 0; }
# since <n> <jq filter> [jq args]: a transcript line after line <n> matches
since() { tail -n +"$(($1 + 1))" "$j" | jq -e "${@:3}" "select($2)" >/dev/null 2>&1; }
# box: the input box's first line (below its upper border) -> $line (with escapes), $plain (text only); waits up to
# 1 min for it (Ctrl+End each time), else saves the screen to $log.screen
box() {
  for b in $(seq 30); do
    e=$($w cli get-text --pane-id "$p" --escapes)
    k=$(sed 's/\x1b[[(][0-9;:]*[A-Za-z]//g' <<<"$e" | awk '/^─/ {b2 = b1; b1 = NR} END {print b2 ? b2 + 1 : 0}')
    [ "$k" -gt 0 ] && line=$(sed -n "${k}p" <<<"$e") || line=
    [[ $line == *❯* ]] && break
    $w cli send-text --pane-id "$p" --no-paste $'\e[1;5F'; sleep 2
  done
  [[ $line == *❯* ]] || { printf '%s\n' "$e" >"$log.screen"; echo "pane $p shows no input box (screen: $log.screen)"; exit 1; }
  plain=$(sed 's/\x1b[[(][0-9;:]*[A-Za-z]//g; s/\xc2\xa0/ /g; s/^[[:space:]]*❯[[:space:]]*//; s/[[:space:]]*$//' <<<"$line")
}
# put <text>: Ctrl+End, the box empty or a dim suggestion, the text, Enter only if the box shows just the text (the
# user typing meanwhile: stop); done once the transcript records it (a prompt or slash command, or a queue entry while
# busy). Retyped only if the keys never reached the box (a scrolled pane eats them), Enter again only if the text
# still sits there (a lost Enter); 3 tries
put() {
  for try in 1 2 3; do
    n=$(wc -l <"$j")
    $w cli send-text --pane-id "$p" --no-paste $'\e[1;5F'; sleep 1; box
    if ! { [ -n "$plain" ] && [[ $1 == "$plain"* ]]; }; then
      [ -z "$plain" ] || grep -qaE $'\e\\[(0;)?2m' <<<"$line" || { echo "pane $p input box has text: $plain"; exit 1; }
      $w cli send-text --pane-id "$p" --no-paste "$1"; sleep 2; box
      [ -z "$plain" ] && continue
      [[ $1 == "$plain"* ]] || { echo "pane $p input box has other text: $plain (no Enter)"; exit 1; }
    fi
    $w cli send-text --pane-id "$p" --no-paste $'\r'
    for i in 1 2 3 4 5; do sleep 2
      since "$n" '(.type == "user" and (.message.content | type == "string" and (. == $x or startswith("<command-name>" + $x + "</command-name>")))) or (.type == "queue-operation" and .operation == "enqueue" and .content == $x)' --arg x "$1" && return 0
    done
    box; [ -n "$plain" ] && [[ $1 == "$plain"* ]] || { echo "pane $p: '$1' sent, but the transcript has no record of it"; exit 1; }
  done
  echo "pane $p: '$1' not taken after 3 tries"; exit 1
}
n=$(wc -l <"$j")
put /compact
# the compaction: up to 30 min (the turn ends first); another /compact reply (e.g. "Not enough messages") stops
for i in $(seq 600); do
  since "$n" '.subtype == "compact_boundary"' && break
  r=$(tail -n +"$((n + 1))" "$j" | jq -r 'select(.subtype == "local_command") | .content' 2>/dev/null |
    sed -n 's/.*<local-command-stdout>\(.*\)<\/local-command-stdout>.*/\1/p' | grep -v Compacted | head -1)
  [ -n "$r" ] && { echo "pane $p: /compact says: $r"; exit 1; }
  sleep 3
done
since "$n" '.subtype == "compact_boundary"' || { echo "pane $p: no compaction within 30 min"; exit 1; }
if [ -n "$msg" ]; then
  sleep 5; now=$(date +%s); [ "$when" -gt "$now" ] && sleep $((when - now))
  put "$msg"
fi
echo "$(date '+%F %T') ok pane $p"
