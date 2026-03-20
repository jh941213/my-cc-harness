---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.py"
---
# Performance Rules

## Frontend
- Eliminate unnecessary re-renders (React.memo, useMemo, useCallback)
- Use code splitting (React.lazy)
- Optimize images (WebP, lazy loading)

## Backend
- Prevent N+1 queries
- Pagination is required
- Cache query results

## Checklist
- Review algorithms with O(n^2) or higher complexity
- Check bundle size
- Apply caching strategies
