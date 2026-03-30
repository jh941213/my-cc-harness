#!/bin/bash
# Ralph Loop — Stop Hook Handler
# Claude Code가 멈출 때 자동으로 다음 반복을 시작하는 Stop Hook
#
# 동작 원리:
#   1. .ralph-loop/state.json이 존재하고 active=true이면 루프 계속
#   2. 완료 프로미스(<promise>DONE</promise>)가 트랜스크립트에 있으면 종료
#   3. max_iterations 초과 시 종료
#   4. 그 외: inject_prompt로 다음 반복 시작
#
# 입력: stdin으로 JSON (session_id, transcript_path, cwd 등)
# 출력: stdout으로 JSON (decision, inject_prompt 등)

set -uo pipefail

# stdin에서 hook input 읽기
INPUT=$(cat)

HOOK_VARS=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('session_id',''))
print(d.get('transcript_path',''))
print(d.get('cwd',''))
" 2>/dev/null) || HOOK_VARS=""
SESSION_ID=$(echo "$HOOK_VARS" | sed -n '1p')
TRANSCRIPT_PATH=$(echo "$HOOK_VARS" | sed -n '2p')
CWD=$(echo "$HOOK_VARS" | sed -n '3p')
CWD="${CWD:-$(pwd)}"

STATE_DIR="${CWD}/.ralph-loop"
STATE_FILE="${STATE_DIR}/state.json"

# 상태 파일이 없으면 루프 비활성 — 정상 종료
if [ ! -f "$STATE_FILE" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

# 상태를 한 번에 읽기 (환경변수로 경로 전달 — 경로 인젝션 방지)
STATE_VARS=$(RALPH_STATE_FILE="$STATE_FILE" python3 -c "
import json, os
f = os.environ['RALPH_STATE_FILE']
s = json.load(open(f))
print(s.get('active', False))
print(s.get('iteration', 0))
print(s.get('max_iterations', 100))
print(s.get('prompt', ''))
print(s.get('completion_promise', 'DONE'))
" 2>/dev/null) || {
  echo '{"decision":"approve"}'
  exit 0
}

ACTIVE=$(echo "$STATE_VARS" | sed -n '1p')
ITERATION=$(echo "$STATE_VARS" | sed -n '2p')
MAX_ITER=$(echo "$STATE_VARS" | sed -n '3p')
PROMPT=$(echo "$STATE_VARS" | sed -n '4p')
COMPLETION=$(echo "$STATE_VARS" | sed -n '5p')

if [ "$ACTIVE" != "True" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

# 완료 프로미스 감지 (트랜스크립트에서)
PROMISE_FOUND=false
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  if grep -q "<promise>${COMPLETION}</promise>" "$TRANSCRIPT_PATH" 2>/dev/null; then
    PROMISE_FOUND=true
  fi
fi

# 종료 조건 체크
if [ "$PROMISE_FOUND" = "true" ]; then
  # 완료 — 상태 비활성화
  RALPH_STATE_FILE="$STATE_FILE" python3 -c "
import json, os, datetime
f = os.environ['RALPH_STATE_FILE']
s = json.load(open(f))
s['active'] = False
s['completed_at'] = datetime.datetime.now().isoformat()
s['status'] = 'completed'
json.dump(s, open(f, 'w'), indent=2, ensure_ascii=False)
" 2>/dev/null
  echo '{"decision":"approve"}'
  exit 0
fi

if [ "$ITERATION" -ge "$MAX_ITER" ]; then
  # 최대 반복 초과 — 상태 비활성화
  RALPH_STATE_FILE="$STATE_FILE" python3 -c "
import json, os, datetime
f = os.environ['RALPH_STATE_FILE']
s = json.load(open(f))
s['active'] = False
s['completed_at'] = datetime.datetime.now().isoformat()
s['status'] = 'max_iterations_reached'
json.dump(s, open(f, 'w'), indent=2, ensure_ascii=False)
" 2>/dev/null
  echo '{"decision":"approve"}'
  exit 0
fi

# 반복 증가
NEW_ITER=$((ITERATION + 1))
RALPH_STATE_FILE="$STATE_FILE" RALPH_NEW_ITER="$NEW_ITER" python3 -c "
import json, os, datetime
f = os.environ['RALPH_STATE_FILE']
s = json.load(open(f))
s['iteration'] = int(os.environ['RALPH_NEW_ITER'])
s['last_iteration_at'] = datetime.datetime.now().isoformat()
json.dump(s, open(f, 'w'), indent=2, ensure_ascii=False)
" 2>/dev/null

# AUDIT.log에 기록
AUDIT_FILE="${CWD}/AUDIT.log"
if [ -f "$AUDIT_FILE" ]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%S)] ralph-loop ITERATION ${NEW_ITER}/${MAX_ITER}" >> "$AUDIT_FILE"
fi

# docs 큐 확인 — 대기 중인 docs 동기화가 있으면 프롬프트에 포함
DOCS_QUEUE_DIR="${CWD}/.docs-queue"
DOCS_INSTRUCTION=""
if [ -d "$DOCS_QUEUE_DIR" ]; then
  PENDING_COUNT=$(find "$DOCS_QUEUE_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$PENDING_COUNT" -gt "0" ]; then
    CHANGED=$(RALPH_DOCS_DIR="$DOCS_QUEUE_DIR" python3 -c "
import json, glob, os
d = os.environ['RALPH_DOCS_DIR']
files = set()
for f in glob.glob(os.path.join(d, '*.json')):
    try:
        data = json.load(open(f))
        files.update(data.get('changed_files', []))
    except (json.JSONDecodeError, OSError): pass
print(', '.join(sorted(files)[:20]))
" 2>/dev/null || echo "")

    if [ -n "$CHANGED" ]; then
      DOCS_INSTRUCTION="
📝 docs 동기화 필요: ${CHANGED} — docs-writer background 스폰."
    fi

    if [ -f "$AUDIT_FILE" ]; then
      echo "[$(date -u +%Y-%m-%dT%H:%M:%S)] docs-writer TRIGGER pending=${PENDING_COUNT}" >> "$AUDIT_FILE"
    fi
  fi
fi

# 기존 팀원 정보 수집 (tmux 세션 재사용)
TEAMMATES_FILE="${STATE_DIR}/teammates.json"
TEAMMATE_INSTRUCTION=""
if [ -f "$TEAMMATES_FILE" ]; then
  TEAMMATE_INFO=$(RALPH_TEAMMATES="$TEAMMATES_FILE" python3 -c "
import json, os
try:
    f = os.environ['RALPH_TEAMMATES']
    data = json.load(open(f))
    running = {k: v for k,v in data.get('teammates',{}).items() if v.get('status')=='running'}
    if running:
        # name 필드가 있으면 이름 사용, 없으면 agent_id 사용
        labels = [v.get('name', k) for k,v in running.items()]
        names = ', '.join(labels)
        print(f'\n⚡ 활성 팀원: {names} — SendMessage(to=이름)로 재사용. 새 Agent() 금지.')
    else:
        print('')
except (json.JSONDecodeError, OSError, KeyError):
    print('')
" 2>/dev/null || echo "")
  TEAMMATE_INSTRUCTION="$TEAMMATE_INFO"
fi

# 연속 프롬프트 주입
CONTINUATION="[Ralph Loop ${NEW_ITER}/${MAX_ITER}] ${PROMPT}${TEAMMATE_INSTRUCTION}${DOCS_INSTRUCTION}
완료 시 <promise>${COMPLETION}</promise> 출력."

# JSON escape — temp file로 안전하게 처리
PROMPT_TMP="${STATE_DIR}/.inject_prompt.tmp"
printf '%s' "$CONTINUATION" > "$PROMPT_TMP"
ESCAPED_PROMPT=$(RALPH_TMP="$PROMPT_TMP" python3 -c "
import json, os
with open(os.environ['RALPH_TMP']) as f:
    print(json.dumps(f.read()))
" 2>/dev/null || echo "\"Continue\"")
rm -f "$PROMPT_TMP"

echo "{\"decision\":\"block\",\"reason\":\"Ralph Loop 계속\",\"inject_prompt\":${ESCAPED_PROMPT}}"
