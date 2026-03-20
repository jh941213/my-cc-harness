---
name: simplify
description: "Code simplification and refactoring -- reviews changed code and removes unnecessary abstractions, duplication, and complexity. Triggers on: simplify, simplify, refactoring, code cleanup, code improvement. NOT for: adding new features, bug fixes."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Edit, Grep
---

# Code Simplification

Reviews and simplifies recently written code.

## Review Items
1. Remove unnecessary abstractions
2. Clean up duplicate code
3. Simplify complex conditionals
4. Improve variable/function names
5. Remove unnecessary comments
6. Remove console.log

## Principles
- Do not change behavior (refactoring only)
- If tests exist, verify tests pass
- Avoid excessive optimization

## Checklist
- [ ] Functions under 50 lines
- [ ] Files under 800 lines
- [ ] Nesting under 4 levels
- [ ] Magic numbers removed
- [ ] Clear variable names
