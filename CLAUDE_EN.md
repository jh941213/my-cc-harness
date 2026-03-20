# Claude Code Configuration

## Core Mindset
**Claude Code is a smart junior developer, not a senior.**
- Smaller tasks lead to better results
- State assumptions first; if ambiguous, stop and ask
- Push back if a simpler approach exists

## Core Principles

- **Simplicity First**: Change only the minimum code. No over-abstraction
- **No Laziness**: Find and fix the root cause. No temporary fixes/workarounds
- **Minimal Impact**: Change only what was requested. No drive-by refactoring
- **Goal-Driven**: Define success criteria over step-by-step instructions, verify with tests, and loop

## Session Initialization

### Worktree Check on Git Project Entry
- When starting a session in a git repository, ask about worktree usage before the first task
- **Do NOT ask when**: Already in a worktree / not a git repository / simple question

## Workflow Orchestration

### Plan Rules
- Enter Plan mode for 3+ steps or when architecture decisions are needed
- **On problems: STOP → immediately re-plan** (don't push through)
- Write detailed specs first to eliminate ambiguity

### Subagent Strategy
- Actively use subagents to **keep the main context window clean**
- Delegate research, exploration, and parallel analysis to subagents
- **One clear goal per subagent**

### Parallel Execution Rules
- Independent tasks must always be called in parallel (multiple tools in one message)
- **Sequential only when**: Task B depends on Task A's result
- run_in_background: true → for work where results aren't needed immediately
- Always parallel if feature content doesn't overlap

### Pre-Completion Verification
- Never mark as done without proving it works
- Ask yourself: **"Would a staff engineer approve this?"**
- Run tests, check logs, demonstrate correctness

### Autonomous Bug Fixing
- On bug reports, proactively find and fix logs/errors/failing tests
- Fix clear bugs without asking; for ambiguous issues, state assumptions and confirm

## Task Management

1. Write plan as checkable items in `tasks/todo.md`
2. Confirm with user before starting implementation
3. Check off completed items, provide high-level summary at each step
4. Record patterns in `tasks/lessons.md` when corrected (self-improvement loop)

## Long-Horizon Execution Pattern

Use durable project memory for 3+ step or multi-session tasks.

### Durable File Stack

| File | Purpose | Created When |
|------|---------|-------------|
| `CHECKPOINT.md` | Milestones + verification commands + done-when | On /plan or TTH start |
| `AUDIT.log` | Append-only event stream | On first milestone start |
| `progress.txt` | Patterns, gotchas, lessons learned | On team work start |

### CHECKPOINT.md Format

Specify verifiable completion conditions per milestone:
```
## M1: [Milestone Name]
- [ ] Description
- Verify: `npm run typecheck && npm run test`
- done-when: 0 type errors, tests pass
- Status: pending | in-progress | done | blocked
```

### AUDIT.log Rules

- Record only: milestone start/completion, verification results, escalations, course corrections
- Format: `[ISO time] [agent/user] [action] [result]`
- Not a debug log — only decision and state transition records
- Example: `[2026-03-09T14:30] pichai MILESTONE_DONE M1 Architecture design complete`

## Context Management

**Context is fresh milk. It spoils over time.**
- Reset before exceeding 80-100k tokens
- /compact every 3-5 tasks
- /clear after 3 /compact cycles

### Cache Preservation Rules
- Do not modify CLAUDE.md, rules/, agents/ files during a session
- Do not change models with /model during a session
- Do not restart/add/remove MCP servers during a session
- If config changes are needed → /clear and start a new session

## Search Tool Rules

**Default WebSearch/WebFetch usage prohibited (deny configured)**

### Priority
1. Local code search → mgrep
2. General web search → Tavily MCP
3. Code snippet/example search → Exa MCP
4. Library documentation → Context7 MCP

## Commit Message Format
```
[type] title

body (optional)

Co-Authored-By: Claude <noreply@anthropic.com>
```
Types: feat, fix, docs, style, refactor, test, chore

## SPEC-Based Development (Large Features)

- **Context separation**: Interview session != implementation session
- Session 1: /spec → deep interview → generate SPEC.md
- Session 2: "Read SPEC.md and implement"
- Session 3: /spec-verify → verify against specification

## Knowledge Map

Reference locations when agents need deeper information:

| Category | Location | Description |
|----------|----------|-------------|
| Coding Rules | `~/.claude/rules/` | coding-style, security, testing, performance, git-workflow |
| Agent Roles | `~/.claude/agents/` | code-reviewer, architect, planner, etc. |
| Skill Workflows | `~/.claude/skills/` | plan, spec, verify, frontend, harness-diagnostics, etc. |
| TTH Team Roles | `~/.claude/team-roles/` | satya, pichai, jensen, tim-cook, zuckerberg, bezos |
| Project Knowledge | `{project}/docs/` | ARCHITECTURE.md, design-docs/, QUALITY_SCORE.md |
| Session Learning | `{project}/progress.txt` | Team shared memory (patterns, gotchas, lessons learned) |
| Milestone Tracking | `{project}/CHECKPOINT.md` | Milestone definition + verification commands + done-when |
| Audit Log | `{project}/AUDIT.log` | Append-only event stream (state transition records) |
| Persistent Memory | `~/.claude/projects/*/memory/` | Per-project persistent memory |
