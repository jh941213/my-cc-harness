---
name: tdd
description: 테스트 주도 개발 - 테스트 먼저 작성 후 구현. 트리거: "TDD", "테스트 먼저", "테스트 주도", "RED-GREEN-REFACTOR". 안티-트리거: "구현 먼저", "테스트 나중에".
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep
user-invocable: true
---

# TDD (테스트 주도 개발)

테스트를 먼저 작성하고, 코드를 구현하는 TDD 방식을 적용합니다.

## TDD 사이클

```
RED → GREEN → REFACTOR → REPEAT

RED:      실패하는 테스트 작성
GREEN:    테스트 통과하는 최소 코드 작성
REFACTOR: 코드 개선 (테스트 유지)
REPEAT:   다음 기능/시나리오
```

## Step 1: 인터페이스 정의 (SCAFFOLD)

```typescript
// 타입 먼저 정의
interface CreateUserInput {
  name: string;
  email: string;
}

// 빈 구현체
export function createUser(input: CreateUserInput): User {
  throw new Error('Not implemented');
}
```

## Step 2: 테스트 작성 (RED)

테스트 순서: **정상 → 엣지 → 에러**

```typescript
describe('createUser', () => {
  // 정상 케이스 먼저
  it('유효한 입력으로 사용자를 생성해야 한다', () => {
    const input = { name: '홍길동', email: 'hong@test.com' };
    const result = createUser(input);
    expect(result).toMatchObject({ name: '홍길동', email: 'hong@test.com' });
    expect(result.id).toBeDefined();
  });

  // 엣지 케이스
  it('이름 앞뒤 공백을 제거해야 한다', () => {
    const result = createUser({ name: '  홍길동  ', email: 'hong@test.com' });
    expect(result.name).toBe('홍길동');
  });

  // 에러 케이스
  it('이메일이 없으면 ValidationError를 던져야 한다', () => {
    expect(() => createUser({ name: '홍길동', email: '' })).toThrow(ValidationError);
  });
});
```

## Step 3: 실패 확인 (중요!)

```bash
# 반드시 실패하는지 확인 — 바로 통과하면 테스트가 잘못된 것
npm test -- path/to/file.test.ts
# 또는
pytest path/to/test_file.py -v
```

**실패 안 하면 STOP** — 테스트를 다시 검토.

## Step 4: 최소 구현 (GREEN)

- 테스트만 통과하는 최소한의 코드
- 하드코딩도 OK (리팩토링에서 개선)
- 우아함보다 정확성

## Step 5: 리팩토링 (REFACTOR)

- 중복 제거, 네이밍 개선
- 테스트 재실행하여 깨지지 않는지 확인
- **새 기능 추가 금지** — 리팩토링만

## Step 6: 반복 (REPEAT)

다음 테스트 케이스 추가 → RED부터 다시.

## 프레임워크별 명령어

| 프레임워크 | 실행 | 워치 | 커버리지 |
|-----------|------|------|---------|
| Vitest | `npx vitest run` | `npx vitest` | `npx vitest --coverage` |
| Jest | `npx jest` | `npx jest --watch` | `npx jest --coverage` |
| pytest | `pytest -v` | `ptw` | `pytest --cov=src` |

## 테스트 파일 위치

| 패턴 | 위치 |
|------|------|
| 코로케이션 | `src/user.ts` → `src/user.test.ts` |
| __tests__ | `src/user.ts` → `src/__tests__/user.test.ts` |
| Python | `src/user.py` → `tests/test_user.py` |

기존 프로젝트 패턴을 따름.

## 주의사항

- 한 번에 하나의 테스트만 추가
- 테스트가 실패하는지 반드시 확인
- 구현이 아닌 행위를 테스트
- 커버리지 목표: 새 코드 80%+
