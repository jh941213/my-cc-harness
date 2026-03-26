---
name: autodev-parallel
description: >
  Ralph Loop 병렬 버전. 여러 에이전트가 worktree에서 동시에 PRD 항목을 처리한다.
  트리거: "병렬 실험", "autodev parallel", "동시에 실험", "워크트리 실험", "병렬 랄프"
  안티-트리거: "순차 실험", "하나씩"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDev Parallel — Ralph Loop 병렬 오케스트레이터

여러 에이전트가 worktree 격리 환경에서 PRD 항목을 병렬 처리한다.
독립적인 항목들을 동시에 진행하여 완료 속도를 극대화.

## 핵심 개념

```
main (또는 현재 브랜치)
 │
 ├── worktree A ── Agent 1: PRD 항목 1
 ├── worktree B ── Agent 2: PRD 항목 2
 ├── worktree C ── Agent 3: PRD 항목 3
 │
 └── Orchestrator (이 스킬)
      - 독립 항목 분류 & 배정
      - 결과 수집 & 검증
      - cherry-pick으로 통합
      - 다음 라운드 반복
```

## Phase 0: 설정 수집

```yaml
goal: "무엇을 달성할 것인가"
prd: "PRD 또는 체크리스트 파일 경로"     # 예: "PRD.md"
scope: ["수정 가능한 파일 패턴"]
verify: "검증 명령어"
parallel: 3                            # 동시 에이전트 수 (기본 3)
rounds: 5                             # 라운드 수 (기본 5)
max_iterations: 100                    # Stop Hook 최대 반복 (기본 100)
completion_promise: "DONE"
```

## Phase 1: 항목 분류

PRD를 읽고 항목들의 의존성을 분석:

```markdown
## 독립 항목 (병렬 가능)
- [ ] 항목 A: API 엔드포인트 — src/api/
- [ ] 항목 B: UI 컴포넌트 — src/components/
- [ ] 항목 C: 테스트 작성 — tests/

## 의존 항목 (순차 필요)
- [ ] 항목 D: A 완료 후 → 통합 테스트
```

## Phase 2: 라운드 루프

```
for round in 1..rounds:

  1. SELECT
     - 미완료 항목 중 독립적인 것 최대 {parallel}개 선택
     - 의존성이 있는 항목은 선행 항목 완료 후에만 선택

  2. LAUNCH (병렬)
     - {parallel}개의 Agent를 동시에 호출
     - 각 Agent는 isolation: "worktree"로 격리
     - 각 Agent에게 전달하는 프롬프트:

     """
     PRD 항목을 구현하라.

     항목: {specific_item}
     Scope: {scope}
     Verify: {verify}

     절차:
     1. scope 내 파일을 읽고 항목을 구현
     2. {verify} 실행으로 검증
     3. 실패 시 build-fix 1회 시도
     4. 성공 시 git commit -m "[autodev] {item_summary}"
     5. 결과를 최종 메시지로 반환:
        AUTODEV_RESULT: status={success|fail}, commit={hash}, item="{desc}"
     """

  3. COLLECT
     - 각 Agent 완료 대기
     - 결과 파싱 (status, commit hash)

  4. INTEGRATE
     - 성공한 Agent의 변경사항을 cherry-pick
     - cherry-pick 충돌 시:
       - 충돌 해결 시도 (1회)
       - 실패 시 해당 항목 다음 라운드로 연기
     - PRD에서 완료된 항목을 [x]로 체크

  5. VERIFY ALL
     - 통합 후 전체 검증: {verify}
     - 실패 시 마지막 cherry-pick 되돌리고 항목 연기

  6. REPORT (라운드별)
     라운드 {round}/{rounds} 완료:
     - Agent 1: {status} — {item}
     - Agent 2: {status} — {item}
     - 남은 미완료 항목: {remaining}

  7. CHECK COMPLETION
     - 모든 항목 완료? → <promise>DONE</promise>
     - 아니면 → 다음 라운드
```

## Phase 3: 완료 보고

```markdown
# AutoDev Parallel 완료 보고서

## 요약
- 총 라운드: {rounds}
- 총 항목: {total} (완료: {done}, 실패: {failed})
- 병렬 에이전트: {parallel}

## 라운드별 결과
| 라운드 | 완료 항목 | 실패 | 누적 완료율 |
|--------|----------|------|-----------|
| 1 | A, B | - | 2/10 (20%) |
| 2 | C, D, E | F | 5/10 (50%) |

## 미완료 항목 (있으면)
- [ ] 항목 F: 이유

## 브랜치
autodev/{tag} — main 머지 준비 완료
```

## 병렬 수 가이드라인

| 상황 | 권장 parallel |
|------|--------------|
| 독립적 파일/모듈 | 5 (최대) |
| 같은 파일 내 변경 | 1-2 (충돌 위험) |
| 성능 벤치마크 포함 | 2-3 (리소스 공유) |
| 테스트만 판정 | 3-5 |

## 안전장치

1. **worktree 격리**: Agent tool의 `isolation: "worktree"` 사용
2. **cherry-pick만**: force push 절대 금지
3. **기존 테스트 보호**: 통합 후 전체 검증 실패 시 롤백
4. **의존성 존중**: 의존 항목은 선행 항목 완료 후에만 처리
5. **라운드 간 동기화**: 이전 라운드 통합 완료 후 다음 라운드 시작
6. **max_iterations**: Stop Hook 안전 장치

## TTH 팀원 활용 (선택)

```yaml
# 팀원별 전문 영역 배정
pichai: 아키텍처 변경, 모듈 분리
jensen: API 최적화, DB 쿼리 개선
zuckerberg: 프론트엔드 컴포넌트
bezos: 코드 삭제, 불필요한 추상화 제거
```

프롬프트에 팀 역할 파일 포함하여 전문성 부여:
```
해당 팀원의 역할 파일을 읽고 그 관점에서 구현하라:
~/.claude/team-roles/{role}.md
```
