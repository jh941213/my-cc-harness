#!/bin/sh
# Stop: if files were modified this session and no lesson was recorded yet,
# block the stop ONCE and ask Claude to append to tasks/lessons.md.
# stop_hook_active guards against infinite block loops.
# Skips while a Ralph Loop is active (the loop's own Stop hook drives continuation);
# the gate applies on the final stop after the loop completes.
IN=$(cat)
SID=$(printf '%s' "$IN" | jq -r '.session_id // "default"')
ACTIVE=$(printf '%s' "$IN" | jq -r '.stop_hook_active // false')
CWD=$(printf '%s' "$IN" | jq -r '.cwd // empty')
M="$HOME/.claude/tmp/lessons-pending-$SID"
if [ -n "$CWD" ] && [ -f "$CWD/.ralph-loop/state.json" ] && \
   [ "$(jq -r '.active' "$CWD/.ralph-loop/state.json" 2>/dev/null)" = "true" ]; then
  exit 0
fi
if [ "$ACTIVE" = "true" ]; then
  rm -f "$M"
  exit 0
fi
if [ -f "$M" ]; then
  rm -f "$M"
  printf '%s' '{"decision":"block","reason":"[lessons] 이번 턴에 파일 수정 작업이 있었습니다. 마무리 전에 프로젝트의 tasks/lessons.md에 이번 작업에서 배운 점을 추가하세요 (파일/디렉토리가 없으면 생성). 형식: ## YYYY-MM-DD - 작업 요약 / 문제·원인 / 교훈 / 다음에 적용할 것. 특별히 기록할 교훈이 없으면 이유를 한 줄로만 남기고 마무리하세요."}'
fi
exit 0
