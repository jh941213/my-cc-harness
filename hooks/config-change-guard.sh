#!/bin/bash
# ConfigChange: 세션 중 설정 파일 변경 감지
# 캐시 보존 규칙 위반 시 경고
set -euo pipefail

CHANGED_FILE="${CLAUDE_CONFIG_PATH:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")

# 캐시에 영향을 주는 파일 변경 경고
case "$CHANGED_FILE" in
  *CLAUDE.md*|*rules/*|*agents/*)
    echo "⚠️ [$TIMESTAMP] 캐시 보존 규칙 위반 가능: $CHANGED_FILE 변경됨" >&2
    echo "세션 중 CLAUDE.md/rules/agents 수정은 캐시를 무효화합니다." >&2
    echo "/clear 후 새 세션에서 작업하는 것을 권장합니다." >&2
    ;;
  *settings.json*|*settings.local.json*)
    echo "ℹ️ [$TIMESTAMP] 설정 파일 변경 감지: $CHANGED_FILE" >&2
    echo "일부 설정은 세션 재시작 후 적용됩니다." >&2
    ;;
esac

exit 0
