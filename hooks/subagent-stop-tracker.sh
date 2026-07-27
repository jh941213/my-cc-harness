#!/bin/bash
# SubagentStop: 서브에이전트 종료 시 추적 정보 정리
# stdin JSON에서 agent_id를 읽어 상태 업데이트
set -euo pipefail

INPUT=$(cat)

AGENT_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('agent_id',''))" 2>/dev/null || echo "")
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "$(pwd)")

# .active-agents에서 제거 (flock으로 동시 접근 보호)
TRACKER="${CWD}/.active-agents"
if [ -f "$TRACKER" ]; then
  (
    flock -w 5 201 || true
    grep -v "^${AGENT_ID}:" "$TRACKER" > "${TRACKER}.tmp" 2>/dev/null && mv "${TRACKER}.tmp" "$TRACKER" || true
  ) 201>"${TRACKER}.lock"
fi

# teammates.json 상태를 stopped로 변경 (flock으로 동시 쓰기 보호)
TEAMMATES_FILE="${CWD}/.ralph-loop/teammates.json"
if [ -f "$TEAMMATES_FILE" ]; then
  (
    flock -w 5 200 || exit 0
    RALPH_AGENT_ID="${AGENT_ID}" RALPH_TEAMMATES="${TEAMMATES_FILE}" python3 -c "
import json, os, datetime

agent_id = os.environ.get('RALPH_AGENT_ID', '')
f = os.environ['RALPH_TEAMMATES']
try: data = json.load(open(f))
except (json.JSONDecodeError, FileNotFoundError): data = {'teammates': {}}
teammates = data.get('teammates', {})
if agent_id in teammates:
    teammates[agent_id]['status'] = 'stopped'
    teammates[agent_id]['stopped_at'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S')
json.dump(data, open(f, 'w'), indent=2, ensure_ascii=False)
" 2>/dev/null || true
  ) 200>"${TEAMMATES_FILE}.lock"
fi

exit 0
