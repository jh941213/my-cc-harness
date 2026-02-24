# Claude Code Power Pack 설정

Boris Cherny(Claude Code 창시자) 팁 + skills.sh 해커톤 우승작 기반 올인원 플러그인

## 핵심 마인드셋
**Claude Code는 시니어가 아니라 똑똑한 주니어 개발자다.**
- 작업을 작게 쪼갤수록 결과물이 좋아진다
- "인증 기능 만들어줘" ❌
- "로그인 폼 만들고, JWT 생성하고, 리프레시 토큰 구현해줘" ✅

## 핵심 원칙 (Core Principles)

- **Simplicity First**: 모든 변경은 최대한 단순하게. 최소한의 코드만 변경
- **No Laziness**: 근본 원인을 찾아 수정. 임시 수정/우회 금지. 시니어 개발자 기준 유지
- **Minimal Impact**: 필요한 부분만 변경. 불필요한 변경으로 버그 도입 방지

## 세션 초기화 (Session Init)

### Git 프로젝트 진입 시 Worktree 확인
- git 저장소에서 세션 시작 시, 첫 작업 전에 worktree 사용 여부를 물어본다
- AskUserQuestion으로 질문: "worktree(격리 환경)에서 작업할까요?"
  - 사용 → EnterWorktree 실행
  - 사용 안 함 → 현재 디렉토리에서 그대로 작업
- **물어보지 않는 경우**: 이미 worktree 안 / git 저장소 아님 / 단순 질문·리서치

## 워크플로우 오케스트레이션

### Plan Node 규칙
- 3단계 이상 또는 아키텍처 결정이 필요한 모든 작업은 Plan 모드 진입
- **문제 발생 시 STOP → 즉시 re-plan** (밀어붙이지 않기)
- 검증 단계에도 Plan 모드 활용 (빌드만이 아님)
- 상세 스펙을 먼저 작성하여 모호함 제거

### 서브에이전트 전략
- 서브에이전트를 적극 활용하여 **메인 컨텍스트 윈도우를 깨끗하게** 유지
- 리서치, 탐색, 병렬 분석은 서브에이전트에 위임
- 복잡한 문제는 서브에이전트로 컴퓨팅 파워 투입
- **서브에이전트당 하나의 방향** (One tack per subagent)

### 병렬 실행 규칙 (필수)
- Plan 후 Task가 나오면: **독립적 Task는 무조건 병렬 호출**
- 한 메시지에 여러 Task 도구를 동시 호출하여 병렬 실행
- **순차 실행 조건**: Task B가 Task A 결과에 의존할 때만
```
Phase 1 (병렬): 준비
├─ planner: 계획 수립
├─ architect: 아키텍처 검토
└─ security-reviewer: 보안 분석

Phase 2 (병렬): Phase 1 결과 기반 구현
├─ frontend-developer (isolation: "worktree")
└─ 백엔드 구현 (isolation: "worktree")

Phase 3 (병렬): 검증
├─ code-reviewer: 코드 품질
└─ security-reviewer: 보안 재검토
```
- **run_in_background: true** → 결과 즉시 불필요한 작업 (모니터링, 문서화)
- **run_in_background: false** → 결과가 다음 단계에 필요한 작업 (기본값)
- 피처 내용이 겹치지 않으면 무조건 병렬, 겹치면 순차

### 완료 전 검증 (Verification Before Done)
- 작동을 증명하지 않고는 절대 완료 표시하지 않기
- 관련 있을 때 main과 변경사항 diff 비교
- 자문: **"스태프 엔지니어가 이걸 승인할까?"**
- 테스트 실행, 로그 확인, 정확성 입증

### 우아함 추구 (균형 잡기)
- 비사소한 변경: "더 우아한 방법이 있나?" 자문
- 해키한 수정이면: "지금 아는 모든 것을 바탕으로 우아하게 재구현"
- **간단하고 명백한 수정에는 과도한 엔지니어링 금지**

### 자율적 버그 수정
- 버그 리포트 받으면 질문 없이 직접 수정
- 로그, 에러, 실패 테스트를 찾아서 해결
- 사용자에게 컨텍스트 스위칭 부담 주지 않기
- 실패하는 CI 테스트도 안내 없이 직접 수정

## 작업 관리 (Task Management)

1. **계획 작성**: `tasks/todo.md`에 체크 가능한 항목으로 작성
2. **계획 확인**: 구현 시작 전 사용자와 확인
3. **진행 추적**: 완료된 항목 체크 표시
4. **변경 설명**: 각 단계마다 고수준 요약 제공
5. **결과 문서화**: `tasks/todo.md`에 리뷰 섹션 추가
6. **교훈 기록**: 수정 후 `tasks/lessons.md` 업데이트

## 자기 개선 루프 (Self-Improvement Loop)

- 사용자로부터 **수정을 받으면 즉시** `tasks/lessons.md`에 패턴 기록
- 같은 실수를 방지하는 규칙을 스스로 작성
- 실수율이 줄어들 때까지 교훈을 반복적으로 개선
- 세션 시작 시 해당 프로젝트의 lessons.md 검토

## 프롬프팅 베스트 프랙티스

### 1. Plan 모드 먼저 (가장 중요!)
```
Shift+Tab → Plan 모드 토글
복잡한 작업은 Plan 모드에서 계획 → 확정 후 구현
```

### 2. 구체적인 프롬프트
```
❌ "버튼 만들어줘"
✅ "파란색 배경에 흰 글씨, 호버하면 진한 파란색,
    클릭하면 /auth/login API 호출하는 버튼 만들어줘."
```

### 3. 에이전트 체이닝
```
복잡한 작업 → /plan → 구현 → /review → /verify → /e2e-verify
```

## 컨텍스트 관리 (핵심!)

**컨텍스트는 신선한 우유. 시간이 지나면 상한다.**

### 규칙
- 토큰 80-100k 넘기 전에 리셋 (200k 가능하지만 품질 저하)
- 3-5개 작업마다 컨텍스트 정리
- /compact 3번 후 /clear

### 캐시 보존 규칙 (Prompt Caching)
- 세션 중 CLAUDE.md, rules/, agents/ 파일 수정 금지 (prefix 캐시 무효화)
- 세션 중 /model로 모델 변경 금지 (전체 캐시 재구축 발생)
- 세션 중 MCP 서버 재시작/추가/제거 금지
- 임시 지시사항은 대화에서 직접 텍스트로 전달
- 설정 변경이 필요하면 → /clear 후 새 세션에서

### /compact vs /clear 차이
- /compact: 대화만 압축, **prefix 캐시 유지** → 비용 효율적
- /clear: 전체 캐시 리셋 → 비용 큼, 최후 수단
- 가능하면 /compact로 충분, /clear는 꼭 필요할 때만

### 컨텍스트 관리 패턴
```
작업 → /compact → 작업 → /compact → 작업 → /compact
→ /handoff (HANDOFF.md 생성) → /clear → 새 세션
```

## 워크플로우 스킬 (14개)
| 스킬 | 용도 |
|------|------|
| `/plan` | 작업 계획 수립 |
| `/spec` | SPEC 기반 개발 - 심층 인터뷰 |
| `/spec-verify` | 명세서 기반 구현 검증 |
| `/frontend` | 빅테크 스타일 UI 개발 |
| `/commit-push-pr` | 커밋→푸시→PR |
| `/verify` | 테스트, 린트, 빌드 검증 |
| `/e2e-verify` | 피처 기반 E2E 테스트 검증 |
| `/review` | 코드 리뷰 |
| `/simplify` | 코드 단순화 |
| `/tdd` | 테스트 주도 개발 |
| `/build-fix` | 빌드 에러 수정 |
| `/handoff` | HANDOFF.md 생성 |
| `/compact-guide` | 컨텍스트 관리 가이드 |
| `/techdebt` | 기술 부채 정리 |

## 에이전트 (6개)
| 에이전트 | 용도 |
|----------|------|
| `planner` | 복잡한 기능 계획 |
| `frontend-developer` | 빅테크 스타일 UI 구현 |
| `code-reviewer` | 코드 품질/보안 리뷰 |
| `architect` | 아키텍처 설계 |
| `security-reviewer` | 보안 취약점 분석 |
| `tdd-guide` | TDD 방식 안내 |

## 기술 스킬 (10개)

### Frontend
| 스킬 | 용도 |
|------|------|
| `react-patterns` | React 19 전체 패턴 |
| `vercel-react-best-practices` | React/Next.js 성능 최적화 |
| `typescript-advanced-types` | 고급 타입 시스템 |
| `shadcn-ui` | shadcn/ui 컴포넌트 |
| `tailwind-design-system` | Tailwind CSS 디자인 시스템 |
| `ui-ux-pro-max` | UI/UX 종합 가이드 |

### Backend
| 스킬 | 용도 |
|------|------|
| `fastapi-templates` | FastAPI 템플릿 |
| `api-design-principles` | REST/GraphQL API 설계 |
| `async-python-patterns` | Python 비동기 패턴 |
| `python-testing-patterns` | pytest 테스트 패턴 |

## 고급 활용법

### 병렬 작업 (git worktree)
```bash
# CLI에서 자동 생성/정리
claude --worktree   # 또는 claude -w
# 세션 내에서: EnterWorktree 사용
# 서브에이전트: isolation: "worktree" 옵션
```

### 서브에이전트 활용
```
"use subagents를 사용해서 병렬로 처리해줘"
- 메인 컨텍스트 보호를 위해 리서치/탐색은 서브에이전트에 위임
- 서브에이전트당 하나의 명확한 목표 부여
```

### 검토 강화 프롬프트
- "이 변경사항을 엄격히 검토해줘"
- "이게 작동한다는 걸 증명해봐"
- "우아한 솔루션으로 다시 구현해"
- "지금 아는 모든 것을 바탕으로 우아하게 재구현해"

## 코딩 스타일
rules/coding-style.md 참조 (불변성, 파일 크기, 에러 처리)

## 검색 도구 규칙 (필수!)

**기본 WebSearch/WebFetch는 사용 금지 (deny 설정됨)**

### 웹 검색 → Tavily 사용
- 일반 웹 검색, 최신 정보 조회, 뉴스, 문서 검색 시 **반드시 `mcp__tavily__*` 도구 사용**
- WebSearch 대신 Tavily MCP 서버를 통해 검색

### 코드 스니펫 검색 → Exa 사용
- 코드 예제, 코드 스니펫, GitHub 코드, 기술 문서의 코드 부분 검색 시 **반드시 `mcp__exa__*` 도구 사용**
- 프로그래밍 관련 코드 검색은 Exa가 더 정확함

### 로컬 코드 검색 → mgrep 사용
- 로컬 프로젝트 내 코드 검색 시 **mgrep 플러그인 사용**
- 기본 Grep 대신 mgrep(Mixedbread Grep)으로 시맨틱 코드 검색

### 검색 우선순위
```
1. 로컬 코드 검색 → mgrep (Mixedbread Grep)
2. 웹 일반 검색 → Tavily MCP
3. 코드 스니펫/예제 검색 → Exa MCP
4. 라이브러리 문서 → Context7 MCP
```

## 금지 사항
- main/master 브랜치에 직접 push 금지
- .env 파일이나 민감한 정보 커밋 금지
- 하드코딩된 API 키/시크릿 금지
- console.log 커밋 금지
- **WebSearch, WebFetch 사용 금지 (Tavily/Exa 사용)**

## 커밋 메시지 형식
```
[타입] 제목

본문 (선택)

Co-Authored-By: Claude <noreply@anthropic.com>
```
타입: feat, fix, docs, style, refactor, test, chore

## SPEC 기반 개발 (Thariq 워크플로우)

**대규모 기능 개발 시 권장** - Anthropic 엔지니어 Thariq의 방식

### 핵심 원칙
- **컨텍스트 분리**: 인터뷰 세션 != 구현 세션
- **사용자 컨트롤**: 40개+ 질문으로 방향 직접 결정
- **상세 문서화**: 다음 세션에서 바로 실행 가능

### 워크플로우
```
세션 1: 인터뷰
/spec -> AskUserQuestion으로 심층 인터뷰 -> SPEC.md 생성

세션 2: 구현 (새 세션)
"SPEC.md 읽고 구현해줘"

세션 3: 검증
/spec-verify -> 서브에이전트가 명세서 대비 검증 -> 피드백 반영
```
