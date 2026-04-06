---
name: simplify
description: "코드 단순화 및 리팩토링 — 변경된 코드를 리뷰하고 불필요한 추상화, 중복, 복잡성을 제거합니다. Triggers on: 단순화, simplify, 리팩토링, 코드 정리, 코드 개선. NOT for: 새 기능 추가, 버그 수정."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Edit, Grep, Bash
---

# 코드 단순화

최근 변경된 코드를 리뷰하고 단순화합니다.

## Step 1: 변경 범위 파악
```bash
git diff --name-only HEAD~1  # 최근 변경 파일 확인
```

## Step 2: 리팩토링 패턴 적용

### 불필요한 추상화 제거
```typescript
// BEFORE: 한 번만 쓰이는 헬퍼
function formatUserName(user: User) { return `${user.first} ${user.last}`; }
const name = formatUserName(user);

// AFTER: 인라인
const name = `${user.first} ${user.last}`;
```

### 조건문 단순화
```typescript
// BEFORE: 깊은 중첩
if (user) {
  if (user.isActive) {
    if (user.hasPermission) {
      doThing();
    }
  }
}

// AFTER: 얼리 리턴
if (!user?.isActive || !user.hasPermission) return;
doThing();
```

### 중복 제거
```typescript
// BEFORE: 반복 패턴
const users = data.filter(d => d.type === 'user').map(d => d.name);
const admins = data.filter(d => d.type === 'admin').map(d => d.name);

// AFTER: 3회 이상 반복될 때만 추출
const namesByType = (type: string) => data.filter(d => d.type === type).map(d => d.name);
```

**주의**: 2회 반복은 추출하지 않음. 3회부터 고려.

## Step 2.5: 중복 코드 탐지
```bash
# jscpd — copy-paste 감지 (3줄 이상 중복)
npx jscpd src/ --min-lines 3 --reporters console 2>/dev/null | head -30

# ast-grep — 구조적 패턴 탐지
sg --pattern 'console.log($$$)' --lang ts 2>/dev/null | head -10
```

## Step 3: 검증

수정 후 반드시 확인:
```bash
npm run typecheck || npx tsc --noEmit  # 타입 안전
npm test                                # 테스트 통과
```

## 체크리스트
- [ ] 함수 50줄 이하
- [ ] 파일 800줄 이하
- [ ] 중첩 4단계 이하
- [ ] 매직 넘버 → 상수
- [ ] 명확한 변수명
- [ ] console.log 제거
- [ ] 사용하지 않는 import 제거
- [ ] any 타입 제거

## 절대 단순화하지 않을 것 (NEVER)
- NEVER 에러 핸들링 제거 — try/catch, 유효성 검사는 의도적 코드
- NEVER 생성된/벤더 파일 수정 — node_modules, generated, vendor 디렉토리
- NEVER 설정 파일 단순화 — tsconfig, eslint, webpack 등은 건드리지 않음
- NEVER 관련 없는 함수 병합 — 비슷해 보여도 도메인이 다르면 분리 유지
- NEVER 테스트 코드 단순화 — 테스트의 명시성은 의도적. DRY 적용 금지
- NEVER 타입 정의 제거 — 중복처럼 보여도 타입 안전성 유지

## 범위 결정
- 사용자가 특정 파일 지정 시 → 해당 파일만
- 지정 없으면 → `git diff --name-only HEAD~1` (최근 커밋 변경 파일)
- 변경 범위 밖 코드는 절대 수정하지 않음

## 원칙
- 동작은 변경하지 않음 (리팩토링만)
- 3줄 비슷한 코드 > 조기 추상화
- 과도한 최적화 지양
- 수정 전 `git stash` 또는 현재 상태 확인 → 수정 후 검증 → 실패 시 원복
