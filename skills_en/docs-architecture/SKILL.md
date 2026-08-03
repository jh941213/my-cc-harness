---
name: docs-architecture
description: "Generate/update architecture docs — ARCHITECTURE.md (codemap), architecture diagrams (C4 mermaid), ADRs (MADR), data model ERD"
when_to_use: "Writing/updating architecture docs or diagrams, recording ADRs, documenting ERD/data models, reflecting structural refactors in docs. Not for API specs (docs-interfaces), user/ops manuals (docs-manuals), or code implementation"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Architecture Documentation Skill

Documents the structural facts of a project. Output goes under `docs/`; diagrams are mermaid (native repo rendering).

## Input

$ARGUMENTS

## Choosing the artifact (decision tree)

| Situation | Artifact |
|-----------|----------|
| Small project (<10k LOC) | README architecture section + 1 context diagram — no over-documentation |
| Contributors get lost | `docs/ARCHITECTURE.md` (codemap) |
| System boundaries/external integrations need explaining | C4 Context + Container diagrams |
| Significant design decision made | `docs/design-docs/ADR-NNN-[title].md` (MADR) |
| Persistent data structure changed | ERD section in `docs/ARCHITECTURE.md` or `docs/data-model.md` |
| Large/regulated system | arc42 12-section document (only on explicit request) |

## ARCHITECTURE.md rules (codemap)

1. **A map, not an atlas** — coarse modules and relations only. No per-file listing
2. First a bird's-eye view of the *problem* the system solves, then the codemap
3. Name important symbols but don't hyperlink them (links rot — readers use symbol search)
4. State **architectural invariants** (e.g., "the domain layer never imports infra")
5. Don't write what reading the code reveals — write decisions/reasons the structure can't show

Structure:
```markdown
# Architecture

## Overview       ← the problem this system solves, 1-2 paragraphs
## Diagrams       ← C4 Context/Container mermaid
## Codemap        ← role + boundary per module (~1 paragraph per directory)
## Invariants     ← structural rules to keep
## Cross-cutting  ← logging, error handling, auth, other shared concerns
```

## Diagrams

Mermaid syntax and conventions: see `references/mermaid-conventions.md` (C4Context/C4Container, sequenceDiagram, erDiagram, architecture-beta).

Key conventions:
- 1 diagram = 1 concern, ≤15-20 nodes
- C4 goes Context → Container by default. For Component-level detail, flowchart + subgraph lays out better
- Infra/deployment topology: prefer `architecture-beta`

## ADRs (MADR format)

- Location: `docs/design-docs/ADR-NNN-[kebab-title].md` — numbers are zero-padded 3 digits (e.g., `ADR-001-use-postgres.md`); update the index in `docs/design-docs/index.md`
- Template: `templates/adr.md` (default is minimal — Context/Decision/Consequences; full MADR only for contested decisions)
- **ADRs are immutable** — to reverse one, supersede with a new ADR; never rewrite
- status: proposed → accepted → superseded by ADR-NNN

## Procedure

1. Identify targets: with no args, detect changed structural elements via `git diff --name-only HEAD~5..HEAD` + project structure scan
2. If `docs/ARCHITECTURE.md` exists, update with Edit (no full rewrites — only changed sections)
3. Verify diagram nodes match actual code structure before generating
4. Update the `docs/docs.yaml` manifest (create if missing):
   ```yaml
   docs:
     - path: docs/ARCHITECTURE.md
       covers: ["src/**", "!src/**/*.test.*"]
       last_reviewed: 2026-07-27
   ```
5. Prose in the project language; code/identifiers verbatim

## Constraints

- Modify only `docs/`. Never touch source code
- Never draw relationships from guesswork — only what was confirmed in code
