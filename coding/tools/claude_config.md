# Claude Code setup

Tested on Claude Code 2.1.319 (November 2026). Replace `<coding>` with the code root everywhere below.

## Install

In WSL: `curl -fsSL https://claude.ai/install.sh | bash`, then `claude` and log in. `claude --version` to check.

## Settings

`~/.claude/settings.json` (all projects). Show the user the merged file before writing it, and validate it after
(`jq . ~/.claude/settings.json`). In auto mode Claude may not edit this file itself: the user does, or approves.

```json
{
  "permissions": {
    "allow": ["Bash(<coding>/tools/claude_autocompact.sh:*)"],
    "defaultMode": "auto"
  },
  "model": "opus",
  "effortLevel": "high",
  "autoCompactEnabled": false,
  "autoMemoryEnabled": false,
  "statusLine": {
    "type": "command",
    "command": "<coding>/tools/claude_statusline.sh",
    "refreshInterval": 60
  },
  "hooks": {
    "PostToolUse": [
      {"matcher": "*", "hooks": [{"type": "command", "command": "<coding>/tools/claude_ctxwarn.sh"}]}
    ]
  }
}
```

- `allow`: selfcompact's script. Without it, auto mode refuses a session typing into its own terminal.
- `defaultMode: "auto"`: Claude acts without asking, a safety check blocks risky actions. Alternatives: leave it out
  (asks for each command) or `"acceptEdits"`.
- `autoCompactEnabled: false`: the agent compacts at a natural break, prompted by the context messages below. Leave
  it out (on) for a safety net: Claude Code then compacts by itself near the window's end, even mid-task.
- `autoMemoryEnabled: false`: memory lives in the repo files (`ltm.md`, `stm.md`), not Claude's own memory folder.
- Settings apply live; a change to the tool list re-reads the whole conversation once, so change those between
  sessions.

## Context bar (`claude_statusline.sh`)

The row under the input box: `<model> <effort> · ctx <n>K · cache <min>m · 5h <%> (<reset in>) · 7d <%> (<reset in>)`.
- Colours fade green → yellow → red as values grow; reset times are coloured by pace (blue slow, green on pace, red
  too fast). `cache` is the prompt cache's time left (1 h on a subscription, 5 min past the limits): a turn after
  it goes cold re-reads the whole context at full price.
- `⚠ HANDOVER → /compact · <reasons>` in bold red when: cache ≤ 15 min left, cache cold with context ≥ 100K, 5h ≥ 85%,
  7d ≥ 95%, or context ≥ 500K. On it: close the session (`close.md`), then `/selfcompact`. Thresholds: env
  `HANDOVER_CACHE_MIN`, `HANDOVER_COLD_CTX`, `HANDOVER_5H`, `HANDOVER_7D`, `HANDOVER_CTX`.
- It saves the 5h/7d numbers to `~/.claude/rate_limits.json`; selfcompact's `reset` reads it. The 5h/7d fields come
  only with a subscription login (Pro/Max).
- Extra items (optional): one JSON file each in `~/.claude/statusline.d/`,
  `{"text": "...", "colour": "#rrggbb", "until": <unix s>}`; delete the file to remove it.
- Test: `echo '{"model":{"display_name":"Opus"},"effort":{"level":"high"},"context_window":{"total_input_tokens":520000}}' | <coding>/tools/claude_statusline.sh; echo`
  prints the row with a HANDOVER warning for ctx.

## Context messages (`claude_ctxwarn.sh`)

After each tool call, Claude gets one line at 250K context, then every 75K:
`context_used: <n>K (<advice>; next note <n>K)`. Advice: 250K "info only, carry on"; from 325K "compact at a natural
break, never mid-discussion"; from 475K "at the next natural break". It starts again after a compaction. Subagents
get none. The start: env `CTXWARN_FROM` (tokens).
- Why never "stop": a warning that said "stopping point" once made two agents close at once.
- Habit: compact at a natural break past 250K; long discussions with the user can run higher to keep their context.
- Test: in a scratch folder start `CTXWARN_FROM=1000 claude`, ask it to run `ls` and to quote any `context_used`
  line it got.

## Selfcompact (`/selfcompact`, `claude_autocompact.sh`)

Claude cannot run `/compact` itself; the script types it into Claude's own WezTerm pane.
Install: copy `skills/selfcompact/` to `~/.claude/skills/selfcompact/` and put the real path in place of `<coding>`.

`/selfcompact [then] [at]`
- then: `boot` (default) types `boot.` after the compaction (a fresh boot); `go` types `continue.`; `stop` types
  nothing (the session stays idle until you write); `"text"` types that text.
- at: `now` (default); `reset` = 2 min after the 5h limit resets (needs the bar's file); `HH:MM` = next time it is
  that clock time. Not with `stop`.
- Examples: `/selfcompact stop` (done for today), `/selfcompact go reset` (out of usage: continue after the reset),
  `/selfcompact boot 07:30`.

What happens: Claude checks the session is committed and recorded, then starts the script in the background and ends
its turn. The script types `/compact`, waits for it in the session's transcript, then types the line at its time. It
never types over text in the input box. Log: `/tmp/claude_autocompact.log`.
- Needs: WezTerm, `$WEZTERM_PANE` (a pane opened after the config change), the allow rule, `jq`.
- Test in a scratch session: chat two turns, `/selfcompact "hello"`; the session compacts, then gets `hello`.
- Without WezTerm: type `/compact`, then the restart line, yourself.

## Optional: fewer tokens per turn

Every enabled tool and skill costs tokens on every call. In `/context` see what loads; then, in settings:
- `"permissions": {"deny": [...]}` for unused tools (seen: Artifact ~5K tokens, SendFeedback ~2K, ScheduleWakeup
  ~1.6K, EnterWorktree ~1.7K). A denied tool is gone until the entry is removed.
- `"skillOverrides": {"<skill>": "user-invocable-only"}`: the skill stays typeable as `/name` and costs nothing idle.
- `"disableClaudeAiConnectors": true`: drops claude.ai connectors (Gmail, Drive, ...).

## Project instructions

Claude Code reads `AGENTS.md` when no `CLAUDE.md` is loaded; this setup uses `AGENTS.md` only (no `CLAUDE.md`
anywhere under `<coding>`, a parent's counts too). Every ancestor `AGENTS.md` loads at start (`<coding>/AGENTS.md`
+ the project's), once: mid-session edits load at the next `/clear` or `/compact`. HTML comments in it are stripped.
