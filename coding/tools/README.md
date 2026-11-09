# Tools: setup and index

A Claude Code setup on WSL, from a friend's working one, stripped to the basics. What it gives:
- WSL + WezTerm: Claude Code runs in Ubuntu inside a WezTerm pane.
- A status line under the input box: model, context size, prompt cache time left, 5h/7d usage, a handover warning.
- Context messages: Claude is told its context size from 250K on, and when to compact.
- `/selfcompact`: Claude wraps up, compacts its own session, then restarts it now, at the usage reset, at a set time,
  or stays stopped.
- A framework for projects (`$coding/workspace/`): memory in repo files, `boot` to start a session, `close.md` to
  end one. This `tools/` folder is itself a repo on it, kept by the agent `claude`.

## Setting it up (for Claude, with its user)

This is a design to learn from, not a package to install as it is: one person's working setup. Take its ideas, fit
them to this user and this machine, and say where you depart from it and why. The ideas that make it work:
- Memory lives in repo files, read at boot and kept at close, so a fresh or compacted session resumes from disk.
- The agent sees its own state (context size, cache, usage) and compacts at natural breaks, never mid-discussion.
- Every change is small, tested and recorded: the change log, docs fixed in place.
Everything else (terminal, shell, colours, thresholds, names) is a choice.

Work as an interactive workflow:
1. Read this file and `map.md`, and skim the docs they name. Then tell the user in a few lines what the setup does
   and how you will go about it.
2. One step at a time (below). For each: say what it is for; ask what you need, one question at a time in plain
   text, with the options and a recommendation; wait for the answer; propose the change; make it once the user
   agrees; run its test and show what it showed.
3. The user decides: any step can be skipped, changed or done differently. Record each choice and its reason in
   `ltm.md` (Decisions).
4. The user runs every admin, `sudo` and Windows-side command: give the exact line and wait for its output.
5. Never delete: an existing file moves aside first (`<file>.bak`). A failed test stops the step: explain it,
   propose a fix, ask.

Steps, each with its questions:
1. Orientation: Windows version; is WSL installed (`wsl -l -v`), which distro; any `~/.claude/settings.json`,
   `~/.wezterm.lua` or shell config to keep?
2. WSL and the shell (`wsl_wezterm.md`, WSL part). Ask: zsh with plugins, or bash? Where should code live:
   `/mnt/c/...` (visible from Windows, slower git) or `~/coding` (fast)?
3. Terminal (`wsl_wezterm.md`, WezTerm part). Ask: WezTerm (`/selfcompact` needs it), or keep theirs and compact by
   hand? The friend's look and keys, or their own? Test: `echo $WEZTERM_PANE` in a new pane prints a number.
4. Place this `coding/` folder at the code root. Replace `<coding>` with its path in `claude_config.md`'s settings
   and in `skills/selfcompact/SKILL.md`; fill the placeholders of `$coding/AGENTS.md` together.
5. Claude Code (`claude_config.md`). Ask: the plan (Pro/Max: 5h/7d usage and `reset` work; API key: neither), the
   permission mode, auto-compaction on or off, the default model and effort, which status line fields and
   thresholds. Then `chmod +x` the scripts, merge the settings, install the skill. Test: status line, context
   messages, selfcompact.
6. This repo: `git init` in `tools/`; the choices in `ltm.md`, a first `tools_updates.md` entry; commit
   `claude: setup`.
7. Restart Claude (`exit`, then `claude` in a new pane) so everything loads; check the status line; type `boot` here.
8. The first project, together: copy `$coding/workspace/` to `$coding/<name>_<DDMMYY>/`, `git init`, and run
   Session zero in its `meta.md`, asking the user what the project is. The template is not a repo; it changes only
   with the user's approval. End with a short walk through daily use (below).

## Daily use

- Start: open a WezTerm pane, `cd` into the repo, `claude`, type `boot`.
- Watch the status line: on `⚠ HANDOVER`, or a context message saying compact, finish the step.
- End: `close` (the agent runs `close.md`), then `/selfcompact stop` (done for now), `/selfcompact go reset` (out of
  usage: continue after the reset), or `/selfcompact boot 07:30` (a fresh start at a set time).
- Never `/clear` a session with work in it: it drops the context without a summary.

## Docs

- `claude_config.md`: Claude Code install, settings, status line, context messages, selfcompact, token savings.
- `wsl_wezterm.md`: WSL, shell, WezTerm (keys, the pane id selfcompact needs), the garbled-line fix.
- `tools_updates.md`: the change log.
- Scripts and configs, each described in its doc: `claude_statusline.sh`, `claude_ctxwarn.sh`,
  `claude_autocompact.sh`, `skills/selfcompact/SKILL.md`, `wezterm.lua`.
