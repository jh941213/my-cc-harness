---
name: systematic-debugging
description: Use on any bug, test failure, or unexpected behavior, before proposing fixes. No fixes without root-cause investigation
---

# Systematic Debugging

**Iron law: no fixes without root-cause investigation. Fixing symptoms is failure.**

The simpler the bug looks, the more urgent the situation, the more this process matters — systematic debugging is faster than guess-and-patch thrashing.

## The four phases (complete each before the next)

### Phase 1: Root cause investigation
- **Read error messages to the end** — full stack trace, line numbers, error codes. The answer is often already there
- **Reproduce consistently** — if you can't reproduce, gather more data instead of guessing
- **Check recent changes** — git diff, recent commits, dependency/config/environment differences
- **Multi-component systems: instrument first** — log what enters/exits each component boundary, run once to see WHERE it breaks, then investigate that layer
- **Trace data flow backwards** — follow the bad value up the call stack to its origin; fix at the source, never at the symptom site

### Phase 2: Pattern analysis
- Find similar working code in the same codebase and compare
- If there is a reference implementation, read it **completely** (no skimming)
- List every difference between working and broken — no "that can't matter" assumptions

### Phase 3: Hypothesis and test
- One hypothesis, stated clearly: "I think X is the cause because Y"
- Test with the **smallest possible change** — one variable at a time
- If it fails, form a new hypothesis. Never stack fixes on top of fixes
- If you don't understand something, say "I don't understand X". No pretending

### Phase 4: Implementation
- **Write the failing test case first** (minimal reproduction) before fixing
- One fix for the identified root cause — no "while I'm here" refactoring
- Verify: test passes? nothing else broken?

## The 3-failures rule
If 3+ fix attempts have failed, **question the architecture.** When every fix reveals a new problem somewhere else, the structure is wrong, not the hypothesis. Do not attempt fix #4 — discuss the architecture with the user first.

## Red flags (any of these thoughts → STOP, back to Phase 1)
- "Quick fix now, investigate later"
- "Just try changing X and see"
- "Change several things at once and run the tests"
- "Skip the test, I'll verify manually"
- "I don't fully understand it, but this might work"
- Listing solutions before tracing the data flow
