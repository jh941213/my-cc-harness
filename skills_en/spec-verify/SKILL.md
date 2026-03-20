---
name: spec-verify
description: "Verifies implementation completeness against SPEC.md specification. Triggers on: spec verify, spec-verify, specification verification, implementation verification. NOT for: code review, unit tests, build verification."
user-invocable: true
disable-model-invocation: true
context: fork
allowed-tools: Read, Grep, Glob
---

# SPEC Verification

Skill for verifying completion after specification-based work.

## Triggers
- "spec verify", "spec-verify", "specification verification", "implementation verification"

## Workflow

### Step 1: Create Sub-Agent

Use the **Task tool** to create a verification agent:

```
subagent_type: "Explore"
prompt: |
  Read the SPEC.md file and verify the following:

  1. Check whether all specification requirements have been implemented
  2. Check each item:
     - [ ] Functional requirements
     - [ ] Non-functional requirements
     - [ ] UI/UX specification
     - [ ] API design (if applicable)
     - [ ] Security considerations

  3. Specifically identify any missing items
  4. Include improvement suggestions

  Write results to SPEC-REVIEW.md file.
```

### Step 2: Address Feedback

If verification results show missing items:

1. Show SPEC-REVIEW.md content to user
2. Confirm whether to fix (use AskUserQuestion)
3. If approved, implement missing items

### Step 3: Completion Report

When all items are complete:

```markdown
## Verification Complete

### Implementation Status
- [x] Functional requirements: 100%
- [x] Non-functional requirements: 100%
- [x] UI/UX: 100%
- [x] Tests: 100%

### Notes
- ...

### Suggested Next Steps
- ...
```

## Verification Checklist

```markdown
## SPEC Verification Checklist

### Feature Completeness
- [ ] All functional requirements implemented
- [ ] All edge cases handled
- [ ] Error handling is adequate

### Code Quality
- [ ] Type safety ensured
- [ ] Lint rules followed
- [ ] Test coverage sufficient

### Documentation
- [ ] Code comments adequate
- [ ] API documentation (if applicable)
- [ ] README updated

### Security
- [ ] Input validation
- [ ] Authentication/authorization verified
- [ ] Sensitive data protected
```

## Core Principles

1. **Objective verification**: Compare specification against actual implementation
2. **Specific feedback**: "X feature's Y part is missing" instead of "not done"
3. **Repeatable**: Feedback -> fix -> re-verify cycle
