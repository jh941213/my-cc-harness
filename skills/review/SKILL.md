---
name: review
description: |
  현재 브랜치의 변경사항 코드 리뷰.
  트리거: "리뷰", "review", "검토", "코드 리뷰", "PR 리뷰", "변경사항 확인"
  안티-트리거: "구현", "코드 작성", "빌드"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# 코드 리뷰

현재 브랜치의 변경사항을 리뷰합니다.

## Step 1: 변경사항 수집
```bash
# 기본 브랜치 자동 감지
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
git diff ${BASE}...HEAD --stat
git log ${BASE}...HEAD --oneline
git diff ${BASE}...HEAD  # 전체 diff
```

## Step 2: 파일별 심층 리뷰

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
- [ ] 하드코딩된 시크릿/API 키
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

## Step 3: 출력 형식

```markdown
# 코드 리뷰: [브랜치명]

## 요약
[1-2문장 전체 평가]

## 파일별 리뷰

### path/to/file.ts
- ✅ [좋은 점]
- ⚠️ [경고] (라인 XX): [설명] → [제안]
- ❌ [차단] (라인 XX): [설명] → [수정 필요]

## 전체 의견
- 승인 / 수정 후 승인 / 재작업 필요
```

## Step 4: 반복 패턴 기록
리뷰 중 발견한 반복되는 패턴이나 실수는 프로젝트 CLAUDE.md에 규칙으로 추가합니다.
