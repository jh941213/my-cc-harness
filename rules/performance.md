---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.py"
---
# 성능 규칙

## 프론트엔드
- 불필요한 리렌더링 제거 (React.memo, useMemo, useCallback)
- 코드 스플리팅 사용 (React.lazy)
- 이미지 최적화 (WebP, lazy loading)

## 백엔드
- N+1 쿼리 방지
- 페이지네이션 필수
- 쿼리 결과 캐싱

## 체크리스트
- O(n^2) 이상 알고리즘 검토
- 번들 사이즈 확인
- 캐싱 전략 적용
