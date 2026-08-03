---
name: auto-memory
description: 레포에서 실질적인 작업(구현·수정·배포·디버깅)을 시작할 때, 새 레포를 처음 파악할 때, 작업을 마치고 기억할 지식이 생겼을 때 사용. 작업 유형에 맞는 docs·메모리만 선택적으로 로드하는 라우팅 테이블을 운영한다
---

# Auto-Memory (docs 라우팅 기반 선택적 메모리)

**원칙: 지식을 복사하지 않고 라우팅한다. 항상 로드되는 것은 라우팅 테이블뿐, 본문(docs·메모리)은 작업 유형이 매칭될 때만 Read한다.**

하네스가 이미 `{project}/docs/`에 문서를 만든다(/docs 스위트, DEPLOY.md, ARCHITECTURE.md 등). 이 문서들을 매번 컨텍스트에 다 넣을 수 없으므로, **특정 작업을 할 때 해당 docs가 로드되도록 라우팅**하는 것이 이 스킬의 역할이다.

## 저장 구조

```
{project}/memory/
├── INDEX.md      # 라우팅 테이블 (아래 형식) — 세션 시작·컴팩션 후 자동 주입, 가볍게 유지
└── {주제}.md     # docs에 집이 없는 지식만 (환경 특이사항, gotcha 등). docs가 있으면 만들지 않는다
```

INDEX.md 형식 (키워드 열은 훅이 결정적 힌트에 사용):

```markdown
# Memory Index (라우팅 테이블)

| 작업 유형 | 키워드 | 로드할 파일 |
|------|------|------|
| 배포/CI | 배포,deploy,docker,release,ci | docs/ops/cicd.md, DEPLOY.md |
| 아키텍처/설계 | 설계,구조,리팩토링,아키텍처 | docs/ARCHITECTURE.md |
| API 작업 | api,엔드포인트,라우터 | docs/api/ |
| 테스트 | 테스트,test,pytest | memory/testing.md |
```

## 동작 원리 (2중 라우팅)

1. **결정적 레이어(훅)**: `memory-route-hint.sh`(UserPromptSubmit)가 프롬프트에서 키워드를 감지하면 "이 작업은 X 유형 → 이 파일을 먼저 Read" **힌트 한 줄**을 주입 (문서 본문은 주입하지 않는다)
2. **모델 레이어(스킬)**: 힌트가 없어도 작업 시작 시 INDEX를 보고 유형을 분류해 매칭 파일만 Read — 매칭 없으면 아무것도 로드하지 않는다

## 워크플로우

### A. 초기화 (레포에 memory/INDEX.md가 없을 때)
1. 레포 파악: docs/ 전체 목록, README, DEPLOY.md류, CI 설정(.github/workflows), 매니페스트, 디렉토리 구조
2. **기존 docs를 작업 유형별로 분류해 INDEX.md 라우팅 행 생성** — docs가 진실의 원천, INDEX는 지도
3. docs에 집이 없는 지식(환경 특이사항 등)만 `memory/{주제}.md`로 생성 (빈 스텁 금지)

### B. 작업 시작 시 (선택적 로드)
1. 훅 힌트가 있으면 그 파일부터 Read
2. 없으면 작업 유형 분류 → INDEX 매칭 파일만 Read
3. 로드한 내용이 낡았으면(경로 소멸 등) 그 자리에서 INDEX/문서를 수정

### C. 작업 종료 시 (기록 라우팅)
"다음에 이 유형의 작업에서 필요한가?"가 기준. 우선순위:
1. **해당 지식을 소유한 docs가 있으면 그 docs를 갱신** (memory에 복사 금지)
2. docs에 집이 없으면 `memory/{주제}.md` 갱신 또는 생성 + INDEX 행 추가
3. 시간순 일지는 `tasks/lessons.md` (Stop 게이트 강제), 프로젝트를 넘는 지식은 `~/.claude/projects/*/memory/`
4. 새 docs가 생겼으면 INDEX에 라우팅 행 추가

### D. 장기 세션 (중기 메모리)
30분+ 작업이면 `tasks/context.md` 유지 (목표/핵심 결정/완료·다음/주요 파일). 컴팩션 후·세션 재시작 시 자동 재주입되므로 여기 적힌 것은 잊혀지지 않는다.

## 금지
- docs 내용을 memory/로 복사 (포인터/라우팅만)
- 인덱스 확인 없이 docs·memory 전체 로드
- 작업과 무관한 파일 로드
- 코드에서 파생 가능한 내용을 문서에 복사 — 코드가 진실의 원천
- 빈 주제 파일 미리 생성
