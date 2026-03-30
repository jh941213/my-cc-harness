# Full Verification — verify + e2e-verify + simplify Integrated Pipeline

Runs code verification -> E2E browser testing (agent-browser) -> AI slop cleanup in one go.
Orchestrates 3 commands with correct ordering and parallelism.

Input: $ARGUMENTS

## Execution Modes

### No arguments: `/full-verify`
- Run full pipeline

### Skip specific steps: `/full-verify skip-e2e`, `/full-verify skip-simplify`
- Skip the specified step

### E2E only: `/full-verify e2e-only`
- Assume verify passed, run E2E only

---

## Pipeline Structure

```
Phase 1: /verify (sequential, blocking)
  typecheck -> lint -> test -> build -> security
  | pass

Phase 2: /e2e-verify + /simplify (parallel)
  +-- Agent A: E2E verification (agent-browser)
  |   open -> snapshot -i -> fill/click -> wait -> verify
  |
  +-- Agent B: Code simplification
      slop removal -> abstraction inline -> dedup

  | both complete

Phase 3: /verify (final check, sequential)
  Regression check since simplify modified code
  | pass

Results report
```

## Phase 1: Code Verification (/verify)

First verify basic code quality. Must pass this step before proceeding to E2E and simplification.

```bash
# Project detection
[ -f package.json ] && echo "NODE"
[ -f pyproject.toml ] && echo "PYTHON"

# Sequential execution
npx tsc --noEmit          # typecheck
npx eslint . --max-warnings=0  # lint
npx vitest run             # test
npm run build              # build
```

- On failure: Fix error -> re-run (max 3 retries per step)
- After 3 failures: Escalate to user, abort pipeline
- **On pass: Proceed immediately to Phase 2**

## Phase 2: E2E + Simplify Parallel Execution

After Phase 1 passes, **spawn two sub-agents in parallel**:

```
Agent A -- E2E Verification:
  Agent(subagent_type="general-purpose",
    name="e2e-verifier",
    run_in_background=true,
    prompt="Execute E2E tests with these steps:

    1. Check agent-browser installation (which agent-browser)
    2. Run app in background (npm run dev &)
    3. Wait for app ready (curl polling 30s)
    4. Analyze user flows for changed features
    5. Write test scripts in e2e/ directory:
       - agent-browser open -> snapshot -i -> check refs
       - fill/click for interactions
       - wait text/url for result verification
    6. Run all with bash e2e/runner.sh
    7. On failure: capture screenshot -> fix code -> re-run (max 3 times)
    8. Save results to E2E_RESULT.md

    agent-browser core commands:
    - open <url>: Open page
    - snapshot -i: Interactive elements + ref numbers
    - click @ref: Click
    - fill @ref 'text': Input
    - wait text 'msg': Wait for text
    - wait url '**/path': Wait for URL
    - screenshot ./path.png: Screenshot
    - close: Close browser

    Test script structure:
    #!/bin/bash
    set -e
    cleanup() { agent-browser close 2>/dev/null || true; }
    trap cleanup EXIT
    agent-browser open http://localhost:3000
    agent-browser snapshot -i
    # ... interactions + verification
    echo 'PASS: [test name]'
    ")

Agent B -- Code Simplification:
  Agent(subagent_type="general-purpose",
    name="simplifier",
    run_in_background=true,
    prompt="Simplify code with these steps:

    1. Check changed files with git diff --name-only HEAD~5..HEAD
    2. Read each file
    3. Remove AI slop patterns:
       - Delete self-evident comments ('This function does X')
       - Inline single-use helpers
       - Simplify verbose error messages
       - Remove unnecessary null checks (type system guarantees)
       - Remove inferable type annotations
    4. Structural simplification:
       - Deep nesting -> early returns
       - Remove unused imports/exports
       - Remove console.log
    5. Verify type safety with npx tsc --noEmit after changes
    6. Save results to SIMPLIFY_RESULT.md
    ")
```

**Wait until both agents complete.**

## Phase 3: Final Verification (/verify Re-run)

Since simplify modified source code, confirm no regressions:

```bash
npx tsc --noEmit
npx eslint . --max-warnings=0
npx vitest run
npm run build
```

- On failure: Regression introduced by simplify -> fix -> re-run
- On pass: Full pipeline complete

## Results Report

Generate integrated report after all Phases complete:

```
## Full Verify Results

### Phase 1: Code Verification
| Step | Status |
|------|--------|
| typecheck | PASS |
| lint | PASS |
| test | 42 passed |
| build | Success |

### Phase 2a: E2E Verification (agent-browser)
| Test | Status |
|------|--------|
| test_login.sh | PASS |
| test_dashboard.sh | PASS |

### Phase 2b: Code Simplification
- Deleted 8 self-evident comments
- Inlined 2 helpers
- Removed 5 unused imports

### Phase 3: Final Verification
| Step | Status |
|------|--------|
| typecheck | PASS |
| lint | PASS |
| test | 42 passed |
| build | Success |

Full pipeline passed
```

**E2E_RESULT.md, SIMPLIFY_RESULT.md** temporary files are deleted after reporting.

## TTH Integration

Satya calls this command in TTH Phase 4:

```
Satya -> Agent(prompt="/full-verify") -> Full pipeline auto-execution
```

Or individual calls are also possible:
```
Satya -> Agent(prompt="/verify") -> Confirm pass
      -> Agent(prompt="/e2e-verify", run_in_background=true)
      -> Agent(prompt="/simplify", run_in_background=true)
      -> Agent(prompt="/verify") -> Final check
```

## Principles

- Do not enter Phase 2 if Phase 1 fails (can't E2E if build fails)
- Phase 2's two agents must run in parallel (independent work)
- Phase 3 is regression verification for simplify changes -- never skip
- agent-browser uses snapshot+ref pattern (no hardcoded CSS selectors)
- Max 3 retries per step, escalate to user if exceeded
