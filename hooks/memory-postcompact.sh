#!/bin/sh
# PostCompact: re-inject mid-term memory (tasks/context.md) and the memory index
# so long sessions survive compaction without losing working state.
cat >/dev/null 2>&1 || :
P="${CLAUDE_PROJECT_DIR:-.}"
OUT=""
if [ -f "$P/tasks/context.md" ]; then
  OUT="[tasks/context.md - 컴팩션 후 작업 상태 복원]
$(cat "$P/tasks/context.md")"
fi
if [ -f "$P/memory/INDEX.md" ]; then
  OUT="$OUT

[memory/INDEX.md - 작업 유형별 로드 조건. 필요한 것만 Read]
$(cat "$P/memory/INDEX.md")"
fi
if [ -n "$OUT" ]; then
  printf '%s' "$OUT" | jq -Rs '{hookSpecificOutput:{hookEventName:"PostCompact",additionalContext:.}}'
fi
exit 0
