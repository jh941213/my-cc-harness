---
name: techdebt
description: Technical debt cleanup - inspects and cleans up duplicate code, console.log, unused imports, etc. Recommended before ending a session. Triggers on "technical debt", "techdebt", "console.log cleanup", "unused imports", "code cleanup". Anti-triggers: "add new features", "refactoring".
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Edit, Bash
user-invocable: true
---

# Technical Debt Cleanup

Finds and cleans up technical debt in the codebase before ending a session.

## Inspection Items

### 1. Duplicate Code
- Check if similar functions/logic exist across multiple files
- Identify code that could be extracted into common utilities

### 2. Unused Code
- Unused import statements
- Unused variables/functions
- Commented-out code blocks

### 3. Debug Code
- console.log / console.error
- debugger statements
- Temporary comments (// TODO, // FIXME, // HACK, // XXX)

### 4. Code Quality
- any type usage (TypeScript)
- Hardcoded values (magic numbers/strings)
- Functions that are too long (over 50 lines)
- Deep nesting (over 4 levels)

## Inspection Commands
```bash
# Find console.log
grep -r "console\." --include="*.ts" --include="*.tsx" src/

# Find TODO comments
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" src/

# Find any types
grep -rn ": any" --include="*.ts" --include="*.tsx" src/
```

## Output Format
```
## Technical Debt Report

### Duplicate Code (3 items)
- src/utils.ts:formatDate <-> src/helpers.ts:formatDateTime

### Unused Imports (12 items)
- src/components/Button.tsx: React (unused)

### Debug Code (5 items)
- src/api/auth.ts:23 - console.log

### Code Quality Issues (8 items)
- src/services/user.ts:45 - any type usage

Total 28 technical debt items found.
Proceed with automatic fixes? (Y/n)
```

## Auto-Fix Scope
- Remove unused imports
- Remove console.log/debugger
- Duplicate code: report only (manual review needed)
