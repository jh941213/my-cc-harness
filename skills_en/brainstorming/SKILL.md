---
name: brainstorming
description: Use before any creative work - adding features, creating components, or changing behavior. Locks down intent, requirements, and design through dialogue before implementation
---

# Brainstorming (design before code)

Turn ideas into a settled design through natural dialogue, and only then implement.

**HARD GATE: no code, no scaffolding, no implementation until a design has been presented and approved by the user.** "Too simple to need a design" is a trap — simple projects are where unexamined assumptions waste the most work. The design may be a few sentences, but it must be presented and approved.

## Process

1. **Understand project context** — files, docs, recent commits
2. **Check scope** — if the request bundles several independent subsystems, propose decomposition before detailed questions. Each sub-project gets its own spec → plan → implementation cycle
3. **One question at a time** — purpose, constraints, success criteria. Prefer multiple choice
4. **Propose 2-3 approaches** — with trade-offs, recommendation first with reasoning. Apply YAGNI ruthlessly to every option
5. **Present the design** — section by section, sized to complexity (a few sentences when simple). Cover architecture, components, data flow, error handling, testing; confirm each section
6. **Save the design doc** — `{project}/docs/design-docs/[date]-[topic].md` (links into the execute-plans convention)
7. **Self-review** — scan for TBD/placeholders, contradictions, ambiguous requirements, scope fit; fix inline
8. **Ask the user to review the spec** → once approved, move to /plan for the implementation plan

## Design principles
- Each unit: one clear purpose + well-defined interface + independently testable
- For every unit you should be able to answer: what does it do / how is it used / what does it depend on
- If a unit can't be understood without reading its internals, or internal changes break consumers, the boundaries are wrong
- In existing codebases follow existing patterns; include targeted improvements only where existing problems affect the current work (no unrelated refactoring)
