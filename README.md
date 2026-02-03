# Claude Code Power Pack

Boris Cherny(Claude Code 창시자) 팁 + skills.sh 해커톤 우승작 기반 **올인원 플러그인**

## 설치

```bash
# 마켓플레이스 추가
/plugin marketplace add jh941213/my-claude-code-asset

# 플러그인 설치
/plugin install claude-code-power-pack@claude-power-pack
```

## 포함된 스킬 (23개)

### 워크플로우 스킬 (13개)

| 스킬 | 용도 |
|------|------|
| `/claude-code-power-pack:plan` | 작업 계획 수립 |
| `/claude-code-power-pack:spec` | SPEC 기반 개발 - 심층 인터뷰로 명세서 작성 |
| `/claude-code-power-pack:spec-verify` | 명세서 기반 구현 검증 |
| `/claude-code-power-pack:frontend` | 빅테크 스타일 UI 개발 |
| `/claude-code-power-pack:verify` | 테스트, 린트, 빌드 검증 |
| `/claude-code-power-pack:commit-push-pr` | 커밋 → 푸시 → PR |
| `/claude-code-power-pack:review` | 코드 리뷰 |
| `/claude-code-power-pack:simplify` | 코드 단순화 |
| `/claude-code-power-pack:tdd` | 테스트 주도 개발 |
| `/claude-code-power-pack:build-fix` | 빌드 에러 수정 |
| `/claude-code-power-pack:handoff` | HANDOFF.md 세션 인계 |
| `/claude-code-power-pack:compact-guide` | 컨텍스트 관리 가이드 |
| `/claude-code-power-pack:techdebt` | 기술 부채 정리 |

### 기술 스킬 (10개)

| 스킬 | 출처 | 용도 |
|------|------|------|
| `react-patterns` | skills.sh | React 19 전체 패턴 |
| `vercel-react-best-practices` | Vercel | React/Next.js 성능 최적화 |
| `typescript-advanced-types` | skills.sh | TypeScript 고급 타입 |
| `shadcn-ui` | skills.sh | shadcn/ui 컴포넌트 |
| `tailwind-design-system` | skills.sh | Tailwind CSS 디자인 시스템 |
| `ui-ux-pro-max` | skills.sh | UI/UX 종합 가이드 |
| `fastapi-templates` | skills.sh | FastAPI 템플릿 |
| `api-design-principles` | skills.sh | REST/GraphQL API 설계 |
| `async-python-patterns` | skills.sh | Python 비동기 패턴 |
| `python-testing-patterns` | skills.sh | pytest 테스트 패턴 |

## 포함된 에이전트 (6개)

| 에이전트 | 용도 |
|----------|------|
| `planner` | 복잡한 기능 계획 수립 |
| `frontend-developer` | 빅테크 스타일 UI 구현 |
| `code-reviewer` | 코드 품질/보안 리뷰 |
| `architect` | 시스템 아키텍처 설계 |
| `security-reviewer` | 보안 취약점 분석 |
| `tdd-guide` | TDD 방식 안내 |

## Boris Cherny 팁 (Claude Code 창시자)

### 1. 병렬 Claude 실행
```
터미널 5개 + claude.ai/code 5-10개 동시 실행
```

### 2. Opus 4.5 + Thinking
```
항상 Opus 4.5 사용. 느리지만 스티어링 적어서 결과적으로 빠름.
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
```

### 5. 실수 시 즉시 재계획
```
작업 잘못되면 Plan 모드로 복귀, 무리하게 밀어붙이지 말 것
```

### 6. 서브에이전트 활용
```
프롬프트에 "use subagents" 추가 → 병렬 처리
```

### 7. git worktree 병렬 작업
```bash
git worktree add ../project-feat -b feature/login
git worktree add ../project-fix -b fix/bug
# 각 터미널에서 claude 실행
```

## 핵심 원칙

1. **주니어처럼 대하기** - 작업을 작게 쪼개서 지시
2. **Plan 모드 먼저** - 복잡한 작업은 계획부터
3. **컨텍스트 관리** - 80-100k 토큰 전에 리셋
4. **HANDOFF.md** - 세션 인계 문서 필수
5. **검증 루프** - 작업 후 반드시 `/verify`

## 참고 자료

- [Boris Cherny 트위터](https://x.com/bcherny)
- [Claude Code Skills 공식 문서](https://code.claude.com/docs/en/skills)
- [skills.sh](https://skills.sh/) - AI 에이전트 스킬 디렉토리

## 라이선스

MIT
