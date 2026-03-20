---
name: build-fix
description: >
  Workflow for incrementally fixing TypeScript and build errors.
  Triggers: "build error", "build error", "compile error", "tsc error", "type error", "build failure", "build fix"
  Anti-triggers: "runtime error", "test failure", "lint errors only", "deployment error"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Edit, Bash, Grep
---

# Build Error Fix

Incrementally fixes TypeScript and build errors.

## Procedure

1. **Run Build**
   ```bash
   npm run build
   # or
   pnpm build
   ```

2. **Analyze Errors**
   - Group by file
   - Sort by severity

3. **Fix Each Error**
   - Check error context (5 lines before and after)
   - Describe the problem
   - Suggest and apply fix
   - Re-run build
   - Confirm error is resolved

4. **Stop Conditions**
   - When a fix causes new errors
   - When the same error persists after 3 attempts
   - On user request

5. **Summary Output**
   - Number of errors fixed
   - Number of remaining errors
   - Newly introduced errors

## Principles

- Fix only one error at a time
- Always re-verify build after each fix
- Consider rollback if new errors are introduced
