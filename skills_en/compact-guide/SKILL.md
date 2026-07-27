---
name: compact-guide
description: "Context window management and token optimization guide. Triggers on: context, tokens, compact, memory management. NOT for: code writing, debugging."
disable-model-invocation: false
user-invocable: true
---

# Context Management Guide

Context is like fresh milk. **The problem is freshness, not volume** — polluted context deserves a reset.

## Core Principles (the 1M-context era)

- Don't count remaining tokens — **auto-compact manages the threshold**
- Manual intervention is **signal-based**, not number-based:

| Signal | Action |
|--------|--------|
| A work unit (milestone/story) just finished | /compact — start the next unit clean |
| The work topic changes entirely | /handoff → /clear — new session |
| Repeating the same mistakes, forgetting earlier decisions, illogical replies | Pollution signal — /handoff → /clear (compact doesn't wash pollution out) |
| Right after long exploration/log output | Consider /compact before the next task |

- Never shrink or rush work out of worry about remaining context — keep going

## Commands

### /compact
- Summarizes and compresses conversation content
- Retains important information, reduces tokens only
- Does not interrupt workflow

### /clear
- Complete reset
- Risky without HANDOFF.md!
- Use when you want a clean start

## Recommended Pattern

```
Start work
    |
Work unit completed (milestone/story)
    |
/compact (clean up at the boundary)
    |
… repeat …
    |
Topic switch or pollution signal
    |
/handoff (generate HANDOFF.md)
    |
/clear (reset)
    |
Read HANDOFF.md in new session
```

## Context Management from a Cache Perspective

### Why /compact is advantageous
- System prompt + tool definition prefix cache is preserved
- Only conversation messages are summarized, so cache hits are possible every turn
- Significantly lower cost than /clear

### Hidden cost of /clear
- Invalidates the entire prefix cache (system prompt + tools + CLAUDE.md + rules/ all recomputed)
- Additional tokens generated when loading HANDOFF.md
- Cache warmup needed from the next API call

### Decision rule
- **On cost alone**: /compact > /clear
- **When quality wobbles**: /clear is the answer — summarizing polluted context summarizes the pollution too
- For long autonomous runs (TTH/autodev), leave it to auto-compact and don't intervene
