# E2E Verification — agent-browser Based

After `/verify` passes, verifies user flows via E2E testing in a real browser.
Uses **agent-browser** CLI's snapshot+ref system for stable accessibility-tree-based testing.

Input: $ARGUMENTS

## Execution Modes

### No arguments: `/e2e-verify`
- Auto-detect implemented features -> write tests -> run

### Specific feature: `/e2e-verify login`, `/e2e-verify checkout`
- E2E test only the specified feature

### Run existing tests: `/e2e-verify run`
- Run existing tests in `e2e/` directory only (no new test writing)

---

## Step 1: Prerequisites Check

```bash
# Check agent-browser installation
which agent-browser || echo "MISSING: npm install -g agent-browser && agent-browser setup"

# Check if app can be started
[ -f package.json ] && cat package.json | python3 -c "
import sys,json
s=json.load(sys.stdin).get('scripts',{})
for k in ['dev','start','serve']:
    if k in s: print(f'START_CMD: npm run {k}'); break
"

# Python (FastAPI/Flask)
[ -f pyproject.toml ] && echo "START_CMD: uvicorn main:app --port 3000"
```

If agent-browser is not installed: provide installation guide and stop.

## Step 2: Feature Analysis

### Auto-detection (when no arguments)
```bash
# Check recently changed route/page files
git diff --name-only HEAD~5..HEAD | grep -E "(page|route|view|screen)\.(tsx?|jsx?|py)" || true

# Next.js App Router
ls app/**/page.tsx 2>/dev/null

# React Router
grep -r "Route.*path=" src/ --include="*.tsx" -l 2>/dev/null

# FastAPI
grep -r "@app\.(get|post|put|delete)" --include="*.py" -l 2>/dev/null
```

Generate test target feature list from analysis:
```
Test targets:
1. /login — Login flow (email + password -> dashboard redirect)
2. /dashboard — Dashboard data loading + display
3. /settings — Settings change + save
```

## Step 3: Start Application

```bash
# Run app in background
npm run dev &
APP_PID=$!

# Wait for app ready (max 30 seconds)
for i in $(seq 1 30); do
  curl -s http://localhost:3000 > /dev/null 2>&1 && break
  sleep 1
done

# On failure
curl -s http://localhost:3000 > /dev/null 2>&1 || {
  echo "FAIL: App did not start within 30 seconds"
  kill $APP_PID 2>/dev/null
  exit 1
}
```

## Step 4: Write E2E Tests (using agent-browser)

Create per-feature test scripts in `e2e/` directory.

### Test Structure
```
e2e/
├── runner.sh              # Full test runner
├── test_login.sh          # Login flow
├── test_dashboard.sh      # Dashboard
├── test_settings.sh       # Settings
└── screenshots/           # Screenshots on failure
```

### Test Writing Pattern

**All tests follow this structure:**

```bash
#!/bin/bash
# e2e/test_[feature].sh
set -e

# Cleanup: close browser on test exit
cleanup() {
  agent-browser screenshot ./e2e/screenshots/$(basename $0 .sh)_$(date +%s).png 2>/dev/null || true
  agent-browser close 2>/dev/null || true
}
trap cleanup EXIT

BASE_URL="${BASE_URL:-http://localhost:3000}"

# -- 1. Open page --
agent-browser open "$BASE_URL/[path]"

# -- 2. Snapshot current state --
agent-browser snapshot -i
# Output example:
# - textbox "Email" [ref=e1]
# - textbox "Password" [ref=e2]
# - button "Sign In" [ref=e3]

# -- 3. Execute interactions --
agent-browser fill @e1 "test@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3

# -- 4. Verify results --
agent-browser wait url "**/dashboard"
agent-browser wait text "Welcome"

# -- 5. Additional verification (snapshot-based) --
SNAP=$(agent-browser snapshot -i)
echo "$SNAP" | grep -q "Dashboard" || {
  echo "FAIL: Dashboard heading not found"
  exit 1
}

echo "PASS: Login flow E2E test"
```

### agent-browser Core Command Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `open <url>` | Open page | `agent-browser open http://localhost:3000` |
| `snapshot -i` | Interactive element snapshot | For ref number identification |
| `snapshot -c -d 3` | Compact snapshot (depth 3) | For structure overview |
| `click @ref` | Click element | `agent-browser click @e2` |
| `fill @ref "text"` | Text input | `agent-browser fill @e1 "email@test.com"` |
| `text @ref` | Extract text | `agent-browser text @heading` |
| `wait text "msg"` | Wait for text | `agent-browser wait text "Success"` |
| `wait url "**/path"` | Wait for URL pattern | `agent-browser wait url "**/dashboard"` |
| `wait @ref` | Wait for element | `agent-browser wait @modal` |
| `isvisible @ref` | Check visibility | Verify modal closed |
| `screenshot ./path` | Screenshot | Debugging + failure recording |
| `drag @src @dst` | Drag and drop | Kanban boards etc. |
| `upload @ref "./file"` | File upload | File input fields |
| `eval "js"` | Execute JS | `agent-browser eval "document.title"` |
| `close` | Close browser | Used in cleanup |

### Snapshot-Based Adaptive Test Writing

The core of agent-browser is the **snapshot -> ref -> action** cycle.
Refs are refreshed with each snapshot, so never hardcode them:

```bash
# 1. Take snapshot
SNAP=$(agent-browser snapshot -i)

# 2. Dynamically extract refs from snapshot
EMAIL_REF=$(echo "$SNAP" | grep -oP 'textbox "Email" \[ref=\K[^\]]+')
SUBMIT_REF=$(echo "$SNAP" | grep -oP 'button "Submit" \[ref=\K[^\]]+')

# 3. Act with extracted refs
agent-browser fill @$EMAIL_REF "test@test.com"
agent-browser click @$SUBMIT_REF
```

## Step 5: Run Tests

### Full Runner (runner.sh)
```bash
#!/bin/bash
# e2e/runner.sh
set -e

PASSED=0
FAILED=0
RESULTS=""

for test in e2e/test_*.sh; do
  echo "=== Running: $test ==="
  if bash "$test"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: $test"
  else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: $test"
  fi
done

echo -e "\n=== E2E Results ==="
echo -e "$RESULTS"
echo "Passed: $PASSED / Failed: $FAILED"

[ $FAILED -eq 0 ] || exit 1
```

Execute:
```bash
bash e2e/runner.sh
```

## Step 6: Debug Cycle on Failure

```
FAIL detected
  |
1. Check screenshots (e2e/screenshots/)
  |
2. Reproduce in headed mode:
   agent-browser open http://localhost:3000 --headed
  |
3. Check console errors:
   agent-browser console --error
  |
4. Fix code (fix source code first, tests last)
  |
5. Re-run /verify (prevent regression)
  |
6. Re-run E2E test
  |
Max 3 retries. Escalate to user after 3 failures.
```

## Step 7: Results Report

```
## E2E Verify Results

| Test | Status | Duration |
|------|--------|----------|
| test_login.sh | PASS | 3.2s |
| test_dashboard.sh | PASS | 2.8s |
| test_settings.sh | FAIL -> PASS (2nd try) | 5.1s |

Total tests: 3
Passed: 3 (1 passed after retry)
Failed: 0

Fixed files:
- src/components/Settings.tsx: Fixed missing onClick handler
```

## Parallel Execution Support

`/e2e-verify` can run **in parallel** with `/verify` and `/simplify`.
However, passing `/verify` first is recommended (E2E will also fail if type/build errors exist).

**Recommended order:**
```
/verify -> (after pass) -> /e2e-verify + /simplify in parallel
```

**In TTH:**
```
Satya -> Agent(prompt="/verify") -> Confirm pass
     -> Agent(prompt="/e2e-verify", run_in_background=true)
     -> Agent(prompt="/simplify", run_in_background=true)
```

## Principles

- **Snapshot first**: Use `snapshot -i` -> `@ref` pattern over CSS selectors
- **No hardcoded waits**: Use `wait text "..."` / `wait url "..."` instead of `sleep 5`
- **Cleanup required**: Always `trap cleanup EXIT` to clean up browser
- **Screenshot recording**: Auto-screenshot on failure -> `e2e/screenshots/`
- **Fix code first**: On E2E failure, fix source code before modifying tests
