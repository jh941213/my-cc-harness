---
name: compact-guide
description: "Context window management and token optimization guide. Triggers on: context, tokens, compact, memory management. NOT for: code writing, debugging."
disable-model-invocation: false
user-invocable: true
---

# Context Management Guide

Context is like fresh milk. It goes bad over time.

## Core Rules
- Reset before exceeding 80-100k tokens
- Clean up context every 3-5 tasks
- /clear after 3 /compact operations

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
Complete 3-5 tasks
    |
/compact (token compression)
    |
Complete 3-5 tasks
    |
/compact
    |
Complete 3-5 tasks
    |
/compact
    |
/handoff (generate HANDOFF.md)
    |
/clear (reset)
    |
Read HANDOFF.md in new session
```

## Warning
You can use up to 200k tokens, but quality degrades beyond 80-100k!

## Context Management from a Cache Perspective

### Why /compact Is Advantageous
- System prompt + tool definition prefix cache is preserved
- Only conversation messages are summarized, so cache hits are possible every turn
- Significantly lower cost than /clear

### Hidden Cost of /clear
- Invalidates the entire prefix cache (system prompt + tools + CLAUDE.md + rules/ all recomputed)
- Additional tokens generated when loading HANDOFF.md
- Cache warmup needed from the next API call

### Compaction Timing Guide
- 50-70k tokens: First /compact (do it early while there's room)
- 80-100k tokens: Second /compact or prepare /handoff
- If still above 80k after /compact: /handoff -> /clear -> new session
- Do not compact above 150k (risk of insufficient buffer)
