# Claude Code Power Pack

[![Version](https://img.shields.io/badge/version-0.3.0-blue.svg)](https://github.com/jh941213/my-claude-code-asset)

Boris Cherny(Claude Code 창시자) 팁 + skills.sh 해커톤 우승작 기반 **올인원 플러그인**

## 설치

### 방법 1: 플러그인 설치 (Skills만 설치됨)

```bash
# 터미널에서 실행
claude plugin marketplace add jh941213/my-claude-code-asset
claude plugin install ccpp@my-claude-code-asset
```

> **Note**: 플러그인 시스템은 **skills만** 지원합니다. 에이전트와 rules는 별도 설정이 필요합니다.

### 방법 2: 전체 설정 (Agents + Rules 포함)

Claude Code 세션에서 아래 프롬프트 입력:

```
https://github.com/jh941213/my-claude-code-asset 저장소의 agents/, rules/, CLAUDE.md를
내 ~/.claude/ 폴더에 반영해줘
```

또는 install.sh 스크립트 실행:

```bash
curl -fsSL https://raw.githubusercontent.com/jh941213/my-claude-code-asset/main/install.sh | bash
```

### 설치 항목 비교

| 항목 | 플러그인 설치 | 전체 설정 |
|------|:------------:|:--------:|
| Skills (28개) | ✅ | ✅ |
| Agents (6개) | ❌ | ✅ |
| Rules (5개) | ❌ | ✅ |
| CLAUDE.md | ❌ | ✅ |
| settings.json | ❌ | ✅ |

## 포함된 스킬 (28개)

### 워크플로우 스킬 (13개)

| 스킬 | 용도 |
|------|------|
| `/ccpp:plan` | 작업 계획 수립 |
| `/ccpp:spec` | SPEC 기반 개발 - 심층 인터뷰로 명세서 작성 |
| `/ccpp:spec-verify` | 명세서 기반 구현 검증 |
| `/ccpp:frontend` | 빅테크 스타일 UI 개발 |
| `/ccpp:verify` | 테스트, 린트, 빌드 검증 |
| `/ccpp:commit-push-pr` | 커밋 → 푸시 → PR |
| `/ccpp:review` | 코드 리뷰 |
| `/ccpp:simplify` | 코드 단순화 |
| `/ccpp:tdd` | 테스트 주도 개발 |
| `/ccpp:build-fix` | 빌드 에러 수정 |
| `/ccpp:handoff` | HANDOFF.md 세션 인계 |
| `/ccpp:compact-guide` | 컨텍스트 관리 가이드 |
| `/ccpp:techdebt` | 기술 부채 정리 |

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

### E2E & Stitch 스킬 (5개)

| 스킬 | 용도 |
|------|------|
| `/ccpp:e2e-agent-browser` | agent-browser CLI로 E2E 테스트 자동화 |
| `/ccpp:stitch-design-md` | Stitch 프로젝트 → DESIGN.md 생성 |
| `/ccpp:stitch-enhance-prompt` | UI 아이디어 → Stitch 최적화 프롬프트 변환 |
| `/ccpp:stitch-loop` | Stitch로 멀티 페이지 웹사이트 자율 생성 |
| `/ccpp:stitch-react` | Stitch 스크린 → React 컴포넌트 변환 |

## 포함된 에이전트 (6개)

> **Note**: 에이전트는 플러그인으로 설치되지 않습니다. `~/.claude/agents/`에 직접 복사하거나, Claude에게 저장소 반영을 요청하세요.

| 에이전트 | 용도 |
|----------|------|
| `planner` | 복잡한 기능 계획 수립 |
| `frontend-developer` | 빅테크 스타일 UI 구현 |
| `code-reviewer` | 코드 품질/보안 리뷰 |
| `architect` | 시스템 아키텍처 설계 |
| `security-reviewer` | 보안 취약점 분석 |
| `tdd-guide` | TDD 방식 안내 |

**수동 설치:**
```bash
# agents 폴더 복사
curl -fsSL https://github.com/jh941213/my-claude-code-asset/archive/main.tar.gz | tar -xz -C /tmp
cp /tmp/my-claude-code-asset-main/agents/*.md ~/.claude/agents/
```

## 포함된 Rules (5개)

> **Note**: Rules도 플러그인으로 설치되지 않습니다. `~/.claude/rules/`에 직접 복사하세요.

| 규칙 파일 | 용도 |
|-----------|------|
| `coding-style.md` | 코딩 스타일 가이드 (불변성, 파일 구성) |
| `git-workflow.md` | Git 브랜치 전략, 커밋 메시지 형식 |
| `testing.md` | 테스트 작성 원칙, 커버리지 목표 |
| `performance.md` | 프론트엔드/백엔드 성능 최적화 |
| `security.md` | 보안 체크리스트, 시크릿 관리 |

**수동 설치:**
```bash
cp /tmp/my-claude-code-asset-main/rules/*.md ~/.claude/rules/
```

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

## 웹 검색 규칙

내장 WebSearch/WebFetch는 비활성화하고 MCP 도구를 사용합니다:

| 용도 | 사용할 MCP |
|------|-----------|
| 일반 검색 (문서, 뉴스, 정보) | **Tavily** (`mcp__tavily__*`) |
| 코드 검색 (스니펫, 구현 예제) | **Exa** (`mcp__exa__*`) |

**판단 기준:**
- "어떻게 동작하는지" 알고 싶다 → **Tavily**
- "어떻게 구현하는지" 코드가 필요하다 → **Exa**

## 참고 자료

- [Boris Cherny 트위터](https://x.com/bcherny)
- [Claude Code Skills 공식 문서](https://code.claude.com/docs/en/skills)
- [skills.sh](https://skills.sh/) - AI 에이전트 스킬 디렉토리

---

## Changelog

### v0.3.0 (2025-02-03)

**새로운 스킬 (5개)**
- `/ccpp:e2e-agent-browser` - agent-browser CLI 기반 E2E 테스트 자동화
  - 스냅샷 기반 접근성 트리와 ref 시스템
  - CI/CD 통합 지원
- `/ccpp:stitch-design-md` - Stitch 프로젝트 분석 → DESIGN.md 생성
- `/ccpp:stitch-enhance-prompt` - UI 아이디어 → Stitch 최적화 프롬프트 변환
- `/ccpp:stitch-loop` - Stitch로 멀티 페이지 웹사이트 자율 생성
- `/ccpp:stitch-react` - Stitch 스크린 → React 컴포넌트 변환

**플러그인 구조 개선**
- plugin.json에 skills 경로 추가
- marketplace.json에 $schema 추가
- install.sh 버그 수정 (commands → skills)

**문서 업데이트**
- 설치 가이드 개선 (플러그인 vs 전체 설정 비교)
- Agents/Rules 수동 설치 방법 추가
- 스킬 개수: 23개 → 28개

### v0.2.0 (2025-02-03)

**새로운 스킬**
- `/spec` - SPEC 기반 개발 (Thariq 워크플로우)
  - AskUserQuestion으로 40개+ 심층 인터뷰
  - SPEC.md 명세서 자동 생성
- `/spec-verify` - 명세서 기반 구현 검증
  - Task 에이전트로 자동 검증
  - SPEC-REVIEW.md 피드백 생성

**새로운 플러그인**
- `mgrep@Mixedbread-Grep` - 강력한 검색 도구
- `claude-hud@claude-hud` - 상태 표시줄 HUD

**설정 변경**
- 웹 검색 규칙 추가: WebSearch/WebFetch 비활성화
- MCP 검색 도구 활성화: Tavily (일반 검색), Exa (코드 검색)
- statusLine 설정 추가 (claude-hud)
- `settings.local.example.json` 템플릿 추가

**문서 업데이트**
- SPEC 기반 개발 워크플로우 섹션 추가
- 웹 검색 규칙 섹션 추가
- 스킬 개수: 21개 → 23개

### v0.1.0 (2025-01-22)

- 초기 릴리스
- 워크플로우 스킬 11개
- 기술 스킬 10개
- 에이전트 6개

## 라이선스

MIT
