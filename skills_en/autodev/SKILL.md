---
name: autodev
description: >
  Ralph Loop based autonomous development loop. A Stop Hook intercepts session termination and completes PRD items one by one with automatic commits.
  Triggers: "autodev", "autonomous development", "run overnight", "ralph loop", "auto development"
  Anti-triggers: "implement it yourself", "do it once", "manual"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDev — Ralph Loop Autonomous Development

Stop Hook based autonomous development loop. Completes PRD/checklist items one by one with automatic commits.
Leave it running overnight and a PR is waiting when you arrive at work.

> Note: this is a separate mechanism from Claude Code's **built-in** `/goal` (session-scoped completion-condition loop). For a single simple completion condition use the built-in /goal; when you need PRD-based multi-item work, quality gates, or team-member reuse, use this skill (autodev).

## Core Principle

```
Session start → Read PRD → Process next item → Commit → Session end
                                                    ↓
                                            Stop Hook detects
                                                    ↓
                                        Done? → Yes → Exit
                                          ↓ No
                                   continuation prompt (reason) → new session starts
                                                    ↓
                                              Read PRD → ...
```

## Phase 0: Configuration Collection

Confirm with the user (only ask about missing items):

```yaml
goal: "What to achieve"                # e.g., "Complete all items in PRD.md"
prd: "Path to PRD or checklist file"   # e.g., "PRD.md" or "tasks/todo.md"
scope: ["Modifiable file patterns"]    # e.g., ["src/**", "tests/**"]
verify: "Verification command"         # e.g., "npm test" (can be auto-detected)
max_iterations: 100                    # Maximum iterations (default 100) — do not set above 50 without user confirmation
completion_promise: "DONE"             # Completion signal (default "DONE")
mode: "continue"                       # continue | reset (default continue)
```

### verify auto-detection

If the user did not provide verify:
1. `package.json` → `npm test` or `vitest run`
2. `pyproject.toml` → `pytest`
3. `Makefile` → `make test`
4. None → `echo "no verify command"`

## Phase 1: Loop Initialization

```bash
# 1. Create autodev branch
git checkout -b autodev/$(date +%Y%m%d-%H%M)

# 2. Create .ralph-loop/ state directory
mkdir -p .ralph-loop

# 3. Initialize state file
cat > .ralph-loop/state.json << 'STATE'
{
  "active": true,
  "iteration": 0,
  "max_iterations": {max_iterations},
  "prompt": "{goal}",
  "completion_promise": "{completion_promise}",
  "prd_path": "{prd}",
  "verify_command": "{verify}",
  "started_at": "{ISO time}",
  "status": "running"
}
STATE

# 4. Add .ralph-loop/ to .gitignore
echo ".ralph-loop/" >> .gitignore

# 5. Baseline verification
{verify} 2>&1 | tee .ralph-loop/baseline.log
```

## Phase 2: Iteration Execution (every session)

Procedure performed in each session (iteration):

```
1. READ PRD
   - Read the {prd} file
   - Select the first incomplete item ([ ])

2. PLAN
   - Minimal change plan to implement the selected item
   - Only files within scope may be modified

3. IMPLEMENT
   - Modify code according to the plan
   - Never modify files outside scope

4. VERIFY
   - Run {verify}
   - On failure, attempt build-fix once
   - After 2 failures, roll back changes (git checkout -- .)

5. COMMIT
   - On success:
     git add -A
     git commit -m "[autodev] {item summary}"
   - Check off the item as [x] in the PRD

6. CHECK COMPLETION
   - Are there incomplete items left in the PRD?
   - Yes → End the session naturally (Stop Hook starts the next iteration)
   - No → All items complete!
     Output <promise>{completion_promise}</promise>
     → Stop Hook detects it and terminates the loop
```

## Phase 3: Completion Report

When the loop ends (completed or max_iterations reached):

```markdown
# AutoDev Completion Report

## Summary
- Total iterations: {N}
- Completed items: {K}/{total}
- Baseline → Final: verification passing
- Status: {completed | max_iterations_reached}

## Completed Items
| # | Item | Commit |
|---|------|--------|
| 1 | Implement API endpoint | abc1234 |
| 2 | Add authentication | def5678 |

## Incomplete Items (if any)
- [ ] Item N: reason

## Branch
autodev/{tag} — ready to merge into main
```

## Safeguards

1. **No modifications outside scope**: only modify files/directories specified in scope
2. **Protect existing tests**: roll back changes when verify fails
3. **Crash recovery limit**: build-fix only once. Skip the item after 2 failures
4. **Git safety**: work only on the autodev/ branch. Never touch main
5. **max_iterations**: prevents infinite loops (default 100. Do not set above 50 without user confirmation)
6. **Cost awareness**: each iteration incurs token cost. Set the iteration count reasonably

## Stop Hook Behavior

`~/.claude/hooks/ralph-loop.sh` runs on session termination:

- If `active` in `.ralph-loop/state.json` is `true`, start the next iteration
- Terminate the loop when `<promise>DONE</promise>` is detected in the transcript
- Terminate the loop when `iteration >= max_iterations`
- Do nothing if there is no state or `active: false`

## Manual Control

```bash
# Stop the loop
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=False; json.dump(s,open('.ralph-loop/state.json','w'))"

# Check state
cat .ralph-loop/state.json

# Resume the loop
python3 -c "import json; s=json.load(open('.ralph-loop/state.json')); s['active']=True; json.dump(s,open('.ralph-loop/state.json','w'))"
```

## Leveraging Existing Skills

| Situation | Skill to use |
|-----------|--------------|
| Recovery on build failure | `build-fix` |
| Code cleanup after commit | `simplify` |
| Test-driven implementation | `tdd` |
| Item implementation planning | `plan` |
| Final verification | `verify` |
