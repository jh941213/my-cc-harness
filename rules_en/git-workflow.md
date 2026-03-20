---
paths:
  - ".git/**"
  - "**"
---
# Git Rules

## Branch Strategy
- main → develop → feature/<name>, fix/<bug>, refactor/<target>

## Commit Messages
- `[type] title` (50 characters or fewer)
- Types: feat, fix, docs, style, refactor, test, chore
- Co-Authored-By: Claude <noreply@anthropic.com>

## Pre-PR Checklist
- Tests, lint, and type checks must pass
- Assign reviewers; link related issues
