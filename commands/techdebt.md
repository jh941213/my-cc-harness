# 기술 부채 정리

세션 종료 전 코드베이스의 기술 부채를 찾아 정리합니다.

## 검사 항목

### 1. 중복 코드
- 유사한 함수/로직이 여러 파일에 있는지 확인
- 공통 유틸리티로 추출 가능한 코드 식별

### 2. 사용하지 않는 코드
- 사용하지 않는 import 문
- 사용하지 않는 변수/함수
- 주석 처리된 코드 블록

### 3. 디버그 코드
- console.log / console.error
- debugger 문
- 임시 주석 (// TODO, // FIXME, // HACK, // XXX)

### 4. 코드 품질
- any 타입 사용 (TypeScript)
- 하드코딩된 값 (매직 넘버/스트링)
- 너무 긴 함수 (50줄 초과)
- 깊은 중첩 (4단계 초과)

## 실행 방법

1. 현재 프로젝트의 src 폴더 스캔
2. 위 항목들 검사
3. 발견된 문제 목록 출력
4. 사용자 확인 후 자동 수정

## 출력 형식

```
## 기술 부채 리포트

### 중복 코드 (3건)
- src/utils.ts:formatDate ↔ src/helpers.ts:formatDateTime
- ...

### 사용하지 않는 import (12건)
- src/components/Button.tsx: React (unused)
- ...

### 디버그 코드 (5건)
- src/api/auth.ts:23 - console.log
- ...

### 코드 품질 이슈 (8건)
- src/services/user.ts:45 - any 타입 사용
- ...

총 28건의 기술 부채가 발견되었습니다.
자동 수정을 진행할까요? (Y/n)
```

## 자동 수정 범위
- 사용하지 않는 import 제거
- console.log/debugger 제거
- 중복 코드는 리포트만 (수동 확인 필요)
