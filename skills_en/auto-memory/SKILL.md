---
name: auto-memory
description: Use when starting substantial work in a repo (implementation, fixes, deploys, debugging), when first exploring a new repo, or when finishing work that produced reusable knowledge. Loads only the memory relevant to the task type and routes new knowledge into topic files
---

# Auto-Memory (task-scoped selective memory)

**Principle: never load everything. Read only the memory this task needs.**
Injecting all memory into every context is wasteful. Only the index is always loaded; bodies are read only when the task type matches their load condition.

## Store layout

```
{project}/memory/
├── INDEX.md          # topic | file | load condition — auto-injected at session start / post-compact (keep lean)
├── architecture.md   # system structure, module boundaries, key design decisions
├── deploy.md         # deploy procedure, CI/CD, env vars, infra (e.g. deploy work → where the CI/CD docs live)
├── testing.md        # how to run tests, fixtures, flaky spots
├── data-model.md     # schemas, migrations, data flow
├── gotchas.md        # traps, workarounds, environment quirks
└── (add topics only when needed — no empty stubs)
```

INDEX.md format:

```markdown
# Memory Index
| Topic | File | Load condition (read when the task is...) |
|------|------|------|
| Deploy/CI | deploy.md | deploy, release, CI/CD changes, env vars, infra work |
| Architecture | architecture.md | new feature design, adding modules, refactoring, structure questions |
| Testing | testing.md | writing/fixing tests, debugging failures |
```

## Workflows

### A. Init (repo has no memory/)
1. Survey the repo: README, docs/, CI config (.github/workflows etc.), manifests (package.json/pyproject.toml), directory layout
2. Create `memory/INDEX.md` plus topic files ONLY for what you actually learned (no empty stubs)
3. If docs already exist (docs/ARCHITECTURE.md etc.), do not copy their content — store a **pointer** (summary + location); docs own the truth

### B. Task start (selective load)
1. Classify the task (deploy? feature? bug? tests?)
2. Read ONLY the files whose load condition matches — if nothing matches, load nothing
3. If loaded memory is stale (paths gone, etc.), fix or delete it on the spot

### C. Task end (routing)
The test is: "will I need this the next time I do this kind of task?" Roles:
- **`memory/{topic}.md`** — latest knowledge per topic (overwrite in place, always reflects current state)
- **`tasks/lessons.md`** — chronological work journal (enforced by the Stop gate, append-only)
- **`~/.claude/projects/*/memory/`** — only cross-project user preferences / environment knowledge
New topic → new file + INDEX.md row. Consider splitting any file that passes ~100 lines.

### D. Long sessions (mid-term memory)
For work stretching past ~30 minutes, maintain `tasks/context.md`:

```markdown
# Current working state
- Goal: <verifiable done-condition>
- Key decisions: <one line each, with reason>
- Done: <finished> / Next: <immediate next step>
- Key files: <paths>
```

Update it at each milestone. This file is re-injected automatically after compaction and at session start, so nothing written here gets forgotten.

## Forbidden
- Reading all of memory/ without consulting the index
- Loading memory unrelated to the task
- Copying anything derivable from code (function lists etc.) — code is the source of truth
- Creating empty topic files in advance
