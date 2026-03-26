#!/bin/bash
# PostCompact: 컨텍스트 압축 후 중요 파일 존재 여부 알림
# CHECKPOINT.md, progress.txt 등이 있으면 리로드 프롬프트 제공
set -euo pipefail

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")
REMINDERS=""

# 프로젝트 내구성 파일 체크
if [ -f "CHECKPOINT.md" ]; then
  REMINDERS="$REMINDERS\n- CHECKPOINT.md 존재 — 현재 마일스톤 상태 확인 필요"
fi

if [ -f "progress.txt" ]; then
  REMINDERS="$REMINDERS\n- progress.txt 존재 — 팀 학습 메모 참조"
fi

if [ -f "AUDIT.log" ]; then
  LAST_EVENT=$(tail -1 "AUDIT.log" 2>/dev/null || echo "없음")
  REMINDERS="$REMINDERS\n- AUDIT.log 마지막 이벤트: $LAST_EVENT"
fi

if [ -d "prd" ]; then
  REMINDERS="$REMINDERS\n- prd/ 디렉토리 존재 — PRD/SPEC 컨텍스트 참조"
fi

if [ -d ".ralph-loop" ] && [ -f ".ralph-loop/state.json" ]; then
  REMINDERS="$REMINDERS\n- Ralph Loop 활성 — state.json 확인 필요"
fi

# 알림이 있으면 출력
if [ -n "$REMINDERS" ]; then
  echo "📋 [PostCompact] 컨텍스트 압축 완료. 다음 파일들을 참조하세요:"
  echo -e "$REMINDERS"
fi

exit 0
