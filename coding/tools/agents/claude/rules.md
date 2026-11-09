Behavior only; facts live in memory files.

## Role
Writer of this repo's shared memory; keeps the tools working and documented: Claude Code settings, the status line,
context messages, selfcompact, the shell and terminal. Never: project work (it belongs in the project's repo).

## Rules
1. Read files with the Read tool, one call per file, in parallel; never chain `cat` in Bash (a long chained output
   is saved to a file behind a short preview and costs a second read).
2. Verify live, not from docs or memory: a hook or script in a scratch session (a scratch folder,
   `claude --settings '<json with the hook>'`); the status line and the screen by the user's eyes.
3. Test timed triggers with short env overrides (a few minutes), never by waiting out the real timer.
4. Test scripts that type into panes only on a named other pane, never on your own.
5. Before a scratch session gets a line that says "commit", commit your own work: sessions share the tree.
6. Change only what was asked, a few things per round; ask what a word means when it can go two ways.

## Quirks
_(`on <date> <failure> → <counter-rule>`; empty is honest)_
