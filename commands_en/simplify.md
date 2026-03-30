# Code Simplification — AI Slop Removal + Refactoring

Reviews recently changed code and removes unnecessary complexity.
Applies Musk 5-Step "Step 2: Delete" and "Step 3: Simplify".

Input: $ARGUMENTS

## Execution Modes

### No arguments: `/simplify`
- Simplify based on recently changed files

### Specific file/directory: `/simplify src/api/`
- Simplify only the specified scope

### AI slop only: `/simplify slop`
- Focus on AI-generated patterns only (comments, over-abstraction, verbose error messages)

### Deletion analysis: `/simplify delete`
- Identify unused code/dependencies + suggest deletion

---

## Step 1: Identify Change Scope

```bash
# Check recently changed files
git diff --name-only HEAD~5..HEAD 2>/dev/null | grep -vE "node_modules|\.lock|dist/"

# If specific path is given, only files in that path
# If $ARGUMENTS contains a path, use that path's file list
```

Read changed files to understand full context before starting simplification.

## Step 2: AI Slop Pattern Detection and Removal

### 2-1. Remove Unnecessary Comments

```bash
# Detect self-evident comments like "This function does X"
grep -rn "// This function\|// This method\|// 이 함수는\|// 이 메서드는" --include="*.ts" --include="*.tsx" --include="*.py"
```

**Remove:**
```typescript
// BAD: Content obvious from reading the code
/** This function calculates the total price */
function calculateTotalPrice(items: Item[]): number { ... }

// GOOD: Delete comment -- function name is self-explanatory
function calculateTotalPrice(items: Item[]): number { ... }
```

**Keep:**
```typescript
// KEEP: Comments that explain "why"
// Stripe API accepts amounts in cents, so multiply by 100
const amountInCents = price * 100;
```

### 2-2. Inline Over-Abstractions

```typescript
// BAD: Single-use helper
function formatUserName(user: User) { return `${user.first} ${user.last}`; }
const name = formatUserName(user);

// GOOD: Inline
const name = `${user.first} ${user.last}`;
```

**Criteria:** If a function is called from only 1 place and is 5 lines or fewer, it's an inline candidate.

### 2-3. Simplify Verbose Error Messages

```typescript
// BAD: AI-generated overly friendly error
throw new Error(
  `An unexpected error occurred while attempting to process the user registration request. ` +
  `The system was unable to complete the operation. Please check the input data and try again. ` +
  `If the problem persists, contact support.`
);

// GOOD: Essential only
throw new Error(`Registration failed: ${err.message}`);
```

### 2-4. Remove Defensive Over-coding

```typescript
// BAD: Unnecessary null checks in internal function
function processItems(items: Item[]) {
  if (!items) return [];           // Type is Item[], null impossible
  if (!Array.isArray(items)) return [];  // Type system guarantees this
  if (items.length === 0) return [];     // Empty array is valid input
  return items.map(transform);
}

// GOOD: Trust the type system
function processItems(items: Item[]) {
  return items.map(transform);
}
```

### 2-5. Remove Redundant Type Annotations

```typescript
// BAD: Inferable types explicitly stated
const name: string = "hello";
const count: number = items.length;
const isValid: boolean = name.length > 0;

// GOOD: Let type inference handle it
const name = "hello";
const count = items.length;
const isValid = name.length > 0;
```

## Step 3: Structural Simplification

### 3-1. Flatten Conditionals

```typescript
// BAD: Deep nesting
if (user) {
  if (user.isActive) {
    if (user.hasPermission) {
      doThing();
    }
  }
}

// GOOD: Early return
if (!user?.isActive || !user.hasPermission) return;
doThing();
```

### 3-2. Deduplicate (3+ occurrences only)

```typescript
// 2 repetitions: Leave as-is (prevent premature abstraction)
// 3+ repetitions: Consider extraction
const namesByType = (type: string) => data.filter(d => d.type === type).map(d => d.name);
```

### 3-3. Delete Unused Code

```bash
# Detect unused exports
grep -rn "^export " --include="*.ts" --include="*.tsx" | while read line; do
  SYMBOL=$(echo "$line" | grep -oP 'export (const|function|class|type|interface) \K\w+')
  [ -n "$SYMBOL" ] && {
    COUNT=$(grep -rn "$SYMBOL" --include="*.ts" --include="*.tsx" | wc -l)
    [ "$COUNT" -le 1 ] && echo "UNUSED: $line"
  }
done

# Unused imports
npx eslint . --rule '{"no-unused-vars": "error", "@typescript-eslint/no-unused-vars": "error"}' --no-eslintrc 2>/dev/null
```

### 3-4. Delete Unused Dependencies

```bash
# Detect unused deps with depcheck
npx depcheck 2>/dev/null || {
  # Manual check if depcheck unavailable
  cat package.json | python3 -c "
import sys,json
deps = json.load(sys.stdin).get('dependencies',{})
for dep in deps:
    print(dep)
  " | while read dep; do
    grep -rq "$dep" --include="*.ts" --include="*.tsx" --include="*.js" src/ || echo "UNUSED DEP: $dep"
  done
}
```

## Step 4: Verification (Required)

**Must verify after simplification. Behavior must not change.**

```bash
# Confirm type safety
npx tsc --noEmit 2>&1 || pytest --tb=short 2>&1

# Confirm tests pass
npx vitest run 2>&1 || npx jest --passWithNoTests 2>&1 || pytest -q 2>&1
```

On verification failure:
1. Simplification changed behavior -> revert
2. Existing code had a bug -> fix and proceed
3. Cannot determine -> ask user

## Step 5: Results Report

```
## Simplify Results

### AI Slop Removal
- Removed 12 unnecessary comments
- Inlined 3 over-abstractions
- Simplified 2 verbose error messages

### Structural Simplification
- Flattened 3-level nesting to 1-level: 2 cases
- Deleted unused exports: 4
- Cleaned unused imports: 8

### Deletion Suggestions (Requires User Judgment)
- `src/utils/legacy.ts` -- Not imported anywhere
- `lodash` -- Only 1 usage (replaceable with native)

### Verification
- typecheck: PASS
- test: 42 passed, 0 failed
- No behavior changes confirmed
```

## Checklist

- [ ] Functions under 50 lines
- [ ] Files under 800 lines
- [ ] Nesting 4 levels or less
- [ ] Magic numbers -> constants
- [ ] console.log / print removed
- [ ] Unused imports removed
- [ ] any type / type: ignore removed
- [ ] AI-generated self-evident comments removed
- [ ] Single-use helpers inlined

## Parallel Execution Support

`/simplify` can run **in parallel** with `/e2e-verify` after `/verify` passes:

```
/verify -> (after pass) -> /simplify + /e2e-verify in parallel
```

**Note:** Since `/simplify` modifies source code, running `/verify` once more after completion is safe.

```
/verify -> /simplify + /e2e-verify -> /verify (final check)
```

## Principles

- **No behavior changes** -- refactoring only
- **3 similar lines > premature abstraction** -- 2 repetitions are allowed
- **Deletion is suggested, execution after confirmation** -- unused code deletion requires user approval
- **Avoid over-optimization** -- readability > performance (unless it's a bottleneck)
- **Comments explain "why" only** -- "what" is explained by the code
