Analyzes code changes in the current project and auto-generates documentation in the /docs/ folder.

Input: $ARGUMENTS

## Execution Mode

### Called without arguments: `/docs`
- Generates/updates documentation based on recently changed files via git diff

### Called with arguments: `/docs api`, `/docs components`
- Generates/updates only the specified type of documentation

### Full generation: `/docs all`
- Analyzes the entire project codebase and generates all /docs/ at once

## Execution Process

### Step 1: Identify Changes

```bash
git diff --name-only HEAD~5..HEAD 2>/dev/null
git diff --name-only
git diff --name-only --cached
```

If the argument is `all`, all source files are targeted.

### Step 2: Run docs-writer Agent

Runs a docs-writer agent (subagent_type: docs-writer) to generate documentation.

If there are many changed files, sub-agents are executed **in parallel** by type:

**10 or fewer files**: Handled by a single docs-writer agent
**More than 10 files**: Parallel execution by type
- Agent A: API docs (routes, endpoints)
- Agent B: Component/hook docs (components, hooks)
- Agent C: Utility/service/model docs (utils, services, models)

### Step 3: Review Results

Displays the list of generated documents and updates the docs/README.md index.

## Parallel Execution Guide with Implementation Agents

Pattern for running docs-writer in the background alongside planner or implementation agents:

```
# Call like this during the Implementation Phase
Agent(subagent_type: "docs-writer", run_in_background: true, prompt: "...")
```

This way, documentation is completed around the same time as the implementation.

## Important Rules

- Only modify the /docs/ folder (never modify source code)
- If existing documentation exists, update rather than overwrite (prefer Edit)
- Descriptions in English, code/variable names kept as-is
- Omit what is obvious from reading the code -- document "why" and "when"
- Do not create documentation files for empty types
