#!/bin/bash
# PostToolUseFailure: 도구 실패 패턴을 progress.txt에 기록
# 반복 실패 감지 시 에스컬레이션 알림
set -euo pipefail

PROGRESS="progress.txt"
FAILURE_LOG=".failure-tracker.jsonl"

# 환경변수에서 실패 정보 추출
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
ERROR="${CLAUDE_TOOL_ERROR:-no error info}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")

# 짧은 에러 요약 (첫 줄만)
ERROR_SUMMARY=$(echo "$ERROR" | head -1 | cut -c1-120)

# 실패 로그 기록 (jsonl)
if [ -d "$(dirname "$FAILURE_LOG")" ]; then
  echo "{\"ts\":\"$TIMESTAMP\",\"tool\":\"$TOOL_NAME\",\"error\":\"$ERROR_SUMMARY\"}" >> "$FAILURE_LOG" 2>/dev/null || true
fi

# 동일 도구 최근 3회 연속 실패 감지
if [ -f "$FAILURE_LOG" ]; then
  RECENT_FAILS=$(tail -10 "$FAILURE_LOG" | grep "\"tool\":\"$TOOL_NAME\"" | wc -l | tr -d ' ')
  if [ "$RECENT_FAILS" -ge 3 ]; then
    echo "⚠️ $TOOL_NAME 3회 이상 연속 실패 — 접근 방식 재검토 필요" >&2
    # progress.txt에 패턴 기록
    if [ -f "$PROGRESS" ]; then
      echo "" >> "$PROGRESS"
      echo "## ⚠️ 반복 실패 감지 [$TIMESTAMP]" >> "$PROGRESS"
      echo "- 도구: $TOOL_NAME" >> "$PROGRESS"
      echo "- 에러: $ERROR_SUMMARY" >> "$PROGRESS"
      echo "- 조치: 다른 접근 방식 시도 필요" >> "$PROGRESS"
    fi
    exit 2
  fi
fi

exit 0
