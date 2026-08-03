---
name: auto-memory
description: Use when starting substantial work in a repo (implementation, fixes, deploys, debugging), when first exploring a new repo, or when finishing work that produced reusable knowledge. Operates a routing table that selectively loads only the docs/memory relevant to the task type
---

# Auto-Memory (docs-routing selective memory)

**Principle: route knowledge, don't copy it. Only the routing table is always loaded; bodies (docs and memory) are Read only when the task type matches.**

The harness already generates documentation in `{project}/docs/` (the /docs suite, DEPLOY.md, ARCHITECTURE.md, ...). Those docs can't all be injected into every context, so this skill's job is to **route the right docs into context when a matching task starts** — e.g. a "deploy this" request loads the CI/CD doc first.

## Store layout

```
{project}/memory/
├── INDEX.md      # routing table (format below) — auto-injected at session start / post-compact, keep lean
└── {topic}.md    # ONLY knowledge with no docs home (environment quirks, gotchas). If a doc exists, don't create one
```

INDEX.md format (the keyword column powers the deterministic hint hook):

```markdown
# Memory Index (routing table)

| Task type | Keywords | Files to load |
|------|------|------|
| Deploy/CI | deploy,docker,release,ci | docs/ops/cicd.md, DEPLOY.md |
| Architecture/design | design,structure,refactor,architecture | docs/ARCHITECTURE.md |
| API work | api,endpoint,router | docs/api/ |
| Testing | test,pytest | memory/testing.md |
```

## How it works (dual routing)

1. **Deterministic layer (hook)**: `memory-route-hint.sh` (UserPromptSubmit) matches prompt keywords against INDEX rows and injects a **one-line hint** — "this looks like an X task → Read these files first". It never injects document bodies
2. **Model layer (skill)**: even without a hint, classify the task at start, consult INDEX, and Read only the matching files — if nothing matches, load nothing

## Workflows

### A. Init (repo has no memory/INDEX.md)
1. Survey the repo: full docs/ listing, README, DEPLOY.md-style files, CI config (.github/workflows), manifests, layout
2. **Classify existing docs by task type and create INDEX.md routing rows** — docs own the truth, INDEX is the map
3. Create `memory/{topic}.md` only for knowledge with no docs home (no empty stubs)

### B. Task start (selective load)
1. If the hook emitted a hint, Read those files first
2. Otherwise classify the task → Read only INDEX-matched files
3. If loaded content is stale (dead paths etc.), fix the INDEX/doc on the spot

### C. Task end (routing new knowledge)
The test: "needed the next time this task type comes up?" Priority:
1. **If a doc owns that knowledge, update the doc** (never copy into memory)
2. If it has no docs home, update/create `memory/{topic}.md` + add an INDEX row
3. Chronological journal goes to `tasks/lessons.md` (Stop-gate enforced); cross-project knowledge to `~/.claude/projects/*/memory/`
4. If new docs were created, add routing rows for them

### D. Long sessions (mid-term memory)
For 30min+ work, maintain `tasks/context.md` (goal / key decisions / done·next / key files). It is auto-reinjected after compaction and at session start, so nothing written there gets forgotten.

## Forbidden
- Copying docs content into memory/ (pointers/routing only)
- Loading docs/memory wholesale without consulting the index
- Loading files unrelated to the task
- Copying anything derivable from code — code is the source of truth
- Creating empty topic files in advance
