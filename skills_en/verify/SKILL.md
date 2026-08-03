---
name: verify
description: "Code verification after task completion (typecheck, lint, test, build). Triggers on: verify, run tests, check build, typecheck. NOT for: E2E tests, code writing, implementation."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Edit
---

# Code Verification

> Identical to the verification the TaskCompleted hook (`verify-task-quality.sh`) runs automatically.
> Use this skill when the hook does not fire (manual verification requests, environments without the hook installed).

Verifies code after task completion. Run in order; proceed to the next step only after the current one passes.

## Step 1: Project Detection

| File | Stack | Typecheck | Lint | Test | Build |
|------|-------|-----------|------|------|-------|
| `package.json` | Node/TS | `npx tsc --noEmit` | `npx eslint .` / `npx biome check .` | `npx vitest run` / `npx jest` | `npm run build` |
| `pyproject.toml` | Python | `mypy .` / `pyright .` | `ruff check .` | `pytest -q` | — |
| `go.mod` | Go | `go vet ./...` | `golangci-lint run` | `go test ./...` | `go build ./...` |
| `Cargo.toml` | Rust | — | `cargo clippy` | `cargo test` | `cargo build` |

```bash
# Auto-detect
[ -f package.json ] && cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); print('\n'.join(f'{k}: {v}' for k,v in s.items()))"
[ -f pyproject.toml ] && echo "Python project detected"
[ -f go.mod ] && echo "Go project detected"
[ -f Cargo.toml ] && echo "Rust project detected"
```

## Step 2: Verification Order (fix immediately on failure)

### 2-1. TypeScript Typecheck
```bash
npx tsc --noEmit
```
On failure: fix type errors → re-run. After 3 failures, escalate to the user.

### 2-2. Lint
```bash
# ESLint
npx eslint . --max-warnings=0
# or Biome
npx biome check .
# Python
ruff check .
```
On failure: try `--fix` auto-fix → manual fix → re-run.

### 2-3. Tests
```bash
# Vitest
npx vitest run
# Jest
npx jest --passWithNoTests
# pytest
pytest -q
```
On failure: analyze failing tests → fix the code (modifying tests is a last resort) → re-run.

### 2-4. Build
```bash
npm run build
```
On failure: analyze build errors → fix → re-run.

### 2-5. Circular Dependency Detection (JS/TS projects)
```bash
npx madge --circular --extensions ts,tsx src/ 2>/dev/null
```
If circular dependencies are found: report as WARNING. Only newly introduced cycles are fix targets.

### 2-6. Dead Code Detection (JS/TS projects)
```bash
npx knip --no-exit-code 2>/dev/null | head -50
```
If unused exports/files/dependencies are found: report as INFO. Do not auto-fix.

### 2-7. Secret Scan
```bash
gitleaks detect --source . --no-git -v 2>&1 | head -20
```
If secrets are found: CRITICAL. Report immediately and drive a fix.

### 2-8. AI Slop Pattern Detection (ast-grep)
```bash
# Unnecessary console.log
sg --pattern 'console.log($$$)' --lang ts src/ 2>/dev/null | head -10
# any type usage
sg --pattern '$A as any' --lang ts src/ 2>/dev/null | head -10
```
If found: report as WARNING.

## Step 3: Result Report

| Step | Status | Details |
|------|--------|---------|
| typecheck | PASS/FAIL/SKIP | Error count or "tool not detected" |
| lint | PASS/FAIL/SKIP | Warning/error count |
| test | PASS/FAIL/SKIP | N passed, M failed |
| build | PASS/FAIL/SKIP | Success or error summary |
| circular | PASS/WARN/SKIP | Circular dependency count (madge) |
| deadcode | INFO/SKIP | Unused export/file count (knip) |
| secrets | PASS/CRITICAL/SKIP | Detected secret count (gitleaks) |
| ai-slop | PASS/WARN/SKIP | console.log/any count (ast-grep) |

**Verdict**: PASS = exit code 0, FAIL = 3 retries exhausted, SKIP = tool not detected
**Overall verdict**: Any CRITICAL → FAIL. All PASS/WARN/INFO/SKIP → PASS. Any FAIL among typecheck/lint/test/build → FAIL.

## Fix Strategy by Error Category

| Category | Priority | Fix Method |
|----------|----------|------------|
| TYPE | High | Extract file:line from output → Read the file → fix the type |
| LINT | Medium | `--fix` auto-fix first → manual fix |
| TEST | High | Analyze failing tests → fix the code (modifying tests is a last resort) |
| BUILD | High | Analyze build logs → check import/export issues first |

## Max Retries
Up to 3 attempts per step. After 3 failures, stop and report to the user.
