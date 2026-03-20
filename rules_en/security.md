---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.py"
  - "**/*.env*"
---
# Security Rules

## Required Checks
- No hardcoded secrets -- use environment variables
- Prevent SQL injection (use parameterized queries)
- Prevent XSS (escape HTML)
- Always validate user input
- Never expose sensitive information in error messages

## When a Security Issue Is Found
1. Stop work immediately
2. Use the security-reviewer agent
3. Fix critical issues first
4. Review the entire codebase for similar issues
