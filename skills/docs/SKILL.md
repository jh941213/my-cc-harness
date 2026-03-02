---
name: docs
description: 현재 프로젝트의 코드 변경사항을 분석하여 /docs/ 폴더에 문서를 자동 생성합니다. 구현 에이전트와 병렬로 background에서 실행되거나 수동 호출됩니다. "문서", "docs", "문서화" 키워드에 활성화.
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

현재 프로젝트의 코드 변경사항을 분석하여 /docs/ 폴더에 문서를 자동 생성합니다.

입력: $ARGUMENTS

## 사용법

- `/docs` — 최근 변경된 파일 기준으로 문서 생성/업데이트
- `/docs api` — API 문서만 생성
- `/docs components` — 컴포넌트 문서만 생성
- `/docs all` — 프로젝트 전체 코드 분석하여 일괄 생성

## 실행 프로세스

### Step 1: 변경사항 파악

```bash
git diff --name-only HEAD~5..HEAD 2>/dev/null
git diff --name-only
git diff --name-only --cached
```

### Step 2: 파일 유형별 문서 생성

| 파일 패턴 | 문서 유형 | 출력 |
|-----------|----------|------|
| `**/api/**`, `**/routes/**` | API 문서 | `docs/api.md` |
| `**/components/**/*.tsx` | 컴포넌트 | `docs/components.md` |
| `**/hooks/**` | 훅 | `docs/hooks.md` |
| `**/utils/**`, `**/lib/**` | 유틸리티 | `docs/utils.md` |
| `**/models/**`, `**/schema/**` | 데이터 모델 | `docs/models.md` |
| `**/services/**` | 서비스 | `docs/services.md` |
| `*.config.*`, `docker*` | 설정 | `docs/setup.md` |

변경 파일이 10개 초과 시 유형별 서브에이전트 병렬 실행.

### Step 3: CHANGELOG 및 인덱스 업데이트

- `docs/CHANGELOG.md`에 Added/Changed/Removed 추가
- `docs/README.md` 문서 인덱스 업데이트

## 문서 작성 원칙

**"코드를 읽으면 아는 것은 쓰지 않는다."**

- 함수 시그니처 나열 ❌ → **왜 이 설계인지, 어떻게 써야 하는지** ✅
- 코드 복붙 ❌ → **복붙 가능한 사용 예시 + 주의사항** ✅
- 모든 것 문서화 ❌ → **변경된 것, 중요한 것만** ✅
- 설명은 한국어, 코드/변수명은 원문 유지
- 기존 문서 있으면 Edit로 업데이트 (덮어쓰기 금지)

## 병렬 실행 패턴

planner가 구현 계획을 세울 때 docs-writer를 background로 병렬 실행:

```
구현 Phase:
├─ frontend-developer (foreground): UI 구현
├─ 백엔드 에이전트 (foreground): API 구현
└─ docs-writer (background): 변경 감지 → /docs/ 생성
```

## 중요 규칙

- /docs/ 폴더만 수정 (소스 코드 절대 수정 금지)
- 빈 유형은 문서 파일 생성하지 않음
