#!/bin/bash
# docs-sync.sh — TaskCompleted hook: 스토리 완료 시 docs 동기화 큐에 기록
# TTH 병렬 작업 중 팀원이 스토리를 완료하면 .docs-queue에 변경사항을 기록한다.
# ralph-loop.sh가 다음 반복 시 이 큐를 읽어 docs-writer 트리거를 inject_prompt에 포함.

set -euo pipefail

# stdin에서 hook 데이터 읽기
INPUT=$(cat)

# TTH 모드가 아니면 무시 (.ralph-loop/state.json 존재 확인)
CWD=$(echo "$INPUT" | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")
[ -z "$CWD" ] && exit 0

STATE_FILE="$CWD/.ralph-loop/state.json"
[ -f "$STATE_FILE" ] || exit 0

# 활성 상태 확인
ACTIVE=$(/usr/bin/python3 -c "import json; print(json.load(open('$STATE_FILE')).get('active', False))" 2>/dev/null || echo "False")
[ "$ACTIVE" != "True" ] && exit 0

# git diff로 최근 변경 파일 수집 (마지막 커밋 기준)
CHANGED_FILES=$(cd "$CWD" && git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
[ -z "$CHANGED_FILES" ] && exit 0

# .docs-queue 디렉토리 생성
QUEUE_DIR="$CWD/.docs-queue"
mkdir -p "$QUEUE_DIR"

# 타임스탬프 기반 큐 파일 생성
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
QUEUE_FILE="$QUEUE_DIR/${TIMESTAMP}.json"

# 태스크 정보 추출
TASK_ID=$(echo "$INPUT" | /usr/bin/python3 -c "
import json, sys
data = json.load(sys.stdin)
tasks = data.get('tasks', [])
# 가장 최근 완료된 태스크 찾기
for t in reversed(tasks):
    if t.get('status') == 'completed':
        print(t.get('id', 'unknown'))
        break
else:
    print('unknown')
" 2>/dev/null || echo "unknown")

# 큐에 기록
/usr/bin/python3 -c "
import json
queue_entry = {
    'timestamp': '$TIMESTAMP',
    'task_id': '$TASK_ID',
    'changed_files': '''$CHANGED_FILES'''.strip().split('\n'),
    'status': 'pending'
}
with open('$QUEUE_FILE', 'w') as f:
    json.dump(queue_entry, f, indent=2)
"

exit 0
