Lane durable: recipes, gotchas, measured facts.
- Session state comes from the transcript (`~/.claude/projects/<folder>/<session id>.jsonl`), not the screen: a
  typed line shows as a `user` entry (idle) or a `queue-operation` enqueue (busy), a compaction as
  `compact_boundary`. `claude_autocompact.sh` works this way.
- One reply can be several assistant entries with the same `message.id`; count replies by id.
- Only the status line gets usage and cache data; `claude_statusline.sh` saves the 5h/7d part to
  `~/.claude/rate_limits.json` for scripts and agents.
