---
name: autodev-parallel
description: >
  여러 실험을 worktree로 병렬 실행하는 AutoDeveloper 오케스트레이터.
  트리거: "병렬 실험", "autodev parallel", "동시에 실험", "워크트리 실험"
  안티-트리거: "순차 실험", "하나씩"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDeveloper Parallel — 병렬 실험 오케스트레이터

여러 실험을 git worktree로 동시에 실행하고, 최고 결과를 선택한다.

## 핵심 개념

```
main (또는 현재 브랜치)
 │
 ├── worktree A ── Agent 1: 아이디어 1 실험
 ├── worktree B ── Agent 2: 아이디어 2 실험
 ├── worktree C ── Agent 3: 아이디어 3 실험
 │
 └── Orchestrator (이 스킬)
      - 아이디어 생성 & 배정
      - 결과 수집 & 비교
      - 최고 브랜치 선택
      - 다음 라운드 반복
```

## Phase 0: 설정 수집

사용자에게 확인:

```yaml
goal: "무엇을 달성할 것인가"
scope: ["수정 가능한 파일 패턴"]
metric: "판정 명령어"
parallel: 3                       # 동시 실행 수 (기본 3)
rounds: 5                         # 라운드 수 (기본 5, 총 실험 = parallel * rounds)
```

## Phase 1: 베이스라인

```bash
# 현재 상태에서 베이스라인 측정
mkdir -p .autodev
{metric_command} > .autodev/baseline.log 2>&1
bash ~/.claude/hooks/autodev-judge.sh
BASELINE_SCORE=$(cat .autodev-score)

# 결과 파일 초기화
echo -e "round\tagent\tcommit\tscore\tstatus\tdescription" > .autodev/results.tsv
```

## Phase 2: 라운드 루프

```
for round in 1..rounds:

  1. BRAINSTORM
     - scope 파일 분석 + goal 기반으로 {parallel}개 아이디어 생성
     - 이전 라운드 결과 참조 (keep된 것 위에 쌓기)
     - 아이디어는 서로 독립적이어야 함 (충돌 방지)

  2. LAUNCH (병렬)
     - {parallel}개의 Agent를 동시에 호출
     - 각 Agent는 isolation: "worktree"로 격리
     - 각 Agent에게 전달하는 프롬프트:

     """
     AutoDeveloper 단일 실험을 수행하라.

     Goal: {goal}
     Scope: {scope}
     Metric: {metric}
     Idea: {specific_idea}

     절차:
     1. scope 내 파일을 읽고 아이디어를 적용
     2. git commit -m "[autodev] {idea_summary}"
     3. {metric} 실행 → .autodev/run.log
     4. bash ~/.claude/hooks/autodev-judge.sh 실행
     5. 스코어를 최종 메시지로 반환:
        AUTODEV_RESULT: score={N}, commit={hash}, description="{desc}"

     빌드 실패 시 1회 복구 시도. 2회 실패 시 포기하고:
        AUTODEV_RESULT: score=-999, commit=none, description="{desc} (crash)"
     """

  3. COLLECT
     - 각 Agent 완료 대기
     - 결과에서 score 파싱
     - results.tsv에 기록

  4. SELECT
     - 최고 score Agent의 worktree/브랜치 식별
     - 최고 score > 현재 best_score 이면:
       - 해당 브랜치의 변경사항을 현재 브랜치에 cherry-pick
       - best_score 갱신
     - 나머지 worktree는 정리됨 (Agent tool이 자동 처리)

  5. REPORT (라운드별)
     라운드 {round}/{rounds} 완료:
     - Agent 1: score={n1} ({status1}) — {desc1}
     - Agent 2: score={n2} ({status2}) — {desc2}
     - 현재 best: score={best}

  6. CONTINUE
     다음 라운드로 (이전 best 위에 새 아이디어 적용)
```

## Phase 3: 최종 보고

```markdown
# AutoDev Parallel 실험 보고서

## 요약
- 총 라운드: {rounds}
- 총 실험: {rounds * parallel}회
- Keep: {K}회 / Discard: {D}회 / Crash: {C}회
- 베이스라인 → 최종: {baseline} → {best} ({improvement}%)

## 라운드별 결과
| 라운드 | 최고 실험 | 스코어 | 설명 |
|--------|----------|--------|------|
| 1 | Agent 2 | 85 | 캐시 레이어 추가 |
| 2 | Agent 1 | 120 | 쿼리 배칭 |
| ... | ... | ... | ... |

## 누적 Keep 변경사항
1. [commit1] 캐시 레이어 추가
2. [commit2] 쿼리 배칭

## 다음 단계 제안
- 추가 최적화 영역: ...
- main 머지 준비: `git merge autodev/{tag}`
```

## 병렬 수 가이드라인

| 상황 | 권장 parallel |
|------|--------------|
| 독립적 파일/모듈 | 5 (최대) |
| 같은 파일 내 변경 | 1-2 (충돌 위험) |
| 성능 벤치마크 포함 | 2-3 (리소스 공유) |
| 테스트만 판정 | 3-5 |

## 안전장치

1. **worktree 격리**: Agent tool의 isolation: "worktree" 사용. 서로 간섭 없음
2. **main 보호**: cherry-pick만 사용. force push 없음
3. **기존 테스트 보호**: 깨지면 무조건 discard
4. **리소스 제한**: parallel 수 초과 금지
5. **라운드 간 동기화**: 이전 라운드 best를 다음 라운드 base로 사용

## 기존 에이전트 활용 (선택)

TTH 팀원을 실험 에이전트로 활용 가능:

| 팀원 | 적합한 실험 유형 |
|------|----------------|
| pichai (아키텍트) | 구조적 변경, 모듈 분리 |
| jensen (백엔드) | API 최적화, DB 쿼리 개선 |
| zuckerberg (프론트엔드) | 컴포넌트 최적화, 번들 축소 |
| bezos (QA) | 코드 삭제, 불필요한 추상화 제거 |

프롬프트에 팀 역할 파일 경로를 포함하여 전문성 부여:
```
해당 팀원의 역할 파일을 읽고 그 관점에서 실험을 수행하라:
~/.claude/team-roles/{role}.md
```
