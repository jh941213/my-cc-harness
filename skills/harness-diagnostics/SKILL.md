---
name: harness-diagnostics
description: "에이전트 하네스 12원칙 기반 자가 진단 및 개선 제안. Triggers on: 하네스 진단, audit, 환경 점검, setup, maintenance, drift 확인. NOT for: 코드 구현, 버그 수정, 테스트 작성."
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
---

# Harness Diagnostics — 에이전트 하네스 자가 진단 스킬

12원칙 기반 하네스 성숙도 진단 및 개선 제안 도구.
**Read-only**: 진단 + 제안만 수행하며, 직접 파일을 수정하지 않음.

## 입력

$ARGUMENTS

## 모드 판별

| 모드 | 트리거 키워드 | 목적 |
|------|-------------|------|
| **Setup** | "환경 구축", "setup", "초기화" | 에이전트 협업 환경 초기 점검 + 추천 |
| **Audit** | "하네스 진단", "점검", "audit", 기본값 | 12원칙 점수화 + 개선 로드맵 |
| **Maintenance** | "drift 확인", "정리", "maintenance" | stale 코드/문서 감지 + 정리 제안 |

키워드가 없으면 **Audit** 모드를 기본으로 실행.

---

## 12원칙 점수 체계

각 원칙 0-8점, 총 100점 (12 × 8 = 96, 나머지 4점은 종합 보너스).

| # | 원칙 | 점검 대상 |
|---|------|----------|
| 1 | **Agent Entry Point** | CLAUDE.md/AGENTS.md 존재 + 명확한 에이전트 진입점 |
| 2 | **Map, Not Manual** | 문서가 "지도"인가 vs "매뉴얼"인가 (포인터, 계층 구조) |
| 3 | **Invariant Enforcement** | 도구가 실수를 자동 차단하는가 (hooks, linters, CI) |
| 4 | **Convention Over Configuration** | 명시적 규칙 파일 존재 (rules/, .eslintrc, prettier 등) |
| 5 | **Progressive Disclosure** | 정보 계층화 (CLAUDE.md → rules/ → docs/ → 코드) |
| 6 | **Layered Architecture** | 의존성 방향 단방향, 레이어 분리 |
| 7 | **Garbage Collection** | stale 파일/문서/의존성 정리 메커니즘 |
| 8 | **Observability** | 자체 검증 가능 (테스트, 빌드, 타입체크) |
| 9 | **Knowledge in Repo** | 지식이 레포에 있는가 (ADR, docs/, 인라인 설명) |
| 10 | **Reproducibility** | 동일 입력 → 동일 결과 (lock 파일, 환경 설정) |
| 11 | **Modularity** | 변경 영향 예측 가능 (모듈 경계, 인터페이스) |
| 12 | **Self-Documentation** | 코드가 의도를 설명하는가 (네이밍, 구조) |

### 성숙도 등급

| 등급 | 점수 | 설명 |
|------|------|------|
| **L1 None** | 0-19 | 하네스 없음. 에이전트가 매번 처음부터 추론 |
| **L2 Basic** | 20-39 | 기본 설정 존재. 일부 자동화 |
| **L3 Structured** | 40-59 | 구조화된 규칙과 도구. 대부분 자동화 |
| **L4 Optimized** | 60-79 | 최적화된 하네스. 에이전트 자율성 높음 |
| **L5 Autonomous** | 80-100 | 자율 운영. 자가 진단/수정 가능 |

---

## 실행 절차

### Setup 모드

1. 프로젝트 루트 탐색 (Explore 서브에이전트)
2. 다음 항목 존재 여부 확인:
   - `CLAUDE.md` 또는 `.claude/CLAUDE.md`
   - `rules/` 또는 `.claude/rules/`
   - `docs/` 디렉토리
   - 패키지 매니저 lock 파일
   - 린터/포매터 설정
   - 테스트 프레임워크 설정
   - CI/CD 설정
3. 누락된 항목에 대해 **생성 추천** (직접 생성하지 않음)
4. 추천 우선순위: P0 (즉시) → P1 (권장) → P2 (개선)

### Audit 모드

1. 12원칙 각각에 대해 점검 실행:
   - 파일/디렉토리 존재 여부 (Glob)
   - 설정 파일 내용 분석 (Read)
   - 패턴 검색 (Grep)
2. 원칙별 점수 산정 (0-8)
3. 종합 보너스 산정 (0-4):
   - 원칙 간 시너지 (예: hooks + rules + docs 3개 모두 있으면 +2)
   - 일관성 (네이밍 규칙, 구조 통일성 +2)
4. 리포트 출력

### Maintenance 모드

1. stale 항목 탐지:
   - 30일 이상 수정 없는 docs/ 파일
   - package.json에 있지만 import되지 않는 의존성
   - TODO/FIXME 주석 수집
   - 빈 디렉토리
   - 사용되지 않는 설정 파일
2. drift 감지:
   - CLAUDE.md 내용 vs 실제 프로젝트 구조 불일치
   - rules/ 규칙 vs 코드 실태 불일치
3. 정리 제안 목록 출력 (직접 수정하지 않음)

---

## 출력 형식

```markdown
# 🔍 Harness Diagnostics Report

## 프로젝트: {프로젝트명}
## 모드: {Setup | Audit | Maintenance}
## 날짜: {YYYY-MM-DD}

---

## 원칙별 점수

| # | 원칙 | 점수 | 근거 |
|---|------|------|------|
| 1 | Agent Entry Point | X/8 | ... |
| 2 | Map, Not Manual | X/8 | ... |
| ... | ... | ... | ... |
| 12 | Self-Documentation | X/8 | ... |

**종합 보너스**: X/4
**총점**: XX/100

## 성숙도 등급: LX {등급명}

---

## 개선 제안 Top 3

### 1. {제안 제목} (P{0-2})
- **현재**: {현재 상태}
- **개선**: {구체적 액션}
- **효과**: {기대 점수 향상}

### 2. ...

### 3. ...

---

## 상세 분석
{원칙별 상세 설명 — 접힌 섹션으로}
```

---

## 제약사항

- **Read-only**: 파일 생성/수정/삭제 금지
- 진단 도구: Glob, Grep, Read, Bash(읽기 전용 명령만) 사용
- 출력은 마크다운 리포트로만 제공
- 직접 수정 대신 "이렇게 하면 X점 향상" 형태로 제안
- 서브에이전트를 활용하여 메인 컨텍스트 보호
