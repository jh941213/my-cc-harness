# 김재현의 Claude Code 설정

## 개인 정보
- 이름: 김재현 (Jaehyun Kim)
- GitHub: jh941213
- 회사: KTDS

## 핵심 마인드셋
**Claude Code는 시니어가 아니라 똑똑한 주니어 개발자다.**
- 작업을 작게 쪼갤수록 결과물이 좋아진다
- "인증 기능 만들어줘" ❌
- "로그인 폼 만들고, JWT 생성하고, 리프레시 토큰 구현해줘" ✅

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
    클릭하면 /auth/login API 호출하는 버튼 만들어줘.
    이 버튼은 로그인 폼에 들어가."
```

### 3. 에이전트 체이닝
```
복잡한 작업 → /plan → 구현 → /review → /verify
```

## 컨텍스트 관리 (핵심!)

**컨텍스트는 신선한 우유. 시간이 지나면 상한다.**

### 규칙
- 토큰 80-100k 넘기 전에 리셋 (200k 가능하지만 품질 저하)
- 3-5개 작업마다 컨텍스트 정리
- /compact 3번 후 /clear

### 컨텍스트 관리 패턴
```
작업 → /compact → 작업 → /compact → 작업 → /compact
→ /handoff (HANDOFF.md 생성) → /clear → 새 세션
```

### HANDOFF.md 필수!
컨텍스트 리셋 전에 반드시 HANDOFF.md 생성
- 지금까지 뭐 했는지
- 다음에 뭐 해야 하는지
- 주의할 점

## 사용 가능한 커맨드
| 커맨드 | 용도 |
|--------|------|
| `/plan` | 작업 계획 수립 |
| `/frontend` | 빅테크 스타일 UI 개발 (플래닝→구현) |
| `/commit-push-pr` | 커밋→푸시→PR 한 번에 |
| `/verify` | 테스트, 린트, 빌드 검증 |
| `/review` | 코드 리뷰 |
| `/simplify` | 코드 단순화 |
| `/tdd` | 테스트 주도 개발 |
| `/build-fix` | 빌드 에러 수정 |
| `/handoff` | HANDOFF.md 생성 |
| `/compact-guide` | 컨텍스트 관리 가이드 |
| `/techdebt` | 기술 부채 정리 (중복 코드, console.log 등) |

## 사용 가능한 에이전트
| 에이전트 | 용도 |
|----------|------|
| `planner` | 복잡한 기능 계획 |
| `frontend-developer` | 빅테크 스타일 UI 구현 (React/TS/Tailwind) |
| `code-reviewer` | 코드 품질/보안 리뷰 |
| `architect` | 아키텍처 설계 |
| `security-reviewer` | 보안 취약점 분석 |
| `tdd-guide` | TDD 방식 안내 |

## MCP 관리 규칙
- MCP 서버 20-30개 설정 가능
- 실제 활성화는 10개 미만 유지
- 전체 도구 수 80개 미만 (너무 많으면 느려짐)
- 프로젝트마다 필요한 MCP만 활성화

## 코딩 스타일
- 한국어로 주석과 커밋 메시지 작성
- 코드는 간결하고 읽기 쉽게
- 불변성 패턴 사용 (뮤테이션 금지)
- 함수 50줄 이하, 파일 800줄 이하

## 자주 사용하는 명령어
```bash
npm run build    # 빌드
npm test         # 테스트
npm run lint     # 린트
```

## 금지 사항
- main/master 브랜치에 직접 push 금지
- .env 파일이나 민감한 정보 커밋 금지
- 하드코딩된 API 키/시크릿 금지
- console.log 커밋 금지

## 선호하는 기술 스택
- Frontend: React, TypeScript, Next.js
- Backend: Node.js, Python
- Database: PostgreSQL, MongoDB

## 커밋 메시지 형식
```
[타입] 제목

본문 (선택)

Co-Authored-By: Claude <noreply@anthropic.com>
```
타입: feat, fix, docs, style, refactor, test, chore

## 작업 완료 후 체크리스트
- [ ] 테스트 통과
- [ ] 린트 통과
- [ ] 타입 체크 통과
- [ ] console.log 제거
- [ ] 보안 검토 (API 키, 시크릿)

## 설치된 스킬 (~/.agents/skills/)

### Frontend (7개)
| 스킬 | 용도 |
|------|------|
| `vercel-react-best-practices` | React/Next.js 성능 패턴 |
| `react-patterns` | React 디자인 패턴 |
| `typescript-advanced-types` | 고급 타입 시스템 |
| `shadcn-ui` | 커스텀 컴포넌트 |
| `tailwind-design-system` | Tailwind 시스템 |
| `ui-ux-pro-max` | UX 종합 가이드 |
| `web-design-guidelines` | UI 가이드라인/리뷰 |

### Backend - FastAPI/Python (4개)
| 스킬 | 용도 |
|------|------|
| `fastapi-templates` | FastAPI 템플릿/패턴 |
| `api-design-principles` | REST API 설계 원칙 |
| `async-python-patterns` | Python 비동기 패턴 |
| `python-testing-patterns` | Python 테스트 패턴 |

### 워크플로우
```
# 프론트엔드
/frontend [요청사항] → frontend-developer 에이전트 → /verify

# 백엔드는 일반 플래닝 사용
/plan [요청사항] → 구현 → /verify
```

## 고급 활용법

### 병렬 작업 (git worktree)
동시에 3-5개 작업 병렬 진행 가능:
```bash
# worktree 생성
git worktree add ../project-feat feature-branch
git worktree add ../project-fix bugfix-branch

# 각 터미널에서 Claude Code 실행
cd ../project-feat && claude
cd ../project-fix && claude
```

### 서브에이전트 활용
복잡한 작업 시 프롬프트에 추가:
```
"use subagents를 사용해서 병렬로 처리해줘"
```
→ 메인 컨텍스트 깔끔하게 유지

### 검토 강화 프롬프트
- "이 변경사항을 엄격히 검토해줘"
- "이게 작동한다는 걸 증명해봐"
- 평균적 결과 시: "우아한 솔루션으로 다시 구현해"

### 실수 시 대처
- 잘못되는 순간 즉시 Plan 모드로 돌아가 재계획
- 무리하게 밀어붙이지 말 것
- "CLAUDE.md 업데이트해서 같은 실수 반복하지 않도록 해"

## Claude가 자주 실수하는 것 (여기에 추가)
<!-- Claude가 실수할 때마다 여기에 규칙 추가 -->
