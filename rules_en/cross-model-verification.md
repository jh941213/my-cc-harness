---
description: "Claude↔Codex cross-model verification rules — plan review, code cross-review, self-eval ban"
globs: ["**/*"]
---

# Cross-Model Verification Rules

## Core principle
**Never verify with the same model that produced the work.**
(Guards against self-grading bias — a structural principle that survives model generations)

## Plan-stage cross-review

For plans with 3+ steps, request a plan review from Codex (see the applicability table):

```
1. [Claude] Draft the plan
2. [Codex] Review the plan — missing edge cases, excessive scope, ordering errors
3. [Claude] Incorporate feedback, finalize the plan
4. Await user approval
```

### Codex plan-review prompt template
```
Review this implementation plan:
[plan content]

Check:
- Missing edge cases or dependencies?
- Is the step order optimal?
- Anything over- or under-scoped?
- Are the verification commands sufficient?
- Anything missed from a security/performance angle?
```

## Code verification cross-loop

```
1. [Claude] First implementation
2. [Codex] First review + fix suggestions
3. [Claude] Apply fixes + second pass
4. [Codex] Final review → PR stage
```

## No self-evaluation

- Writing code and asking the same model in the same session to "evaluate it" → **forbidden**
- Run evals in a separate session or a separate model (Codex)
- The evaluator agent is fully separated from implementation agents

## When it applies

| Situation | Cross-verification | Can skip |
|-----------|--------------------|----------|
| 3+ step plans | O — Codex review | X |
| Architecture changes | O — Codex + human review | X |
| 1-2 line fixes | X | O |
| Bug fixes (clear cause) | X | O |
| Test-only additions | X | O |
