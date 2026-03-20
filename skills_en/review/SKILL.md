---
name: review
description: |
  Code review of changes on the current branch.
  Triggers: "review", "review", "inspection", "code review", "PR review", "check changes"
  Anti-triggers: "implementation", "code writing", "build"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# Code Review

Reviews changes on the current branch.

## Check Changes
```bash
git diff main...HEAD --stat
git log main...HEAD --oneline
```

## Review Checklist
1. **Functionality**: Does it meet the requirements?
2. **Bugs**: Any potential bugs or edge cases?
3. **Security**: Any security vulnerabilities?
4. **Performance**: Any performance issues?
5. **Readability**: Is the code easy to read?
6. **Tests**: Are tests sufficient?

## Output Format
Write review comments for each file.
Provide specific suggestions for areas needing improvement.

## CLAUDE.md Updates
Add patterns or mistakes discovered during review as rules to CLAUDE.md.
