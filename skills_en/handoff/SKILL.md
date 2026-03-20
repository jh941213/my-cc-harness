---
name: handoff
description: "Generate HANDOFF.md work handoff document before ending session. Triggers on: handoff, handoff, session cleanup, HANDOFF.md, pass work. NOT for: code writing, review."
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

# HANDOFF.md Generation

Generates a work handoff document before ending a session.

## What is HANDOFF.md?
A file that records work state before a context reset.
In a new session, just reading this file lets you immediately continue the work.

## Content to Generate

```markdown
# Work Handoff Document

## Completed Tasks
- [x] Completed task 1
- [x] Completed task 2

## In-Progress Tasks
- [ ] Currently working on
  - Progress: 70%
  - Next step: Implement ~~

## Tasks to Do Next
1. High priority task
2. Next task

## Notes
- Files not to touch: ~~
- Known bugs: ~~
- Temporary workarounds: ~~

## Related Files
- src/components/Login.tsx - Login form
- src/api/auth.ts - Auth API

## Last State
- Branch: feature/auth
- Last commit: abc1234
- Test status: Passing
```

## When to Use
- When context reaches 80-100k tokens
- After using /compact 3 times
- Before taking days off from work
- In the middle of complex tasks

In a new session, just say "Read HANDOFF.md and continue working."

## HANDOFF.md Size Guidelines
- Target maximum 100 lines, under 3000 characters
- Keep code snippets minimal (record file paths only)
- Record only key context; check details in the code
- Reduce initial token consumption in new sessions to save cache warmup cost
