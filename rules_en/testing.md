---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
---
# Testing Rules

## Principles
- New feature = new tests
- Bug fix = add regression tests
- Refactoring = existing tests must be preserved

## Structure
- Follow the Arrange -> Act -> Assert pattern
- Write test descriptions in English

## Coverage
- New code: 80%+
- Core business logic: 90%+
- Utility functions: 100%
- The coverage gate is skipped when `coverage/coverage-summary.json` is absent (verify-task-quality hook behavior)
