#!/usr/bin/env bash
# Claude Code status line: "<model> <effort> · ctx <n>K · cache <min>m|cold · 5h <%> (<reset>) · 7d <%> (<reset>)"
# + custom items: one JSON file each in ~/.claude/statusline.d/ then <project>/.claude/statusline.d/ (by name),
#   {"text": "...", "colour": "#rrggbb", "until": <unix time>} (colour, until optional; any writer; /addtoline);
# prefixed with a warning when a handover is due. Colour (24-bit, faded): model by family; effort low → max
# blue, sea green, yellow, orange, red (auto lilac);
# labels sage; 5h/7d green 0% → yellow 70% → red at threshold; ctx green 100K → yellow 300K →
# orange 500K (warning) → red 700K;
# reset time by pace (used % ÷ elapsed % of the window): blue ≤ 0.5 (slow), green 0.85–1.15, yellow 1.35, red ≥ 1.7;
# cache green ≥ warning + 15m → orange at HANDOVER_CACHE_MIN (warning) → red ≤ 5m, cold grey (red above HANDOVER_COLD_CTX); warning bold red.
# Thresholds (env overrides): HANDOVER_CACHE_MIN (min left), HANDOVER_5H / HANDOVER_7D (%), HANDOVER_CTX (tokens),
# HANDOVER_COLD_CTX (tokens: warn on cold cache only above this context size).
# Saves .rate_limits to ~/.claude/rate_limits.json (live 5h/7d read for agents).
input=$(cat)
rl=$(jq -c '.rate_limits // empty' <<<"$input") && [ -n "$rl" ] &&
  echo "$rl" >~/.claude/rate_limits.json.$$ && mv ~/.claude/rate_limits.json.$$ ~/.claude/rate_limits.json
project=$(jq -r '.workspace.project_dir // .cwd // empty' <<<"$input")
dirs=(~/.claude/statusline.d); [ "$project/.claude" -ef ~/.claude ] || dirs+=("$project/.claude/statusline.d")
items=$(for d in "${dirs[@]}"; do for f in "$d"/*.json; do [ -f "$f" ] &&
  jq -cn 'input | select(type == "object" and .text != null) | .text |= (tostring | .[:80])' "$f" 2>/dev/null
done; done | jq -sc .)
num() { [[ $1 =~ ^[0-9]+$ ]] && echo "$1" || echo "$2"; }  # bad env override → default
jq -j --argjson now "$(date +%s)" \
  --argjson items "${items:-[]}" \
  --argjson cmin "$(num "$HANDOVER_CACHE_MIN" 15)" --argjson h5 "$(num "$HANDOVER_5H" 85)" --argjson d7 "$(num "$HANDOVER_7D" 95)" \
  --argjson cmax "$(num "$HANDOVER_CTX" 500000)" --argjson cold "$(num "$HANDOVER_COLD_CTX" 100000)" '
  def dur: (. / 60 | floor) as $m
    | if $m < 60 then "\($m)m" elif $m < 1440 then "\($m / 60 | floor)h\($m % 60)m"
      else "\($m / 1440 | floor)d\($m % 1440 / 60 | floor)h" end;
  def rgb($c): "\u001b[38;2;\($c | map(tostring) | join(";"))m\(.)\u001b[0m";
  def hexrgb: ascii_downcase | explode[1:] | map(if . >= 97 then . - 87 else . - 48 end)
    | [.[0] * 16 + .[1], .[2] * 16 + .[3], .[4] * 16 + .[5]];
  def mix($a; $b; $t): [range(3) as $i | $a[$i] + ($b[$i] - $a[$i]) * $t | round];
  def ramp($v; $s): if $v <= $s[0][0] then $s[0][1] elif $v >= $s[-1][0] then $s[-1][1]
    else first(range(1; $s | length) | select($v <= $s[.][0])) as $i
    | mix($s[$i - 1][1]; $s[$i][1]; ($v - $s[$i - 1][0]) / ($s[$i][0] - $s[$i - 1][0])) end;
  [135, 195, 135] as $green | [215, 200, 115] as $yellow | [220, 115, 110] as $red | [225, 160, 105] as $orange
  | [125, 160, 210] as $blue | [125, 125, 125] as $sep | [150, 150, 150] as $grey | [140, 160, 150] as $lab
  | def field($l; $v; $c): ($l | rgb($lab)) + " " + ($v | rgb($c));
  def used($r): if ($r.resets_at // $now + 1) <= $now then 0 else $r.used_percentage // 0 end;
  def usage($name; $r; $limit; $win): if $r then used($r) as $u
    | field($name; "\($u | floor)%"; ramp($u; [[0, $green], ([70, $limit - 1] | min | [., $yellow]), [$limit, $red]]))
      + (if $r.resets_at then ([$r.resets_at - $now, 0] | max) as $rem | ($win - $rem) as $el
         | " " + ("(" + ($rem | dur) + ")"
           | rgb(if $el < 0.05 * $win then $grey else ramp($u / (100 * $el / $win);
               [[0.5, $blue], [0.85, $green], [1.15, $green], [1.35, $yellow], [1.7, $red]]) end))
         else "" end)
    else empty end;
  (.model.display_name // "") as $name
  | (if $name | test("opus"; "i") then [180, 155, 220] elif $name | test("sonnet"; "i") then [130, 175, 220]
     elif $name | test("haiku"; "i") then [120, 200, 195] elif $name | test("fable"; "i") then [220, 165, 200]
     else [175, 175, 175] end) as $mc
  | (.context_window.total_input_tokens // 0) as $ctx
  | (.prompt_cache.expires_at // null) as $exp
  | (if $exp then (($exp - $now) / 60 | floor) else null end) as $left
  | (.prompt_cache.warm == true and $left != null and $left >= 0) as $warm
  | used(.rate_limits.five_hour) as $u5
  | used(.rate_limits.seven_day) as $u7
  | ([ ([($name | select(. != "") | rgb($mc)), (.effort.level // empty | rgb({low: $blue, medium: [135, 190, 160], high: $yellow,
         xhigh: $orange, max: $red}[ascii_downcase] // [170, 160, 185])),
         (if .fast_mode then "fast" | rgb([230, 170, 110]) else empty end)] | select(length > 0) | join(" ")),
       field("ctx"; "\($ctx / 1000 | floor)K"; ramp($ctx; [[100000, $green], [300000, $yellow], [500000, $orange], [700000, $red]])),
       (if $warm then field("cache"; "\($left)m"; ramp($left; ([$cmin, 6] | max) as $o | [[5, $red], [$o, $orange], [$o + 15, $green]]))
        elif $exp != null then field("cache"; "cold"; if $ctx >= $cold then $red else $grey end) else empty end),
       usage("5h"; .rate_limits.five_hour; $h5; 18000),
       usage("7d"; .rate_limits.seven_day; $d7; 604800),
       ($items[] | select(((.until | numbers) // $now + 1) > $now) | .colour as $c
        | .text | tostring | gsub("[[:cntrl:]\u200e\u200f\u202a-\u202e\u2066-\u2069]"; " ")
        | rgb(if $c | type == "string" and test("^#[0-9a-fA-F]{6}$") then $c | hexrgb else [160, 160, 160] end)) ] | join(" · " | rgb($sep))) as $base
  | [ (if $warm and $left <= $cmin then "cache \($left)m" else empty end),
      (if ($warm | not) and $exp != null and $ctx >= $cold
       then "cache cold · next turn re-reads \($ctx / 1000 | floor)K" else empty end),
      (if $u5 >= $h5 then "5h \($u5 | floor)%" else empty end),
      (if $u7 >= $d7 then "7d \($u7 | floor)%" else empty end),
      (if $ctx >= $cmax then "ctx \($ctx / 1000 | floor)K" else empty end) ]
  | if length > 0 then ("⚠ HANDOVER → /compact · " + join(" · ") | "\u001b[1;31m\(.)\u001b[0m") + "  " + $base else $base end' <<<"$input"
