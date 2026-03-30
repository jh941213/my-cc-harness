# 전체 검증 — verify + e2e-verify + simplify 통합 파이프라인

코드 검증 → E2E 브라우저 테스트(agent-browser) → AI 슬롭 정리를 한 번에 실행합니다.
3개 커맨드를 올바른 순서와 병렬성으로 오케스트레이션.

입력: $ARGUMENTS

## 실행 방식

### 인자 없이: `/full-verify`
- 전체 파이프라인 실행

### 특정 단계 스킵: `/full-verify skip-e2e`, `/full-verify skip-simplify`
- 해당 단계를 건너뜀

### E2E만: `/full-verify e2e-only`
- verify 통과 가정, E2E만 실행

---

## 파이프라인 구조

```
Phase 1: /verify (순차, 블로킹)
  typecheck → lint → test → build → security
  ↓ 통과

Phase 2: /e2e-verify + /simplify (병렬)
  ┌─ Agent A: E2E 검증 (agent-browser)
  │   open → snapshot -i → fill/click → wait → 검증
  │
  └─ Agent B: 코드 단순화
      슬롭 제거 → 추상화 인라인 → 중복 제거

  ↓ 둘 다 완료

Phase 3: /verify (최종 확인, 순차)
  simplify가 코드를 수정했으므로 회귀 검증
  ↓ 통과

결과 보고
```

## Phase 1: 코드 검증 (/verify)

먼저 기본 코드 품질을 확인한다. 이 단계를 통과해야 E2E와 단순화를 진행.

```bash
# 프로젝트 감지
[ -f package.json ] && echo "NODE"
[ -f pyproject.toml ] && echo "PYTHON"

# 순차 실행
npx tsc --noEmit          # typecheck
npx eslint . --max-warnings=0  # lint
npx vitest run             # test
npm run build              # build
```

- 실패 시: 에러 수정 → 재실행 (단계당 최대 3회)
- 3회 실패 시: 사용자에게 에스컬레이션, 파이프라인 중단
- **통과 시: Phase 2로 즉시 진행**

## Phase 2: E2E + Simplify 병렬 실행

Phase 1 통과 후, **두 개의 서브에이전트를 병렬 스폰**:

```
Agent A — E2E 검증:
  Agent(subagent_type="general-purpose",
    name="e2e-verifier",
    run_in_background=true,
    prompt="다음 단계로 E2E 테스트를 실행하라:

    1. agent-browser 설치 확인 (which agent-browser)
    2. 앱 백그라운드 실행 (npm run dev &)
    3. 앱 준비 대기 (curl 30초 폴링)
    4. 변경된 피처의 사용자 플로우 분석
    5. e2e/ 디렉토리에 테스트 스크립트 작성:
       - agent-browser open → snapshot -i → ref 확인
       - fill/click으로 인터랙션
       - wait text/url로 결과 검증
    6. bash e2e/runner.sh로 전체 실행
    7. 실패 시: screenshot 캡처 → 코드 수정 → 재실행 (최대 3회)
    8. 결과를 E2E_RESULT.md에 저장

    agent-browser 핵심 명령어:
    - open <url>: 페이지 열기
    - snapshot -i: 인터랙티브 요소 + ref 번호
    - click @ref: 클릭
    - fill @ref 'text': 입력
    - wait text 'msg': 텍스트 대기
    - wait url '**/path': URL 대기
    - screenshot ./path.png: 스크린샷
    - close: 브라우저 닫기

    테스트 스크립트 구조:
    #!/bin/bash
    set -e
    cleanup() { agent-browser close 2>/dev/null || true; }
    trap cleanup EXIT
    agent-browser open http://localhost:3000
    agent-browser snapshot -i
    # ... 인터랙션 + 검증
    echo 'PASS: [테스트명]'
    ")

Agent B — 코드 단순화:
  Agent(subagent_type="general-purpose",
    name="simplifier",
    run_in_background=true,
    prompt="다음 단계로 코드를 단순화하라:

    1. git diff --name-only HEAD~5..HEAD로 변경 파일 확인
    2. 각 파일 Read
    3. AI 슬롭 패턴 제거:
       - 자명한 주석 삭제 ('이 함수는 X를 합니다')
       - 1회 사용 헬퍼 인라인화
       - 장황한 에러 메시지 단순화
       - 불필요한 null 체크 제거 (타입 시스템이 보장하는 것)
       - 추론 가능한 타입 어노테이션 제거
    4. 구조적 단순화:
       - 깊은 중첩 → 얼리 리턴
       - 사용하지 않는 import/export 제거
       - console.log 제거
    5. 수정 후 npx tsc --noEmit로 타입 안전 확인
    6. 결과를 SIMPLIFY_RESULT.md에 저장
    ")
```

**두 에이전트가 모두 완료될 때까지 대기.**

## Phase 3: 최종 검증 (/verify 재실행)

simplify가 소스 코드를 수정했으므로, 회귀가 없는지 최종 확인:

```bash
npx tsc --noEmit
npx eslint . --max-warnings=0
npx vitest run
npm run build
```

- 실패 시: simplify가 도입한 회귀 → 수정 → 재실행
- 통과 시: 전체 파이프라인 완료

## 결과 보고

모든 Phase 완료 후 통합 리포트 생성:

```
## Full Verify 결과

### Phase 1: 코드 검증
| 단계 | 상태 |
|------|------|
| typecheck | PASS |
| lint | PASS |
| test | 42 passed |
| build | 성공 |

### Phase 2a: E2E 검증 (agent-browser)
| 테스트 | 상태 |
|--------|------|
| test_login.sh | PASS |
| test_dashboard.sh | PASS |

### Phase 2b: 코드 단순화
- 자명한 주석 8개 삭제
- 헬퍼 2개 인라인화
- unused import 5개 제거

### Phase 3: 최종 검증
| 단계 | 상태 |
|------|------|
| typecheck | PASS |
| lint | PASS |
| test | 42 passed |
| build | 성공 |

✅ 전체 파이프라인 통과
```

**E2E_RESULT.md, SIMPLIFY_RESULT.md** 임시 파일은 보고 후 삭제.

## TTH 연동

TTH Phase 4에서 사티아가 이 커맨드를 호출:

```
사티아 → Agent(prompt="/full-verify 실행") → 전체 파이프라인 자동 실행
```

또는 개별 호출도 가능:
```
사티아 → Agent(prompt="/verify") → 통과 확인
      → Agent(prompt="/e2e-verify", run_in_background=true)
      → Agent(prompt="/simplify", run_in_background=true)
      → Agent(prompt="/verify") → 최종 확인
```

## 원칙

- Phase 1 실패 시 Phase 2 진입 금지 (빌드 안 되면 E2E도 불가)
- Phase 2의 두 에이전트는 반드시 병렬 (독립적 작업)
- Phase 3는 simplify 수정에 대한 회귀 검증 — 생략 금지
- agent-browser는 스냅샷+ref 패턴 사용 (CSS 셀렉터 하드코딩 금지)
- 각 단계 최대 3회 재시도, 초과 시 사용자 에스컬레이션
