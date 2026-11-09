Boot: read from disk, in order, `agents/<you>/rules.md`, `map.md`, `ltm.md` (thoroughly), `stm.md`, your `ltm.md` and
`stm.md`, `todo.md` and yours, `mail/` and yours; then `git log --oneline -15` and `git status` (another agent's
uncommitted files: it is live, leave them). REFLECT on what is settled and open before any other read. Close:
`close.md`.

- "Report to me": read the relevant context, then cue in the user and await their response.
- Mutate docs in place: fix the wrong line, delete the superseded one, never append a correction (history: git and
  `logs/`). A fact lives in one place, linked from elsewhere. A file that outgrows its topic splits into branches
  `<root>_<sub>.md` (deeper `_<sub>`), connected by links.
- Writing: always with care, for a human reader: clear, concise, well ordered; say what it is, where it stands, why,
  and what comes next.
- Stale content moves, never deleted: still useful → `graveyard/`, old memory and evidence → `logs/` (your own:
  under `agents/<you>/`), plus one line in that `index.jsonl`:
  `{"date":"<YYYY-MM-DD>","file":"<original path>","by":"<you>","why":"<reason>","tags":["#<tag>"]}`; low quality:
  move to `/tmp/` (prune).
- Writer: `<name_agent_orchestrator>` alone edits shared `ltm.md` and `stm.md` Now.
- Docs: short, self-explanatory names, minimal comments; no thin wrappers, no version suffixes, no tombstones.
- Same commit: a change + its docs; a file added, moved or removed + `registry.md` (except under `logs/`,
  `graveyard/`, `mail/`, `workspace/`).
- Git: commits `<you>: <what>`, one logical change, explicit paths (never `git add -A`). Shared files: re-read,
  edit, commit at once.
