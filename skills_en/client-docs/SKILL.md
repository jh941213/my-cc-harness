---
name: client-docs
description: Use when asked for client-submission SI/AO deliverables (architecture design doc, interface spec, DB design doc, requirements traceability matrix, test result reports, manuals, operations reports). Triggered by acceptance/delivery/deliverable requests. On-demand only — produce exactly the deliverable requested
---

# Client-Docs (on-demand client deliverables)

**Principle: deliverables are infrequent. Generate only the requested one, by transforming materials that already exist (docs/, code, actual run output).**

## Deliverable routing

| Deliverable | Source material (generate first if missing) | Notes |
|---|---|---|
| Architecture design doc | `docs/ARCHITECTURE.md` + diagrams + ERD (else /docs arch first) | |
| Interface spec | `docs/api/` OpenAPI (else /docs api first) | includes internal/external integrations |
| DB design doc | ERD + model/migration code → table definition tables | |
| Requirements spec / RTM | SPEC.md·PRD.md + requirement↔implementation(files/commits)↔test mapping | never fill cells without mapping evidence |
| Unit/integration test report | **actual test run output** (pytest/CI logs) | recording results of tests that were not run is absolutely forbidden — evidence-based reporting |
| User/operator manual | `docs/manuals/`, `docs/ops/` (else /docs manual·ops first) | |
| AO operations report | AUDIT.log, incident/change records, git log | confirm the reporting period with the user |

## Generation rules

1. **Output location**: `{project}/deliverables/[name]_[YYYY-MM-DD].md`
2. **Common skeleton**: cover (project name·date·version) → revision history → TOC → body → appendix. Body structure follows each deliverable's convention
3. **Client template wins**: if `~/.claude/templates/client/` or `{project}/templates/` has the client's template, follow its structure and field names exactly. Otherwise generate markdown with the skeleton above (convert to Excel/Word later via pandoc etc.)
4. **Facts only**: only content verified from code/docs/run output. Leave unverified items empty marked `[NEEDS CONFIRMATION]` — never fill plausibly
5. **If sources are stale, run /docs sync first**, then generate
6. After generating, add a deliverables/ routing row to `memory/INDEX.md` if absent (keywords: deliverable, acceptance, delivery)
7. **Acceptance-grade requirements** (rejection-prevention rules from independent evaluation):
   - Test reports need more than summary tables — include a **per-case detail appendix** (ID, test name, verdict) generated from actual `-v` output
   - Coverage must **state the measurement command and scope**; never report a tests-included figure alone — also give the source-package-only figure (denominator differences can double the apparent number)
   - Include an **approval box** (author/reviewer/approver) and a **requirements traceability matrix** skeleton — mark missing values [NEEDS CONFIRMATION]
8. After generating, verify facts (number reproduction) with a separate agent when possible — the generator must not grade its own deliverable

## Entry points
- Slash command: `/client-docs [arch|api|db|rtm|test|manual|ops|report]`
- Natural language: requests like "acceptance deliverables", "delivery docs", "test result report"

## Forbidden
- Bulk-generating deliverables that weren't requested (on-demand principle)
- Recording test results that weren't run or figures that weren't verified
- Modifying docs/ originals (deliverables go to deliverables/ only — originals are owned by the /docs suite)
