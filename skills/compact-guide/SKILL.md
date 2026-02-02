---
name: compact-guide
description: 컨텍스트 관리 가이드. "컨텍스트", "토큰", "compact" 키워드에 활성화.
disable-model-invocation: false
user-invocable: true
---

# 컨텍스트 관리 가이드

컨텍스트는 신선한 우유와 같습니다. 시간이 지나면 상합니다.

## 핵심 규칙
- 토큰 80-100k 넘기 전에 리셋
- 3-5개 작업마다 컨텍스트 정리
- /compact 3번 후 /clear

## 명령어

### /compact
- 대화 내용을 요약해서 압축
- 중요한 정보는 유지, 토큰만 줄임
- 작업 흐름이 끊기지 않음

### /clear
- 완전히 초기화
- HANDOFF.md 없으면 위험!
- 깨끗하게 시작하고 싶을 때

## 권장 패턴

```
작업 시작
    ↓
3-5개 작업 완료
    ↓
/compact (토큰 압축)
    ↓
3-5개 작업 완료
    ↓
/compact
    ↓
3-5개 작업 완료
    ↓
/compact
    ↓
/handoff (HANDOFF.md 생성)
    ↓
/clear (초기화)
    ↓
새 세션에서 HANDOFF.md 읽기
```

## 주의
200k 토큰까지 쓸 수 있지만, 80-100k 넘으면 품질 저하!
