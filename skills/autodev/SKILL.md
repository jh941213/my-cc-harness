---
name: autodev
description: >
  자율 코드 실험 루프. AI 에이전트가 코드를 수정하고, 검증하고, keep/discard를 반복하며 자율적으로 개선한다.
  Karpathy의 autoresearch 패턴을 일반 소프트웨어 개발에 적용.
  트리거: "autodev", "자율 개발", "자율 실험", "밤새 돌려", "실험 루프", "자동 최적화"
  안티-트리거: "직접 구현해", "한번만 해", "수동"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDeveloper — 자율 코드 실험 루프

autoresearch 패턴: 코드 수정 → 검증 → keep/discard → 반복.
사람이 자는 동안 에이전트가 수십 번의 실험을 자율적으로 수행한다.

## Phase 0: 설정 수집

사용자에게 다음을 확인한다 (빠진 것만 질문):

```yaml
goal: "무엇을 달성할 것인가"      # 예: "API 응답시간 50% 단축"
scope: ["수정 가능한 파일 패턴"]    # 예: ["src/api/**", "src/utils/**"]
metric: "판정 명령어"              # 예: "npm test" 또는 "npm run bench"
budget: 20                        # 최대 실험 횟수 (기본 20)
mode: "single"                    # single | parallel (기본 single)
```

### metric 자동 감지

사용자가 metric을 안 줬으면 프로젝트를 분석해서 자동 설정:
1. `package.json` → `npm test` 또는 `vitest run` 또는 `jest`
2. `pyproject.toml` → `pytest`
3. `Makefile` → `make test`
4. 벤치마크 스크립트 존재 시 → 해당 명령어 제안

## Phase 1: 베이스라인 수립

실험 시작 전 현재 상태를 기록한다:

```bash
# 1. 현재 브랜치에서 autodev 브랜치 생성
git checkout -b autodev/$(date +%Y%m%d-%H%M)

# 2. 베이스라인 검증 실행
{metric_command} > .autodev/baseline.log 2>&1

# 3. 베이스라인 스코어 추출
bash ~/.claude/hooks/autodev-judge.sh

# 4. results.tsv 초기화
echo -e "experiment\tcommit\tscore\tstatus\tdescription" > .autodev/results.tsv
```

### .autodev/ 디렉토리 구조

```
.autodev/
  results.tsv      # 실험 결과 로그 (autoresearch의 results.tsv)
  baseline.log     # 베이스라인 실행 로그
  run.log          # 현재 실험 실행 로그
  ideas.md         # 시도할 아이디어 목록
```

`.gitignore`에 `.autodev/`를 추가한다.

## Phase 2: 아이디어 생성

scope 내 파일들을 읽고 goal에 맞는 개선 아이디어 목록을 만든다.

`.autodev/ideas.md`에 기록:

```markdown
# 실험 아이디어

## 시도 대기
- [ ] 아이디어 1: 설명
- [ ] 아이디어 2: 설명
...

## 완료
- [x] 아이디어 N: 설명 → keep (score: 85)
- [x] 아이디어 M: 설명 → discard (score: 40)
```

아이디어가 바닥나면:
1. 기존 keep된 변경들을 조합해본다
2. scope 파일을 다시 읽고 새 각도를 찾는다
3. keep된 코드를 simplify 해본다

## Phase 3: 실험 루프 (LOOP)

**NEVER STOP**: budget 소진 전까지 절대 멈추지 않는다. 질문하지 않는다.

```
LOOP (experiment = 1 to budget):

  1. SNAPSHOT
     git_snapshot=$(git rev-parse HEAD)

  2. MODIFY
     - ideas.md에서 다음 아이디어 선택
     - scope 내 파일만 수정
     - scope 밖 파일 수정 금지

  3. COMMIT
     git add -A
     git commit -m "[autodev] exp-{N}: {description}"

  4. VERIFY
     {metric_command} > .autodev/run.log 2>&1
     EXIT_CODE=$?

  5. SCORE
     bash ~/.claude/hooks/autodev-judge.sh
     SCORE=$(cat .autodev-score)

  6. JUDGE
     if SCORE == -999:
       # CRASH — 복구 시도
       build-fix skill 1회 적용
       재실행 → 여전히 실패 시 DISCARD
     elif SCORE > BEST_SCORE:
       # KEEP — 브랜치 전진
       BEST_SCORE = SCORE
       STATUS = "keep"
     else:
       # DISCARD — 롤백
       git reset --hard $git_snapshot
       STATUS = "discard"

  7. LOG
     results.tsv에 한 줄 추가:
     {experiment}\t{commit}\t{SCORE}\t{STATUS}\t{description}

     ideas.md 업데이트 (체크 표시 + 결과)

  8. CONTINUE
     다음 아이디어로 진행
```

## 판정 함수 (score 계산)

`~/.claude/hooks/autodev-judge.sh`가 스코어를 계산한다.
스코어 기준:

| 조건 | 점수 |
|------|------|
| 빌드 실패 | -999 (즉시 discard) |
| 기존 테스트 깨짐 | -999 (즉시 discard) |
| 테스트 전체 통과 | +100 |
| 새 테스트 통과 수 | +10/개 |
| 타입 에러 0개 | +50 |
| 린트 에러 0개 | +20 |
| 성능 개선 (있으면) | +200 |
| 코드 줄 수 감소 | +0.1/줄 (단순함 보너스) |

## Phase 4: 완료 보고

budget 소진 또는 goal 달성 시:

```markdown
# AutoDev 실험 보고서

## 요약
- 총 실험: {N}회
- Keep: {K}회 / Discard: {D}회 / Crash: {C}회
- 베이스라인 스코어: {baseline}
- 최종 스코어: {best}
- 개선율: {improvement}%

## Keep된 실험들
| # | 설명 | 스코어 변화 |
|---|------|-----------|
| 3 | 캐시 레이어 추가 | 45 → 85 |
| 7 | 쿼리 배칭 | 85 → 120 |

## 최종 브랜치
autodev/{tag} — main에 머지 준비 완료

## 상세 로그
.autodev/results.tsv 참조
```

## 안전장치

1. **scope 밖 수정 금지**: scope에 명시된 파일/디렉토리만 수정
2. **기존 테스트 보호**: 기존 테스트가 깨지면 무조건 discard
3. **crash 복구 제한**: build-fix 1회만 시도. 2회 이상 실패 시 포기
4. **git 안전**: 모든 실험은 autodev/ 브랜치에서만. main 절대 안 건드림
5. **.autodev/ 추적 안함**: .gitignore에 추가

## 기존 스킬 활용

| 상황 | 사용 스킬 |
|------|----------|
| 빌드 실패 시 복구 | `build-fix` |
| keep 후 코드 정리 | `simplify` |
| 테스트 기반 실험 | `tdd` |
| 실험 아이디어 생성 | `plan` (planner agent) |
| 최종 검증 | `verify` |
