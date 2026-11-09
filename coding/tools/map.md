# Map

Tools for working with Claude Code on WSL: its settings and helper scripts (status line, context messages,
self-compaction) and the terminal setup. Not an application: project work lives in its own repos under `$coding`.
Every repo finds these docs through `README.md`.

## The codebase
- `README.md`: the setup as an interactive workflow (the design's ideas, steps, tests), daily use, the doc index.
- Claude Code: `claude_config.md` (install, settings, status line, context messages, selfcompact) · `#claude`
  - `claude_statusline.sh`: the status line (model, context, cache, 5h/7d usage, handover warning)
  - `claude_ctxwarn.sh`: tells the agent its context size from 250K on (PostToolUse hook)
  - `claude_autocompact.sh`: types `/compact` and a restart line into Claude's WezTerm pane
  - `skills/selfcompact/SKILL.md`: the `/selfcompact` skill (installed to `~/.claude/skills/selfcompact/`)
- Terminal: `wsl_wezterm.md` (WSL, shell, WezTerm, garbled-line fix), `wezterm.lua` (the WezTerm config, installed
  to `C:\Users\<name>\.wezterm.lua`) · `#shell`
- `tools_updates.md`: the change log (what, why, undo), newest first · `#docs`
- `tmp/`: scratch, git-ignored; never read at boot.

## Memory and workflow
- Shared at the root, per agent in `agents/<name>/`: `ltm.md` durable truth; `stm.md` Now + Ledger (agent: live
  thread); `todo.md`; agent `rules.md`.
- `mail/<from>_<topic>.md`; `logs/` and `graveyard/`, each with `index.jsonl`; agent only: `workspace/` (scratch).
- `review_queue.md`: anything for the user to read, decide or know (format in its header; not a boot read).
- On demand: `registry.md` (every tracked file with comment and tags; grep), `$coding/workspace/meta.md` (the
  framework's manual); new agents copy `$coding/workspace/agents/_skeleton/`.

## Agents
- `claude`: writer; Claude Code configuration, scripts, docs, terminal.

## Tags
Registered tags are the only ones used in `registry.md` and the indexes; register a new one here first. Tags label
files across topics; they are not topics and not part of file names.
`#mail` handled mail · `#memory` memory files · `#workflow` protocol and agent folders · `#docs` doc index and
change log · `#claude` Claude Code · `#shell` shell and terminal

## Where to look
- A tool → `README.md` or grep `registry.md`; Claude Code → `claude_config.md`; terminal → `wsl_wezterm.md`.
- Recent changes → the top of `tools_updates.md`; why a decision was made → `grep '#<tag>' logs/index.jsonl`, then
  the log.
- Live runs: none.
