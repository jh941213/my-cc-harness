현재 프로젝트의 코드 변경사항을 분석하여 /docs/ 폴더에 문서를 자동 생성합니다.

입력: $ARGUMENTS

## 실행 방식

### 인자 없이 호출 시: `/docs`
- git diff로 최근 변경된 파일 기준으로 문서 생성/업데이트

### 인자 있을 시: `/docs api`, `/docs components`
- 특정 유형의 문서만 생성/업데이트

### 전체 생성: `/docs all`
- 프로젝트 전체 코드를 분석하여 /docs/ 일괄 생성

## 실행 프로세스

### Step 1: 변경사항 파악

```bash
git diff --name-only HEAD~5..HEAD 2>/dev/null
git diff --name-only
git diff --name-only --cached
```

인자가 `all`이면 전체 소스 파일을 대상으로 합니다.

### Step 2: docs-writer 에이전트 실행

docs-writer 에이전트(subagent_type: docs-writer)를 실행하여 문서를 생성합니다.

변경된 파일이 많으면 유형별로 서브에이전트를 **병렬** 실행:

**파일 수가 10개 이하**: 단일 docs-writer 에이전트로 처리
**파일 수가 10개 초과**: 유형별 병렬 실행
- Agent A: API 문서 (routes, endpoints)
- Agent B: 컴포넌트/훅 문서 (components, hooks)
- Agent C: 유틸/서비스/모델 문서 (utils, services, models)

### Step 3: 결과 확인

생성된 문서 목록을 보여주고, docs/README.md 인덱스를 업데이트합니다.

## 구현 에이전트와 병렬 실행 가이드

planner나 구현 에이전트가 작업할 때, docs-writer를 background로 함께 실행하는 패턴:

```
# 구현 Phase에서 이렇게 호출
Agent(subagent_type: "docs-writer", run_in_background: true, prompt: "...")
```

이렇게 하면 구현이 끝날 때쯤 문서도 함께 완성됩니다.

## 중요 규칙

- /docs/ 폴더만 수정 (소스 코드 절대 수정 금지)
- 기존 문서가 있으면 덮어쓰기가 아닌 업데이트 (Edit 우선)
- 설명은 한국어, 코드/변수명은 원문 유지
- 코드 읽으면 아는 것은 생략 — "왜"와 "언제"를 문서화
- 빈 유형은 문서 파일 생성하지 않음
