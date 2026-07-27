---
name: harness-audit
description: "Diagnose the overall health of the harness (hooks, skills, agents, rules) with scoring. Triggers on: harness audit, harness diagnosis, config check, harness check. NOT for: writing code, implementation."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# Harness Health Audit

Diagnoses the overall health of a Claude Code harness across 8 dimensions.

## The 8 dimensions

### 1. CLAUDE.md quality (0-3)
- 0: none
- 1: exists but basic
- 2: project context + rules included
- 3: detailed architecture + patterns + anti-patterns

### 2. Skills coverage (0-3)
- 0: no skills
- 1: 1-5
- 2: 6-15 + trigger/anti-trigger definitions
- 3: 16+ + domain classification + eval skill included

### 3. Agents architecture (0-3)
- 0: no agents
- 1: 1-3 (basic)
- 2: 4-8 + clear role separation
- 3: 9+ + separate evaluator + role boundary matrix

### 4. Hooks automation (0-3)
- 0: no hooks
- 1: basic (prettier, lint)
- 2: quality gates + security scan
- 3: full pipeline (coverage + security + e2e + eval)

### 5. Rules structure (0-3)
- 0: no rules
- 1: 1-2 general rules
- 2: file-pattern rules (*.ts, *.py, etc.)
- 3: per-domain + security + performance + testing rules

### 6. MCP servers (0-3)
- 0: no MCP
- 1: 1-2 basic
- 2: search + docs + UI tools
- 3: search + docs + code analysis (code-review-graph, etc.)

### 7. Eval pipeline (0-3)
- 0: no eval
- 1: manual verify only
- 2: automated quality gates + scoring
- 3: independent evaluator + pass@k + AI slop detection

### 8. Team/multi-agent (0-3)
- 0: solo use
- 1: basic subagents
- 2: role-based team + communication protocol
- 3: TTH-grade silos + Ralph Loop + backpressure

## Procedure

1. Scan the entire `~/.claude/` directory
2. Score each dimension (0-3)
3. Total (0-24) + grade

## Grades

| Total | Grade | Meaning |
|-------|-------|---------|
| 21-24 | S | Production-grade harness |
| 16-20 | A | Advanced setup. Few items to improve |
| 11-15 | B | Intermediate. Core gaps exist |
| 6-10 | C | Basic. Mostly manual |
| 0-5 | D | Unconfigured. Vanilla state |

## Output format

```
📊 Harness health: [Grade] ([N]/24)

| Dimension | Score | Status |
|-----------|-------|--------|
| CLAUDE.md | [N]/3 | [🟢/🟡/🔴] |
| Skills | [N]/3 | ... |
| Agents | [N]/3 | ... |
| Hooks | [N]/3 | ... |
| Rules | [N]/3 | ... |
| MCP | [N]/3 | ... |
| Eval | [N]/3 | ... |
| Team | [N]/3 | ... |

🔧 Improvement suggestions:
1. [How to improve the lowest-scoring dimension]
2. ...
```
