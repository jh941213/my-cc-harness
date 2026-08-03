---
paths:
  - "**/*"
---

# Tool Overlap Minimization Policy

## Disabled built-in tools
- **WebSearch**: deny (blocked in settings.json)
- **WebFetch**: deny (blocked in settings.json)

## Role separation per tool

| Purpose | Use | Never use |
|---------|-----|-----------|
| General web search | Tavily MCP | WebSearch |
| Code examples/snippets | Exa MCP | WebSearch |
| Library documentation | Context7 MCP | WebFetch |
| Semantic code exploration | mgrep | — |
| Exact strings/regex | built-in Grep, Glob | — |

If mgrep/Tavily/Exa MCP servers are not installed, fall back to built-in Grep/Glob (code exploration) and WebSearch/WebFetch (web).

## Error handling

- Never ignore a tool error
- On API rate limits: stop using that tool, notify the user
- Same error 3 times in a row: switch to an alternative tool or escalate to the user

## Tool output context management

- Test results: 1-line summary on success, details only on failure
- Long logs: extract key errors only; don't put the whole log in context
- Large files: read only the needed parts with offset/limit
