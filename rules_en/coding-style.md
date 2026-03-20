---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# Coding Style (Non-Standard Rules Only)

## Immutability (Required)
- Always create new objects/arrays; never mutate
- Use immutable patterns such as spread operator, map, filter, etc.

## File Organization
- Many small files > few large files
- Functions: 50 lines or fewer; Files: 800 lines or fewer
- Organize by feature/domain, not by type

## Code Quality
- No deep nesting (extract when exceeding 4 levels)
- Names must convey intent
- Always validate user input (Zod recommended)
