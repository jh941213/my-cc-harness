---
name: spec
description: "SPEC-based development interview -- generates a detailed SPEC.md specification through in-depth questioning. Triggers on: spec, spec, specification, interview, feature design. NOT for: immediate implementation, simple fixes, code writing."
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Edit
---

# SPEC-Based Development - Interview

SPEC-based development workflow from Anthropic engineer Thariq.

## Triggers
- "spec", "specification", "interview", "feature design"

## Workflow

### Step 1: Check or Create SPEC.md

Check if SPEC.md exists in the current directory.
- If yes: Read it and start interview
- If no: Ask user for basic idea, then generate draft

### Step 2: In-Depth Interview

**Must use AskUserQuestion tool** to ask questions in the following areas:

1. **Technical Implementation**
   - What tech stack to use
   - Integration method with existing codebase
   - Performance requirements

2. **UI & UX**
   - User flows
   - Design patterns
   - Accessibility requirements

3. **Concerns**
   - Security considerations
   - Scalability issues
   - Maintenance complexity

4. **Trade-offs**
   - Time vs quality
   - Simplicity vs functionality
   - Flexibility vs performance

### Step 3: Question Rules

- **No obvious questions**: Skip clear ones like "what language?"
- **Go deep**: 40+ questions are fine
- **Continuous interview**: Keep asking until complete
- **1-2 questions at a time**: Easy for user to answer

### Step 4: Specification Writing

After interview completion, update SPEC.md file in detail:

```markdown
# [Feature Name] Specification

## Overview
[One sentence description]

## Goals
- [ ] Goal 1
- [ ] Goal 2

## Tech Stack
- ...

## Detailed Requirements
### Functional Requirements
1. ...

### Non-Functional Requirements
1. ...

## UI/UX Specification
- ...

## API Design (if applicable)
- ...

## Data Model (if applicable)
- ...

## Security Considerations
- ...

## Test Plan
- ...

## Milestones
1. [ ] Phase 1
2. [ ] Phase 2

## Open Questions / Decisions Needed
- ...
```

### Step 5: Guidance

After completing the specification, guide the user:

> "The specification is complete. Start implementation in a new session with the following command:"
> ```
> Read SPEC.md and start implementing
> ```
>
> After implementation, verify:
> ```
> /spec-verify
> ```

## Core Principles

1. **Context separation**: Interview session != Implementation session
2. **User control**: User decides direction through questions
3. **Detailed documentation**: Sufficient detail for immediate execution in the next session
