#!/bin/bash
# E2E 테스트 스위트 템플릿
# 사용법: ./test-suite.sh [BASE_URL]

set -e

BASE_URL="${1:-http://localhost:3000}"
PASSED=0
FAILED=0
FAILED_TESTS=()

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 테스트 헬퍼 함수
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

# 브라우저 정리 함수
cleanup() {
  agent-browser close 2>/dev/null || true
}
trap cleanup EXIT

# 테스트 실행 함수
run_test() {
  local test_name="$1"
  local test_func="$2"

  log_info "Running: $test_name"

  if $test_func; then
    log_pass "$test_name"
    ((PASSED++))
  else
    log_fail "$test_name"
    ((FAILED++))
    FAILED_TESTS+=("$test_name")
    # 실패 시 스크린샷 저장
    agent-browser screenshot "./screenshots/${test_name//[^a-zA-Z0-9]/_}.png" 2>/dev/null || true
  fi

  # 테스트 간 브라우저 초기화
  agent-browser cookies clear 2>/dev/null || true
}

# 어서션 헬퍼
assert_url_contains() {
  local expected="$1"
  local url
  url=$(agent-browser url)
  [[ "$url" == *"$expected"* ]] || {
    echo "Expected URL to contain '$expected', got '$url'"
    return 1
  }
}

assert_text_visible() {
  local text="$1"
  agent-browser snapshot -i | grep -q "$text" || {
    echo "Expected text '$text' to be visible"
    return 1
  }
}

assert_element_exists() {
  local ref="$1"
  agent-browser isvisible "$ref" 2>/dev/null | grep -q "true" || {
    echo "Expected element $ref to exist and be visible"
    return 1
  }
}

# ============================================
# 테스트 케이스 정의
# ============================================

test_homepage_loads() {
  agent-browser open "$BASE_URL"
  agent-browser wait load

  # 페이지 타이틀 확인
  local title
  title=$(agent-browser title)
  [[ -n "$title" ]] || return 1

  # 주요 요소 확인
  agent-browser snapshot -i >/dev/null
}

test_navigation_works() {
  agent-browser open "$BASE_URL"
  agent-browser wait load

  # 네비게이션 링크 클릭 (예: About 페이지)
  agent-browser snapshot -i
  agent-browser click "role:link" "About" 2>/dev/null || \
    agent-browser click "text:About" 2>/dev/null || \
    return 1

  agent-browser wait url "**/about"
  assert_url_contains "about"
}

test_login_form() {
  agent-browser open "$BASE_URL/login"
  agent-browser wait load

  # 폼 요소 확인
  agent-browser snapshot -i

  # 이메일 입력
  agent-browser fill "role:textbox" "Email" "test@example.com" 2>/dev/null || \
    agent-browser fill "#email" "test@example.com" 2>/dev/null || \
    return 1

  # 비밀번호 입력
  agent-browser fill "role:textbox" "Password" "password123" 2>/dev/null || \
    agent-browser fill "#password" "password123" 2>/dev/null || \
    return 1

  # 입력값 확인
  local email_value
  email_value=$(agent-browser value "#email" 2>/dev/null || echo "")
  [[ "$email_value" == "test@example.com" ]] || return 1
}

test_form_validation() {
  agent-browser open "$BASE_URL/register"
  agent-browser wait load

  # 빈 폼 제출
  agent-browser click "role:button" "Submit" 2>/dev/null || \
    agent-browser click "#submit" 2>/dev/null || \
    agent-browser click "text:Submit" 2>/dev/null || \
    return 1

  # 유효성 검사 에러 메시지 대기
  agent-browser wait 1000  # 에러 렌더링 대기

  # 에러 메시지 확인 (필요에 따라 수정)
  agent-browser snapshot -i | grep -qi "required\|error\|invalid" || {
    echo "Validation error message not found"
    return 1
  }
}

test_responsive_mobile() {
  # 모바일 뷰포트 설정
  agent-browser set viewport 375 667
  agent-browser open "$BASE_URL"
  agent-browser wait load

  # 모바일 메뉴 버튼 확인 (햄버거 메뉴)
  agent-browser snapshot -i

  # 뷰포트 복원
  agent-browser set viewport 1280 720
}

# ============================================
# 테스트 실행
# ============================================

main() {
  echo "========================================"
  echo "E2E Test Suite"
  echo "Base URL: $BASE_URL"
  echo "========================================"
  echo ""

  mkdir -p ./screenshots

  # 테스트 실행
  run_test "Homepage Loads" test_homepage_loads
  run_test "Navigation Works" test_navigation_works
  run_test "Login Form" test_login_form
  run_test "Form Validation" test_form_validation
  run_test "Responsive Mobile" test_responsive_mobile

  # 결과 출력
  echo ""
  echo "========================================"
  echo "Results: $PASSED passed, $FAILED failed"
  echo "========================================"

  if [[ $FAILED -gt 0 ]]; then
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_TESTS[@]}"; do
      echo "  - $test"
    done
    exit 1
  fi

  exit 0
}

main
