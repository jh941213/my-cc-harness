# ADR 템플릿 (MADR 기반)

## Minimal (기본값 — 대부분의 결정)

```markdown
---
status: accepted        # proposed | accepted | superseded by ADR-NNNN
date: {YYYY-MM-DD}
decision-makers: [{이름}]
---

# ADR-{NNNN}: {결정을 한 문장으로}

## Context
{어떤 문제/제약 때문에 결정이 필요했나. 2-5문장}

## Decision
{무엇을 선택했나. 능동태 한 문장 + 보충}

## Consequences
- 좋아지는 것: {…}
- 감수하는 것: {…}
- 후속 작업: {…}
```

## Full MADR (논쟁적/고비용 결정만)

```markdown
---
status: proposed
date: {YYYY-MM-DD}
decision-makers: [{이름}]
consulted: [{의견 준 사람/에이전트}]
informed: [{공유 대상}]
---

# ADR-{NNNN}: {제목}

## Context and Problem Statement
{문제 정의}

## Decision Drivers
- {드라이버 1 — 예: 운영 비용}
- {드라이버 2}

## Considered Options
1. {옵션 A}
2. {옵션 B}
3. {옵션 C}

## Decision Outcome
선택: **{옵션}** — {이유 요약}

### Consequences
- Good: {…}
- Bad: {…}

### Confirmation
{이 결정이 지켜지는지 어떻게 확인하나 — 린트 룰, 리뷰 체크, 테스트}

## Pros and Cons of the Options

### {옵션 A}
- Good: {…}
- Bad: {…}

### {옵션 B}
- Good: {…}
- Bad: {…}
```

## 인덱스 갱신

`docs/design-docs/index.md`에 한 줄 추가:

```markdown
| ADR-{NNNN} | {제목} | {status} | {date} |
```
