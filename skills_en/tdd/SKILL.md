---
name: tdd
description: Test-driven development - write tests first, then implement. Triggers on "TDD", "test first", "test-driven", "RED-GREEN-REFACTOR". Anti-triggers: "implement first", "tests later".
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash
user-invocable: true
---

# TDD (Test-Driven Development)

Applies TDD methodology: write tests first, then implement code.

## TDD Cycle

```
RED -> GREEN -> REFACTOR -> REPEAT

RED:      Write a failing test
GREEN:    Write minimal code to pass the test
REFACTOR: Improve code (keeping tests passing)
REPEAT:   Next feature/scenario
```

## Procedure

1. **Define Interface** (SCAFFOLD)
   - Define types/interfaces first
   - Write function signatures

2. **Write Tests** (RED)
   - Happy path
   - Edge cases (empty values, null, max values)
   - Error cases

3. **Run Tests - Confirm Failure**
   ```bash
   npm test -- path/to/file.test.ts
   ```

4. **Minimal Implementation** (GREEN)
   - Only enough code to pass the tests

5. **Refactor** (REFACTOR)
   - Improve code while keeping tests passing

6. **Check Coverage**
   ```bash
   npm test -- --coverage
   ```
   - Target: 80% or higher

## Precautions

- Write tests first (before implementation!)
- Write only one test at a time
- Always verify the test fails first
- Write only minimal code
