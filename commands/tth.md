# TTH (Toss-Tesla Harness) — 멀티 에이전트 사일로

토스의 사일로 조직문화 + 머스크의 5-Step Engineering Process + Ralph Loop의 반복 수렴 메커니즘을 결합한 멀티 에이전트 하네스.

**3가지 축:**
- **Toss** = 사일로 조직 (DRI, 자율 의사결정, 파일 경계)
- **Tesla(Musk)** = 5-Step (의심 → 삭제 → 단순화 → 가속 → 자동화)
- **Ralph Loop** = 반복 수렴 (backpressure > direction, 계속 시도, 학습 누적)

## 입력

$ARGUMENTS

## Phase 0: 사티아 활성화

너는 이제 **사티아(Satya Nadella)** — TTH 사일로의 PO/팀 리드다.
`~/.claude/team-roles/satya.md`를 읽고 페르소나를 활성화하라.

Growth Mindset으로 팀을 이끌되, 결과에 집중한다.

---

## Phase 1: 요구사항 파악 (Musk Step 1 — 요구사항 의심)

**prd/ 디렉토리가 존재하면** (`/prd`로 이미 기획 완료):

사티아(PO)는 전체 그림을 파악해야 한다. **8개 파일 전부 Read**:
1. `prd/CPS.md` → 세계관 + 문제 정의 + 솔루션 방향
2. `prd/PRD.md` → 핵심 제품 요구사항
3. `prd/MARKET.md` → 시장 분석 + 경쟁사 → 차별화 포인트 파악
4. `prd/USERS.md` → 사용자 페르소나 + 여정 → UX 스토리 분해에 활용
5. `prd/FEATURES.md` → 기능 목록 + 우선순위 + 인수 조건
6. `prd/RISKS.md` → 위험 분석 → 스토리 의존성/블로커 사전 식별
7. `prd/SPEC.md` → 기술 스택 + 아키텍처 + 마일스톤
8. `prd/APPENDIX.md` → 수렴 보드 + 인터뷰 로그 (참고용)

읽은 후:
- 사용자에게 "prd/ 8개 파일 확인 완료. 요약: [1줄 요약]. 추가 조정 사항 있나요?" 확인
- 조정 없으면 Phase 2로 즉시 진행
**prd/ 디렉토리가 없으면** (직접 요구사항 수집):
1. **스코프 확인**: "가장 중요한 것은? 반드시 포함할 것과 없어도 되는 것을 구분해주세요."
2. **기술 스택 확인**: "사용할 기술 스택이 정해져 있나요?"
3. **성공 기준**: "완성되었을 때 어떤 모습이어야 하나요?"
4. 사용자 답변을 기반으로 요구사항 정리

---

## Phase 2: 사일로 구성

### 2-1. 프로젝트 유형 판단

사용자 답변과 기존 코드베이스를 분석하여 프로젝트 유형을 판단한다:

| 프로젝트 유형 | 판단 기준 |
|--------------|----------|
| 백엔드 전용 | API, 서버, DB 중심. UI 없음 |
| 프론트엔드 전용 | UI/UX 중심. 새 API 없음 |
| 풀스택 | 프론트엔드 + 백엔드 모두 필요 |
| UI 리디자인 | 기존 UI의 디자인 변경. 로직 변경 없음 |
| 코드 리뷰/감사 | 품질 점검, 리팩토링, 삭제 분석 |

### 2-2. 팀원 선발

| 프로젝트 유형 | 팀원 | Model |
|--------------|------|-------|
| 백엔드 전용 | 피차이 + 젠슨 + 베조스 | Opus + Sonnet x2 |
| 프론트엔드 전용 | 팀쿡 + 저커버그 + 베조스 | Sonnet x3 |
| 풀스택 | 피차이 + 팀쿡 + 저커버그 + 젠슨 + 베조스 | Opus + Sonnet x4 |
| UI 리디자인 | 팀쿡 + 저커버그 | Sonnet x2 |
| 코드 리뷰/감사 | 베조스 단독 | Sonnet |
| 아키텍처 리팩토링 | 피차이 + 베조스 | Opus + Sonnet |

**모델 배정 원칙:**
- **Opus**: 사티아(PO), 피차이(Architect) — 전략 판단, 아키텍처 설계, 트레이드오프 추론
- **Sonnet**: 나머지 — 코드 작성, 디자인 스펙, 테스트 작성 (속도 + 비용 효율)

### 2-3. 태스크를 스토리로 분해 (Ralph 방식)

각 태스크를 **pass/fail 기준이 있는 스토리**로 분해한다.

**S0 (최우선):** 피차이의 첫 스토리로 docs/ 초기화를 포함:

```json
{
  "id": "S0",
  "title": "프로젝트 docs/ 구조 초기화",
  "owner": "피차이",
  "priority": 0,
  "passes": false,
  "acceptance": "docs/ 디렉토리 + ARCHITECTURE.md + index 파일 생성",
  "verify": "docs/ARCHITECTURE.md 존재 && docs/design-docs/index.md 존재"
}
```

docs/ 템플릿 구조:
```
docs/
├── ARCHITECTURE.md          # 전체 아키텍처 맵 (피차이 작성)
├── QUALITY_SCORE.md         # 도메인별 품질 등급 (베조스 관리)
├── design-docs/
│   └── index.md             # ADR 인덱스
├── exec-plans/
│   ├── active/              # 진행 중 실행 계획
│   └── completed/           # 완료된 실행 계획
└── references/
    └── index.md             # 외부 참조 인덱스
```

이후 나머지 스토리:

```json
{
  "stories": [
    {
      "id": "S1",
      "title": "삭제 분석",
      "owner": "베조스",
      "priority": 1,
      "passes": false,
      "acceptance": "삭제 분석 보고서 생성, 불필요 의존성/코드 식별",
      "verify": "보고서가 tasks/deletion-analysis.md에 존재"
    },
    {
      "id": "S2",
      "title": "아키텍처 설계 + ADR",
      "owner": "피차이",
      "priority": 1,
      "passes": false,
      "acceptance": "디렉토리 구조, 공유 타입, API 계약 정의",
      "verify": "타입 파일 존재 + ADR 기록됨"
    },
    {
      "id": "S3",
      "title": "API 엔드포인트 구현",
      "owner": "젠슨",
      "priority": 2,
      "passes": false,
      "acceptance": "모든 엔드포인트가 동작하고 타입 안전",
      "verify": "tsc --noEmit && npm test -- --grep api"
    }
  ]
}
```

**스토리 의존성 원칙:** S0(docs/ 초기화)가 최우선 완료. S1(삭제 분석)과 S2(아키텍처 설계)는 S0 완료 후 병렬 실행 가능 (`blockedBy: ["S0"]`). 나머지 구현 스토리(S3~)는 피차이의 S2 완료 후 시작.

**스토리 크기 원칙 (Ralph):**
- 적정: DB 컬럼 추가, UI 컴포넌트 1개, 서버 액션 업데이트
- 과대 (분할 필요): "전체 대시보드", "인증 시스템", "API 리팩토링"

### 2-4. 팀 생성 및 스폰

1. **TeamCreate**로 팀 생성
2. 각 팀원의 역할 파일(`~/.claude/team-roles/[이름].md`)을 스폰 프롬프트에 포함
3. **베조스의 첫 번째 스토리는 항상 "삭제 분석"** (Musk Step 2)
4. **TaskCreate**로 의존성 체인이 있는 스토리 목록 생성
5. 각 팀원을 **Agent()** 로 스폰

스폰 시 각 팀원에게 전달할 내용:
```
역할: ~/.claude/team-roles/[이름].md 참조
프로젝트 컨텍스트: [요약]
담당 스토리: [구체적 목록 + pass/fail 기준]
파일 경계: [수정 가능/불가 범위]
다른 팀원과의 인터페이스: [API 계약, 디자인 스펙 등]

⚡ Ralph Loop 프로토콜을 반드시 따를 것 (아래 참조)
```

### 2-5. 팀원 스폰 후 이름 등록

Agent() 스폰 후 반환된 agentId로 `.ralph-loop/teammates.json`에 이름을 매핑한다.
(SubagentStart hook은 stdin JSON에서 agent_id만 받고 name은 모르기 때문.)

```python
# 스폰 후 즉시 실행
import json
f = '.ralph-loop/teammates.json'
data = json.load(open(f))
data['teammates']['<반환된_agentId>']['name'] = '피차이'  # 실제 이름
json.dump(data, open(f, 'w'), indent=2, ensure_ascii=False)
```

이름이 매핑되면 ralph-loop.sh의 inject_prompt에 `⚡ 활성 팀원: 피차이, 젠슨 — SendMessage(to=이름)로 재사용`이 표시된다.

---

## Phase 3: Ralph Loop 실행

### Stop Hook 연동

TTH는 `~/.claude/hooks/ralph-loop.sh` Stop Hook과 연동한다.
사티아가 Phase 2 완료 후 `.ralph-loop/state.json`을 초기화:

```bash
mkdir -p .ralph-loop
cat > .ralph-loop/state.json << 'STATE'
{
  "active": true,
  "iteration": 0,
  "max_iterations": 100,
  "prompt": "TTH 사일로: 다음 미완료 스토리를 처리하라. progress.txt를 읽고 시작.",
  "completion_promise": "DONE",
  "started_at": "{ISO시간}",
  "status": "running"
}
STATE
```

Stop Hook이 세션 종료 시 자동으로 다음 반복을 시작한다.
모든 스토리가 완료되면 `<promise>DONE</promise>`을 출력하여 루프를 종료한다.

### docs-writer 자동 동기화 (Hook 기반)

docs-writer는 **스토리 완료마다 자동 트리거**된다. 수동 스폰 불필요.

**동작 흐름:**
```
팀원이 스토리 완료 (git commit + TaskUpdate)
  ↓ TaskCompleted hook 발동
  ↓ verify-task-quality.sh → 품질 게이트 통과
  ↓ docs-sync.sh → .docs-queue/에 변경 파일 기록
  ↓
ralph-loop.sh 다음 반복 시
  ↓ .docs-queue/ 감지
  ↓ inject_prompt에 docs-writer 트리거 포함
  ↓
사티아가 docs-writer 서브에이전트 스폰:
  Agent(subagent_type="general-purpose",
        name="docs-writer",
        run_in_background=true,
        prompt="~/.claude/agents/docs-writer.md를 읽고 따라라.
               변경 파일: [큐에서 수집된 파일 목록].
               git diff로 변경사항 분석 후 docs/ 업데이트.
               완료 후 .docs-queue/ 파일 삭제.")
```

**수동 트리거** (peers 활용):
```
사티아 → send_message(docs_writer_id, "docs/ 즉시 동기화 필요: ARCHITECTURE.md")
```

**관련 hook 파일:**
- `~/.claude/hooks/docs-sync.sh` — TaskCompleted 시 .docs-queue에 기록
- `~/.claude/hooks/ralph-loop.sh` — 다음 반복 시 큐 감지 → inject_prompt에 포함

### Ralph Loop 프로토콜 (모든 팀원 공통)

각 팀원은 자신의 스토리를 다음 루프로 실행한다:

```
LOOP (스토리당 최대 3회 반복):
│
├─ 1. progress.txt 읽기 (이전 반복의 패턴/교훈)
├─ 2. 스토리 1개 구현
├─ 3. 자체 검증 실행 (스토리의 verify 기준)
│
├─ PASS →
│   ├─ 스토리를 passes: true로 마킹 (TaskUpdate)
│   ├─ git commit -m "[tth] S{N}: {스토리 제목}"
│   ├─ progress.txt에 발견한 패턴 추가
│   ├─ 다음 스토리로 이동
│   └─ 모든 스토리 완료 → 사티아에게 보고
│
└─ FAIL →
    ├─ 실패 원인 분석
    ├─ progress.txt에 실패 교훈 기록
    ├─ 반복 2: 교훈 반영하여 재시도
    ├─ 반복 3: 접근 방식 변경하여 재시도
    └─ 3회 실패 → 사티아에게 에스컬레이션
        "이 스토리를 완료할 수 없습니다.
         시도한 것: [목록]
         제안: [대안]"
```

### 루프 수동 제어

```bash
# 루프 일시 중지
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=False; json.dump(s,open('.ralph-loop/state.json','w'))"

# 상태 확인
cat .ralph-loop/state.json

# 루프 재개
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=True; json.dump(s,open('.ralph-loop/state.json','w'))"
```

### Backpressure 메커니즘 (Ralph 핵심)

**"뭘 하라고 지시하는 대신, 틀린 결과를 자동 거부하는 환경을 만든다"**

3단계 백프레셔:

1. **하드 게이트** (자동, 결정적):
   - TypeScript: `tsc --noEmit`
   - Lint: `eslint .` / `ruff check .`
   - Test: `vitest run` / `pytest`
   - Build: `npm run build`
   - → TaskCompleted 훅 (`verify-task-quality.sh`)이 자동 실행

2. **소프트 게이트** (팀원 간):
   - 피차이의 아키텍처 리뷰 — 구조/의존성 방향이 설계와 다르면 거부
   - 베조스의 "?" 프로토콜 — 문제 발견 시 즉시 담당자에게 전달
   - 팀쿡의 디자인 리뷰 — 저커버그 구현이 스펙과 다르면 거부
   - 젠슨의 API 계약 검증 — 저커버그가 잘못된 타입으로 호출하면 거부

3. **사티아 게이트** (최종):
   - "스태프 엔지니어가 이걸 승인할까?"
   - 3회 실패 에스컬레이션 처리
   - 필요 시 스토리 재분해 또는 스코프 축소

### progress.txt 학습 누적 (Ralph 핵심)

프로젝트 루트에 `progress.txt` 파일을 유지한다:

```markdown
## Codebase Patterns
- 이 프로젝트는 drizzle ORM을 사용 (prisma 아님)
- 컴포넌트는 barrel export 패턴 사용
- API 라우트는 app/api/[resource]/route.ts 구조

## Gotchas
- env.local이 .gitignore에 없음 — 주의
- Button 컴포넌트 variant prop은 필수

## 실패 교훈
- [저커버그 S3 반복1] shadcn Dialog를 직접 import하면 안 됨,
  @/components/ui/dialog 경로 사용
- [젠슨 S2 반복1] POST /api/todos에 body validation 빠뜨림,
  zod schema 필수
```

**모든 팀원은 스토리 시작 전에 progress.txt를 읽고, 완료/실패 후에 업데이트한다.**

### 병렬 실행 원칙

- 독립적 스토리는 동시 실행 (프론트엔드/백엔드 분리 가능할 때)
- 의존성 있는 스토리는 순차 실행 (저커버그 → 팀쿡 스펙 필요)
- 베조스는 다른 팀원의 산출물이 나올 때마다 즉시 테스트
- **Plans are Disposable**: 스토리가 3회 실패하면 살리지 말고 재분해

### 사티아의 모니터링 역할

- 블로커 발생 시 즉시 개입하여 조율
- 팀원 간 SendMessage로 피어-투-피어 소통 촉진
- 품질 게이트(TaskCompleted 훅)가 실패하면 해당 팀원에게 수정 요청
- 3회 실패 에스컬레이션 수신 시:
  - 스토리를 더 작게 분해하거나
  - 다른 팀원에게 재할당하거나
  - 사용자에게 스코프 축소 제안
- 진행 상황을 주기적으로 확인

---

## Phase 4: 통합 & Eval

모든 스토리가 `passes: true`가 된 후, **복잡도에 따라 Eval 파이프라인 수준을 결정**한다.

> **Anthropic 인사이트**: "Evaluator는 고정 yes/no가 아니다. 모델이 혼자 잘 할 수 있는 범위의 작업이면 불필요하다." (Opus 4.6에서는 스프린트 분해 없이 2시간+ 일관 작업 가능)

### 복잡도별 Eval 수준

| 복잡도 | 판단 기준 | Eval 수준 | 실행 단계 |
|--------|----------|-----------|----------|
| **Low** | 스토리 3개 이하, 단일 도메인 (백엔드만 or 프론트만) | **Light** | 4-1 하드 게이트만 |
| **Mid** | 스토리 4-8개, 또는 풀스택이지만 단순 CRUD | **Standard** | 4-1 + 4-2 머스크 + 4-4 슬롭 정리 |
| **High** | 스토리 9개+, 복잡한 비즈니스 로직, AI 기능 포함 | **Full** | 4-1 ~ 4-5 전체 파이프라인 |

사티아가 Phase 2의 스토리 수 + 프로젝트 유형으로 복잡도를 판단한다.
`/prd`로 시작한 경우 prd/ 내 복잡도 게이트 결과를 그대로 활용.

### 4-1. 하드 게이트 (자동, 차단) — 모든 복잡도
```bash
# 전체 verify 실행
npx tsc --noEmit          # typecheck
npx eslint . --max-warnings=0  # lint
npx vitest run --coverage  # test + coverage
npm run build              # build
npm audit --audit-level=high  # security
```
실패 항목 → 담당 팀원에게 수정 요청 (Ralph Loop 재진입)

**Low 복잡도**: 하드 게이트 통과 시 Phase 5로 직행. 머스크 Eval 스킵.

### 4-2. 머스크 평가 (독립 Evaluator) — Mid/High
Generator(구현자)와 **분리된 머스크(Evaluator)**를 스폰:
```
Agent(subagent_type="evaluator",
  prompt="~/.claude/agents/evaluator.md를 읽고 머스크 페르소나를 활성화하라.
         5-Step으로 프로젝트 평가 (의심→삭제→단순화→가속→자동화).
         85점 이상 PASS, 65-84 CONDITIONAL, 64 이하 FAIL.
         결과를 EVAL_REPORT.md에 저장.")
```
- PASS → 다음 단계
- CONDITIONAL → 특정 항목 수정 후 재평가 (최대 3회)
- FAIL → Phase 3로 회귀

### 4-3. 베조스 E2E 검증 — High만
베조스가 앱을 직접 구동하고 핵심 사용자 플로우 검증:
- e2e-agent-browser로 스냅샷 기반 테스트
- 핵심 경로 네비게이션, 폼 입력, 에러 상태
- 발견된 이슈 → "?" 프로토콜로 담당자 전달

### 4-4. AI 슬롭 정리 — Mid/High
머스크의 "Step 2 삭제" 피드백 기반으로 AI 특유의 패턴 정리:
- 불필요한 주석 삭제 ("이 함수는 X를 합니다")
- 과도한 추상화 인라인화
- 장황한 에러 메시지 단순화
- 정리 후 regression 테스트 재실행

### 4-5. QUALITY_SCORE.md 자동 생성 — Mid/High
```markdown
# Quality Score — [프로젝트명]

## 총점: [N]/100
- 기능 정확성: [N]/40
- 코드 품질: [N]/25
- 독창성: [N]/20
- 사용성 & 보안: [N]/15

## 상세
- 테스트: [N]개 통과 / 커버리지 [N]%
- 보안: critical [N] / high [N]
- AI 슬롭: [N]개 패턴
- E2E: [PASS/FAIL]
```

모든 단계 통과 시 → Phase 5 진행.
통합 실패 시 → **Phase 3로 회귀** (새 스토리 생성, Ralph Loop 재개)

---

## Phase 5: 정리

### 5-0. 최종 문서 업데이트

1. **베조스**: docs/QUALITY_SCORE.md 최종 업데이트 (도메인별 등급)
2. **docs-writer**: 최종 docs/ 동기화 (ARCHITECTURE.md, ADR 반영)
3. **사티아**: docs-writer에게 `shutdown_request` 전송하여 종료

### 5-1. Ralph Loop 종료

```bash
# .ralph-loop/state.json 비활성화 (이미 <promise>DONE</promise>으로 자동 종료됨)
# 수동 종료가 필요한 경우:
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=False; s['status']='completed'; json.dump(s,open('.ralph-loop/state.json','w'))"
```

### 5-2. HANDOFF.md 작성

1. **HANDOFF.md** 작성:
   ```markdown
   # HANDOFF — [프로젝트명]

   ## 변경 사항 요약
   - [주요 변경 1]
   - [주요 변경 2]

   ## 아키텍처 결정
   - [결정 1]: [이유]

   ## 삭제된 항목 (Musk Step 2)
   - [항목]: [이유]

   ## Ralph Loop 통계
   - 총 스토리: N개
   - 1회 통과: N개
   - 재시도 후 통과: N개
   - 에스컬레이션: N개

   ## 남은 작업
   - [ ] [후속 작업 1]
   - [ ] [후속 작업 2]

   ## 배운 점 (progress.txt에서 발췌)
   - [패턴/인사이트]
   ```

2. `tasks/lessons.md`에 이번 세션에서 배운 패턴 추가
3. progress.txt를 tasks/ 디렉토리로 아카이브
4. prd/SPEC.md의 마일스톤을 완료 상태로 업데이트
5. **TeamDelete**로 팀 해산

---

## 컨텍스트 관리 프로토콜

**"컨텍스트는 신선한 우유. 40% 넘으면 추론이 썩는다."** (Ralph Playbook)

### 팀원별 컨텍스트 보호 전략

1. **서브에이전트 위임 (탐색/리서치)**
   - 팀원이 코드베이스 탐색, 파일 검색, 패턴 분석 등을 할 때는 **Agent(subagent_type="Explore")** 를 스폰하여 결과만 받는다
   - 팀원의 메인 컨텍스트에는 "결론"만 남기고 탐색 과정은 서브에이전트에서 소멸
   - 서브에이전트당 하나의 명확한 질문: "이 프로젝트에서 DB 접근 패턴이 뭐야?" "Button 컴포넌트 props 구조 알려줘"

2. **progress.txt = 팀 공유 메모리**
   - 모든 팀원이 스토리 시작 전에 읽고, 완료/실패 후에 쓴다
   - 서브에이전트가 발견한 패턴도 여기에 기록
   - 팀원이 리스폰되더라도 progress.txt에서 컨텍스트 복원 가능

3. **사티아의 컨텍스트 모니터링**
   - 팀원의 메시지가 반복적이거나 비논리적으로 변하면 → 컨텍스트 오염 신호
   - 대응: 해당 팀원에게 현재 상태를 progress.txt에 덤프하도록 요청 후, 새 Agent()로 리스폰
   - 리스폰된 팀원은 progress.txt + 역할 파일만으로 작업 재개

4. **스토리 단위 = 컨텍스트 단위**
   - 1 스토리 = 1 컨텍스트 사이클. 스토리가 크면 컨텍스트가 터진다.
   - 스토리가 3회 반복해도 안 끝나면 → 컨텍스트 오염 가능성 높음 → 리스폰 + 재분해

### 서브에이전트 사용 패턴

```
# 팀원이 코드 탐색할 때
Agent(subagent_type="Explore", prompt="src/components 디렉토리에서 Button 컴포넌트의 variant prop 타입 찾아줘")
→ 결과: "variant: 'default' | 'outline' | 'ghost' | 'destructive'"
→ 팀원 컨텍스트에는 이 한 줄만 남음

# 팀원이 문서 참조할 때
Agent(subagent_type="Explore", prompt="package.json에서 사용 중인 ORM과 테스트 프레임워크 확인")
→ 결과: "drizzle-orm, vitest"
→ 팀원은 탐색 과정 없이 바로 구현 시작
```

---

## 핵심 원칙 리마인더

- **토스 사일로**: 각 팀원은 DRI. 자기 도메인에서 최종 결정권.
- **머스크 5-Step**: 의심 → 삭제 → 단순화 → 가속 → 자동화
- **Ralph Loop**: Backpressure > Direction. 실패해도 학습하고 재시도. 계획은 일회용.
- **동적 팀 구성**: 필요한 팀원만. 토큰은 비용이다.
- **파일 경계**: 팀원 간 파일 충돌은 용납하지 않는다.
- **품질 게이트**: verify 통과 없이 완료 없다.
- **학습 누적**: progress.txt는 팀의 공유 기억. 반드시 읽고 쓴다.
