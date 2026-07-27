---
description: "Docs generation/sync router — code docs, architecture diagrams, API specs, manuals, ops docs, docs CI, drift sync"
argument-hint: "[code|arch|api|manual|ops|ci|sync|all]"
---

Generates/synchronizes project documentation — from code-level docs to architecture diagrams, API specs, manuals, ops docs, and docs CI.

Input: $ARGUMENTS

## Routing

| Invocation | Target | Execution |
|------------|--------|-----------|
| `/docs` | Update code docs from recent changes | docs-writer agent |
| `/docs code` | Code-level docs (api.md, components.md, utils.md, models.md) | docs-writer agent |
| `/docs arch` | Architecture diagrams + ARCHITECTURE.md + ADRs + ERD | **docs-architecture skill** |
| `/docs api` | API topology + OpenAPI/AsyncAPI specs + API CHANGELOG | **docs-interfaces skill** |
| `/docs manual` | User manual (Diátaxis quadrants) | **docs-manuals skill** |
| `/docs ops` | Operator manual + runbooks + deployment guide + incident playbook | **docs-manuals skill** (ops mode) |
| `/docs ci` | Install docs validation pipeline (links/OpenAPI/mermaid/freshness) | **docs-ci skill** |
| `/docs sync` | Detect docs drift → refresh stale docs | sync procedure below |
| `/docs all` | Generate the full documentation set | all procedure below |

## `/docs sync` procedure (docs-code synchronization)

1. Check `docs/docs.yaml` exists — if not, generate the manifest first via the docs-ci skill
2. Run `bash scripts/check-docs-freshness.sh` (or diff docs.yaml covers vs git log directly)
3. Report stale docs grouped by area
4. Refresh each stale area with its owner:
   - `docs/ARCHITECTURE.md` → docs-architecture
   - `docs/api/*` → docs-interfaces
   - `docs/manuals/*`, `docs/ops/*` → docs-manuals
   - `docs/*.md` code docs → docs-writer
5. Update `last_reviewed` to today for refreshed docs
6. If `.docs-queue/` exists (TTH mode), process and delete queue files

## `/docs all` procedure

Analyze the whole project and generate the documentation set. Independent areas run in parallel:

```
Agent A (docs-writer): code-level docs
Agent B (docs-architecture skill): ARCHITECTURE.md + diagrams + ERD
Agent C (docs-interfaces skill): API specs + topology
Agent D (docs-manuals skill): manuals + ops docs
```

Afterwards, install the manifest + CI pipeline via the docs-ci skill and update the `docs/README.md` index.

## Parallel execution with implementation agents

Pattern for running docs-writer in the background during implementation (TTH triggers this via hooks automatically):

```
Agent(subagent_type: "docs-writer", run_in_background: true, prompt: "...")
```

## Important rules

- Only modify the /docs/ folder (never modify source code)
- Update existing docs rather than overwrite (prefer Edit)
- Descriptions in English, code/variable names kept as-is
- Omit what is obvious from reading the code — document "why" and "when"
- Do not create documentation files for empty types
- When creating or updating a doc, also update its `docs/docs.yaml` entry
