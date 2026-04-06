---
name: verify
description: "작업 완료 후 코드 검증 (타입체크, 린트, 테스트, 빌드). Triggers on: 검증, verify, 테스트 돌려, 빌드 확인, 타입체크. NOT for: E2E 테스트, 코드 작성, 구현."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Edit
---

# 코드 검증

작업 완료 후 코드를 검증합니다. 순서대로 실행하며, 각 단계 통과 후 다음으로 진행.

## Step 1: 프로젝트 감지

| 파일 | 스택 | 타입체크 | 린트 | 테스트 | 빌드 |
|------|------|---------|------|--------|------|
| `package.json` | Node/TS | `npx tsc --noEmit` | `npx eslint .` / `npx biome check .` | `npx vitest run` / `npx jest` | `npm run build` |
| `pyproject.toml` | Python | `mypy .` / `pyright .` | `ruff check .` | `pytest -q` | — |
| `go.mod` | Go | `go vet ./...` | `golangci-lint run` | `go test ./...` | `go build ./...` |
| `Cargo.toml` | Rust | — | `cargo clippy` | `cargo test` | `cargo build` |

```bash
# 자동 감지
[ -f package.json ] && cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); print('\n'.join(f'{k}: {v}' for k,v in s.items()))"
[ -f pyproject.toml ] && echo "Python project detected"
[ -f go.mod ] && echo "Go project detected"
[ -f Cargo.toml ] && echo "Rust project detected"
```

## Step 2: 검증 순서 (실패 시 즉시 수정)

### 2-1. TypeScript 타입체크
```bash
npx tsc --noEmit
```
실패 시: 타입 에러 수정 → 재실행. 3회 실패 시 사용자에게 에스컬레이션.

### 2-2. 린트
```bash
# ESLint
npx eslint . --max-warnings=0
# 또는 Biome
npx biome check .
# Python
ruff check .
```
실패 시: `--fix` 자동 수정 시도 → 수동 수정 → 재실행.

### 2-3. 테스트
```bash
# Vitest
npx vitest run
# Jest
npx jest --passWithNoTests
# pytest
pytest -q
```
실패 시: 실패 테스트 분석 → 코드 수정 (테스트 수정은 최후 수단) → 재실행.

### 2-4. 빌드
```bash
npm run build
```
실패 시: 빌드 에러 분석 → 수정 → 재실행.

### 2-5. 순환참조 탐지 (JS/TS 프로젝트)
```bash
npx madge --circular --extensions ts,tsx src/ 2>/dev/null
```
순환참조 발견 시: WARNING으로 보고. 새로 추가된 순환만 수정 대상.

### 2-6. 데드코드 탐지 (JS/TS 프로젝트)
```bash
npx knip --no-exit-code 2>/dev/null | head -50
```
미사용 export/파일/의존성 발견 시: INFO로 보고. 자동 수정하지 않음.

### 2-7. 시크릿 스캔
```bash
gitleaks detect --source . --no-git -v 2>&1 | head -20
```
시크릿 발견 시: CRITICAL. 즉시 보고 후 수정 유도.

### 2-8. AI 슬롭 패턴 탐지 (ast-grep)
```bash
# 불필요한 console.log
sg --pattern 'console.log($$$)' --lang ts src/ 2>/dev/null | head -10
# any 타입 사용
sg --pattern '$A as any' --lang ts src/ 2>/dev/null | head -10
```
발견 시: WARNING으로 보고.

## Step 3: 결과 보고

| 단계 | 상태 | 상세 |
|------|------|------|
| typecheck | PASS/FAIL/SKIP | 에러 수 또는 "도구 미감지" |
| lint | PASS/FAIL/SKIP | 경고/에러 수 |
| test | PASS/FAIL/SKIP | N passed, M failed |
| build | PASS/FAIL/SKIP | 성공 또는 에러 요약 |
| circular | PASS/WARN/SKIP | 순환참조 수 (madge) |
| deadcode | INFO/SKIP | 미사용 export/파일 수 (knip) |
| secrets | PASS/CRITICAL/SKIP | 시크릿 탐지 수 (gitleaks) |
| ai-slop | PASS/WARN/SKIP | console.log/any 수 (ast-grep) |

**판정**: PASS = exit code 0, FAIL = 3회 재시도 소진, SKIP = 해당 도구 미감지
**전체 판정**: CRITICAL 있으면 FAIL. 모든 PASS/WARN/INFO/SKIP → PASS. typecheck/lint/test/build 중 FAIL → FAIL.

## 에러 카테고리별 수정 전략

| 카테고리 | 우선순위 | 수정 방법 |
|----------|---------|----------|
| TYPE | 높음 | 출력에서 file:line 추출 → 해당 파일 Read → 타입 수정 |
| LINT | 중간 | `--fix` 자동 수정 먼저 → 수동 수정 |
| TEST | 높음 | 실패 테스트 분석 → 코드 수정 (테스트 수정은 최후 수단) |
| BUILD | 높음 | 빌드 로그 분석 → import/export 문제 우선 확인 |

## 최대 재시도
각 단계 최대 3회 시도. 3회 실패 시 멈추고 사용자에게 보고.

