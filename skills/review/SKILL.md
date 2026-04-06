---
name: review
description: |
  현재 브랜치의 변경사항 코드 리뷰. Codex + Claude 듀얼 리뷰.
  트리거: "리뷰", "review", "검토", "코드 리뷰", "PR 리뷰", "변경사항 확인"
  안티-트리거: "구현", "코드 작성", "빌드"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# 코드 리뷰 (Codex + Claude 듀얼 리뷰)

현재 브랜치의 변경사항을 Codex(GPT-5.4)와 Claude 두 관점에서 리뷰합니다.

## Step 0: Codex 리뷰 (1차 — GPT-5.4)

Codex 플러그인으로 1차 리뷰를 실행한다:

```
/codex:review
```

Codex 리뷰 결과를 수신한 후, Step 1로 진행하여 Claude 관점에서 2차 리뷰를 수행한다.
두 리뷰 결과를 종합하여 최종 보고서에 병합한다.

## Step 1: 변경사항 수집
```bash
# 기본 브랜치 자동 감지
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
git diff ${BASE}...HEAD --stat
git log ${BASE}...HEAD --oneline

# 구조적 diff (포매팅 변경 무시, 로직 변경만 표시)
GIT_EXTERNAL_DIFF=difft git diff ${BASE}...HEAD 2>/dev/null || git diff ${BASE}...HEAD
```

## Step 2: 파일별 심층 리뷰 (Claude 2차)

각 변경 파일에 대해 아래 체크리스트 적용:

### 기능 (필수)
- [ ] 요구사항을 충족하는가?
- [ ] 엣지 케이스 처리 (null, 빈 값, 경계값)
- [ ] 에러 핸들링이 적절한가?

### 버그 (필수)
- [ ] 오프바이원 에러
- [ ] 비동기 race condition
- [ ] 타입 안전성 (any 사용, 타입 단언 남용)

### 보안 (필수)
- [ ] 하드코딩된 시크릿/API 키 — `gitleaks detect --source . --no-git -v` 로 자동 스캔
- [ ] SQL/XSS/명령어 인젝션
- [ ] 사용자 입력 검증
- [ ] 보안 이슈 발견 시 → security-reviewer 에이전트 에스컬레이션

### 성능
- [ ] N+1 쿼리, 불필요한 루프
- [ ] 번들 크기 영향 (큰 라이브러리 추가)
- [ ] 메모리 누수 가능성

### 코드 품질
- [ ] 함수 50줄 / 파일 800줄 이내
- [ ] 중첩 4단계 이하
- [ ] 네이밍이 의도를 설명
- [ ] 불필요한 추상화 없음

### 테스트
- [ ] 새 기능에 새 테스트 있는가?
- [ ] 버그 수정에 회귀 테스트 있는가?
- [ ] 기존 테스트가 깨지지 않는가?

## 심각도 분류

| 레벨 | 의미 | 예시 |
|------|------|------|
| **CRITICAL** | 머지 차단. 보안/데이터 손실/크래시 | SQL 인젝션, 인증 우회, null 참조 |
| **WARNING** | 수정 권장. 향후 문제 될 수 있음 | N+1 쿼리, any 타입, 누락된 에러 핸들링 |
| **INFO** | 참고. 선택적 개선 | 네이밍 개선, 약간의 중복 |

## 지적하지 않을 것 (False Positive 방지)
- 코드 스타일/포매팅 (린터/포매터 역할)
- 변경되지 않은 기존 코드의 문제 (diff 범위 밖)
- 주관적 네이밍 선호 ("나라면 이렇게 이름 짓겠다")
- import 순서
- 줄바꿈/공백 스타일

## Step 3: 출력 형식

각 발견 사항은 구조화된 형식으로:

```
[CRITICAL] [보안] (src/api/auth.ts:42): 사용자 입력이 SQL 쿼리에 직접 삽입됨
→ 수정: parameterized query 사용

[WARNING] [성능] (src/hooks/useData.ts:15): useEffect 의존성 배열에 객체 리터럴
→ 수정: useMemo로 감싸거나 개별 프로퍼티를 의존성으로
```

### 전체 리뷰 보고서
```markdown
# 코드 리뷰: [브랜치명]

## 요약
[1-2문장 전체 평가]
- CRITICAL: N건 / WARNING: N건 / INFO: N건

## 파일별 리뷰

### path/to/file.ts
- [CRITICAL] (라인 XX): [설명] → [수정 방법]
- [WARNING] (라인 XX): [설명] → [제안]

## 판정
- **승인** — CRITICAL 0건
- **수정 후 승인** — CRITICAL 0건, WARNING 있음
- **재작업** — CRITICAL 1건 이상
```

## Step 4: 듀얼 리뷰 종합

최종 보고서에 다음 섹션을 추가:

```markdown
## Codex (GPT-5.4) 리뷰 결과
[Codex가 발견한 이슈 요약]

## Claude 추가 발견
[Codex가 놓쳤지만 Claude가 발견한 이슈]

## 교차 검증
[두 리뷰어가 동시에 지적한 항목 — 높은 신뢰도]
```

## Step 5: 구조 분석 (자동)
```bash
# 순환참조 검사 (JS/TS)
npx madge --circular --extensions ts,tsx src/ 2>/dev/null

# AI 슬롭 패턴 (ast-grep)
sg --pattern 'console.log($$$)' --lang ts 2>/dev/null | head -10
sg --pattern 'as any' --lang ts 2>/dev/null | head -10

# 시크릿 스캔 (gitleaks)
gitleaks detect --source . --no-git -v 2>&1 | head -20

# 코드 통계 (scc) — 변경 파일만
scc $(git diff ${BASE}...HEAD --name-only) 2>/dev/null
```

## Step 6: 반복 패턴 기록
리뷰 중 발견한 반복 패턴이나 실수는 `progress.txt`에 기록합니다.
