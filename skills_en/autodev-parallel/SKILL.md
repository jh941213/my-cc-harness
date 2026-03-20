---
name: autodev-parallel
description: >
  AutoDeveloper orchestrator that runs multiple experiments in parallel using worktrees.
  Triggers: "parallel experiments", "autodev parallel", "simultaneous experiments", "worktree experiments"
  Anti-triggers: "sequential experiments", "one at a time"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent
---

# AutoDeveloper Parallel -- Parallel Experiment Orchestrator

Runs multiple experiments simultaneously via git worktrees and selects the best result.

## Core Concept

```
main (or current branch)
 |
 +-- worktree A -- Agent 1: Experiment idea 1
 +-- worktree B -- Agent 2: Experiment idea 2
 +-- worktree C -- Agent 3: Experiment idea 3
 |
 +-- Orchestrator (this skill)
      - Generate & assign ideas
      - Collect & compare results
      - Select best branch
      - Repeat for next round
```

## Phase 0: Configuration Collection

Confirm with user:

```yaml
goal: "What to achieve"
scope: ["Modifiable file patterns"]
metric: "Evaluation command"
parallel: 3                       # Concurrent execution count (default 3)
rounds: 5                         # Number of rounds (default 5, total experiments = parallel * rounds)
```

## Phase 1: Baseline

```bash
# Measure baseline from current state
mkdir -p .autodev
{metric_command} > .autodev/baseline.log 2>&1
bash ~/.claude/hooks/autodev-judge.sh
BASELINE_SCORE=$(cat .autodev-score)

# Initialize results file
echo -e "round\tagent\tcommit\tscore\tstatus\tdescription" > .autodev/results.tsv
```

## Phase 2: Round Loop

```
for round in 1..rounds:

  1. BRAINSTORM
     - Generate {parallel} ideas based on scope file analysis + goal
     - Reference previous round results (build on kept changes)
     - Ideas must be independent of each other (avoid conflicts)

  2. LAUNCH (parallel)
     - Invoke {parallel} Agents simultaneously
     - Each Agent is isolated with isolation: "worktree"
     - Prompt passed to each Agent:

     """
     Perform a single AutoDeveloper experiment.

     Goal: {goal}
     Scope: {scope}
     Metric: {metric}
     Idea: {specific_idea}

     Procedure:
     1. Read files within scope and apply the idea
     2. git commit -m "[autodev] {idea_summary}"
     3. Run {metric} -> .autodev/run.log
     4. Run bash ~/.claude/hooks/autodev-judge.sh
     5. Return score as final message:
        AUTODEV_RESULT: score={N}, commit={hash}, description="{desc}"

     On build failure, attempt recovery once. On 2nd failure, give up:
        AUTODEV_RESULT: score=-999, commit=none, description="{desc} (crash)"
     """

  3. COLLECT
     - Wait for each Agent to complete
     - Parse score from results
     - Record in results.tsv

  4. SELECT
     - Identify the worktree/branch of the highest-scoring Agent
     - If highest score > current best_score:
       - Cherry-pick changes from that branch to current branch
       - Update best_score
     - Remaining worktrees are cleaned up (Agent tool handles automatically)

  5. REPORT (per round)
     Round {round}/{rounds} complete:
     - Agent 1: score={n1} ({status1}) -- {desc1}
     - Agent 2: score={n2} ({status2}) -- {desc2}
     - Current best: score={best}

  6. CONTINUE
     Proceed to next round (apply new ideas on top of previous best)
```

## Phase 3: Final Report

```markdown
# AutoDev Parallel Experiment Report

## Summary
- Total rounds: {rounds}
- Total experiments: {rounds * parallel}
- Keep: {K} / Discard: {D} / Crash: {C}
- Baseline -> Final: {baseline} -> {best} ({improvement}%)

## Per-Round Results
| Round | Best Experiment | Score | Description |
|-------|-----------------|-------|-------------|
| 1 | Agent 2 | 85 | Added cache layer |
| 2 | Agent 1 | 120 | Query batching |
| ... | ... | ... | ... |

## Cumulative Kept Changes
1. [commit1] Added cache layer
2. [commit2] Query batching

## Next Steps
- Additional optimization areas: ...
- Ready to merge into main: `git merge autodev/{tag}`
```

## Parallel Count Guidelines

| Situation | Recommended parallel |
|-----------|---------------------|
| Independent files/modules | 5 (maximum) |
| Changes within the same file | 1-2 (conflict risk) |
| Includes performance benchmarks | 2-3 (resource sharing) |
| Tests only for evaluation | 3-5 |

## Safety Measures

1. **Worktree isolation**: Uses Agent tool's isolation: "worktree". No mutual interference
2. **Main protection**: Uses cherry-pick only. No force push
3. **Existing test protection**: Unconditionally discard if broken
4. **Resource limits**: Do not exceed the parallel count
5. **Cross-round synchronization**: Use previous round's best as the next round's base

## Leveraging Existing Agents (Optional)

TTH team members can be used as experiment agents:

| Team Member | Suitable Experiment Types |
|-------------|--------------------------|
| pichai (architect) | Structural changes, module separation |
| jensen (backend) | API optimization, DB query improvement |
| zuckerberg (frontend) | Component optimization, bundle reduction |
| bezos (QA) | Code deletion, removing unnecessary abstractions |

Include the team role file path in the prompt to provide expertise:
```
Read the role file for the team member and perform the experiment from that perspective:
~/.claude/team-roles/{role}.md
```
