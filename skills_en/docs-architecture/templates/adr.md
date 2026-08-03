# ADR Template (MADR-based)

## Minimal (default — most decisions)

```markdown
---
status: accepted        # proposed | accepted | superseded by ADR-NNN
date: {YYYY-MM-DD}
decision-makers: [{name}]
---

# ADR-{NNN}: {the decision in one sentence}

## Context
{What problem/constraint forced a decision. 2-5 sentences}

## Decision
{What was chosen. One active-voice sentence + support}

## Consequences
- Better: {…}
- Accepted cost: {…}
- Follow-ups: {…}
```

## Full MADR (contested/high-cost decisions only)

```markdown
---
status: proposed
date: {YYYY-MM-DD}
decision-makers: [{name}]
consulted: [{who gave input}]
informed: [{who was told}]
---

# ADR-{NNN}: {title}

## Context and Problem Statement
{problem definition}

## Decision Drivers
- {driver 1 — e.g., operating cost}
- {driver 2}

## Considered Options
1. {Option A}
2. {Option B}
3. {Option C}

## Decision Outcome
Chosen: **{option}** — {reason summary}

### Consequences
- Good: {…}
- Bad: {…}

### Confirmation
{How adherence is checked — lint rule, review check, test}

## Pros and Cons of the Options

### {Option A}
- Good: {…}
- Bad: {…}

### {Option B}
- Good: {…}
- Bad: {…}
```

## Index update

Add one line to `docs/design-docs/index.md`:

```markdown
| ADR-{NNN} | {title} | {status} | {date} |
```
