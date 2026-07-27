---
name: docs-manuals
description: "Generate user manuals (Diátaxis) and operator manuals (runbooks, deployment guide, configuration reference, incident playbook)"
when_to_use: "Writing user manuals/guides/tutorials, operator manuals, runbooks, deployment guides, on-call/incident response docs. API specs → docs-interfaces; architecture docs → docs-architecture; docs CI pipeline → docs-ci"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# User/Operator Manual Skill

Writes for the actual reader (end user vs operator) in their actual situation (learning vs firefighting).

## Input

$ARGUMENTS

## User manual — the Diátaxis quadrants

**Cardinal rule: never mix two modes in one page.** Classify before writing:

| Quadrant | Purpose | Form | Location |
|----------|---------|------|----------|
| Tutorial | Learning (newcomers) | A lesson that succeeds when followed. One path, no choices | `docs/manuals/tutorials/` |
| How-to | Solving a task ("how do I X?") | Goal-oriented steps. Prerequisites stated | `docs/manuals/how-to/` |
| Reference | Looking things up | Dictionary-like. Mirrors the product's structure | `docs/manuals/reference/` |
| Explanation | Understanding ("why is it like this?") | Background, design reasons, trade-offs | `docs/manuals/explanation/` |

Trigger mapping: new feature → how-to + reference / new concept → explanation / onboarding gap → tutorial

Index at `docs/manuals/README.md` — navigation organized by the four quadrants.

## Operator manual

Location: `docs/ops/`

### 1. Operations overview (`docs/ops/README.md`)
- System topology (link/include the deployment diagram from docs-architecture)
- Capacity/scaling notes, steady-state metric baselines

### 2. Configuration reference (`docs/ops/configuration.md`)
Every env var/flag in a table — extracted from code (`.env.example`, config files, `process.env`/`os.environ` grep):

| Name | Type | Default | Effect | Valid values |
|------|------|---------|--------|--------------|

### 3. Runbooks (`docs/ops/runbooks/[alert-name].md`)
**Someone seeing this for the first time at 3 a.m. must be able to follow it.** Template: `templates/runbook.md`
- One file per alert: alert name/severity/user impact → **diagnosis** (dashboard links + paste-ready queries) → **mitigation** (ordered paste-ready commands + trade-off warnings per step) → **root fix/follow-up** → escalation path
- A new alert rule ships with its runbook in the same PR. A runbook used in an incident gets updated afterward, always

### 4. Deployment guide (`docs/ops/deployment.md`)
Environments, pipeline description, rollout procedure, post-deploy verification (smoke check commands), **rollback procedure** (the most important part — paste-ready)

### 5. Incident playbook (`docs/ops/incident-playbook.md`)
Severity matrix, roles (incident commander/comms lead), comms templates, escalation policy, blameless postmortem template

## Procedure

1. Determine target: user docs vs ops docs, specific doc vs full set
2. Collect sources: code (config/alert rules/deploy scripts), existing docs/, CI config, docker/k8s manifests
3. **State only facts confirmed in code** — unknown operational values (dashboard URLs, on-call rotations) get `<!-- TODO: confirm with ops -->` markers and a reported list
4. Update existing docs with Edit; Write only new ones
5. Update the `docs/docs.yaml` manifest
6. Prose in the project language; commands/identifiers verbatim

## Constraints

- Modify only `docs/`
- Runbook commands must actually run — no nonexistent scripts/commands
- One Diátaxis quadrant per page — propose a split when mixing is detected
