---
name: autodev
description: >
  Ralph Loop 기반 자율 개발 루프. Stop Hook이 세션 종료를 가로채어 PRD 항목을 하나씩 완료하며 자동 커밋한다.
  트리거: "autodev", "자율 개발", "밤새 돌려", "랄프 루프", "ralph loop", "자동 개발"
  안티-트리거: "직접 구현해", "한번만 해", "수동"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDev — Ralph Loop 자율 개발

Stop Hook 기반 자율 개발 루프. PRD/체크리스트의 항목을 하나씩 완료하고 자동 커밋한다.
밤새 돌려놓으면 출근 시 PR이 올라와 있다.

## 핵심 원리

```
세션 시작 → PRD 읽기 → 다음 항목 처리 → 커밋 → 세션 종료
                                                    ↓
                                            Stop Hook 감지
                                                    ↓
                                        완료? → Yes → 종료
                                          ↓ No
                                   inject_prompt → 새 세션 시작
                                                    ↓
                                              PRD 읽기 → ...
```

## Phase 0: 설정 수집

사용자에게 확인 (빠진 것만 질문):

```yaml
goal: "무엇을 달성할 것인가"           # 예: "PRD.md의 모든 항목 완료"
prd: "PRD 또는 체크리스트 파일 경로"    # 예: "PRD.md" 또는 "tasks/todo.md"
scope: ["수정 가능한 파일 패턴"]        # 예: ["src/**", "tests/**"]
verify: "검증 명령어"                  # 예: "npm test" (자동 감지 가능)
max_iterations: 100                   # 최대 반복 수 (기본 100)
completion_promise: "DONE"            # 완료 시그널 (기본 "DONE")
mode: "continue"                      # continue | reset (기본 continue)
```

### verify 자동 감지

사용자가 verify를 안 줬으면:
1. `package.json` → `npm test` 또는 `vitest run`
2. `pyproject.toml` → `pytest`
3. `Makefile` → `make test`
4. 없으면 → `echo "no verify command"`

## Phase 1: 루프 초기화

```bash
# 1. autodev 브랜치 생성
git checkout -b autodev/$(date +%Y%m%d-%H%M)

# 2. .ralph-loop/ 상태 디렉토리 생성
mkdir -p .ralph-loop

# 3. 상태 파일 초기화
cat > .ralph-loop/state.json << 'STATE'
{
  "active": true,
  "iteration": 0,
  "max_iterations": {max_iterations},
  "prompt": "{goal}",
  "completion_promise": "{completion_promise}",
  "prd_path": "{prd}",
  "verify_command": "{verify}",
  "started_at": "{ISO시간}",
  "status": "running"
}
STATE

# 4. .gitignore에 .ralph-loop/ 추가
echo ".ralph-loop/" >> .gitignore

# 5. 베이스라인 검증
{verify} 2>&1 | tee .ralph-loop/baseline.log
```

## Phase 2: 반복 실행 (매 세션)

각 세션(반복)에서 수행하는 절차:

```
1. READ PRD
   - {prd} 파일을 읽는다
   - 미완료 항목([ ]) 중 첫 번째를 선택

2. PLAN
   - 선택한 항목을 구현하기 위한 최소 변경 계획
   - scope 내 파일만 수정 가능

3. IMPLEMENT
   - 계획대로 코드 수정
   - scope 밖 파일 절대 수정 금지

4. VERIFY
   - {verify} 실행
   - 실패 시 build-fix 1회 시도
   - 2회 실패 시 변경 롤백 (git checkout -- .)

5. COMMIT
   - 성공 시:
     git add -A
     git commit -m "[autodev] {항목 요약}"
   - PRD에서 해당 항목을 [x]로 체크

6. CHECK COMPLETION
   - PRD에 미완료 항목이 남아있는가?
   - Yes → 세션 자연 종료 (Stop Hook이 다음 반복 시작)
   - No → 모든 항목 완료!
     <promise>{completion_promise}</promise> 출력
     → Stop Hook이 감지하고 루프 종료
```

## Phase 3: 완료 보고

루프 종료 시 (완료 또는 max_iterations 도달):

```markdown
# AutoDev 완료 보고서

## 요약
- 총 반복: {N}회
- 완료 항목: {K}/{total}
- 베이스라인 → 최종: 검증 통과
- 상태: {completed | max_iterations_reached}

## 완료된 항목
| # | 항목 | 커밋 |
|---|------|------|
| 1 | API 엔드포인트 구현 | abc1234 |
| 2 | 인증 추가 | def5678 |

## 미완료 항목 (있으면)
- [ ] 항목 N: 이유

## 브랜치
autodev/{tag} — main 머지 준비 완료
```

## 안전장치

1. **scope 밖 수정 금지**: scope에 명시된 파일/디렉토리만 수정
2. **기존 테스트 보호**: verify 실패 시 변경 롤백
3. **crash 복구 제한**: build-fix 1회만. 2회 실패 시 해당 항목 스킵
4. **git 안전**: autodev/ 브랜치에서만 작업. main 절대 안 건드림
5. **max_iterations**: 무한 루프 방지 (기본 100)
6. **비용 인식**: 각 반복은 토큰 비용 발생. 반복 수를 합리적으로 설정

## Stop Hook 동작

`~/.claude/hooks/ralph-loop.sh`가 세션 종료 시 실행:

- `.ralph-loop/state.json`의 `active`가 `true`이면 다음 반복 시작
- 트랜스크립트에서 `<promise>DONE</promise>` 감지 시 루프 종료
- `iteration >= max_iterations` 시 루프 종료
- 상태가 없거나 `active: false`이면 아무 동작 없음

## 수동 제어

```bash
# 루프 중지
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=False; json.dump(s,open('.ralph-loop/state.json','w'))"

# 상태 확인
cat .ralph-loop/state.json

# 루프 재개
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=True; json.dump(s,open('.ralph-loop/state.json','w'))"
```

## 기존 스킬 활용

| 상황 | 사용 스킬 |
|------|----------|
| 빌드 실패 시 복구 | `build-fix` |
| 커밋 후 코드 정리 | `simplify` |
| 테스트 기반 구현 | `tdd` |
| 항목 구현 계획 | `plan` |
| 최종 검증 | `verify` |
