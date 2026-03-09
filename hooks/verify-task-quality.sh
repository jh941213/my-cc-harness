#!/bin/bash
# TTH 품질 게이트: TaskCompleted 훅
# 태스크 완료 시 typecheck/lint/test 자동 실행
# 실패 시 exit 2로 태스크 완료 차단

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR"

ERRORS=()

# Node.js/TypeScript 프로젝트 감지
if [ -f "package.json" ]; then
  # TypeScript 타입체크
  if [ -f "tsconfig.json" ]; then
    if command -v npx &>/dev/null; then
      echo "🔍 TypeScript 타입체크 실행 중..."
      if ! npx tsc --noEmit 2>&1; then
        ERRORS+=("TypeScript 타입체크 실패")
      fi
    fi
  fi

  # Lint (eslint 또는 biome)
  if npx --no-install eslint --version &>/dev/null 2>&1; then
    echo "🔍 ESLint 실행 중..."
    if ! npx eslint . --max-warnings=0 2>&1; then
      ERRORS+=("ESLint 실패")
    fi
  elif npx --no-install biome --version &>/dev/null 2>&1; then
    echo "🔍 Biome 실행 중..."
    if ! npx biome check . 2>&1; then
      ERRORS+=("Biome 린트 실패")
    fi
  fi

  # 테스트 (vitest, jest, 또는 npm test)
  if npx --no-install vitest --version &>/dev/null 2>&1; then
    echo "🔍 Vitest 실행 중..."
    if ! npx vitest run 2>&1; then
      ERRORS+=("Vitest 테스트 실패")
    fi
  elif npx --no-install jest --version &>/dev/null 2>&1; then
    echo "🔍 Jest 실행 중..."
    if ! npx jest --passWithNoTests 2>&1; then
      ERRORS+=("Jest 테스트 실패")
    fi
  elif grep -q '"test"' package.json 2>/dev/null; then
    echo "🔍 npm test 실행 중..."
    if ! npm test 2>&1; then
      ERRORS+=("npm test 실패")
    fi
  fi
fi

# Python 프로젝트 감지
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  # mypy 타입체크
  if command -v mypy &>/dev/null; then
    echo "🔍 mypy 타입체크 실행 중..."
    if ! mypy . 2>&1; then
      ERRORS+=("mypy 타입체크 실패")
    fi
  fi

  # ruff 린트
  if command -v ruff &>/dev/null; then
    echo "🔍 Ruff 린트 실행 중..."
    if ! ruff check . 2>&1; then
      ERRORS+=("Ruff 린트 실패")
    fi
  fi

  # pytest
  if command -v pytest &>/dev/null; then
    echo "🔍 pytest 실행 중..."
    if ! pytest 2>&1; then
      ERRORS+=("pytest 실패")
    fi
  fi
fi

# 결과 판정
if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "❌ 품질 게이트 실패:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
  echo ""
  echo "태스크를 완료하려면 위 문제를 먼저 수정하세요."
  exit 2
fi

# 아키텍처 불변식 검사 (소프트 게이트 — 경고만, 차단 안 함)
if [ -f "$HOME/.claude/hooks/check-architecture.sh" ]; then
  source "$HOME/.claude/hooks/check-architecture.sh"
fi

echo "✅ 품질 게이트 통과"
exit 0
