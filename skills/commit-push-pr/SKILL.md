---
name: commit-push-pr
description: >
  변경사항 커밋, 푸시, PR 생성을 한 번에 수행하는 워크플로우.
  트리거: "커밋", "PR 만들어", "푸시해", "PR 생성", "commit and push", "커밋하고 푸시", "PR 올려"
  안티-트리거: "코드 리뷰", "git log 확인", "diff 보여줘", "브랜치 목록"
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash, Read
---

# 커밋, 푸시, PR 생성

현재 변경사항을 커밋하고 푸시한 후 PR을 생성합니다.

## Step 1: 사전 검증

```bash
# 현재 브랜치 확인 — main/master면 STOP
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "BLOCKED: main/master 브랜치에서 직접 커밋 금지"
  exit 1
fi

# 상태 확인
git status
git diff --stat
git log --oneline -5
```

## Step 2: 위험 파일 확인

```bash
# 민감한 파일이 staged 되었는지 검사
git diff --cached --name-only | grep -E '\.(env|pem|key|credentials)' && echo "WARNING: 민감 파일 포함!"
```

## Step 3: 커밋

```bash
# 변경 파일 선택적 staging (git add -A 지양)
git add [specific-files]

# 커밋 메시지 작성
git commit -m "$(cat <<'EOF'
[타입] 제목 (50자 이내)

본문 (선택 — 무엇이 아닌 왜를 설명)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

타입: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Step 4: 푸시

```bash
# 원격 브랜치 설정 + 푸시
git push -u origin $(git branch --show-current)
```

## Step 5: PR 생성

```bash
gh pr create --title "[타입] 제목" --body "$(cat <<'EOF'
## 요약
- 변경 내용 1
- 변경 내용 2

## 테스트
- [ ] typecheck 통과
- [ ] lint 통과
- [ ] test 통과
EOF
)"
```

## 출력
완료 시 PR URL을 반환합니다.
