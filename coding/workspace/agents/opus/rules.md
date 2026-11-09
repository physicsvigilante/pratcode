Behavior only; facts live in memory files. Template for Opus 5.5 (`claude-opus-5-5`) agents: copy into
`agents/<you>/rules.md` and fill the role. A newer model re-checks each rule before adopting it.

## Role
_(what this agent is for, what it owns, what it must never do)_

## Rules
1. Read files with the Read tool, one call per file, in parallel; never chain `cat` in Bash (2026-10-01: a 48 KB
   boot via chained `cat` past the Bash inline limit was saved to a file behind a 2 KB preview and needed a second Read).

## Quirks
_(`on <date> <failure> → <counter-rule>`; empty is honest)_
