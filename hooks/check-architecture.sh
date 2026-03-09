#!/bin/bash
# 아키텍처 불변식 검사 스크립트
# verify-task-quality.sh에서 호출됨

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR"

ARCH_WARNINGS=()

# 1. 파일 크기 검사: 800줄 초과 파일 경고
echo "🏗️ 아키텍처 검사: 파일 크기..."
while IFS= read -r file; do
  lines=$(wc -l < "$file" 2>/dev/null || echo 0)
  if [ "$lines" -gt 800 ]; then
    ARCH_WARNINGS+=("파일 크기 초과 (${lines}줄): $file")
  fi
done < <(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" \) \
  -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/dist/*" -not -path "*/__pycache__/*" \
  -not -path "*/venv/*" -not -path "*/.venv/*" -not -name "*.min.*" -not -name "*.lock" 2>/dev/null)

# 2. 순환 import 검사 (madge 설치된 경우)
if command -v npx &>/dev/null && [ -f "package.json" ]; then
  if npx --no-install madge --version &>/dev/null 2>&1; then
    echo "🏗️ 아키텍처 검사: 순환 import..."
    CIRCULAR=$(npx madge --circular --no-spinner . 2>/dev/null | grep -c "✖" || true)
    if [ "$CIRCULAR" -gt 0 ]; then
      ARCH_WARNINGS+=("순환 import 감지: madge --circular로 확인하세요")
    fi
  fi
fi

# 3. 금지 패턴 검사
echo "🏗️ 아키텍처 검사: 금지 패턴..."

# console.log (프로덕션 코드에서만, 테스트 제외)
CONSOLE_COUNT=$(grep -rn "console\.log" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.next \
  --exclude="*.test.*" --exclude="*.spec.*" . 2>/dev/null | wc -l | tr -d ' ')
if [ "$CONSOLE_COUNT" -gt 5 ]; then
  ARCH_WARNINGS+=("console.log ${CONSOLE_COUNT}개 발견 (프로덕션 코드에서 제거 권장)")
fi

# 하드코딩 시크릿 패턴
SECRET_PATTERNS='(api[_-]?key|secret[_-]?key|password|token)\s*[:=]\s*["\x27][A-Za-z0-9]'
SECRET_COUNT=$(grep -rniE "$SECRET_PATTERNS" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" \
  --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.next --exclude-dir=venv --exclude-dir=.venv \
  --exclude="*.test.*" --exclude="*.spec.*" --exclude="*.example*" --exclude="*.sample*" . 2>/dev/null | wc -l | tr -d ' ')
if [ "$SECRET_COUNT" -gt 0 ]; then
  ARCH_WARNINGS+=("하드코딩 시크릿 패턴 ${SECRET_COUNT}건 의심 — 확인 필요")
fi

# 4. 디렉토리 규칙 검사
echo "🏗️ 아키텍처 검사: 디렉토리 규칙..."

# components/ 안에 API 로직 (fetch/axios 직접 호출)
if [ -d "src/components" ] || [ -d "components" ]; then
  COMP_DIR=$([ -d "src/components" ] && echo "src/components" || echo "components")
  API_IN_COMP=$(grep -rlE "(fetch\(|axios\.|\.get\(|\.post\(|\.put\(|\.delete\()" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    "$COMP_DIR" 2>/dev/null | grep -v "hook" | grep -v "use" | wc -l | tr -d ' ')
  if [ "$API_IN_COMP" -gt 0 ]; then
    ARCH_WARNINGS+=("components/ 내 직접 API 호출 ${API_IN_COMP}건 — hooks/services로 분리 권장")
  fi
fi

# api/ 안에 UI 로직 (React import)
if [ -d "src/app/api" ] || [ -d "app/api" ] || [ -d "src/api" ] || [ -d "api" ]; then
  for api_dir in src/app/api app/api src/api api; do
    if [ -d "$api_dir" ]; then
      UI_IN_API=$(grep -rl "from ['\"]react['\"]" --include="*.ts" --include="*.tsx" "$api_dir" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$UI_IN_API" -gt 0 ]; then
        ARCH_WARNINGS+=("${api_dir}/ 내 React import ${UI_IN_API}건 — API에 UI 로직 혼재")
      fi
    fi
  done
fi

# 결과 출력
if [ ${#ARCH_WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo "⚠️ 아키텍처 경고 (${#ARCH_WARNINGS[@]}건):"
  for warn in "${ARCH_WARNINGS[@]}"; do
    echo "  - $warn"
  done
  echo ""
  echo "💡 경고는 태스크 완료를 차단하지 않지만, 개선을 권장합니다."
fi

# 경고만 출력, 실패하지 않음 (소프트 게이트)
exit 0
