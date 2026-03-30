# 코드 검증 파이프라인

작업 완료 후 코드 품질을 자동 검증합니다. 실패 시 자동 수정 후 재검증.

입력: $ARGUMENTS

## 실행 방식

### 인자 없이: `/verify`
- 전체 파이프라인 실행 (typecheck → lint → test → build → security)

### 특정 단계만: `/verify typecheck`, `/verify test`
- 해당 단계만 실행

### 빠른 모드: `/verify quick`
- typecheck + lint만 실행 (빌드/테스트 스킵)

---

## Step 1: 프로젝트 감지

```bash
# 프로젝트 타입 자동 감지
[ -f package.json ] && echo "NODE" && cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); print('\n'.join(f'{k}: {v}' for k,v in s.items()))"
[ -f pyproject.toml ] && echo "PYTHON"
[ -f Cargo.toml ] && echo "RUST"
[ -f go.mod ] && echo "GO"
```

감지된 프로젝트 타입에 따라 검증 도구를 자동 선택한다.

## Step 2: 검증 파이프라인 (순차 실행, 실패 시 즉시 수정)

각 단계는 **최대 3회 재시도**. 실패 → 자동 수정 → 재실행. 3회 실패 시 사용자에게 에스컬레이션.

### 2-1. TypeScript 타입체크 / Python 타입체크

**Node.js/TypeScript:**
```bash
npx tsc --noEmit 2>&1
```

**Python:**
```bash
mypy . --ignore-missing-imports 2>&1 || ruff check . --select=E 2>&1
```

실패 시:
1. 에러 메시지에서 파일:줄번호 추출
2. 해당 파일 Read → 타입 에러 수정
3. 재실행

### 2-2. 린트

**Node.js:**
```bash
# ESLint (있으면)
npx eslint . --max-warnings=0 2>&1
# Biome (있으면)
npx biome check . 2>&1
```

**Python:**
```bash
ruff check . 2>&1
```

실패 시:
1. `--fix` 자동 수정 먼저 시도: `npx eslint . --fix` / `ruff check . --fix`
2. 자동 수정 안 되는 항목 → 수동 수정
3. 재실행

### 2-3. 테스트

**Node.js:**
```bash
# Vitest
npx vitest run 2>&1
# Jest
npx jest --passWithNoTests 2>&1
```

**Python:**
```bash
pytest -q 2>&1
```

실패 시:
1. 실패한 테스트 파일과 에러 메시지 분석
2. **코드를 수정** (테스트 수정은 최후 수단 — 테스트가 의도한 동작을 검증하는 경우)
3. 재실행

### 2-4. 빌드

```bash
npm run build 2>&1
```

실패 시:
1. 빌드 에러 분석 (import 경로, 환경변수, 타입 불일치)
2. 수정 → 재실행

### 2-5. 보안 감사 (선택)

```bash
# Node.js
npm audit --audit-level=high 2>&1
# Python
pip-audit 2>&1 || safety check 2>&1
```

critical/high 취약점 발견 시 보고. 자동 수정하지 않음 (의존성 업그레이드는 사용자 판단).

## Step 3: 결과 보고

모든 단계 완료 후 요약 보고:

```
## Verify 결과

| 단계 | 상태 | 비고 |
|------|------|------|
| typecheck | PASS | 에러 0 |
| lint | PASS | 경고 0 |
| test | PASS | 42 passed, 0 failed |
| build | PASS | 성공 |
| security | WARN | high 1건 (보고만) |

총 수정: 3개 파일
- src/api/handler.ts: 타입 에러 수정
- src/utils/format.ts: unused import 제거
- src/components/Form.tsx: lint warning 수정
```

## 병렬 실행 지원

`/verify`는 `/e2e-verify`, `/simplify`와 **병렬 실행 가능**:

```
# 사용자가 직접 병렬 호출
/verify && /e2e-verify && /simplify

# TTH에서 사티아가 병렬 스폰
Agent(prompt="/verify 실행", run_in_background=true)
Agent(prompt="/e2e-verify 실행", run_in_background=true)
Agent(prompt="/simplify 실행", run_in_background=true)
```

각 커맨드는 서로 다른 파일을 수정하므로 충돌 없음:
- `/verify`: 소스 코드 수정 (타입/린트 에러)
- `/e2e-verify`: `e2e/` 디렉토리만 수정
- `/simplify`: 소스 코드 리팩토링 (verify 후 실행 권장)

## 원칙

- 실패를 무시하지 않는다 — 모든 에러를 수정하거나 에스컬레이션
- 테스트를 수정하기 전에 코드를 수정한다
- `--fix` 자동 수정을 먼저 시도한다
- 3회 실패 시 멈추고 보고한다
