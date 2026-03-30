# Code Verification Pipeline

Automatically verifies code quality after task completion. Auto-fixes on failure and re-verifies.

Input: $ARGUMENTS

## Execution Modes

### No arguments: `/verify`
- Run full pipeline (typecheck -> lint -> test -> build -> security)

### Specific step: `/verify typecheck`, `/verify test`
- Run only the specified step

### Quick mode: `/verify quick`
- Run typecheck + lint only (skip build/test)

---

## Step 1: Project Detection

```bash
# Auto-detect project type
[ -f package.json ] && echo "NODE" && cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); print('\n'.join(f'{k}: {v}' for k,v in s.items()))"
[ -f pyproject.toml ] && echo "PYTHON"
[ -f Cargo.toml ] && echo "RUST"
[ -f go.mod ] && echo "GO"
```

Automatically selects verification tools based on detected project type.

## Step 2: Verification Pipeline (Sequential, Auto-fix on Failure)

Each step retries **up to 3 times**. Failure -> auto-fix -> re-run. Escalate to user after 3 failures.

### 2-1. TypeScript Typecheck / Python Typecheck

**Node.js/TypeScript:**
```bash
npx tsc --noEmit 2>&1
```

**Python:**
```bash
mypy . --ignore-missing-imports 2>&1 || ruff check . --select=E 2>&1
```

On failure:
1. Extract file:line from error message
2. Read the file -> fix type error
3. Re-run

### 2-2. Lint

**Node.js:**
```bash
# ESLint (if available)
npx eslint . --max-warnings=0 2>&1
# Biome (if available)
npx biome check . 2>&1
```

**Python:**
```bash
ruff check . 2>&1
```

On failure:
1. Try `--fix` auto-fix first: `npx eslint . --fix` / `ruff check . --fix`
2. Manually fix items that can't be auto-fixed
3. Re-run

### 2-3. Tests

**Node.js:**
```bash
# Vitest
npx vitest run 2>&1
# Jest
npx jest --passWithNoTests 2>&1
```

**Python:**
```bash
pytest -q 2>&1
```

On failure:
1. Analyze failed test file and error message
2. **Fix the code** (fixing tests is last resort -- only when tests verify intended behavior)
3. Re-run

### 2-4. Build

```bash
npm run build 2>&1
```

On failure:
1. Analyze build error (import paths, env vars, type mismatches)
2. Fix -> re-run

### 2-5. Security Audit (Optional)

```bash
# Node.js
npm audit --audit-level=high 2>&1
# Python
pip-audit 2>&1 || safety check 2>&1
```

Report critical/high vulnerabilities. Do not auto-fix (dependency upgrades require user judgment).

## Step 3: Results Report

Summary report after all steps complete:

```
## Verify Results

| Step | Status | Notes |
|------|--------|-------|
| typecheck | PASS | 0 errors |
| lint | PASS | 0 warnings |
| test | PASS | 42 passed, 0 failed |
| build | PASS | Success |
| security | WARN | 1 high (report only) |

Total fixes: 3 files
- src/api/handler.ts: Fixed type error
- src/utils/format.ts: Removed unused import
- src/components/Form.tsx: Fixed lint warning
```

## Parallel Execution Support

`/verify` can run **in parallel** with `/e2e-verify` and `/simplify`:

```
# User direct parallel invocation
/verify && /e2e-verify && /simplify

# TTH Satya parallel spawn
Agent(prompt="/verify", run_in_background=true)
Agent(prompt="/e2e-verify", run_in_background=true)
Agent(prompt="/simplify", run_in_background=true)
```

Each command modifies different files, so no conflicts:
- `/verify`: Fixes source code (type/lint errors)
- `/e2e-verify`: Only modifies `e2e/` directory
- `/simplify`: Refactors source code (recommended after verify)

## Principles

- Never ignore failures -- fix every error or escalate
- Fix code before fixing tests
- Try `--fix` auto-fix first
- Stop and report after 3 failures
