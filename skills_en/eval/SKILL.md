---
name: eval
description: "Evaluate code output on 4 axes (functionality/quality/originality/security) with scoring. Spawns an independent Evaluator agent. Triggers on: eval, evaluate, quality score, code evaluation. NOT for: writing code, implementation, review."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# Code Eval (independent evaluation)

Spawns an Evaluator agent separated from the Generator (implementer) for independent assessment.

## Process

### Step 1: Spawn the Evaluator agent

```
Agent(subagent_type="evaluator",
  prompt="Read ~/.claude/agents/evaluator.md and evaluate the current project.
         4 axes (functional correctness/code quality/originality/usability&security), 100 points total.
         Save the result to EVAL_REPORT.md.")
```

### Step 2: Review results

When the Evaluator finishes, read EVAL_REPORT.md and summarize for the user:

```
📊 Eval result: [PASS/CONDITIONAL/FAIL] — [N]/100

Functional correctness: [N]/40 | Code quality: [N]/25
Originality: [N]/20 | Usability & security: [N]/15

[Summary of items needing fixes]
```

### Step 3: On CONDITIONAL/FAIL

List the required fixes concretely and ask whether to re-evaluate after fixing.
Re-evaluation applies the same criteria (max 5 rounds).

## pass@k idempotency test (optional)

Run the same prompt k times to measure quality consistency:

```bash
# k=3 example
for i in 1 2 3; do
  run /eval → record score
done
# all 3 runs 85+ → idempotency achieved
# score variance > 15 points → unstable (harness needs tuning)
```

Level idempotency: measures whether the **same quality level** holds — not byte-identical code.
