# 실행 계획: Opus 5 세대 하네스 업그레이드

- 날짜: 2026-07-27
- 목표: 컨셉(TTH 사일로 + Ralph Loop + 백프레셔 + 교차검증)은 유지하면서, 프롬프트·하네스를 Claude 5 세대(Opus 5)에 최적화하고, docs 스킬 스위트와 Claude Code 신기능 시너지를 추가한다.
- done-when: `scripts/validate-harness.sh` 오류 0 + harness-audit S등급(21+/24) + 신규 docs 스킬 동작 검증

## 리서치 소스

1. Anthropic 공식 마이그레이션 가이드 — "Migrating to Claude Opus 5" 행동 변화 섹션
2. keyflow 블로그 "Claude 5 시대의 Context Engineering" (2026-07-27, @ekyu)
3. Claude Code 2026 신기능 조사 (changelog, skills/hooks/plugins 스펙)
4. 문서화 프레임워크 조사 (C4, arc42, Diátaxis, docs-as-code CI/CD)

## 진단 결과 (현재 상태)

- 구조 검증 베이스라인: 오류 0, 경고 5 (실행권한 1건 수정 완료, 한/영 패리티 갭 4건)
- CLAUDE.md: Claude 4.x 세대 전제 다수 —
  - "똑똑한 주니어" 마인드셋 + "모호하면 멈추고 질문" (Opus 5는 자율성↑, 사소한 질문 차단 필요)
  - "서브에이전트 적극 활용" (Opus 5는 기본적으로 위임 과다 — 역방향 캡 필요)
  - "토큰 150k 전에 /compact, 3번 후 /clear" (1M 컨텍스트 시대에 구식)
  - 완료 전 검증 강제 스캐폴딩 (Opus 5는 자가 검증 — 강제 지시는 과잉 검증 유발)
- CLAUDE.md ↔ rules/ ↔ commands/ 간 규칙 중복 (병렬 실행, 검증 원칙 등)
- 플러그인(plugin.json)이 skills만 배포 — commands/agents/hooks 미포함 (현행 스펙은 전부 지원)
- docs 계열: docs-writer(코드 레벨 문서만) + /docs 커맨드 + docs-sync.sh 훅 존재.
  아키텍처 구성도/인터페이스 구성도/매뉴얼/운영 문서/CI 연동은 부재

## 변경 원칙 (Opus 5 튜닝)

공식 마이그레이션 가이드의 행동 변화에 근거:

| # | Opus 5 특성 | 하네스 대응 |
|---|------------|------------|
| 1 | 지시를 문자 그대로 따름 | CRITICAL/MUST/절대 류 과격 지시 → 조건이 명시된 평서형 지시로 완화 |
| 2 | 자가 검증 내장 | "재검증하라/더블체크하라" 강제 스캐폴딩 삭제. 검증은 결정적 게이트(hooks)가 담당 |
| 3 | 서브에이전트 위임 과다 경향 | "적극 활용" → 위임 기준 + 스폰 상한 명시 |
| 4 | 응답/산출물 장황화 경향 | 간결성 지침 + 산출물 길이 캘리브레이션 추가 |
| 5 | 범위 확장 경향 | 범위 규율(scope discipline) 지침 추가 — 기존 Minimal Impact 원칙과 결합 |
| 6 | 사소한 결정도 질문 경향 | 소소한 선택은 스스로, 파괴적/범위 변경만 질문 |
| 7 | 1M 컨텍스트 기본 | compact 규칙 완화, 캐시 보존 규칙은 유지 |
| 8 | 자기 수정 내레이션 과다 | 결과를 바꾸는 수정만 언급하도록 지침 추가 |

keyflow/Anthropic context engineering 원칙:
- CLAUDE.md = 내비게이션 맵 (규칙 저장소 아님) — 중복 제거, 단일 소유
- Progressive disclosure — 세부 규칙은 rules/skills로, 트리거 명확화
- 코드/파일 레퍼런스 우선

## 작업 목록

### A. 프롬프트 현대화 (컨셉 유지)
- [ ] CLAUDE.md 재작성 (경량화 + Opus 5 튜닝 + 중복 제거)
- [ ] CLAUDE_EN.md 동기화
- [ ] rules/ 점검: 모델 세대 민감 문구 수정 (탐색 에이전트 결과 기반)
- [ ] commands/tth.md: Opus 4.6 인용 갱신, 컨텍스트 수치 갱신
- [ ] agents/: model 필드 확인 (별칭 유지), 과잉 지시 완화

### B. docs 스킬 스위트 (신규)
- [ ] skills/docs-architecture: ARCHITECTURE.md + C4 mermaid 구성도 + ADR
- [ ] skills/docs-interface: API 구성도 + 인터페이스 문서 (OpenAPI/시퀀스/ERD)
- [ ] skills/docs-manual: 사용자 매뉴얼 + 운영자 매뉴얼/런북 (Diátaxis)
- [ ] skills/docs-ops: CI/CD OPS 문서 + docs 파이프라인(GitHub Actions) 생성
- [ ] commands/docs.md 확장: arch|api|manual|ops|sync|all 라우팅
- [ ] agents/docs-writer.md 확장: 신규 문서 유형 인지
- [ ] docs drift 감지: docs-sync 스킬 or 기존 훅 확장

### C. Claude Code 신기능 시너지
- [ ] plugin.json: commands/agents/hooks 포함 풀 패키지화 (스펙 확인 후)
- [ ] 스킬 frontmatter 최신 필드 정비 (리서치 결과 반영)
- [ ] settings.json 스키마 점검
- [ ] install.sh 갱신 (신규 컴포넌트 + 개수)

### D. 검증 (/goal valid 루프)
- [x] scripts/validate-harness.sh 제작 + 베이스라인
- [ ] .github/workflows/validate.yml — 하네스 자체 CI
- [ ] harness-audit 8차원 자체 평가 → S등급까지 반복
- [ ] 한/영 패리티 갭 해소

## 회고 (완료 후 작성)

- 계획 대비 실제:
- drift 발생 여부:
- 개선점:
