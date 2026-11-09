---
name: selfcompact
description: Walk through the session end to end, then compact; optionally type a restart line now, at the 5h reset or at a time.
disable-model-invocation: true
argument-hint: "[boot|go|stop|\"text\"] [now|reset|HH:MM]"
---

Arguments: $ARGUMENTS (from `close.md` or the user's words: map them to these, e.g. "don't start fresh" → `stop`,
"continue after the reset" → `go reset`)
- then: `boot` (default) → line `boot.`; `go` → `continue.`; `stop` → no line, stay idle; `"<text>"` → that text.
- at: `now` (default), `reset` (2 min after the 5h reset), `HH:MM` (next occurrence). Not with `stop`.

1. Walkthrough (skip right after `close.md`): go through the entire session end to end (every request, change,
   decision) and check each is committed, documented, and recorded where the next session reads it. Fix gaps and
   commit.
2. Last action of the turn: one Bash call with `run_in_background: true`:
   `<coding>/tools/claude_autocompact.sh self <then> <at>`, the words as they are (`boot`, `go`, `stop`, or
   `"<text>"`; the script maps them; `stop` takes no at, detaches and returns `detached` at once). `self` is your
   pane from `$WEZTERM_PANE`; if the script says it is unset, use `mark:ac-` + 4 random letters you make up now
   instead of `self` (never an id seen before).
3. End the turn with one short line. The script types `/compact` (it waits in the queue until your turn ends), then
   the line once the compaction is done (and at <at>). Its notice (`ok pane N` or why it stopped) reaches the
   compacted session; if it stopped, tell the user. With `stop`, nothing reaches the compacted session;
   `/tmp/claude_autocompact.log` says ok or why it stopped.
