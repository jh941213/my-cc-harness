# E2E 검증 — agent-browser 기반

`/verify` 통과 후, 실제 브라우저에서 사용자 플로우를 E2E 테스트로 검증합니다.
**agent-browser** CLI의 스냅샷+ref 시스템을 활용한 접근성 트리 기반 안정적 테스트.

입력: $ARGUMENTS

## 실행 방식

### 인자 없이: `/e2e-verify`
- 구현된 피처 자동 감지 → 테스트 작성 → 실행

### 특정 피처: `/e2e-verify login`, `/e2e-verify checkout`
- 해당 피처만 E2E 테스트

### 기존 테스트 실행: `/e2e-verify run`
- `e2e/` 디렉토리의 기존 테스트만 실행 (새 테스트 작성 안 함)

---

## Step 1: 전제 조건 확인

```bash
# agent-browser 설치 확인
which agent-browser || echo "MISSING: npm install -g agent-browser && agent-browser setup"

# 앱 실행 가능 여부 확인
[ -f package.json ] && cat package.json | python3 -c "
import sys,json
s=json.load(sys.stdin).get('scripts',{})
for k in ['dev','start','serve']:
    if k in s: print(f'START_CMD: npm run {k}'); break
"

# Python (FastAPI/Flask)
[ -f pyproject.toml ] && echo "START_CMD: uvicorn main:app --port 3000"
```

agent-browser 미설치 시: 설치 안내 후 중단.

## Step 2: 피처 분석

### 자동 감지 (인자 없을 때)
```bash
# 최근 변경된 라우트/페이지 파일 확인
git diff --name-only HEAD~5..HEAD | grep -E "(page|route|view|screen)\.(tsx?|jsx?|py)" || true

# Next.js App Router
ls app/**/page.tsx 2>/dev/null

# React Router
grep -r "Route.*path=" src/ --include="*.tsx" -l 2>/dev/null

# FastAPI
grep -r "@app\.(get|post|put|delete)" --include="*.py" -l 2>/dev/null
```

분석 결과로 테스트 대상 피처 목록 생성:
```
테스트 대상:
1. /login — 로그인 플로우 (이메일 + 비밀번호 → 대시보드 리다이렉트)
2. /dashboard — 대시보드 데이터 로딩 + 표시
3. /settings — 설정 변경 + 저장
```

## Step 3: 앱 실행

```bash
# 앱을 백그라운드로 실행
npm run dev &
APP_PID=$!

# 앱 준비 대기 (최대 30초)
for i in $(seq 1 30); do
  curl -s http://localhost:3000 > /dev/null 2>&1 && break
  sleep 1
done

# 실패 시
curl -s http://localhost:3000 > /dev/null 2>&1 || {
  echo "FAIL: 앱이 30초 내 시작되지 않음"
  kill $APP_PID 2>/dev/null
  exit 1
}
```

## Step 4: E2E 테스트 작성 (agent-browser 활용)

`e2e/` 디렉토리에 피처별 테스트 스크립트를 생성한다.

### 테스트 구조
```
e2e/
├── runner.sh              # 전체 테스트 실행기
├── test_login.sh          # 로그인 플로우
├── test_dashboard.sh      # 대시보드
├── test_settings.sh       # 설정
└── screenshots/           # 실패 시 스크린샷
```

### 테스트 작성 패턴

**모든 테스트는 이 구조를 따른다:**

```bash
#!/bin/bash
# e2e/test_[피처명].sh
set -e

# Cleanup: 테스트 종료 시 브라우저 닫기
cleanup() {
  agent-browser screenshot ./e2e/screenshots/$(basename $0 .sh)_$(date +%s).png 2>/dev/null || true
  agent-browser close 2>/dev/null || true
}
trap cleanup EXIT

BASE_URL="${BASE_URL:-http://localhost:3000}"

# ── 1. 페이지 열기 ──
agent-browser open "$BASE_URL/[경로]"

# ── 2. 스냅샷으로 현재 상태 파악 ──
agent-browser snapshot -i
# 출력 예:
# - textbox "Email" [ref=e1]
# - textbox "Password" [ref=e2]
# - button "Sign In" [ref=e3]

# ── 3. 인터랙션 실행 ──
agent-browser fill @e1 "test@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3

# ── 4. 결과 검증 ──
agent-browser wait url "**/dashboard"
agent-browser wait text "Welcome"

# ── 5. 추가 검증 (스냅샷 기반) ──
SNAP=$(agent-browser snapshot -i)
echo "$SNAP" | grep -q "Dashboard" || {
  echo "FAIL: Dashboard heading not found"
  exit 1
}

echo "PASS: Login flow E2E test"
```

### agent-browser 핵심 명령어 참조

| 명령어 | 용도 | 예시 |
|--------|------|------|
| `open <url>` | 페이지 열기 | `agent-browser open http://localhost:3000` |
| `snapshot -i` | 인터랙티브 요소 스냅샷 | ref 번호 확인용 |
| `snapshot -c -d 3` | 컴팩트 스냅샷 (깊이 3) | 구조 파악용 |
| `click @ref` | 요소 클릭 | `agent-browser click @e2` |
| `fill @ref "text"` | 텍스트 입력 | `agent-browser fill @e1 "email@test.com"` |
| `text @ref` | 텍스트 추출 | `agent-browser text @heading` |
| `wait text "msg"` | 텍스트 대기 | `agent-browser wait text "Success"` |
| `wait url "**/path"` | URL 패턴 대기 | `agent-browser wait url "**/dashboard"` |
| `wait @ref` | 요소 출현 대기 | `agent-browser wait @modal` |
| `isvisible @ref` | 가시성 확인 | 모달 닫힘 검증 |
| `screenshot ./path` | 스크린샷 | 디버깅 + 실패 기록 |
| `drag @src @dst` | 드래그 앤 드롭 | 칸반 보드 등 |
| `upload @ref "./file"` | 파일 업로드 | 파일 입력 필드 |
| `eval "js"` | JS 실행 | `agent-browser eval "document.title"` |
| `close` | 브라우저 닫기 | cleanup에서 사용 |

### 스냅샷 기반 적응형 테스트 작성법

agent-browser의 핵심은 **스냅샷 → ref → 액션** 사이클이다.
ref는 매 스냅샷마다 갱신되므로 하드코딩하지 않는다:

```bash
# 1. 스냅샷 찍기
SNAP=$(agent-browser snapshot -i)

# 2. 스냅샷에서 ref 동적 추출
EMAIL_REF=$(echo "$SNAP" | grep -oP 'textbox "Email" \[ref=\K[^\]]+')
SUBMIT_REF=$(echo "$SNAP" | grep -oP 'button "Submit" \[ref=\K[^\]]+')

# 3. 추출된 ref로 액션
agent-browser fill @$EMAIL_REF "test@test.com"
agent-browser click @$SUBMIT_REF
```

## Step 5: 테스트 실행

### 전체 실행기 (runner.sh)
```bash
#!/bin/bash
# e2e/runner.sh
set -e

PASSED=0
FAILED=0
RESULTS=""

for test in e2e/test_*.sh; do
  echo "=== Running: $test ==="
  if bash "$test"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: $test"
  else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: $test"
  fi
done

echo -e "\n=== E2E Results ==="
echo -e "$RESULTS"
echo "Passed: $PASSED / Failed: $FAILED"

[ $FAILED -eq 0 ] || exit 1
```

실행:
```bash
bash e2e/runner.sh
```

## Step 6: 실패 시 디버그 사이클

```
FAIL 감지
  ↓
1. 스크린샷 확인 (e2e/screenshots/)
  ↓
2. headed 모드로 재현:
   agent-browser open http://localhost:3000 --headed
  ↓
3. 콘솔 에러 확인:
   agent-browser console --error
  ↓
4. 코드 수정 (소스 코드 수정, 테스트 수정은 최후)
  ↓
5. /verify 재실행 (회귀 방지)
  ↓
6. E2E 테스트 재실행
  ↓
최대 3회 반복. 3회 실패 시 사용자에게 에스컬레이션.
```

## Step 7: 결과 보고

```
## E2E Verify 결과

| 테스트 | 상태 | 소요 시간 |
|--------|------|-----------|
| test_login.sh | PASS | 3.2s |
| test_dashboard.sh | PASS | 2.8s |
| test_settings.sh | FAIL → PASS (2차) | 5.1s |

총 테스트: 3개
통과: 3개 (1개 재시도 후 통과)
실패: 0개

수정된 파일:
- src/components/Settings.tsx: onClick 핸들러 누락 수정
```

## 병렬 실행 지원

`/e2e-verify`는 `/verify`, `/simplify`와 **병렬 실행 가능**.
단, `/verify`가 먼저 통과하는 것을 권장 (타입/빌드 에러가 있으면 E2E도 실패).

**권장 순서:**
```
/verify → (통과 후) → /e2e-verify + /simplify 병렬
```

**TTH에서:**
```
사티아 → Agent(prompt="/verify") → 통과 확인
     → Agent(prompt="/e2e-verify", run_in_background=true)
     → Agent(prompt="/simplify", run_in_background=true)
```

## 원칙

- **스냅샷 우선**: CSS 셀렉터보다 `snapshot -i` → `@ref` 패턴 사용
- **하드코딩 대기 금지**: `sleep 5` 대신 `wait text "..."` / `wait url "..."`
- **cleanup 필수**: `trap cleanup EXIT`로 브라우저 정리
- **스크린샷 기록**: 실패 시 자동 스크린샷 → `e2e/screenshots/`
- **코드 수정 우선**: E2E 실패 시 테스트가 아닌 소스 코드를 먼저 수정
