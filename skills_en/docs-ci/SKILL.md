---
name: docs-ci
description: "Scaffold a docs-as-code CI/CD pipeline + docs drift detection — link check, OpenAPI lint/breaking gate, mermaid validation, docs freshness check, CHANGELOG automation, docs.yaml manifest"
when_to_use: "Installing docs CI/pipelines, detecting docs drift/freshness, docs sync automation, link checks, changelog automation. Writing doc content → docs-architecture/interfaces/manuals; not for the app's own deploy pipeline"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Docs CI Skill — validate docs like code

Builds the **pipeline that guards the docs**, not the docs themselves. Output: GitHub Actions workflow + drift detection script + the `docs/docs.yaml` manifest convention.

## Input

$ARGUMENTS

## The docs.yaml manifest (the drift-detection contract)

Written by every skill in the docs suite; consumed by this skill's checks:

```yaml
# docs/docs.yaml — doc ↔ code mapping
docs:
  - path: docs/ARCHITECTURE.md
    covers: ["src/**"]          # code paths this doc describes
    last_reviewed: 2026-07-27   # last human/agent review date
  - path: docs/api/openapi.yaml
    covers: ["src/api/**", "src/routes/**"]
    last_reviewed: 2026-07-27
  - path: docs/ops/runbooks/
    covers: ["deploy/**", "monitoring/**"]
    last_reviewed: 2026-07-27
review_max_age_days: 90
```

**Stale verdict**: the latest commit under `covers` is newer than `last_reviewed`, or the review age exceeds `review_max_age_days`.

## Checks it installs (pick per project)

| Check | Tool/method | Failure policy |
|-------|-------------|----------------|
| Broken links | lychee (`lycheeverse/lychee-action`) | internal broken = fail, external = warn |
| OpenAPI style | `redocly lint` or `spectral lint` | fail |
| API breaking changes | `oasdiff breaking base rev --fail-on ERR` | fail + PR comment |
| Code-first spec drift | regenerate spec in CI → `git diff --exit-code` | fail |
| Mermaid syntax | extract blocks → `mmdc -i x.mmd -o /dev/null` | fail |
| Docs freshness | `scripts/check-docs-freshness.sh` (docs.yaml-based) | warn (or open an issue) |
| Code+doc co-change | `src/api/** changed && docs/api/** untouched` → PR warning comment | warn |
| CHANGELOG | conventional commits + `git cliff` (on release) | auto-generated |
| Preview deploys | per-PR preview URL if a docs site exists | — |

## Procedure

1. **Diagnose the project**: which docs/specs exist (`docs/`, `openapi.*`, mermaid blocks, docs site generator)
2. Install only checks that match what exists — no spectral gate for a project without OpenAPI
3. Create/update `docs/docs.yaml` (scan existing docs to draft `covers` — include comments so users can refine)
4. Create `scripts/check-docs-freshness.sh` (template: `templates/check-docs-freshness.sh`)
5. Create `.github/workflows/docs-ci.yml` (only the needed jobs from `templates/docs-ci.yml`)
6. Run once locally and report: `bash scripts/check-docs-freshness.sh`

## Harness integration (with this plugin's other components)

- TTH mode: `hooks/docs-sync.sh` queues changed files into `.docs-queue/` per completed story → ralph-loop spawns docs-writer. **docs-ci is the final layer that re-verifies in CI**
- `/docs sync` command: report stale docs from docs.yaml → delegate updates to the matching docs-* skill

## Constraints

- Create only workflows/scripts/`docs/`. Never modify app source
- Checks requiring uninstalled tools: `continue-on-error` or conditional (`if: hashFiles(...)`)
- If a CI workflow already exists, add a separate `docs-ci.yml` — never overwrite
