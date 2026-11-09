Everyone:
1. Housekeeping: handled mail → your graveyard; replies = new mail in `agents/<them>/mail/<you>_<topic>.md`;
   scratch → `agents/<you>/workspace/`; todo: done or stale removed; quick fixes now, the rest → `todo.md`; what the
   user should see → `review_queue.md`.
2. Registry check (bash; a new part of the codebase also goes in `map.md`):
   `comm -3 <(git ls-files -co --exclude-standard | grep -vE '(^|/)(logs|graveyard|mail|workspace)/|\.gitkeep$' | sort) <(grep -v '^#' registry.md | awk 'NF{print $1}' | sort)`
   prints nothing for your files.
3. Coherence: the docs read as one textbook or wiki: each topic in one place, linked, current, and true to the code
   and configs they describe. Code changed → its tests or a real run; a config changed → validate it.
4. REFLECT: what did this session settle, what is open, what matters next time? Is your `ltm.md`/`stm.md` still
   true, needed, tight?
5. Memory: entry in `agents/<you>/stm.md`; lane facts → your `ltm.md`; facts others need: tag the stm line
   `[durable]` (the writer folds it) or mail the writer. Prune per the REFLECT; old content → `agents/<you>/logs/`.
6. Append your Ledger line at the end of `stm.md` (re-read it first): `date · <you> · what · next`.
   Commit (check `git status` for keys or large binaries first).

The writer (`<name_agent_orchestrator>`), at the very end: REFLECT on shared `ltm.md`/`stm.md` and the boot budget
(the boot reads, mail aside, ≤ ~64 KB; over → split a branch or move old content to `logs/`), then maintain them
token-efficiently: prune stale memories; fold `[durable]` lines (`grep -rn '^- .*\[durable\]' agents/*/stm.md`) and
remove the tags; answered `review_queue.md` items → their home, then removed; rewrite Now (state, open decisions;
queued work only in `todo.md`, the user's items only in `review_queue.md`, both pointed to); keep the last 20 Ledger
lines (older → `logs/`); broadcast mail reflected in Now → `graveyard/`. Boot size:
`cat AGENTS.md map.md ltm.md stm.md todo.md agents/<you>/{rules,ltm,stm,todo}.md 2>/dev/null | wc -c`.
Commit.

RECHECK everything once more: re-read what you changed, the registry check passes, `git status` shows none of your files.

Then compact per `~/.claude/skills/selfcompact/SKILL.md`: in autonomous mode on your own (`go`), otherwise only
when the user says so (their words pick the options).
