---
paths:
  - "**/CHECKPOINT.md"
  - "**/progress.txt"
---

# Drift Control

3-axis drift measurement to prevent straying from goals mid-work.

## CHECKPOINT.md drift section format

Include drift tracking fields per milestone:

```markdown
## M1: [milestone name]
- [ ] description
- verify: `npm run typecheck && npm run test`
- done-when: 0 type errors, tests pass
- status: in-progress
- drift:
  - goal: 0.0    # goal deviation (0.0=on target, 1.0=fully off)
  - constraint: 0.0  # constraint violations (+0.1 each)
  - scope: 0.0   # scope deviation (ratio of unplanned file changes)
  - combined: 0.0  # weighted average (goal×50% + constraint×30% + scope×20%)
```

## Drift thresholds

| combined | Verdict | Action |
|----------|---------|--------|
| ≤ 0.15 | ✅ Normal | Keep going |
| 0.15~0.30 | ⚠️ Caution | Check drift causes before the next task |
| > 0.30 | 🔴 Danger | **STOP** — re-plan required. Record in AUDIT.log |

## When to measure

1. **Milestone start**: initialize at 0.0
2. **After every code change**: update scope drift (unplanned files / changed files)
3. **On verification failure**: update goal drift
4. **Milestone completion**: record final drift

## Scope drift auto-calculation

```
scope_drift = (unplanned changed files) / (total changed files)
```

Unplanned file: any change to a file not listed in CHECKPOINT.md

## Constraint drift accumulation

+0.1 per constraint violation:
- Performance SLA miss
- Backward-compatibility break
- Security rule violation
- Coding style violation

## Combined drift formula

```
combined = goal × 0.5 + constraint × 0.3 + scope × 0.2
```
