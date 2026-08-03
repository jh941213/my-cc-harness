---
name: docs-interfaces
description: "Generate interface/API docs — OpenAPI 3.1/AsyncAPI 3.0 specs, API topology diagrams, interface flow (sequence) diagrams, API changelog. Use when writing API docs/specs (OpenAPI, swagger, AsyncAPI), interface/API topology diagrams, endpoint docs, API changelogs. Whole-system diagrams → docs-architecture; user manuals → docs-manuals; API design principles themselves → api-design-principles"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Interface/API Documentation Skill

Documents contracts between systems. The spec in Git is the single source of truth (docs-as-code).

## Input

$ARGUMENTS

## Artifact map

| Target | Artifact | Location |
|--------|----------|----------|
| REST API | OpenAPI 3.1 spec | `docs/api/openapi.yaml` |
| Event/message interfaces | AsyncAPI 3.0 spec | `docs/api/asyncapi.yaml` |
| API topology (inter-system calls) | C4 Container + per-flow sequence diagrams | `docs/api/README.md` |
| Human-readable reference | Per-endpoint markdown (inherits docs-writer's api.md format) | `docs/api/reference.md` |
| API change history | breaking/non-breaking + deprecation schedule | `docs/api/CHANGELOG.md` |

## Spec-first vs code-first

- **Multiple teams/external consumers** → spec-first: author and review `docs/api/openapi.yaml` first; code follows the spec
- **Single-team internal service** → code-first is fine, but the generated spec must be committed and diffed in CI (the drift gate is installed by the docs-ci skill)
- Either way a spec file must exist in the repo — "the code is the doc" doesn't count

## OpenAPI rules

1. Write from actual routes/schemas read from code — no guessing. Mark unverifiable fields with TODO comments
2. `operationId` required, group resources with tags, include 4xx/5xx responses
3. Examples must be real working values
4. Declare auth schemes (`securitySchemes`)
5. Don't force event-driven interfaces (queues, websockets, webhooks) into OpenAPI — split into AsyncAPI

## API topology + flow diagrams

- Inter-system topology: 1 C4 Container diagram
- One sequence diagram per key flow (auth, order creation, …) — use the shared conventions in `../docs-architecture/references/mermaid-conventions.md`
- Include at least one error path (`alt` block) — never draw only the happy path

## API CHANGELOG rules

```markdown
## [v1.4.0] - 2026-07-27
### Breaking
- `GET /users` response: removed `nickname` → `profile.nickname` (migration: …)
### Added
- `POST /invoices/bulk`
### Deprecated
- `GET /v1/legacy-search` — sunset 2026-10-01
```

- Breaking changes must ship with a migration path
- If oasdiff is installed, draft with `oasdiff changelog <base> <rev>` then polish

## Procedure

1. Find route/handler/schema files (`**/routes/**`, `**/api/**`, `**/controllers/**`, framework patterns)
2. If a spec exists, diff it against actual code → report mismatches first, then update
3. If new, generate an OpenAPI 3.1 skeleton → fill per resource
4. Write `docs/api/README.md` with topology + flow diagrams
5. Update `docs/docs.yaml` manifest entries for `docs/api/*` (covers: route path globs)
6. Validate the spec: `npx @redocly/cli lint docs/api/openapi.yaml` or `npx @stoplight/spectral-cli lint` (only if installed; otherwise skip and suggest docs-ci)

## Constraints

- Modify only `docs/`. Never touch source code
- Never put endpoints in the spec that don't exist in code
