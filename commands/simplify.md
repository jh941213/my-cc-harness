# 코드 단순화 — AI 슬롭 제거 + 리팩토링

최근 변경된 코드를 리뷰하고 불필요한 복잡성을 제거합니다.
머스크 5-Step의 "Step 2: 삭제"와 "Step 3: 단순화"를 적용.

입력: $ARGUMENTS

## 실행 방식

### 인자 없이: `/simplify`
- 최근 변경 파일 기준으로 단순화

### 특정 파일/디렉토리: `/simplify src/api/`
- 해당 범위만 단순화

### AI 슬롭만: `/simplify slop`
- AI가 생성한 패턴만 집중 정리 (주석, 과도한 추상화, 장황한 에러 메시지)

### 삭제 분석: `/simplify delete`
- 사용하지 않는 코드/의존성 식별 + 삭제 제안

---

## Step 1: 변경 범위 파악

```bash
# 최근 변경 파일 확인
git diff --name-only HEAD~5..HEAD 2>/dev/null | grep -vE "node_modules|\.lock|dist/"

# 특정 경로가 지정되면 해당 경로만
# $ARGUMENTS에 경로가 있으면 그 경로의 파일 목록
```

변경된 파일을 Read하여 전체 맥락을 파악한 후 단순화 시작.

## Step 2: AI 슬롭 패턴 탐지 및 제거

### 2-1. 불필요한 주석 제거

```bash
# "이 함수는 X를 합니다" 류의 자명한 주석 탐지
grep -rn "// This function\|// This method\|// 이 함수는\|// 이 메서드는" --include="*.ts" --include="*.tsx" --include="*.py"
```

**제거 대상:**
```typescript
// BAD: 코드를 읽으면 아는 내용
/** This function calculates the total price */
function calculateTotalPrice(items: Item[]): number { ... }

// GOOD: 주석 삭제 — 함수명이 충분히 설명적
function calculateTotalPrice(items: Item[]): number { ... }
```

**유지 대상:**
```typescript
// KEEP: "왜"를 설명하는 주석
// Stripe API는 금액을 센트 단위로 받으므로 100을 곱한다
const amountInCents = price * 100;
```

### 2-2. 과도한 추상화 인라인화

```typescript
// BAD: 한 번만 쓰이는 헬퍼
function formatUserName(user: User) { return `${user.first} ${user.last}`; }
const name = formatUserName(user);

// GOOD: 인라인
const name = `${user.first} ${user.last}`;
```

**판단 기준:** 함수가 1곳에서만 호출되고, 5줄 이하이면 인라인 후보.

### 2-3. 장황한 에러 메시지 단순화

```typescript
// BAD: AI가 만든 과잉 친절 에러
throw new Error(
  `An unexpected error occurred while attempting to process the user registration request. ` +
  `The system was unable to complete the operation. Please check the input data and try again. ` +
  `If the problem persists, contact support.`
);

// GOOD: 핵심만
throw new Error(`Registration failed: ${err.message}`);
```

### 2-4. 과잉 방어 코드 제거

```typescript
// BAD: 내부 함수에서 불필요한 null 체크
function processItems(items: Item[]) {
  if (!items) return [];           // 타입이 Item[]이면 null 불가
  if (!Array.isArray(items)) return [];  // 타입 시스템이 보장
  if (items.length === 0) return [];     // 빈 배열은 정상 입력
  return items.map(transform);
}

// GOOD: 타입 시스템 신뢰
function processItems(items: Item[]) {
  return items.map(transform);
}
```

### 2-5. 불필요한 타입 어노테이션 제거

```typescript
// BAD: 추론 가능한 타입 명시
const name: string = "hello";
const count: number = items.length;
const isValid: boolean = name.length > 0;

// GOOD: 타입 추론에 맡김
const name = "hello";
const count = items.length;
const isValid = name.length > 0;
```

## Step 3: 구조적 단순화

### 3-1. 조건문 평탄화

```typescript
// BAD: 깊은 중첩
if (user) {
  if (user.isActive) {
    if (user.hasPermission) {
      doThing();
    }
  }
}

// GOOD: 얼리 리턴
if (!user?.isActive || !user.hasPermission) return;
doThing();
```

### 3-2. 중복 제거 (3회 이상만)

```typescript
// 2회 반복: 그대로 둔다 (조기 추상화 방지)
// 3회 이상 반복: 추출 고려
const namesByType = (type: string) => data.filter(d => d.type === type).map(d => d.name);
```

### 3-3. 사용하지 않는 코드 삭제

```bash
# 사용하지 않는 export 탐지
grep -rn "^export " --include="*.ts" --include="*.tsx" | while read line; do
  SYMBOL=$(echo "$line" | grep -oP 'export (const|function|class|type|interface) \K\w+')
  [ -n "$SYMBOL" ] && {
    COUNT=$(grep -rn "$SYMBOL" --include="*.ts" --include="*.tsx" | wc -l)
    [ "$COUNT" -le 1 ] && echo "UNUSED: $line"
  }
done

# 사용하지 않는 import
npx eslint . --rule '{"no-unused-vars": "error", "@typescript-eslint/no-unused-vars": "error"}' --no-eslintrc 2>/dev/null
```

### 3-4. 사용하지 않는 의존성 삭제

```bash
# depcheck으로 미사용 의존성 탐지
npx depcheck 2>/dev/null || {
  # depcheck 없으면 수동 확인
  cat package.json | python3 -c "
import sys,json
deps = json.load(sys.stdin).get('dependencies',{})
for dep in deps:
    print(dep)
  " | while read dep; do
    grep -rq "$dep" --include="*.ts" --include="*.tsx" --include="*.js" src/ || echo "UNUSED DEP: $dep"
  done
}
```

## Step 4: 검증 (필수)

**단순화 후 반드시 검증. 동작을 변경하면 안 됨.**

```bash
# 타입 안전 확인
npx tsc --noEmit 2>&1 || pytest --tb=short 2>&1

# 테스트 통과 확인
npx vitest run 2>&1 || npx jest --passWithNoTests 2>&1 || pytest -q 2>&1
```

검증 실패 시:
1. 단순화가 동작을 변경한 것 → 되돌리기
2. 기존 코드에 버그가 있었던 것 → 수정 후 진행
3. 판단 불가 → 사용자에게 확인

## Step 5: 결과 보고

```
## Simplify 결과

### AI 슬롭 제거
- 불필요한 주석 12개 삭제
- 과도한 추상화 3개 인라인화
- 장황한 에러 메시지 2개 단순화

### 구조적 단순화
- 중첩 3단계→1단계 평탄화: 2건
- 사용하지 않는 export 삭제: 4건
- 미사용 import 정리: 8건

### 삭제 제안 (사용자 판단 필요)
- `src/utils/legacy.ts` — 어디서도 import 안 함
- `lodash` — 실제 사용처 1곳 (native로 대체 가능)

### 검증
- typecheck: PASS
- test: 42 passed, 0 failed
- 동작 변경 없음 확인
```

## 체크리스트

- [ ] 함수 50줄 이하
- [ ] 파일 800줄 이하
- [ ] 중첩 4단계 이하
- [ ] 매직 넘버 → 상수
- [ ] console.log / print 제거
- [ ] 사용하지 않는 import 제거
- [ ] any 타입 / type: ignore 제거
- [ ] AI가 생성한 자명한 주석 제거
- [ ] 1회 사용 헬퍼 인라인화

## 병렬 실행 지원

`/simplify`는 `/verify` 통과 후 `/e2e-verify`와 **병렬 실행 가능**:

```
/verify → (통과 후) → /simplify + /e2e-verify 병렬
```

**주의:** `/simplify`가 소스 코드를 수정하므로, 완료 후 `/verify`를 한 번 더 실행하는 것이 안전.

```
/verify → /simplify + /e2e-verify → /verify (최종 확인)
```

## 원칙

- **동작은 변경하지 않음** — 리팩토링만
- **3줄 비슷한 코드 > 조기 추상화** — 2회 반복은 허용
- **삭제는 제안, 실행은 확인 후** — 미사용 코드 삭제는 사용자 승인
- **과도한 최적화 지양** — 가독성 > 성능 (병목이 아닌 한)
- **주석은 "왜"만 남긴다** — "무엇"은 코드가 설명
