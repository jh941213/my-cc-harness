---
name: plan
description: |
  Plan before tackling complex tasks (3+ implementation steps or architecture decisions involved). Used in Plan mode or auto-activated.
  Triggers: "plan", "planning", "how to implement", "design", "architecture decision"
  Anti-triggers: "just implement it", "simple fix"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Grep, Glob
---

# Task Planning

Creates a plan before starting new features or complex tasks.

## Planning Steps
1. **Requirements Analysis**: What needs to be implemented?
2. **Current Code Assessment**: Explore the relevant codebase
3. **Approach Decision**: Compare possible implementation methods
4. **Task Decomposition**: Break into specific steps
5. **Risk Identification**: Anticipated issues

## Output Format
```markdown
## Requirements Summary
- ...

## Implementation Plan
1. Step 1: ...
2. Step 2: ...

## Files to Modify
- File1: Change description
- File2: Change description

## Expected Risks
- ...
```

## After Plan Approval
Save the plan to `docs/execute-plans/` — use the `~/.claude/templates/execute-plan.md.template` format.
For plans with 3+ steps, run cross-model verification (`~/.claude/rules/cross-model-verification.md`).
Once the plan is approved, switch to auto-accept mode for implementation.
If a mistake occurs, immediately return to Plan mode and re-plan.
