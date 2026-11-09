#!/usr/bin/env bash
# Claude Code PostToolUse hook: tells the agent "context_used: <n>K (<advice>; next note <n>K)" once at 250K, then
# once per further 75K (CTXWARN_FROM to change the start), again after a compaction. Context = last usage in the
# transcript; state in ~/.claude/ctxwarn/<session>.
in=$(cat)
jq -e '.agent_id' <<<"$in" >/dev/null && exit 0  # subagents: no warning
t=$(jq -r '.transcript_path // empty' <<<"$in"); s=$(jq -r '.session_id // empty' <<<"$in")
[ -f "$t" ] && [ -n "$s" ] || exit 0
ctx=$(tac "$t" | grep -m1 '"usage"' | jq '.message.usage | .input_tokens + (.cache_creation_input_tokens // 0)
  + (.cache_read_input_tokens // 0)' 2>/dev/null)
from=${CTXWARN_FROM:-250000}; f=~/.claude/ctxwarn/$s; [[ $ctx =~ ^[0-9]+$ ]] || exit 0
# below the start (a compaction keeps the session id): forget the steps already warned
[ "$ctx" -ge "$from" ] || { rm -f "$f"; exit 0; }
step=$(( (ctx - from) / 75000 ))
[ "$step" -gt "$(cat "$f" 2>/dev/null || echo -1)" ] || exit 0
mkdir -p ~/.claude/ctxwarn && echo "$step" >"$f"
if [ "$step" -eq 0 ]; then a="info only, carry on"  # 250K; from 325K advice, from 475K firmer; never mid-discussion
elif [ "$step" -lt 3 ]; then a="compact at a natural break, never mid-discussion"
else a="compact at the next natural break, never mid-discussion"; fi
m="context_used: $((ctx / 1000))K ($a; next note $(( (from + (step + 1) * 75000) / 1000 ))K)"
jq -nc --arg m "$m" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
