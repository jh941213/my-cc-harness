---
name: review
description: |
  Code review of changes on the current branch. Codex + Claude dual review.
  Triggers: "review", "inspection", "code review", "PR review", "check changes"
  Anti-triggers: "implementation", "code writing", "build"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# Code Review (Codex + Claude Dual Review)

Reviews changes on the current branch from two perspectives: Codex (latest installed model) and Claude.

## Step 0: Codex Review (1st pass)

Run the first-pass review with the Codex plugin:

```
/codex:review
```

After receiving the Codex review results, proceed to Step 1 for a second-pass review from Claude's perspective.
Merge both review results into the final report.

**Fallback**: If the codex plugin is not installed, skip Step 0 and go straight to Step 1. Do not fabricate Codex results that do not exist — in that case, mark the Codex section of the final report as "not run (plugin not installed)".

## Step 1: Collect Changes
```bash
# Auto-detect base branch
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
git diff ${BASE}...HEAD --stat
git log ${BASE}...HEAD --oneline

# Structural diff (ignores formatting changes, shows logic changes only)
GIT_EXTERNAL_DIFF=difft git diff ${BASE}...HEAD 2>/dev/null || git diff ${BASE}...HEAD
```

## Step 2: In-Depth Per-File Review (Claude 2nd pass)

Apply the checklist below to each changed file:

### Functionality (required)
- [ ] Does it meet the requirements?
- [ ] Edge cases handled (null, empty values, boundary values)
- [ ] Is error handling adequate?

### Bugs (required)
- [ ] Off-by-one errors
- [ ] Async race conditions
- [ ] Type safety (any usage, type assertion abuse)

### Security (required)
- [ ] Hardcoded secrets/API keys — auto-scan with `gitleaks detect --source . --no-git -v`
- [ ] SQL/XSS/command injection
- [ ] User input validation
- [ ] If a security issue is found → escalate to the security-reviewer agent

### Performance
- [ ] N+1 queries, unnecessary loops
- [ ] Bundle size impact (large library additions)
- [ ] Potential memory leaks

### Code Quality
- [ ] Functions under 50 lines / files under 800 lines
- [ ] Nesting 4 levels or less
- [ ] Naming explains intent
- [ ] No unnecessary abstraction

### Tests
- [ ] Do new features have new tests?
- [ ] Do bug fixes have regression tests?
- [ ] Do existing tests still pass?

## Severity Classification

| Level | Meaning | Examples |
|-------|---------|----------|
| **CRITICAL** | Blocks merge. Security/data loss/crash | SQL injection, auth bypass, null reference |
| **WARNING** | Fix recommended. May become a problem later | N+1 query, any type, missing error handling |
| **INFO** | For reference. Optional improvement | Naming improvement, minor duplication |

## What NOT to Flag (False Positive Prevention)
- Code style/formatting (that's the linter/formatter's job)
- Problems in unchanged existing code (outside the diff)
- Subjective naming preferences ("I would name it this way")
- Import order
- Line break/whitespace style

## Step 3: Output Format

Each finding in structured form:

```
[CRITICAL] [Security] (src/api/auth.ts:42): User input inserted directly into SQL query
→ Fix: use parameterized queries

[WARNING] [Performance] (src/hooks/useData.ts:15): Object literal in useEffect dependency array
→ Fix: wrap in useMemo or use individual properties as dependencies
```

### Full Review Report
```markdown
# Code Review: [branch name]

## Summary
[1-2 sentence overall assessment]
- CRITICAL: N / WARNING: N / INFO: N

## Per-File Review

### path/to/file.ts
- [CRITICAL] (line XX): [description] → [fix]
- [WARNING] (line XX): [description] → [suggestion]

## Verdict
- **Approve** — 0 CRITICAL
- **Approve after fixes** — 0 CRITICAL, some WARNING
- **Rework** — 1+ CRITICAL
```

For how the receiving side should handle review feedback, see `~/.claude/rules/code-review-reception.md` (review-reception rules).

## Step 4: Dual Review Synthesis

Add the following sections to the final report:

```markdown
## Codex Review Results
[Summary of issues found by Codex]

## Additional Claude Findings
[Issues Codex missed but Claude found]

## Cross-Validation
[Items flagged by both reviewers — high confidence]
```

## Step 5: Structural Analysis (automated)
```bash
# Shell state does not persist between bash calls — redefine BASE in this block
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Circular dependency check (JS/TS)
npx madge --circular --extensions ts,tsx src/ 2>/dev/null

# AI slop patterns (ast-grep)
sg --pattern 'console.log($$$)' --lang ts 2>/dev/null | head -10
sg --pattern '$A as any' --lang ts 2>/dev/null | head -10

# Secret scan (gitleaks)
gitleaks detect --source . --no-git -v 2>&1 | head -20

# Code stats (scc) — changed files only
scc $(git diff ${BASE}...HEAD --name-only) 2>/dev/null
```

## Step 6: Record Recurring Patterns
Record recurring patterns or mistakes discovered during review in `progress.txt`.
