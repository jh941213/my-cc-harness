#!/bin/sh
# PostToolUse (Write|Edit|NotebookEdit): mark that real work happened this session,
# so the Stop gate can require a tasks/lessons.md entry before finishing.
# Bookkeeping writes (tasks/lessons.md, tasks/todo.md, ~/.claude/*) do not arm the marker.
IN=$(cat)
F=$(printf '%s' "$IN" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
SID=$(printf '%s' "$IN" | jq -r '.session_id // "default"')
case "$F" in
  *LESSONS_LEARNED*|*/tasks/lessons.md)
    # recording lessons satisfies the gate — clear the pending marker
    rm -f "$HOME/.claude/tmp/lessons-pending-$SID" ;;
  ""|*/tasks/todo.md|"$HOME/.claude/"*) : ;;
  *) mkdir -p "$HOME/.claude/tmp" && touch "$HOME/.claude/tmp/lessons-pending-$SID" ;;
esac
exit 0
