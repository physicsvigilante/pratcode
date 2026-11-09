# Map

<What the project is: its goal and its basic ideas, in a few plain lines. Mutated in place as the project changes.>

## The codebase
<One entry per part, in the order a newcomer should meet them: what it is, what it does, where to enter it (its
index or main file), tags where they help. Nest a part's own parts under it; mark what is never read at boot
(e.g. run outputs).>
- `docs/`: <the project's documents>: one tree per topic, a root `<topic>.md` and its branches
  `<topic>_<sub>.md`, linked; enter at `<the main root>` · `#<tag>`
- `src/`: <the code: what it does>; enter at `<main file or index>` · `#<tag>`
  - `<sub-part>/`: <what it does>
- `<part>/`: <what it is and does>; enter at `<index or main file>` · `#<tag>`

## Memory and workflow
- Shared at the root, per agent in `agents/<name>/`: `ltm.md` durable truth; `stm.md` Now + Ledger (agent: live
  thread); `todo.md`; agent `rules.md`.
- `mail/<from>_<topic>.md`; `logs/` and `graveyard/`, each with `index.jsonl`; agent only: `workspace/` (scratch).
- `review_queue.md`: anything for the user to read, decide or know (format in its header; not a boot read).
- On demand: `registry.md` (every tracked file with comment and tags; grep), `meta.md` (workflow manual).

## Agents
- `<name>`: <role, one line>

## Tags
Registered tags are the only ones used in `registry.md` and the indexes; register a new one here first. Tags label
files across topics; they are not topics and not part of file names.
- `#<tag>`: <meaning>

## Where to look
- <question> → <file> (e.g. why a decision was made → `grep '#<tag>' logs/index.jsonl`, then the log)
- Live runs: <status command, or none>
