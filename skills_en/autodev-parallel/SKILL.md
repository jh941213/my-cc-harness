---
name: autodev-parallel
description: >
  Parallel version of the Ralph Loop. Multiple agents process PRD items simultaneously in worktrees.
  Triggers: "parallel experiments", "autodev parallel", "simultaneous experiments", "worktree experiments", "parallel ralph"
  Anti-triggers: "sequential experiments", "one at a time"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDev Parallel — Ralph Loop Parallel Orchestrator

Multiple agents process PRD items in parallel within worktree-isolated environments.
Maximizes completion speed by working on independent items simultaneously.

## Core Concept

```
main (or current branch)
 │
 ├── worktree A ── Agent 1: PRD item 1
 ├── worktree B ── Agent 2: PRD item 2
 ├── worktree C ── Agent 3: PRD item 3
 │
 └── Orchestrator (this skill)
      - Classify & assign independent items
      - Collect & verify results
      - Integrate via cherry-pick
      - Repeat for next round
```

## Phase 0: Configuration Collection

```yaml
goal: "What to achieve"
prd: "Path to PRD or checklist file"    # e.g., "PRD.md"
scope: ["Modifiable file patterns"]
verify: "Verification command"
parallel: 3                            # Number of concurrent agents (default 3)
rounds: 5                             # Number of rounds (default 5)
max_iterations: 100                    # Stop Hook maximum iterations (default 100)
completion_promise: "DONE"
```

## Phase 1: Item Classification

Read the PRD and analyze item dependencies:

```markdown
## Independent items (parallelizable)
- [ ] Item A: API endpoint — src/api/
- [ ] Item B: UI component — src/components/
- [ ] Item C: Write tests — tests/

## Dependent items (require sequencing)
- [ ] Item D: after A completes → integration tests
```

## Phase 2: Round Loop

```
for round in 1..rounds:

  1. SELECT
     - Pick up to {parallel} independent items among the incomplete ones
     - Items with dependencies are selected only after their prerequisites complete

  2. LAUNCH (parallel)
     - Invoke {parallel} Agents simultaneously
     - Each Agent is isolated with isolation: "worktree"
     - Prompt passed to each Agent:

     """
     Implement the PRD item.

     Item: {specific_item}
     Scope: {scope}
     Verify: {verify}

     Procedure:
     1. Read files within scope and implement the item
     2. Verify by running {verify}
     3. On failure, attempt build-fix once
     4. On success, git commit -m "[autodev] {item_summary}"
     5. Return the result as the final message:
        AUTODEV_RESULT: status={success|fail}, commit={hash}, item="{desc}"
     """

  3. COLLECT
     - Wait for each Agent to complete
     - Parse results (status, commit hash)

  4. INTEGRATE
     - Cherry-pick the changes of successful Agents
     - On cherry-pick conflict:
       - Attempt conflict resolution (once)
       - On failure, defer the item to the next round
     - Check off completed items as [x] in the PRD

  5. VERIFY ALL
     - Full verification after integration: {verify}
     - On failure, revert the last cherry-pick and defer the item

  6. REPORT (per round)
     Round {round}/{rounds} complete:
     - Agent 1: {status} — {item}
     - Agent 2: {status} — {item}
     - Remaining incomplete items: {remaining}

  7. CHECK COMPLETION
     - All items complete? → <promise>DONE</promise>
     - Otherwise → next round
```

## Phase 3: Completion Report

```markdown
# AutoDev Parallel Completion Report

## Summary
- Total rounds: {rounds}
- Total items: {total} (completed: {done}, failed: {failed})
- Parallel agents: {parallel}

## Results by Round
| Round | Completed items | Failed | Cumulative completion |
|-------|-----------------|--------|-----------------------|
| 1 | A, B | - | 2/10 (20%) |
| 2 | C, D, E | F | 5/10 (50%) |

## Incomplete Items (if any)
- [ ] Item F: reason

## Branch
autodev/{tag} — ready to merge into main
```

## Parallelism Guidelines

| Situation | Recommended parallel |
|-----------|----------------------|
| Independent files/modules | 5 (maximum) |
| Changes within the same file | 1-2 (conflict risk) |
| Includes performance benchmarks | 2-3 (shared resources) |
| Test-only judgment | 3-5 |

## Safeguards

1. **Worktree isolation**: use the Agent tool's `isolation: "worktree"`
2. **Cherry-pick only**: force push is strictly forbidden
3. **Protect existing tests**: roll back when full verification fails after integration
4. **Respect dependencies**: process dependent items only after prerequisites complete
5. **Synchronize between rounds**: start the next round only after the previous round's integration completes
6. **max_iterations**: Stop Hook safety mechanism
7. **TTH mutual exclusion**: do not use simultaneously with TTH (/tth) (Stop hook loop conflict)

## TTH Team Member Utilization (optional)

```yaml
# Assign specialty areas per team member
pichai: architecture changes, module separation
jensen: API optimization, DB query improvements
zuckerberg: frontend components
bezos: code deletion, removing unnecessary abstractions
```

Include the team role file in the prompt to grant expertise:
```
Read the team member's role file and implement from that perspective:
~/.claude/team-roles/{role}.md
```
