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

SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('transcript_path',''))" 2>/dev/null || echo "")
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "$(pwd)")

STATE_DIR="${CWD}/.ralph-loop"
STATE_FILE="${STATE_DIR}/state.json"

# 상태 파일이 없으면 루프 비활성 — 정상 종료
if [ ! -f "$STATE_FILE" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

# 상태 읽기
ACTIVE=$(python3 -c "import json; s=json.load(open('${STATE_FILE}')); print(s.get('active', False))" 2>/dev/null || echo "False")

if [ "$ACTIVE" != "True" ]; then
  echo '{"decision":"approve"}'
  exit 0
fi

# 현재 반복 수와 최대 반복 수
ITERATION=$(python3 -c "import json; s=json.load(open('${STATE_FILE}')); print(s.get('iteration', 0))" 2>/dev/null || echo "0")
MAX_ITER=$(python3 -c "import json; s=json.load(open('${STATE_FILE}')); print(s.get('max_iterations', 100))" 2>/dev/null || echo "100")
PROMPT=$(python3 -c "import json; s=json.load(open('${STATE_FILE}')); print(s.get('prompt', ''))" 2>/dev/null || echo "")
COMPLETION=$(python3 -c "import json; s=json.load(open('${STATE_FILE}')); print(s.get('completion_promise', 'DONE'))" 2>/dev/null || echo "DONE")

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
  python3 -c "
import json
s = json.load(open('${STATE_FILE}'))
s['active'] = False
s['completed_at'] = __import__('datetime').datetime.now().isoformat()
s['status'] = 'completed'
json.dump(s, open('${STATE_FILE}', 'w'), indent=2, ensure_ascii=False)
" 2>/dev/null
  echo '{"decision":"approve"}'
  exit 0
fi

if [ "$ITERATION" -ge "$MAX_ITER" ]; then
  # 최대 반복 초과 — 상태 비활성화
  python3 -c "
import json
s = json.load(open('${STATE_FILE}'))
s['active'] = False
s['completed_at'] = __import__('datetime').datetime.now().isoformat()
s['status'] = 'max_iterations_reached'
json.dump(s, open('${STATE_FILE}', 'w'), indent=2, ensure_ascii=False)
" 2>/dev/null
  echo '{"decision":"approve"}'
  exit 0
fi

# 반복 증가
NEW_ITER=$((ITERATION + 1))
python3 -c "
import json, datetime
s = json.load(open('${STATE_FILE}'))
s['iteration'] = ${NEW_ITER}
s['last_iteration_at'] = datetime.datetime.now().isoformat()
json.dump(s, open('${STATE_FILE}', 'w'), indent=2, ensure_ascii=False)
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
    # 변경 파일 목록 수집
    CHANGED=$(python3 -c "
import json, glob, os
files = set()
for f in glob.glob('${DOCS_QUEUE_DIR}/*.json'):
    try:
        data = json.load(open(f))
        files.update(data.get('changed_files', []))
    except: pass
print(', '.join(sorted(files)[:20]))
" 2>/dev/null || echo "")

    if [ -n "$CHANGED" ]; then
      DOCS_INSTRUCTION="

⚠️ [docs-writer 트리거] ${PENDING_COUNT}개 스토리 완료됨. 변경 파일: ${CHANGED}
→ docs-writer 서브에이전트를 스폰하여 docs/ 동기화:
  Agent(subagent_type=\"general-purpose\", name=\"docs-writer\", run_in_background=true,
    prompt=\"~/.claude/agents/docs-writer.md를 읽고 따라라. 변경 파일: ${CHANGED}. git diff로 변경사항 분석 후 docs/ARCHITECTURE.md, ADR 업데이트. 완료 후 .docs-queue/ 파일 삭제.\")"
    fi

    # AUDIT.log에 docs 트리거 기록
    if [ -f "$AUDIT_FILE" ]; then
      echo "[$(date -u +%Y-%m-%dT%H:%M:%S)] docs-writer TRIGGER pending=${PENDING_COUNT}" >> "$AUDIT_FILE"
    fi
  fi
fi

# 연속 프롬프트 주입
CONTINUATION="[Ralph Loop 반복 ${NEW_ITER}/${MAX_ITER}] ${PROMPT}

진행 상황을 확인하고 다음 항목을 처리하세요.${DOCS_INSTRUCTION}
모든 항목이 완료되면 반드시 <promise>${COMPLETION}</promise>를 출력하세요."

# JSON escape
ESCAPED_PROMPT=$(python3 -c "import json; print(json.dumps('${CONTINUATION}'))" 2>/dev/null || echo "\"Continue\"")

echo "{\"decision\":\"block\",\"reason\":\"Ralph Loop 계속\",\"inject_prompt\":${ESCAPED_PROMPT}}"
