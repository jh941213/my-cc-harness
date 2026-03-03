#!/bin/bash
# TTH 유휴 리다이렉트: TeammateIdle 훅
# 미완료 pending 태스크가 있으면 exit 2로 teammate 유휴 방지
# 모든 태스크 완료 시 exit 0으로 종료 허용

# CLAUDE_TASKS 환경변수에서 pending 태스크 확인
if [ -n "${CLAUDE_TASKS:-}" ]; then
  PENDING=$(echo "$CLAUDE_TASKS" | grep -c '"status":"pending"' 2>/dev/null || true)
  IN_PROGRESS=$(echo "$CLAUDE_TASKS" | grep -c '"status":"in_progress"' 2>/dev/null || true)

  if [ "$PENDING" -gt 0 ] || [ "$IN_PROGRESS" -gt 0 ]; then
    echo "⏳ 아직 미완료 태스크가 ${PENDING}개 (pending), ${IN_PROGRESS}개 (in_progress) 남아있습니다."
    echo "남은 태스크를 클레임하여 작업을 계속하세요."
    exit 2
  fi
fi

echo "✅ 모든 태스크 완료. 유휴 상태 허용."
exit 0
