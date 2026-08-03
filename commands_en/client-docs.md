---
description: "On-demand client deliverables — architecture/interface/DB design docs, RTM, test reports, manuals, operations reports"
argument-hint: "[arch|api|db|rtm|test|manual|ops|report]"
---

Generate client-submission deliverables using the client-docs skill.

Input: $ARGUMENTS

## Routing

| Invocation | Deliverable |
|------|--------|
| `/client-docs arch` | Architecture design doc (← docs/ARCHITECTURE.md, diagrams, ERD) |
| `/client-docs api` | Interface spec (← docs/api/ OpenAPI) |
| `/client-docs db` | DB design doc / table definitions (← ERD, model code) |
| `/client-docs rtm` | Requirements spec / traceability matrix (← SPEC.md/PRD.md + implementation·test mapping) |
| `/client-docs test` | Unit/integration test report (← actual pytest/CI run output) |
| `/client-docs manual` | User manual (← docs/manuals/) |
| `/client-docs ops` | Operator manual / handover doc (← docs/ops/) |
| `/client-docs report` | AO operations report (← AUDIT.log, incident/change records; confirm period) |
| `/client-docs` (no args) | Show available deliverables with source-readiness status and let the user pick |

## Procedure

1. Load the client-docs skill, check source materials for the requested deliverable
2. If sources are missing, propose generating them first (/docs arch etc.) — proceed after user confirmation
3. Generate `deliverables/[name]_[date].md` (client template wins if present)
4. Mark unverified items `[NEEDS CONFIRMATION]` — never fill by guess
