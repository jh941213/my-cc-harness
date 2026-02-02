# Claude Code Power Pack 설정

Boris Cherny(Claude Code 창시자) 팁 + skills.sh 해커톤 우승작 기반 올인원 플러그인

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
    클릭하면 /auth/login API 호출하는 버튼 만들어줘."
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

## 워크플로우 스킬 (11개)
| 스킬 | 용도 |
|------|------|
| `/plan` | 작업 계획 수립 |
| `/frontend` | 빅테크 스타일 UI 개발 |
| `/commit-push-pr` | 커밋→푸시→PR |
| `/verify` | 테스트, 린트, 빌드 검증 |
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
git worktree add ../project-feat -b feature/login
git worktree add ../project-fix -b fix/bug
# 각 터미널에서 claude 실행
```

### 서브에이전트 활용
```
"use subagents를 사용해서 병렬로 처리해줘"
```

### 검토 강화 프롬프트
- "이 변경사항을 엄격히 검토해줘"
- "이게 작동한다는 걸 증명해봐"
- "우아한 솔루션으로 다시 구현해"

## 코딩 스타일
- 코드는 간결하고 읽기 쉽게
- 불변성 패턴 사용 (뮤테이션 금지)
- 함수 50줄 이하, 파일 800줄 이하

## 금지 사항
- main/master 브랜치에 직접 push 금지
- .env 파일이나 민감한 정보 커밋 금지
- 하드코딩된 API 키/시크릿 금지
- console.log 커밋 금지

## 커밋 메시지 형식
```
[타입] 제목

본문 (선택)

Co-Authored-By: Claude <noreply@anthropic.com>
```
타입: feat, fix, docs, style, refactor, test, chore
