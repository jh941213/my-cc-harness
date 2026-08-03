#!/bin/sh
# SessionStart: stdout is injected into context.
# Injects (when present): mid-term working state, memory index, recent lessons.
cat >/dev/null 2>&1 || :
P="${CLAUDE_PROJECT_DIR:-.}"
if [ -f "$P/tasks/context.md" ]; then
  echo '[tasks/context.md - 이전 세션 작업 상태]'
  cat "$P/tasks/context.md"
  echo ''
fi
if [ -f "$P/memory/INDEX.md" ]; then
  echo '[memory/INDEX.md - 작업 유형별 로드 조건. auto-memory 스킬로 필요한 것만 Read]'
  cat "$P/memory/INDEX.md"
  echo ''
fi
f="$P/tasks/lessons.md"
[ -f "$f" ] || f="$P/LESSONS_LEARNED.md"
if [ -f "$f" ]; then
  echo '[tasks/lessons.md 최근 교훈 - 이번 세션 작업과 관련되면 적용할 것]'
  tail -n 60 "$f"
fi
exit 0
