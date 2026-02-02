---
name: commit-push-pr
description: 변경사항 커밋, 푸시, PR 생성을 한 번에 수행. "커밋", "PR", "푸시" 키워드에 활성화.
disable-model-invocation: true
allowed-tools: Bash, Read
---

# 커밋, 푸시, PR 생성

현재 변경사항을 커밋하고 푸시한 후 PR을 생성합니다.

## 현재 상태 확인
```bash
git status
git diff --stat
git log --oneline -5
```

## 작업 순서
1. 변경된 파일들을 확인하고 적절한 커밋 메시지 작성
2. 커밋 메시지는 한국어로, [타입] 형식 사용
3. 원격 브랜치로 푸시
4. GitHub PR 생성 (gh pr create 사용)
5. PR 제목과 본문도 한국어로 작성

## 커밋 메시지 형식
```
[타입] 제목

본문 (선택)

Co-Authored-By: Claude <noreply@anthropic.com>
```

타입: feat, fix, docs, style, refactor, test, chore

## 주의사항
- main/master 브랜치에서는 실행하지 않음
- 민감한 정보가 포함된 파일은 커밋하지 않음
- .env, credentials 파일 확인
