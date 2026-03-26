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
```bash
# Node.js/TypeScript
[ -f package.json ] && cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); print('\n'.join(f'{k}: {v}' for k,v in s.items()))"

# Python
[ -f pyproject.toml ] && echo "Python project detected"
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

## Step 3: 결과 보고

```
✅ typecheck: 통과
✅ lint: 통과
✅ test: 42 passed
✅ build: 성공
```

## 최대 재시도
각 단계 최대 3회 시도. 3회 실패 시 멈추고 사용자에게 보고.

