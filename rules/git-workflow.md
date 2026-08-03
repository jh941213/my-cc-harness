---
paths:
  - ".git/**"
  - "**"
---
# Git 규칙

## 브랜치 전략
- main → develop → feature/기능명, fix/버그명, refactor/대상

## 커밋 메시지
- `[타입] 제목` (50자 이내)
- 타입: feat, fix, docs, style, refactor, test, chore
- 예외: /tth 커밋은 `[tth] S{N}: 제목` 형식 사용
- Co-Authored-By: Claude <noreply@anthropic.com>

## PR 전 확인
- 테스트, 린트, 타입체크 통과
- 리뷰어 지정, 관련 이슈 연결
