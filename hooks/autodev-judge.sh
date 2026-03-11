#!/bin/bash
# AutoDeveloper 판정 함수
# 프로젝트의 빌드/테스트/린트 상태를 숫자 스코어로 환산
# 출력: .autodev-score 파일에 정수 스코어 기록
#
# 사용법: bash ~/.claude/hooks/autodev-judge.sh [결과파일경로]

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR"

RESULT_FILE="${1:-.autodev-score}"
SCORE=0
DETAILS=""

log() {
  DETAILS="${DETAILS}${1}\n"
}

# ─────────────────────────────────────────────
# 1. 빌드 체크 (실패 시 -999)
# ─────────────────────────────────────────────

BUILD_OK=true

# Node.js / TypeScript
if [ -f "tsconfig.json" ]; then
  if npx tsc --noEmit 2>/dev/null; then
    SCORE=$((SCORE + 50))
    log "typecheck: PASS (+50)"
  else
    echo "-999" > "$RESULT_FILE"
    log "typecheck: FAIL (-999)"
    echo -e "$DETAILS" > "${RESULT_FILE}.details"
    exit 0
  fi
fi

# Python
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  if command -v ruff &>/dev/null; then
    if ruff check . --quiet 2>/dev/null; then
      SCORE=$((SCORE + 20))
      log "ruff: PASS (+20)"
    else
      LINT_ERRORS=$(ruff check . --quiet 2>/dev/null | wc -l)
      PENALTY=$((LINT_ERRORS * 5))
      SCORE=$((SCORE - PENALTY))
      log "ruff: ${LINT_ERRORS} errors (-${PENALTY})"
    fi
  fi
  if command -v mypy &>/dev/null; then
    if mypy . --no-error-summary 2>/dev/null | grep -q "Success"; then
      SCORE=$((SCORE + 50))
      log "mypy: PASS (+50)"
    fi
  fi
fi

# ─────────────────────────────────────────────
# 2. 테스트 체크 (기존 테스트 깨지면 -999)
# ─────────────────────────────────────────────

# Node.js 테스트 (vitest / jest / npm test)
if [ -f "package.json" ]; then
  TEST_CMD=""
  if npx --no-install vitest --version &>/dev/null 2>&1; then
    TEST_CMD="npx vitest run --reporter=json"
  elif npx --no-install jest --version &>/dev/null 2>&1; then
    TEST_CMD="npx jest --json --passWithNoTests"
  fi

  if [ -n "$TEST_CMD" ]; then
    TEST_OUTPUT=$($TEST_CMD 2>/dev/null) || true

    # JSON 결과 파싱
    PASSED=$(echo "$TEST_OUTPUT" | grep -oE '"numPassedTests":\s*[0-9]+' | grep -oE '[0-9]+' | tail -1)
    FAILED=$(echo "$TEST_OUTPUT" | grep -oE '"numFailedTests":\s*[0-9]+' | grep -oE '[0-9]+' | tail -1)
    TOTAL=$(echo "$TEST_OUTPUT" | grep -oE '"numTotalTests":\s*[0-9]+' | grep -oE '[0-9]+' | tail -1)

    PASSED=${PASSED:-0}
    FAILED=${FAILED:-0}
    TOTAL=${TOTAL:-0}

    if [ "$FAILED" -gt 0 ]; then
      echo "-999" > "$RESULT_FILE"
      log "test: ${FAILED}/${TOTAL} FAILED (-999)"
      echo -e "$DETAILS" > "${RESULT_FILE}.details"
      exit 0
    fi

    if [ "$PASSED" -gt 0 ]; then
      TEST_SCORE=$((PASSED * 10))
      SCORE=$((SCORE + TEST_SCORE))
      log "test: ${PASSED}/${TOTAL} passed (+${TEST_SCORE})"
    fi
  fi
fi

# Python 테스트 (pytest)
if command -v pytest &>/dev/null && [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "pytest.ini" ]; then
  PYTEST_OUTPUT=$(pytest --tb=no -q 2>/dev/null) || true

  PY_PASSED=$(echo "$PYTEST_OUTPUT" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+')
  PY_FAILED=$(echo "$PYTEST_OUTPUT" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+')

  PY_PASSED=${PY_PASSED:-0}
  PY_FAILED=${PY_FAILED:-0}

  if [ "$PY_FAILED" -gt 0 ]; then
    echo "-999" > "$RESULT_FILE"
    log "pytest: ${PY_FAILED} FAILED (-999)"
    echo -e "$DETAILS" > "${RESULT_FILE}.details"
    exit 0
  fi

  if [ "$PY_PASSED" -gt 0 ]; then
    PY_SCORE=$((PY_PASSED * 10))
    SCORE=$((SCORE + PY_SCORE))
    log "pytest: ${PY_PASSED} passed (+${PY_SCORE})"
  fi
fi

# ─────────────────────────────────────────────
# 3. 린트 체크 (감점)
# ─────────────────────────────────────────────

if [ -f "package.json" ]; then
  if npx --no-install eslint --version &>/dev/null 2>&1; then
    LINT_COUNT=$(npx eslint . --format=json 2>/dev/null | grep -oE '"errorCount":\s*[0-9]+' | grep -oE '[0-9]+' | paste -sd+ | bc 2>/dev/null || echo "0")
    LINT_COUNT=${LINT_COUNT:-0}
    if [ "$LINT_COUNT" -eq 0 ]; then
      SCORE=$((SCORE + 20))
      log "eslint: PASS (+20)"
    else
      LINT_PENALTY=$((LINT_COUNT * 5))
      SCORE=$((SCORE - LINT_PENALTY))
      log "eslint: ${LINT_COUNT} errors (-${LINT_PENALTY})"
    fi
  fi
fi

# ─────────────────────────────────────────────
# 4. 코드 변경량 (단순함 보너스)
# ─────────────────────────────────────────────

if git rev-parse HEAD~1 &>/dev/null; then
  STAT=$(git diff --stat HEAD~1 2>/dev/null | tail -1)
  INSERTIONS=$(echo "$STAT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
  DELETIONS=$(echo "$STAT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")

  INSERTIONS=${INSERTIONS:-0}
  DELETIONS=${DELETIONS:-0}

  # 삭제가 추가보다 많으면 보너스 (단순화)
  NET_CHANGE=$((INSERTIONS - DELETIONS))
  if [ "$NET_CHANGE" -lt 0 ]; then
    SIMPLIFY_BONUS=$(( (-NET_CHANGE) / 5 ))
    SCORE=$((SCORE + SIMPLIFY_BONUS))
    log "simplify: net ${NET_CHANGE} lines (+${SIMPLIFY_BONUS})"
  fi

  log "diff: +${INSERTIONS} -${DELETIONS} (net: ${NET_CHANGE})"
fi

# ─────────────────────────────────────────────
# 5. 결과 출력
# ─────────────────────────────────────────────

echo "$SCORE" > "$RESULT_FILE"
echo -e "$DETAILS" > "${RESULT_FILE}.details"

echo "AUTODEV_SCORE: $SCORE"
echo "---"
echo -e "$DETAILS"
