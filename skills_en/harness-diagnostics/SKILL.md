---
name: harness-diagnostics
description: "Self-diagnostics and improvement suggestions based on 12-principle agent harness. Triggers on: harness diagnostics, audit, environment check, setup, maintenance, drift check. NOT for: code implementation, bug fixes, writing tests."
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
---

# Harness Diagnostics -- Agent Harness Self-Diagnostic Skill

12-principle based harness maturity diagnostics and improvement suggestion tool.
**Read-only**: Performs diagnostics + suggestions only; does not directly modify files.

## Input

$ARGUMENTS

## Mode Selection

| Mode | Trigger Keywords | Purpose |
|------|-----------------|---------|
| **Setup** | "environment setup", "setup", "initialize" | Initial check + recommendations for agent collaboration environment |
| **Audit** | "harness diagnostics", "check", "audit", default | 12-principle scoring + improvement roadmap |
| **Maintenance** | "drift check", "cleanup", "maintenance" | Stale code/doc detection + cleanup suggestions |

Default to **Audit** mode if no keywords match.

---

## 12-Principle Scoring System

Each principle scores 0-8, total 100 (12 x 8 = 96, remaining 4 points as overall bonus).

| # | Principle | Check Target |
|---|-----------|-------------|
| 1 | **Agent Entry Point** | CLAUDE.md/AGENTS.md existence + clear agent entry point |
| 2 | **Map, Not Manual** | Is documentation a "map" vs "manual"? (pointers, hierarchy) |
| 3 | **Invariant Enforcement** | Do tools auto-block mistakes? (hooks, linters, CI) |
| 4 | **Convention Over Configuration** | Explicit rule files exist (rules/, .eslintrc, prettier, etc.) |
| 5 | **Progressive Disclosure** | Information layering (CLAUDE.md -> rules/ -> docs/ -> code) |
| 6 | **Layered Architecture** | Unidirectional dependencies, layer separation |
| 7 | **Garbage Collection** | Mechanism for cleaning stale files/docs/dependencies |
| 8 | **Observability** | Self-verifiable (tests, build, typecheck) |
| 9 | **Knowledge in Repo** | Knowledge lives in repo (ADR, docs/, inline explanations) |
| 10 | **Reproducibility** | Same input -> same output (lock files, env config) |
| 11 | **Modularity** | Predictable change impact (module boundaries, interfaces) |
| 12 | **Self-Documentation** | Code explains intent (naming, structure) |

### Maturity Levels

| Level | Score | Description |
|-------|-------|-------------|
| **L1 None** | 0-19 | No harness. Agent reasons from scratch every time |
| **L2 Basic** | 20-39 | Basic setup exists. Some automation |
| **L3 Structured** | 40-59 | Structured rules and tools. Mostly automated |
| **L4 Optimized** | 60-79 | Optimized harness. High agent autonomy |
| **L5 Autonomous** | 80-100 | Autonomous operation. Self-diagnosis/repair capable |

---

## Execution Procedure

### Setup Mode

1. Explore project root (Explore sub-agent)
2. Check existence of these items:
   - `CLAUDE.md` or `.claude/CLAUDE.md`
   - `rules/` or `.claude/rules/`
   - `docs/` directory
   - Package manager lock files
   - Linter/formatter configuration
   - Test framework configuration
   - CI/CD configuration
3. **Recommend creation** for missing items (do not create directly)
4. Recommendation priority: P0 (immediate) -> P1 (recommended) -> P2 (improvement)

### Audit Mode

1. Run checks for each of the 12 principles:
   - File/directory existence (Glob)
   - Configuration file content analysis (Read)
   - Pattern search (Grep)
2. Score each principle (0-8)
3. Calculate overall bonus (0-4):
   - Synergy between principles (e.g., hooks + rules + docs all present: +2)
   - Consistency (naming conventions, structural uniformity: +2)
4. Output report

### Maintenance Mode

1. Detect stale items:
   - docs/ files unmodified for 30+ days
   - Dependencies in package.json not imported anywhere
   - Collect TODO/FIXME comments
   - Empty directories
   - Unused configuration files
2. Detect drift:
   - CLAUDE.md content vs actual project structure mismatch
   - rules/ rules vs code reality mismatch
3. Output cleanup suggestion list (do not modify directly)

---

## Output Format

```markdown
# Harness Diagnostics Report

## Project: {project name}
## Mode: {Setup | Audit | Maintenance}
## Date: {YYYY-MM-DD}

---

## Per-Principle Scores

| # | Principle | Score | Rationale |
|---|-----------|-------|-----------|
| 1 | Agent Entry Point | X/8 | ... |
| 2 | Map, Not Manual | X/8 | ... |
| ... | ... | ... | ... |
| 12 | Self-Documentation | X/8 | ... |

**Overall Bonus**: X/4
**Total Score**: XX/100

## Maturity Level: LX {level name}

---

## Top 3 Improvement Suggestions

### 1. {suggestion title} (P{0-2})
- **Current**: {current state}
- **Improvement**: {specific action}
- **Impact**: {expected score increase}

### 2. ...

### 3. ...

---

## Detailed Analysis
{per-principle detailed description -- as collapsible sections}
```

---

## Constraints

- **Read-only**: No file creation/modification/deletion
- Diagnostic tools: Glob, Grep, Read, Bash (read-only commands only)
- Output provided as markdown report only
- Instead of direct modification, suggest in "doing X will improve score by Y" format
- Leverage sub-agents to protect main context
