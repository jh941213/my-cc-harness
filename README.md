<div align="center">

# Claude Code Power Pack

<img src="assets/banner.png" alt="Claude Code Power Pack" width="720" />

[![Version](https://img.shields.io/badge/version-0.5.0-7C3AED.svg?style=for-the-badge)](https://github.com/jh941213/my-claude-code-asset)
[![License](https://img.shields.io/badge/license-MIT-E87C3E.svg?style=for-the-badge)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-32-blue.svg?style=for-the-badge)](#포함된-스킬-32개)
[![Agents](https://img.shields.io/badge/agents-10-green.svg?style=for-the-badge)](#포함된-에이전트-10개)

**실무에서 바로 쓸 수 있는 Claude Code 최적 에이전트 하네스**

`Skills` `Agents` `Hooks` `Rules` `Commands` 올인원

---

**32개 스킬** | **10개 에이전트** | **5개 조건부 Rules** | **Hooks 보장 시스템** | **Six Thinking Hats PRD**

</div>

## v0.5.0 주요 변경

- **CLAUDE.md 최적화**: 277줄 → 94줄 (ETH Zurich 논문 + Addy Osmani 가이드 기반)
- **Hooks 보장 시스템**: 금지 사항을 "제안" → "물리적 차단"으로 격상
- **Rules 조건부 로드**: YAML frontmatter로 관련 파일 작업 시에만 로드
- **Six Thinking Hats PRD**: `prd-planner` 에이전트에 de Bono의 6색 모자 프레임워크 통합
- **자동 문서 생성**: `docs-writer` 에이전트가 구현과 병렬로 /docs/ 자동 생성

## 설치

### 방법 1: 플러그인 설치 (Skills만 설치됨)

```bash
# 터미널에서 실행
claude plugin marketplace add jh941213/my-claude-code-asset
claude plugin install ccpp@my-claude-code-asset
```

> **Note**: 플러그인 시스템은 **skills만** 지원합니다. 에이전트와 rules는 별도 설정이 필요합니다.

### 방법 2: 전체 설정 (Agents + Rules + Commands 포함)

Claude Code 세션에서 아래 프롬프트 입력:

```
https://github.com/jh941213/my-claude-code-asset 저장소의 agents/, rules/, commands/, CLAUDE.md를
내 ~/.claude/ 폴더에 반영해줘
```

또는 install.sh 스크립트 실행:

```bash
curl -fsSL https://raw.githubusercontent.com/jh941213/my-claude-code-asset/main/install.sh | bash
```

### 설치 항목 비교

| 항목 | 플러그인 설치 | 전체 설정 |
|------|:------------:|:--------:|
| Skills (32개) | ✅ | ✅ |
| Agents (10개) | ❌ | ✅ |
| Rules (5개, 조건부) | ❌ | ✅ |
| Commands (2개) | ❌ | ✅ |
| CLAUDE.md | ❌ | ✅ |
| settings.json | ❌ | ✅ |

## CLAUDE.md 최적화 철학

> ETH Zurich 논문 + Anthropic 공식 가이드 기반

**"Claude가 코드를 읽어도 알 수 없는 것만 적어라."**

- 200줄 이내 (현재 94줄)
- 발견 가능한 정보 제거 (스킬 목록, 에이전트 목록, 코드베이스 개요)
- 린터로 강제 가능한 규칙은 hooks로 이동
- Auto Memory(MEMORY.md)와 역할 분리

## Hooks 보장 시스템

CLAUDE.md의 "제안"을 settings.json의 "보장"으로 격상:

| 규칙 | 방식 | Hook 유형 |
|------|------|-----------|
| main/master push 금지 | 물리적 차단 | PreToolUse |
| force push 금지 | 물리적 차단 | PreToolUse |
| .env 커밋 금지 | 물리적 차단 | PreCommit |
| console.log 커밋 금지 | 경고 + 차단 | PreCommit |
| prettier 자동 포맷팅 | 자동 실행 | PostToolUse |

## 포함된 스킬 (32개)

### 워크플로우 스킬 (16개)

| 스킬 | 용도 |
|------|------|
| `/ccpp:prd` | **NEW** 인사이트 중심 PRD 생성 (Six Thinking Hats + 시장 리서치 + 5라운드 인터뷰) |
| `/ccpp:docs` | **NEW** 코드 변경 기반 자동 문서 생성 |
| `/ccpp:plan` | 작업 계획 수립 |
| `/ccpp:spec` | SPEC 기반 개발 - 심층 인터뷰로 명세서 작성 |
| `/ccpp:spec-verify` | 명세서 기반 구현 검증 |
| `/ccpp:frontend` | 빅테크 스타일 UI 개발 |
| `/ccpp:verify` | 테스트, 린트, 빌드 검증 |
| `/ccpp:e2e-verify` | 피처 기반 E2E 테스트 검증 |
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

### 이미지 생성 스킬 (1개)

| 스킬 | 용도 |
|------|------|
| `/ccpp:nano-banana` | Gemini CLI로 이미지 생성/편집 (썸네일, 아이콘, 다이어그램 등) |

## 포함된 에이전트 (10개)

> **Note**: 에이전트는 플러그인으로 설치되지 않습니다. `~/.claude/agents/`에 직접 복사하거나, Claude에게 저장소 반영을 요청하세요.

| 에이전트 | 용도 |
|----------|------|
| `prd-planner` | **NEW** Six Thinking Hats 기반 인사이트 PRD (시장 리서치 + 경쟁 분석 + 5라운드 인터뷰) |
| `docs-writer` | **NEW** 코드 변경 감지 → /docs/ 자동 문서 생성 (구현과 병렬 실행) |
| `planner` | 복잡한 기능 계획 수립 (docs-writer 병렬 실행 포함) |
| `frontend-developer` | 빅테크 스타일 UI 구현 |
| `stitch-developer` | Stitch MCP 기반 UI/웹사이트 생성 |
| `junior-mentor` | 주니어 학습 하네스 - 코드 + EXPLANATION.md 생성 |
| `code-reviewer` | 코드 품질/보안 리뷰 |
| `architect` | 시스템 아키텍처 설계 |
| `security-reviewer` | 보안 취약점 분석 |
| `tdd-guide` | TDD 방식 안내 |

**수동 설치:**
```bash
curl -fsSL https://github.com/jh941213/my-claude-code-asset/archive/main.tar.gz | tar -xz -C /tmp
cp /tmp/my-claude-code-asset-main/agents/*.md ~/.claude/agents/
```

## 포함된 Commands (2개)

> **Note**: Commands는 `~/.claude/commands/`에 설치됩니다.

| 커맨드 | 용도 |
|--------|------|
| `/prd [아이디어]` | Six Thinking Hats 기반 인사이트 PRD 생성 |
| `/docs [유형]` | 코드 변경 기반 자동 문서 생성 |

### PRD → SPEC → 구현 파이프라인

```
/prd [아이디어]  → PRD.md (무엇을, 왜 — Six Hats 인사이트)
/spec            → SPEC.md (어떻게 — 기술 상세)
/plan            → 구현 계획 (+ docs-writer 병렬 실행)
구현 → /review → /verify → /docs
```

## 포함된 Rules (5개, 조건부 로드)

> YAML frontmatter로 관련 파일 작업 시에만 로드됩니다.

| 규칙 파일 | 조건 | 용도 |
|-----------|------|------|
| `coding-style.md` | `**/*.ts`, `**/*.tsx`, `**/*.js` | 불변성, 파일 구성 |
| `git-workflow.md` | 모든 파일 | Git 브랜치, 커밋 형식 |
| `testing.md` | `**/*.test.*`, `**/*.spec.*` | 테스트 원칙, 커버리지 |
| `performance.md` | `**/*.ts`, `**/*.tsx`, `**/*.py` | 성능 최적화 |
| `security.md` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.env*` | 보안 체크리스트 |

## Boris Cherny 팁 (Claude Code 창시자)

### 1. 병렬 Claude 실행
```
터미널 5개 + claude.ai/code 5-10개 동시 실행
```

### 2. Opus 4.6 + Thinking
```
항상 Opus 4.6 사용. 느리지만 스티어링 적어서 결과적으로 빠름.
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
claude --worktree   # 또는 claude -w
```

### 8. 병렬 에이전트 실행
```
Plan 후 Task가 독립적이면 → 무조건 병렬 호출
피처가 겹치지 않으면 → 병렬, 겹치면 → 순차
```

## OpenAI Codex CLI 버전

<div align="center">

**동일한 하네스를 OpenAI Codex CLI에서도 사용할 수 있습니다.**

[![Codex CLI Power Pack](https://img.shields.io/badge/Codex_CLI_Power_Pack-33_Skills-orange.svg?style=for-the-badge)](https://github.com/jh941213/my-codex-cli-asset)

</div>

| | Claude Code Power Pack | Codex CLI Power Pack |
|---|:---:|:---:|
| **Skills** | 32개 (`/ccpp:skill`) | 33개 (`$skill`) |
| **Agents** | 10개 (서브에이전트) | AGENTS.md 통합 |
| **Rules** | 5개 (YAML 조건부 로드) | AGENTS.md 통합 |
| **Hooks** | settings.json 물리 차단 | config.toml |
| **PRD** | Six Thinking Hats | Six Thinking Hats |
| **자동 문서** | docs-writer 병렬 실행 | $docs |
| **모델** | Claude Opus 4.6 | GPT-5.3 Codex |

```bash
# Codex CLI 버전 설치
curl -fsSL https://raw.githubusercontent.com/jh941213/my-codex-cli-asset/main/install.sh | bash
```

> **GitHub**: [jh941213/my-codex-cli-asset](https://github.com/jh941213/my-codex-cli-asset)

## 참고 자료

- [Boris Cherny 트위터](https://x.com/bcherny)
- [Claude Code Skills 공식 문서](https://code.claude.com/docs/en/skills)
- [skills.sh](https://skills.sh/) - AI 에이전트 스킬 디렉토리
- [ETH Zurich 논문 - AGENTS.md 효과 분석](https://arxiv.org/abs/2602.11988)
- [Addy Osmani - Stop Using /init for AGENTS.md](https://addyosmani.com/blog/agents-md/)

---

## Changelog

### v0.5.0 (2026-03-02)

**CLAUDE.md 논문 기반 최적화**
- 277줄 → 94줄 (ETH Zurich 논문 + Anthropic 가이드 기반)
- 발견 가능한 정보 제거 (스킬/에이전트/기술 테이블)
- 사용자 가이드와 Claude 지시 분리
- Karpathy 원칙 추가: Think Before Coding, Goal-Driven Execution

**Hooks 보장 시스템**
- main/master push → PreToolUse hook 차단
- force push → PreToolUse hook 차단
- .env 커밋 → PreCommit hook 차단
- console.log 커밋 → PreCommit hook 차단
- prettier → PostToolUse hook 자동 실행

**Rules 조건부 로드**
- 모든 rules에 YAML frontmatter 추가
- 관련 파일 작업 시에만 로드 (토큰 절약)

**새로운 에이전트 (2개)**
- `prd-planner` - Six Thinking Hats 기반 인사이트 PRD 생성
  - 서브에이전트 3개 병렬 시장 리서치
  - Six Thinking Hats 매핑 5라운드 인터뷰 (White+Red → Black+Green → Blue)
  - Hat 충돌 해소 프레임워크 (Yellow vs Black, Red vs White)
  - 경쟁사 공백 분석, 가정 위험도 매트릭스, Six Hats 제품 평가표
- `docs-writer` - 코드 변경 자동 문서 생성
  - git diff 기반 변경 파일 감지
  - 파일 유형별 문서 자동 생성 (API, 컴포넌트, 유틸, 모델)
  - 구현 에이전트와 background 병렬 실행

**새로운 커맨드 (2개)**
- `/prd [아이디어]` - 인사이트 중심 PRD 생성
- `/docs [유형]` - 코드 변경 기반 자동 문서 생성

**새로운 스킬 (2개)**
- `prd` - PRD 생성 스킬
- `docs` - 자동 문서 생성 스킬

**변경사항**
- `planner` 에이전트 업데이트 (docs-writer 병렬 실행 가이드 추가)
- 에이전트 개수: 8개 → 10개
- 스킬 개수: 30개 → 32개

### v0.4.0 (2026-02-24)

**새로운 스킬**
- `/ccpp:e2e-verify` - 피처 기반 E2E 테스트 검증 (verify 이후 실제 브라우저 테스트)

**새로운 기능**
- 세션 초기화 시 Worktree 사용 여부 자동 질문
- 병렬 에이전트 실행 규칙 추가 (독립 Task는 무조건 병렬 호출)
- `claude --worktree` / `EnterWorktree` 지원

**변경사항**
- `langfuse` 스킬 제거
- Boris 팁 확장 (핵심 원칙, 워크플로우 오케스트레이션, 작업 관리 등)
- Prompt Caching 캐시 보존 규칙 추가
- 검색 도구 규칙 추가 (Tavily/Exa/mgrep/Context7)
- 스킬 개수: 29개 → 30개

### v0.3.1 (2026-02-06)

**버그 수정**
- `settings.json`의 `ccpp@ccpp` → `ccpp@my-claude-code-asset`로 수정 (플러그인 마켓플레이스 참조 오류)
- `install.sh` 에이전트/스킬 개수 업데이트 (6→8개 에이전트, 23→29개 스킬)

**문서 업데이트**
- Opus 4.5 → Opus 4.6 반영

### v0.3.0 (2025-02-03)

**새로운 스킬 (5개)**
- `/ccpp:e2e-agent-browser` - agent-browser CLI 기반 E2E 테스트 자동화
- `/ccpp:stitch-design-md` - Stitch 프로젝트 분석 → DESIGN.md 생성
- `/ccpp:stitch-enhance-prompt` - UI 아이디어 → Stitch 최적화 프롬프트 변환
- `/ccpp:stitch-loop` - Stitch로 멀티 페이지 웹사이트 자율 생성
- `/ccpp:stitch-react` - Stitch 스크린 → React 컴포넌트 변환

**새로운 에이전트 (2개)**
- `stitch-developer` - Stitch MCP 기반 UI/웹사이트 생성 전문가
- `junior-mentor` - 주니어 개발자 학습 하네스

**새로운 스킬**
- `nano-banana` - Gemini CLI 기반 이미지 생성/편집

### v0.2.0 (2025-02-03)

**새로운 스킬**
- `/spec` - SPEC 기반 개발 (Thariq 워크플로우)
- `/spec-verify` - 명세서 기반 구현 검증

### v0.1.0 (2025-01-22)

- 초기 릴리스

## 라이선스

MIT
