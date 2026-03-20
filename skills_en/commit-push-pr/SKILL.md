---
name: commit-push-pr
description: >
  Workflow for committing changes, pushing, and creating PRs in one step.
  Triggers: "commit", "create PR", "push", "PR creation", "commit and push", "commit and push", "submit PR"
  Anti-triggers: "code review", "check git log", "show diff", "branch list"
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash, Read
---

# Commit, Push, PR Creation

Commits current changes, pushes, and creates a PR.

## Check Current State
```bash
git status
git diff --stat
git log --oneline -5
```

## Workflow
1. Review changed files and compose an appropriate commit message
2. Use [type] format for commit messages
3. Push to remote branch
4. Create GitHub PR (using gh pr create)
5. Write PR title and body

## Commit Message Format
```
[type] Title

Body (optional)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: feat, fix, docs, style, refactor, test, chore

## Precautions
- Do not run on main/master branch
- Do not commit files containing sensitive information
- Check for .env, credentials files
