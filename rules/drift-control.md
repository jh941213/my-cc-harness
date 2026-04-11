---
description: "CHECKPOINT.md 기반 작업 drift 추적 규칙"
globs: ["**/CHECKPOINT.md", "**/progress.txt"]
---

# Drift Control

작업 진행 중 목표에서 벗어나는 것을 방지하는 3축 drift 측정.

## CHECKPOINT.md Drift 섹션 형식

마일스톤마다 drift 추적 필드를 포함:

```markdown
## M1: [마일스톤명]
- [ ] 설명
- 검증: `npm run typecheck && npm run test`
- done-when: 타입 에러 0, 테스트 통과
- 상태: in-progress
- drift:
  - goal: 0.0    # 목표 이탈 (0.0=정확, 1.0=완전이탈)
  - constraint: 0.0  # 제약조건 위반 (위반당 +0.1)
  - scope: 0.0   # 범위 이탈 (계획 외 파일 변경 비율)
  - combined: 0.0  # 가중평균 (goal×50% + constraint×30% + scope×20%)
```

## Drift 임계값

| combined | 판정 | 행동 |
|----------|------|------|
| ≤ 0.15 | ✅ 정상 | 계속 진행 |
| 0.15~0.30 | ⚠️ 주의 | 다음 작업 전 drift 원인 점검 |
| > 0.30 | 🔴 위험 | **STOP** — re-plan 필요. AUDIT.log에 기록 |

## Drift 측정 시점

1. **마일스톤 시작 시**: 초기값 0.0 설정
2. **매 코드 변경 후**: scope drift 갱신 (변경 파일 중 계획 외 비율)
3. **검증 실패 시**: goal drift 갱신
4. **마일스톤 완료 시**: 최종 drift 기록

## Scope Drift 자동 계산

```
scope_drift = (계획 외 변경 파일 수) / (전체 변경 파일 수)
```

계획 외 파일: CHECKPOINT.md에 명시되지 않은 파일의 변경

## Constraint Drift 누적

제약조건 위반 시 +0.1 누적:
- 성능 SLA 미달
- 하위호환 깨짐
- 보안 규칙 위반
- 코딩 스타일 위반

## Combined Drift 공식

```
combined = goal × 0.5 + constraint × 0.3 + scope × 0.2
```
