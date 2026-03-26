#!/bin/bash
# SubagentStart: 서브에이전트 스폰 추적 → AUDIT.log 기록
# 동시 에이전트 수 모니터링 (backpressure 정보)
set -euo pipefail

AUDIT_LOG="AUDIT.log"
AGENT_NAME="${CLAUDE_SUBAGENT_NAME:-unnamed}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")

# AUDIT.log가 있는 프로젝트에서만 작동
if [ -f "$AUDIT_LOG" ]; then
  echo "[$TIMESTAMP] system SUBAGENT_START $AGENT_NAME" >> "$AUDIT_LOG"
fi

# 현재 실행 중인 에이전트 수 추적
TRACKER=".active-agents"
if [ -d "$(pwd)" ]; then
  echo "$AGENT_NAME:$TIMESTAMP" >> "$TRACKER" 2>/dev/null || true
  ACTIVE_COUNT=$(wc -l < "$TRACKER" 2>/dev/null | tr -d ' ' || echo "0")

  # 5개 이상이면 경고 (리소스 backpressure)
  if [ "$ACTIVE_COUNT" -ge 5 ]; then
    echo "⚠️ 활성 에이전트 ${ACTIVE_COUNT}개 — 리소스 과부하 주의" >&2
  fi
fi

exit 0
