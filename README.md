# My Claude Code Configuration

김재현 님의 클로드 코드 configuration 설정 값입니다. 어디서나 이식해서 사용하세요.

## 빠른 설치

다른 컴퓨터에서 Claude Code에게 이렇게 말하세요:

```
https://github.com/jh941213/my-claude-code-asset 이 레포의 설정 파일들을 ~/.claude/에 복사해서 적용해줘
```

## 수동 설치

```bash
# 1. 레포 클론
git clone https://github.com/jh941213/my-claude-code-asset.git
cd my-claude-code-asset

# 2. 설정 파일 복사
cp CLAUDE.md ~/.claude/
cp settings.json ~/.claude/
cp -r agents ~/.claude/
cp -r commands ~/.claude/
cp -r rules ~/.claude/
cp -r skills ~/.claude/

# 3. (선택) 터미널 alias 추가
echo 'alias c="claude"' >> ~/.zshrc
source ~/.zshrc
```

## 설치 스크립트

```bash
curl -fsSL https://raw.githubusercontent.com/jh941213/my-claude-code-asset/main/install.sh | bash
```

## 구조

```
.
├── CLAUDE.md           # 전역 설정 (자동 로드)
├── settings.json       # 권한 + Hooks + 플러그인
├── agents/             # 전문 서브에이전트 (6개)
│   ├── planner.md
│   ├── frontend-developer.md
│   ├── code-reviewer.md
│   ├── architect.md
│   ├── security-reviewer.md
│   └── tdd-guide.md
├── skills/             # 스킬 (21개) - commands 통합됨
│   ├── react-patterns/
│   ├── vercel-react-best-practices/
│   ├── typescript-advanced-types/
│   ├── shadcn-ui/
│   ├── tailwind-design-system/
│   ├── ui-ux-pro-max/
│   ├── fastapi-templates/
│   ├── api-design-principles/
│   ├── async-python-patterns/
│   └── python-testing-patterns/
└── rules/              # 자동 적용 규칙 (5개)
    ├── security.md
    ├── coding-style.md
    ├── testing.md
    ├── git-workflow.md
    └── performance.md
```

## 포함된 기능

### 에이전트 (6개)

| 에이전트 | 용도 |
|----------|------|
| `planner` | 복잡한 기능 계획 수립 |
| `frontend-developer` | 빅테크 스타일 UI 구현 (React/TS/Tailwind) |
| `code-reviewer` | 코드 품질/보안 리뷰 |
| `architect` | 시스템 아키텍처 설계 |
| `security-reviewer` | 보안 취약점 분석 |
| `tdd-guide` | TDD 방식 안내 |

### 워크플로우 스킬 (11개)

| 스킬 | 용도 |
|------|------|
| `/plan` | 작업 계획 수립 |
| `/frontend` | 빅테크 스타일 UI 개발 |
| `/commit-push-pr` | 커밋 → 푸시 → PR |
| `/verify` | 테스트, 린트, 빌드 검증 |
| `/review` | 코드 리뷰 |
| `/simplify` | 코드 단순화 |
| `/tdd` | 테스트 주도 개발 |
| `/build-fix` | 빌드 에러 수정 |
| `/handoff` | HANDOFF.md 생성 |
| `/compact-guide` | 컨텍스트 관리 가이드 |
| `/techdebt` | 기술 부채 정리 |

### 기술 스킬 (10개)

#### Frontend (6개)
| 스킬 | 용도 |
|------|------|
| `react-patterns` | React 19 전체 패턴 (hooks, 서버 컴포넌트, Actions) |
| `vercel-react-best-practices` | React/Next.js 성능 최적화 |
| `typescript-advanced-types` | TypeScript 고급 타입 시스템 |
| `shadcn-ui` | shadcn/ui 컴포넌트 라이브러리 |
| `tailwind-design-system` | Tailwind CSS 디자인 시스템 |
| `ui-ux-pro-max` | UI/UX 종합 가이드 + 디자인 시스템 생성 |

#### Backend (4개)
| 스킬 | 용도 |
|------|------|
| `fastapi-templates` | FastAPI 템플릿/패턴 |
| `api-design-principles` | REST/GraphQL API 설계 원칙 |
| `async-python-patterns` | Python 비동기 패턴 |
| `python-testing-patterns` | pytest 테스트 패턴 |

### 규칙 (5개)

| 규칙 | 내용 |
|------|------|
| `security.md` | 보안 가이드라인 |
| `coding-style.md` | 코딩 스타일 (불변성, 파일 크기 제한) |
| `testing.md` | 테스트 가이드 |
| `git-workflow.md` | Git 워크플로우 |
| `performance.md` | 성능 최적화 |

## 사용법

### 프론트엔드 워크플로우

```bash
# 빅테크 스타일 UI 개발
/frontend 로그인 페이지 만들어줘. Vercel 스타일로.
# → 디자인 규격 작성 → frontend-developer 에이전트가 구현
/verify                         # 빌드 검증
/commit-push-pr                 # 커밋 → 푸시 → PR
```

### 기본 워크플로우

```bash
# 새 기능 개발
/plan 로그인 기능 만들어줘     # 계획 수립
# (계획 확인 후 구현)
/verify                         # 테스트/빌드 검증
/commit-push-pr                 # 커밋 → 푸시 → PR
```

### 컨텍스트 관리

```bash
# 작업 3-5개 완료 후
/compact                        # 토큰 압축

# /compact 3번 후
/handoff                        # HANDOFF.md 생성
/clear                          # 초기화

# 새 세션에서
HANDOFF.md 읽고 이어서 작업해줘
```

### 세션 종료 전

```bash
/techdebt                       # 기술 부채 정리
# → 중복 코드, console.log, 사용 안 하는 import 검사
```

## Claude Code 창시자의 실전 팁 (Boris Cherny)

> 출처: [@bcherny](https://x.com/bcherny) - Claude Code 창시자

### 1. 병렬 Claude 실행
```
터미널 탭 5개 + 웹(claude.ai/code) 5-10개 동시 실행
시스템 알림으로 Claude가 입력 대기 중인지 확인
```

### 2. Opus 4.5 + Thinking 사용
```
항상 Opus 4.5 사용. 느리지만 스티어링이 적어 결과적으로 더 빠름.
```

### 3. Plan 모드 필수
```
Shift+Tab 두 번 → Plan 모드
계획 확정 후 → Auto-accept 모드로 1-shot 구현
```

### 4. CLAUDE.md 팀 공유
```
팀 전체가 CLAUDE.md를 git에 커밋
Claude가 실수할 때마다 규칙 추가
코드 리뷰 시 @.claude 태그로 규칙 추가 요청
```

### 5. 실수 시 즉시 재계획
```
작업이 잘못되면 Plan 모드로 복귀
무리하게 밀어붙이지 말 것
```

### 6. 검증 시에도 Plan 모드
```
검증 단계에서도 명시적으로 plan 모드 진입 지시
```

### 7. 하루에 한 번 이상 반복하는 작업 → Skill 만들기
```
/techdebt - 세션 종료 시 중복 코드 제거
자동화 스크립트 → git에 커밋
```

### 8. 서브에이전트 활용
```
프롬프트에 "use subagents" 추가
메인 컨텍스트 깔끔하게 유지
```

### 9. 프롬프트 수준 끌어올리기
```
"이 변경사항을 엄격히 검토하고, 테스트 통과할 때까지 PR 만들지 마"
"이게 작동한다는 걸 증명해봐"
"우아한 솔루션으로 다시 구현해"
```

### 10. 음성 받아쓰기 활용
```
macOS: fn 키 두 번
타이핑보다 3배 빠르고 프롬프트가 더 상세해짐
```

---

## 고급 활용법

### 병렬 작업 (git worktree)

3-5개 작업을 동시에 병렬로 진행:

```bash
# worktree 생성
git worktree add ../project-feat -b feature/login
git worktree add ../project-fix -b fix/auth-bug

# 각 터미널에서 Claude Code 실행
cd ../project-feat && claude   # "로그인 기능 만들어"
cd ../project-fix && claude    # "버그 수정해"
```

### 서브에이전트 활용

복잡한 작업 시 프롬프트에 추가:

```
이 프로젝트 리팩토링해줘. use subagents
```

→ Claude가 알아서 작업을 분업해서 병렬 처리

### 검토 강화 프롬프트

- "이 변경사항을 엄격히 검토해줘"
- "이게 작동한다는 걸 증명해봐"
- 평균적 결과 시: "우아한 솔루션으로 다시 구현해"

## 핵심 원칙

1. **주니어처럼 대하기** - 작업을 작게 쪼개서 지시
2. **Plan 모드 먼저** - 복잡한 작업은 계획부터 (Shift+Tab)
3. **컨텍스트 관리** - 80-100k 토큰 전에 리셋
4. **HANDOFF.md** - 세션 인계 문서 필수
5. **검증 루프** - 작업 후 반드시 `/verify`
6. **실수 시 재계획** - 잘못되면 Plan 모드로 돌아가기

## 참고 자료

- [Claude Code Skills 공식 문서](https://code.claude.com/docs/en/skills)
- [skills.sh](https://skills.sh/) - AI 에이전트 스킬 디렉토리
- [Boris Cherny 워크플로우](https://www.infoq.com/news/2026/01/claude-code-creator-workflow/)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

## 라이선스

MIT
