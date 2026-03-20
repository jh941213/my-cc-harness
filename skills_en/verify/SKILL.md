---
name: verify
description: "Code verification after task completion (typecheck, lint, test, build). Triggers on: verify, verify, run tests, check build, typecheck. NOT for: E2E tests, code writing, implementation."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep
---

# Code Verification

Verifies code after task completion.

## Verification Order
1. TypeScript type check (if applicable)
2. Run lint
3. Run tests
4. Run build

## Execution Commands
```bash
# Check package.json scripts
cat package.json | grep -A 20 '"scripts"'

# Typical verification order
npm run typecheck || npx tsc --noEmit
npm run lint
npm test
npm run build
```

## Verification Loop
When an error occurs at any step:
1. Fix immediately
2. Re-verify
3. Repeat until all pass
