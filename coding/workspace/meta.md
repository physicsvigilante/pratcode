# meta.md — workflow manual (not a boot read)

How this workflow works, how to set it up, why. Per-project changes go in `AGENTS.md` (project rules), `map.md` and
`agents/<name>/rules.md`; the rest stays as in the template so repos stay comparable.

## How it works
- Boot: the user types `boot` (a restart line after a compaction says the same); the read order sits in `AGENTS.md`,
  which loads every session anyway, so boot costs no extra file. Repo files must carry everything.
- Close (`close.md`): each agent closes its own files; the writer (the orchestrator) then maintains shared memory.
- Memory: shared (`ltm`/`stm`/`todo`) + per agent (`agents/<name>/`). Distilled truth is cheap to read; raw
  detail goes to `logs/`, read on demand.
- Mutate in place: a wrong line is fixed, a superseded one deleted; never an appended correction. History lives in
  git and `logs/`, so the files read as the current truth only. One fact in one place, linked from elsewhere: a copy
  drifts. A file that outgrows its topic splits into branches `<root>_<sub>.md`, linked; `ls <root>*` shows the tree.
- Names and tags are separate: a file's name gives its topic (`<topic>_<subtopic>.md`, the tree above); tags
  (registered in `map.md`) label files across topics in `registry.md` and the indexes, for grep.
- Stale content: graveyard (still useful), logs (old memory, evidence), `/tmp/` (low quality; git keeps it).
- `review_queue.md`: the user's inbox, not a boot read. Anything for the user to read, decide or know is one item
  there instead of scattered across stm, todo and chat; the writer files each answer where it belongs.
- `map.md`: the navigation map and the repo's first description: what the project is, what each part of the
  codebase does and where to enter it, then memory, agents, tags, where to look. Mutated in place as the repo changes.
- One boot budget (~64 KB for the boot reads, mail aside) instead of per-file caps, checked by the writer at close:
  REFLECT keeps memory true and tight; over budget → split a branch or move old content to `logs/`.
- `registry.md`: every tracked file with a comment and tags; grep finds files by meaning without scanning;
  kept current in the same commit as the file change. Large repos: a path ending in `/` is a region line for a
  subtree with its own index; the close check then skips files inside regions (drop `^(<region>|…)/[^/]+/` from
  the listing and region lines from the registry side).
- One writer for shared memory: prose merges fail silently. Others tag `[durable]` or mail.
- Mail: `mail/` (broadcast; the writer graveyards it once reflected in Now) and `agents/<name>/mail/`; short,
  pointer-based, `<from>_<topic>.md`, committed by the sender; a reply is new mail to the sender's inbox;
  after handling, the recipient `git mv`s it to `agents/<you>/graveyard/` (broadcast: `graveyard/`).
- Boot reads stay lean: boot reads recent git history (no date query); todo items are referred to by
  description, never by number (numbers break on rewrites).
- `logs/`: old memory and evidence ("when did we decide X, why?"). Find by `grep '#<tag>' logs/index.jsonl`
  or by date; three hops: index → log → cited artifact.

## Session zero (setup)
1. Copy this template to the repo root.
2. Ask only what can't be inferred: mission (one line), which agents, known model quirks.
3. `map.md`: replace every `<…>` placeholder with real content or delete it. `registry.md`: every tracked file.
   `AGENTS.md`: the writer's name, plus the project's own rules (e.g. its git branch).
4. Every listed agent: copy `agents/_skeleton/` to `agents/<name>/` (so mail can reach it), list it in `map.md`
   Agents; write its `rules.md` (role, rules, quirks as `on <date> X → rule`; Opus agents start from
   `agents/opus/rules.md`).
5. Seed: `ltm.md` invariants; `stm.md` Now + first Ledger line; `todo.md` first tasks; `review_queue.md` empty.
6. Cold-boot exam: a zero-context agent must state the mission, name the maps, find its rules, list the
   durable facts, find its next task. Each failure names the file to fix.

## New agent (existing repo)
1. `<you>` = the name the user gave you (ask if none); ask the user for your role.
2. Copy `agents/_skeleton/` to `agents/<you>/`; write `rules.md` (role, rules, quirks; Opus: from
   `agents/opus/rules.md`).
3. Add yourself to `map.md` Agents (name, rough role) and your files to `registry.md`; commit `<you>: join`.
4. Boot: the read order in `AGENTS.md`.

## Workflow review (occasional, not a close step)
Run when the user asks or the workflow feels heavy. Analyze how the workflow is actually used; report findings to
the user (`review_queue.md`):
- Token cost: boot read size per agent (the `close.md` command, ÷ 4 for tokens) against the ~64 KB budget; which
  files grow fastest; mail and logs volume.
- Compliance: steps agents skip (missing Ledger lines, unfolded `[durable]`, stale registry, full inboxes, appended
  corrections).
- Value: files nobody reads, rules nobody follows, friction the user reports.
Change the protocol only with the user's approval.
