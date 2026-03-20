<div align="center">

**🌐 English | [한국어](README.md)**

# Claude Code Power Pack

<img src="assets/banner.png" alt="Claude Code Power Pack" width="720" />

[![Version](https://img.shields.io/badge/version-0.9.0-7C3AED.svg?style=for-the-badge)](https://github.com/jh941213/my-claude-code-asset)
[![License](https://img.shields.io/badge/license-MIT-E87C3E.svg?style=for-the-badge)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-33-blue.svg?style=for-the-badge)](#-skills-33)
[![Agents](https://img.shields.io/badge/agents-11-green.svg?style=for-the-badge)](#-agents-11)
[![PRD](https://img.shields.io/badge/PRD-Aletheia_v2-9333ea.svg?style=for-the-badge)](#-prd-aletheia-v2)
[![TTH](https://img.shields.io/badge/TTH-Multi--Agent-ff6b35.svg?style=for-the-badge)](#-tth-multi-agent-silo)
[![AutoDev](https://img.shields.io/badge/AutoDev-Autonomous-00d4aa.svg?style=for-the-badge)](#-autodev-autonomous-experiment-loop)

**Production-ready optimal agent harness for Claude Code**

`Skills` `Agents` `Hooks` `Rules` `Commands` `TTH` All-in-One

---

**33 Skills** | **11 Agents** | **5 Conditional Rules** | **Hooks Guarantee System** | **TTH Multi-Agent** | **AutoDev Autonomous Experiments**

</div>

---

## Table of Contents

- [Installation](#-installation)
- [PRD Aletheia v2](#-prd-aletheia-v2)
- [TTH Multi-Agent Silo](#-tth-multi-agent-silo)
- [AutoDev Autonomous Experiment Loop](#-autodev-autonomous-experiment-loop)
- [CLAUDE.md Optimization Philosophy](#-claudemd-optimization-philosophy)
- [Hooks Guarantee System](#-hooks-guarantee-system)
- [Skills (33)](#-skills-33)
- [Agents (11)](#-agents-11)
- [Commands (3)](#-commands-3)
- [Rules (5)](#-rules-5-conditional-loading)
- [Boris Cherny Tips](#-boris-cherny-tips)
- [Codex CLI Version](#-codex-cli-version)
- [References](#-references)
- [Changelog](#-changelog)

---

## 🚀 Installation

### Method 1: One-Click Full Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/jh941213/my-claude-code-asset/main/install.sh | bash
```

### Method 2: Plugin Installation (Skills Only)

```bash
claude plugin marketplace add jh941213/my-claude-code-asset
claude plugin install ccpp@my-claude-code-asset
```

> **Note**: The plugin system only supports **skills**. Agents, rules, and TTH require separate configuration.

### Method 3: Ask Claude Directly

```
Copy agents/, rules/, commands/, and CLAUDE.md from
https://github.com/jh941213/my-claude-code-asset to my ~/.claude/ folder
```

### Installation Comparison

| Item | Plugin Install | Full Setup |
|------|:---:|:---:|
| Skills (33) | ✅ | ✅ |
| Agents (11) | ❌ | ✅ |
| Rules (5) | ❌ | ✅ |
| Commands (3) | ❌ | ✅ |
| TTH Team Roles (6) | ❌ | ✅ |
| TTH Hooks (2) | ❌ | ✅ |
| CLAUDE.md | ❌ | ✅ |
| settings.json | ❌ | ✅ |

---

## 📋 PRD Aletheia v2

<div align="center">
<img src="assets/tth-banner.png" alt="PRD Aletheia v2" width="720" />
</div>

> **Humanities Framework + Six Thinking Hats + Convergence Board = Insight-Driven PRD**

Automate everything from complexity-adaptive interviews to PRD document generation with a single line: `/prd "idea"`.

```
/prd "AI Code Review SaaS for Developers"
```

### Key Innovations

| Element | Description |
|---------|-------------|
| **Complexity Gate** | Auto-classify Low/Mid/High → adaptive process (2–5 rounds) |
| **Convergence Board** | 6-dimension progress tracking (🔴→🟡→🟢) — Terminology, Structure, Depth, Consistency, Robustness, Market |
| **Humanities Framework** | Wittgenstein (terminology alignment) + Descartes (methodical doubt) + Socrates (contradiction detection) + Johari (blind spots) + Gadamer (coherence) |
| **Graceful Exit** | Exit anytime → saves PRD.partial.md → resume in next session |

### Pipeline

```
Phase 0: Complexity assessment + Convergence board init
    ↓
Phase 1 (bg) ──┐  Market research subagent (Tavily/Exa/Gemini CLI)
Phase 2 R1 ────┘  Terminology alignment + W6H structure scan (parallel)
    ↓
Phase 2 R2-5: Adaptive interview (research joins)
    ↓
Phase 3-5: Delegated to prd-planner subagent
    ├── Six Hats synthesis + differentiation strategy
    ├── MVP boundary + risk analysis
    └── PRD.md generation (with convergence board appendix)
    ↓
Phase 6: Self-verification → /spec connection
```

### Complexity-Based Adaptation

| Complexity | Example | Phase 1 | Interview |
|------------|---------|---------|-----------|
| **Low** | CLI tool, simple feature | Skip | 2 rounds |
| **Mid** | New module, library | 1 subagent | 3 rounds |
| **High** | SaaS, platform | 3 subagents (parallel) | 5 rounds |

### PRD → SPEC → Implementation

```
/prd [idea]  → PRD.md (what & why)
/spec        → SPEC.md (how — technical details)
/tth         → Autonomous implementation via multi-agent
```

---

## 🤖 TTH Multi-Agent Silo

<div align="center">
<img src="assets/tth-banner.png" alt="TTH Multi-Agent Harness" width="720" />
</div>

> **Toss Silo + Tesla 5-Step + Ralph Loop = Autonomous Multi-Agent Team**

A single line `/tth "feature description"` activates an M7 CEO persona team that collaborates autonomously.

```
/tth "Build a TODO app"
```

### Three-Axis Integration

| Axis | Origin | Role |
|------|--------|------|
| **Toss Silo** | Toss org culture | DRI structure, file boundaries, autonomous decision-making |
| **Tesla 5-Step** | Musk | Question → Delete → Simplify → Accelerate → Automate |
| **Ralph Loop** | ghuntley/ralph | Iterative convergence, backpressure, progress.txt learning |

### Team Composition (M7 CEO Mapping)

| Role | Name | CEO Philosophy |
|------|------|----------------|
| PO/Team Lead | **Satya** (Satya Nadella) | Growth Mindset, Team Empowerment |
| Architect | **Pichai** (Sundar Pichai) | Platform Thinking, 10x Thinking, Simplicity at Scale |
| Designer/UX | **Tim Cook** (Tim Cook) | Apple Design Philosophy, Perfectionism |
| Frontend | **Zuckerberg** (Mark Zuckerberg) | Move Fast, Product-Centric |
| Backend | **Jensen** (Jensen Huang) | Intellectual Honesty, Technical Depth |
| QA | **Bezos** (Jeff Bezos) | Customer Obsession, "?" Email |

### Long-Horizon Execution Pattern

For tasks with 3+ steps or multi-session work, durable project memory is automatically created:

| File | Manager | Purpose |
|------|---------|---------|
| `CHECKPOINT.md` | Satya (create) + Pichai (verification commands) | Milestone definition + verification + done-when |
| `AUDIT.log` | Satya (record) + Bezos (gate) | Append-only event stream |
| `progress.txt` | Entire team | Patterns, gotchas, lessons learned |

### Pipeline

```
Phase 0: Satya activation (PO mode)
    ↓
Phase 1: Question requirements (Musk Step 1)
    ↓
Phase 2: Dynamic team selection + story decomposition + CHECKPOINT.md creation
    ↓
Phase 3: Ralph Loop parallel execution
         (self-verification → pass/fail → retry → accumulated learning)
         AUDIT.log recorded at each milestone
    ↓
Phase 4: Integration & review (Bezos milestone gate verification)
    ↓
Phase 5: HANDOFF.md + TeamDelete
```

### Automatic Team Selection by Project Type

| Type | Team Members |
|------|-------------|
| Backend only | Pichai + Jensen + Bezos |
| Frontend only | Tim Cook + Zuckerberg + Bezos |
| Full-stack | Pichai + Tim Cook + Zuckerberg + Jensen + Bezos |
| UI redesign | Tim Cook + Zuckerberg |
| Code review/audit | Bezos solo |
| Architecture refactoring | Pichai + Bezos |

### TTH File Structure

```
~/.claude/
├── commands/tth.md           ← /tth slash command (orchestration)
├── team-roles/
│   ├── satya.md              ← PO/Lead (Opus) — CHECKPOINT.md, AUDIT.log management
│   ├── pichai.md             ← Architect (Opus) — milestone verification command definition
│   ├── tim-cook.md           ← Designer (Sonnet)
│   ├── zuckerberg.md         ← Frontend (Sonnet)
│   ├── jensen.md             ← Backend (Sonnet)
│   └── bezos.md              ← QA (Sonnet) — milestone gate final verification
├── hooks/
│   ├── verify-task-quality.sh ← TaskCompleted quality gate
│   ├── check-architecture.sh  ← Architecture invariant check
│   ├── check-remaining-tasks.sh ← TeammateIdle idle prevention
│   └── autodev-judge.sh       ← AutoDev score evaluation
└── skills/
    ├── autodev/SKILL.md       ← Autonomous experiment loop
    └── autodev-parallel/SKILL.md ← Parallel worktree orchestrator
```

> **Requirement**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable required (included in settings.json)

---

## 🔬 AutoDev Autonomous Experiment Loop

<div align="center">
<img src="assets/autodev-banner.png" alt="AutoDev - AI works while you sleep" width="720" />
</div>

> **Applying Karpathy's [autoresearch](https://github.com/karpathy/autoresearch) pattern to general software development**

An AI agent modifies code, validates with tests/builds, and iterates keep/discard decisions to **autonomously improve code**.
It automatically runs dozens of experiments while you sleep.

```
/autodev
> goal: "Make all failing tests pass"
> scope: ["src/**"]
> budget: 50
```

### autoresearch → AutoDev Mapping

| autoresearch | AutoDev |
|---|---|
| `val_bpb` (single metric) | `autodev-judge.sh` (composite score: build/test/lint) |
| `train.py` single file | Files within scope |
| `program.md` | `/autodev` skill |
| 5-min training | `npm test` / `pytest` |
| `results.tsv` | `.autodev/results.tsv` |
| NEVER STOP | NEVER STOP until budget exhausted |

### Experiment Loop

```
LOOP (until budget exhausted):
  1. Modify code (only files within scope)
  2. git commit
  3. Run tests/build
  4. Calculate score (autodev-judge.sh)
  5. Improved → KEEP (branch advances)
     Degraded → DISCARD (git reset)
  6. Repeat
```

### Parallel Mode (`/autodev-parallel`)

Run multiple ideas **simultaneously** using git worktrees.

```
/autodev-parallel
> goal: "Optimize API response time"
> scope: ["src/api/**"]
> parallel: 3
> rounds: 5
```

```
main
 ├── worktree A ── Agent 1: Add caching layer
 ├── worktree B ── Agent 2: Query optimization
 ├── worktree C ── Agent 3: Index changes
 └── Orchestrator: Collect results → cherry-pick best branch
```

### Suitable Use Cases

| Scenario | Metric |
|----------|--------|
| Batch-fix failing tests | Test pass rate |
| Performance optimization exploration | Benchmark / Lighthouse |
| TypeScript strict migration | Type error count |
| Major dependency upgrade | Build + test pass |
| Legacy refactoring | Tests maintained + LOC count |

### AutoDev File Structure

```
~/.claude/
├── skills/
│   ├── autodev/SKILL.md          ← Single experiment loop
│   └── autodev-parallel/SKILL.md ← Parallel worktree orchestrator
└── hooks/
    └── autodev-judge.sh          ← Score evaluation function
```

---

## 📐 CLAUDE.md Optimization Philosophy

> Based on ETH Zurich paper + Anthropic official guide

**"Only write what Claude can't discover by reading the code."**

- Under 200 lines (currently 140 lines)
- Remove discoverable information (skill lists, agent lists, codebase overview)
- Move linter-enforceable rules to hooks
- Separate roles between Auto Memory (MEMORY.md) and instructions

---

## 🔒 Hooks Guarantee System

Elevate CLAUDE.md "suggestions" to settings.json "guarantees":

| Rule | Method | Hook Type |
|------|--------|-----------|
| Block push to main/master | Physical block | PreToolUse |
| Block force push | Physical block | PreToolUse |
| Block .env commits | Physical block | PreCommit |
| Block console.log commits | Warning + block | PreCommit |
| Auto prettier formatting | Auto execution | PostToolUse |
| TTH task completion typecheck/lint/test | Quality gate | TaskCompleted |
| Architecture invariant violation detection | Structure protection | TaskCompleted |
| TTH teammate idle remaining task check | Idle prevention | TeammateIdle |
| Subagent completion PRD.md generation check | Generation notification | SubagentStop |
| AutoDev score evaluation | Build/test/lint composite score | autodev-judge.sh |

---

## 🛠 Skills (33)

### Autonomous Experiment Skills (2)

| Skill | Purpose |
|-------|---------|
| `/ccpp:autodev` | Autonomous code experiment loop (autoresearch pattern) |
| `/ccpp:autodev-parallel` | Parallel worktree experiment orchestrator |

### Workflow Skills (15)

| Skill | Purpose |
|-------|---------|
| `/ccpp:plan` | Task planning |
| `/ccpp:spec` | SPEC-based development - deep interview for specification writing |
| `/ccpp:spec-verify` | Specification-based implementation verification |
| `/ccpp:frontend` | Big-tech style UI development |
| `/ccpp:verify` | Test, lint, build verification |
| `/ccpp:e2e-verify` | Feature-based E2E test verification |
| `/ccpp:commit-push-pr` | Commit → Push → PR |
| `/ccpp:review` | Code review |
| `/ccpp:simplify` | Code simplification |
| `/ccpp:tdd` | Test-driven development |
| `/ccpp:build-fix` | Build error fix |
| `/ccpp:handoff` | HANDOFF.md session handover |
| `/ccpp:compact-guide` | Context management guide |
| `/ccpp:techdebt` | Technical debt cleanup |
| `/ccpp:harness-diagnostics` | TTH harness diagnostics and debugging |

### Technical Skills (10)

| Skill | Source | Purpose |
|-------|--------|---------|
| `react-patterns` | skills.sh | React 19 complete patterns |
| `vercel-react-best-practices` | Vercel | React/Next.js performance optimization |
| `typescript-advanced-types` | skills.sh | TypeScript advanced types |
| `shadcn-ui` | skills.sh | shadcn/ui components |
| `tailwind-design-system` | skills.sh | Tailwind CSS design system |
| `ui-ux-pro-max` | skills.sh | Comprehensive UI/UX guide |
| `fastapi-templates` | skills.sh | FastAPI templates |
| `api-design-principles` | skills.sh | REST/GraphQL API design |
| `async-python-patterns` | skills.sh | Python async patterns |
| `python-testing-patterns` | skills.sh | pytest testing patterns |

### E2E & Stitch Skills (5)

| Skill | Purpose |
|-------|---------|
| `/ccpp:e2e-agent-browser` | E2E test automation with agent-browser CLI |
| `/ccpp:stitch-design-md` | Stitch project → DESIGN.md generation |
| `/ccpp:stitch-enhance-prompt` | UI idea → Stitch-optimized prompt transformation |
| `/ccpp:stitch-loop` | Autonomous multi-page website generation with Stitch |
| `/ccpp:stitch-react` | Stitch screens → React component conversion |

### Image Generation Skill (1)

| Skill | Purpose |
|-------|---------|
| `/ccpp:nano-banana` | Image generation/editing with Gemini (thumbnails, icons, diagrams, etc.) |

---

## 🤖 Agents (11)

> Agents are not installed via plugins. Copy them directly to `~/.claude/agents/`.

| Agent | Purpose |
|-------|---------|
| `langchain-specialist` | LangChain/LangGraph/Deep Agents project building expert |
| `prd-planner` | /prd Phase 3-5 specialist — Six Hats synthesis + strategic scoping + PRD writing (humanities framework based) |
| `docs-writer` | Code change detection → auto /docs/ documentation generation (runs parallel to implementation) |
| `planner` | Complex feature planning (includes docs-writer parallel execution) |
| `frontend-developer` | Big-tech style UI implementation |
| `stitch-developer` | Stitch MCP-based UI/website generation |
| `junior-mentor` | Junior developer learning harness - code + EXPLANATION.md generation |
| `code-reviewer` | Code quality/security review |
| `architect` | System architecture design |
| `security-reviewer` | Security vulnerability analysis |
| `tdd-guide` | TDD methodology guidance |

<details>
<summary><b>Manual Installation</b></summary>

```bash
curl -fsSL https://github.com/jh941213/my-claude-code-asset/archive/main.tar.gz | tar -xz -C /tmp
cp /tmp/my-claude-code-asset-main/agents/*.md ~/.claude/agents/
```

</details>

---

## 📝 Commands (3)

| Command | Purpose |
|---------|---------|
| `/tth [description]` | TTH multi-agent silo (Toss + Tesla + Ralph Loop) |
| `/prd [idea]` | Aletheia v2 — complexity gate + humanities framework adaptive interview + convergence board-based PRD generation |
| `/docs [type]` | Auto documentation generation based on code changes |

---

## 📏 Rules (5, Conditional Loading)

> Loaded only when working with relevant files via YAML frontmatter.

| Rule File | Condition | Purpose |
|-----------|-----------|---------|
| `coding-style.md` | `**/*.ts`, `**/*.tsx`, `**/*.js` | Immutability, file organization |
| `git-workflow.md` | All files | Git branching, commit format |
| `testing.md` | `**/*.test.*`, `**/*.spec.*` | Testing principles, coverage |
| `performance.md` | `**/*.ts`, `**/*.tsx`, `**/*.py` | Performance optimization |
| `security.md` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.env*` | Security checklist |

---

## 💡 Boris Cherny Tips

> Practical tips from the creator of Claude Code

| # | Tip | Summary |
|---|-----|---------|
| 1 | **Parallel Execution** | 5 terminals + 5-10 claude.ai/code sessions simultaneously |
| 2 | **Opus 4.6** | Always use Opus. Slower but less steering needed, so faster overall |
| 3 | **Plan Mode** | Shift+Tab twice → Plan, then Auto-accept for 1-shot implementation |
| 4 | **Share CLAUDE.md** | Entire team commits to git, add rules for every mistake |
| 5 | **Immediate Re-plan** | If things go wrong, return to Plan mode — don't force it |
| 6 | **Subagents** | Add "use subagents" to prompt → parallel processing |
| 7 | **git worktree** | `claude --worktree` or `claude -w` for parallel work |
| 8 | **Parallel Agents** | Independent tasks → always parallel, overlapping → sequential |

---

## 🔄 Codex CLI Version

<div align="center">

**The same harness is also available for OpenAI Codex CLI.**

[![Codex CLI Power Pack](https://img.shields.io/badge/Codex_CLI_Power_Pack-33_Skills-orange.svg?style=for-the-badge)](https://github.com/jh941213/my-codex-cli-asset)

</div>

| | Claude Code Power Pack | Codex CLI Power Pack |
|---|:---:|:---:|
| **Skills** | 33 (`/ccpp:skill`) | 33 (`$skill`) |
| **Agents** | 11 (subagents) | AGENTS.md integrated |
| **Rules** | 5 (YAML conditional loading) | AGENTS.md integrated |
| **Hooks** | settings.json physical block | config.toml |
| **PRD** | Six Thinking Hats | Six Thinking Hats |
| **Auto Docs** | docs-writer parallel execution | $docs |
| **Model** | Claude Opus 4.6 | GPT-5.3 Codex |

```bash
# Codex CLI version installation
curl -fsSL https://raw.githubusercontent.com/jh941213/my-codex-cli-asset/main/install.sh | bash
```

> **GitHub**: [jh941213/my-codex-cli-asset](https://github.com/jh941213/my-codex-cli-asset)

---

## 📚 References

- [Boris Cherny Twitter](https://x.com/bcherny)
- [Claude Code Skills Official Docs](https://code.claude.com/docs/en/skills)
- [skills.sh](https://skills.sh/) - AI Agent Skill Directory
- [ETH Zurich Paper - AGENTS.md Effectiveness Analysis](https://arxiv.org/abs/2602.11988)
- [Addy Osmani - Stop Using /init for AGENTS.md](https://addyosmani.com/blog/agents-md/)

---

## 📋 Changelog

<details>
<summary><b>v0.9.0 (2026-03-16) — /prd v2: Aletheia Engine Absorption</b></summary>

**/prd v2 Complete Rewrite**
- Aletheia engine absorption: Convergence board (6-dimension progress tracking) + Complexity gate (Low/Mid/High)
- 5 humanities framework principles (Wittgenstein, Descartes, Socrates, Johari, Gadamer)
- Phase 1 research + Phase 2 R1 parallel execution for time reduction
- Graceful Exit: saves PRD.partial.md on mid-session exit, resume later
- Gemini CLI cross-validation added (alongside Tavily/Exa)

**prd-planner Agent Role Redefinition**
- "Agent that does everything" → "Phase 3-5 specialist (synthesis + scoping + PRD writing)"
- Delegation structure for main session context protection

**Hooks Added**
- `SubagentStop` — PRD.md generation check on subagent completion

**settings.json Changes**
- `Bash(gemini:*)` permission added
- `SubagentStop` hook added

**Deleted**
- `commands/aletheia.md` — fully absorbed into /prd v2

</details>

<details>
<summary><b>v0.8.0 (2026-03-11) — AutoDev Autonomous Experiment Loop</b></summary>

**AutoDev (autoresearch Pattern)**
- Inspired by Karpathy's autoresearch: AI agent modifies code → validates → autonomous keep/discard loop
- `/autodev` single experiment loop: scope-limited + budget-based autonomous execution
- `/autodev-parallel` parallel orchestrator: multiple experiments via git worktree
- `autodev-judge.sh` evaluation function: composite score for build/test/lint/code complexity

**New Files**
- `skills/autodev/SKILL.md` - Autonomous experiment loop skill
- `skills/autodev-parallel/SKILL.md` - Parallel worktree orchestrator
- `hooks/autodev-judge.sh` - AutoDev score evaluation function
- `agents/langchain-specialist.md` - LangChain/LangGraph specialist agent

**Changes**
- Skills: 31 → 33 (+autodev, +autodev-parallel)
- Agents: 10 → 11 (+langchain-specialist)
- Hooks: 3 → 4 (+autodev-judge.sh)

</details>

<details>
<summary><b>v0.7.0 (2026-03-09) — Long-Horizon Execution Pattern + Milestone Gates</b></summary>

**Skills 2.0 Migration**
- Updated SKILL.md frontmatter for all 30 skills
- Added explicit `user-invocable` field (slash command invocability)
- Structured descriptions: trigger/anti-trigger separation (single line → multiline block)
- `allowed-tools` cleanup

**Long-Horizon Execution Pattern**
- Added CHECKPOINT.md / AUDIT.log durable file stack to CLAUDE.md
- Added Knowledge Map table (reference locations for agents/skills/team-roles/project docs)

**TTH Milestone Gates**
- satya: CHECKPOINT.md creation/management + AUDIT.log protocol (9 event types)
- pichai: Executable verification command definition per milestone
- bezos: Milestone gate final verification (CHECKPOINT.md execution → AUDIT.log recording)

**New Files**
- `hooks/check-architecture.sh` - Architecture invariant check
- `skills/harness-diagnostics/SKILL.md` - TTH harness diagnostics skill

**Changes**
- `settings.json` - TEAMMATE_MODE tmux, hook matcher improvements, extraKnownMarketplaces
- `commands/tth.md` - Task decomposition section expansion
- `hooks/verify-task-quality.sh` - check-architecture integration

**Deleted**
- `skills/docs/`, `skills/prd/` - Fully migrated to commands (/docs, /prd)

</details>

<details>
<summary><b>v0.6.0 (2026-03-03) — TTH Multi-Agent Silo</b></summary>

**TTH (Toss-Tesla Harness)**
- `/tth` command for automatic M7 CEO persona multi-agent team composition
- Toss silo (DRI, file boundaries) + Tesla 5-Step (Question→Delete→Simplify→Accelerate→Automate)
- Ralph Loop iterative convergence mechanism integration (backpressure, progress.txt accumulated learning)
- Dynamic team selection by project type (backend/frontend/full-stack/redesign/review)
- Subagent-based context protection strategy

**New Files**
- `commands/tth.md` - Main orchestration (5 Phase pipeline)
- `team-roles/` - 6 CEO persona role definitions (satya, pichai, tim-cook, zuckerberg, jensen, bezos)
- `hooks/verify-task-quality.sh` - TaskCompleted quality gate (auto-detect Node.js/Python)
- `hooks/check-remaining-tasks.sh` - TeammateIdle idle prevention

**Hooks Added**
- `TaskCompleted` - Auto-run typecheck/lint/test on task completion, block on failure
- `TeammateIdle` - Prevent teammate idle when incomplete tasks remain

**settings.json Changes**
- `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` added (Agent Teams activation)

</details>

<details>
<summary><b>v0.5.0 (2026-03-02) — CLAUDE.md Optimization + PRD + Auto Docs</b></summary>

**CLAUDE.md Paper-Based Optimization**
- 277 lines → 94 lines (based on ETH Zurich paper + Anthropic guide)
- Removed discoverable information (skill/agent/tech tables)
- Added Karpathy principles: Think Before Coding, Goal-Driven Execution

**Hooks Guarantee System**
- main/master push → PreToolUse hook block
- force push → PreToolUse hook block
- .env commit → PreCommit hook block
- console.log commit → PreCommit hook block
- prettier → PostToolUse hook auto-execution

**Rules Conditional Loading**
- Added YAML frontmatter to all rules
- Load only when working with relevant files (token savings)

**New Agents (2)**
- `prd-planner` - Six Thinking Hats insight-based PRD generation
- `docs-writer` - Auto documentation generation from code changes

**New Commands (2)**
- `/prd [idea]` - Insight-driven PRD generation
- `/docs [type]` - Auto documentation generation based on code changes

</details>

<details>
<summary><b>v0.4.0 (2026-02-24) — E2E Verification + Worktree Support</b></summary>

- `/ccpp:e2e-verify` - Feature-based E2E test verification
- Auto-prompt for Worktree usage on session initialization
- Added parallel agent execution rules
- Removed `langfuse` skill
- Expanded Boris tips, added Prompt Caching rules

</details>

<details>
<summary><b>v0.3.1 (2026-02-06) — Bug Fix</b></summary>

- Fixed `settings.json` plugin marketplace reference error
- Updated `install.sh` agent/skill counts
- Reflected Opus 4.5 → Opus 4.6

</details>

<details>
<summary><b>v0.3.0 (2025-02-03) — Stitch + Image Generation</b></summary>

- Added E2E agent-browser, 5 Stitch skills
- Added `stitch-developer`, `junior-mentor` agents
- Added `nano-banana` image generation skill

</details>

<details>
<summary><b>v0.2.0 (2025-02-03) — SPEC-Based Development</b></summary>

- Added `/spec`, `/spec-verify` skills

</details>

<details>
<summary><b>v0.1.0 (2025-01-22) — Initial Release</b></summary>

- Initial release

</details>

---

## License

MIT
