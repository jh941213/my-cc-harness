---
name: e2e-verify
description: "Feature-based E2E test writing and execution after development. Verifies actual user flows after /verify. Triggers on: e2e verification, e2e-verify, E2E testing, browser test execution. NOT for: unit tests, type checking, build verification."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
---

# E2E Feature Verification

After development + `/verify` completion, verifies that the implemented feature works in an actual browser via E2E tests.

## Prerequisites
- `/verify` passed (typecheck, lint, test, build)
- App is runnable locally

## Workflow

### Step 1: Feature Analysis
Identify user flows for the implemented feature.
```
- What page does it start on?
- What interactions are needed? (clicks, inputs, navigation)
- What are the success conditions? (URL change, text display, state change)
- Edge cases? (empty input, error responses)
```

### Step 2: Run the App
```bash
# Check dev/start scripts in package.json
cat package.json | grep -A 5 '"scripts"'

# Run app (background)
npm run dev &
sleep 5  # Wait for app to be ready
```

### Step 3: Write E2E Tests
Create test files in the `e2e/` directory.

```bash
# Check for existing E2E setup
ls e2e/ 2>/dev/null || ls tests/e2e/ 2>/dev/null || ls __tests__/e2e/ 2>/dev/null

# Check existing E2E framework (Playwright, Cypress, agent-browser)
cat package.json | grep -E "playwright|cypress|agent-browser"
```

#### Writing Tests Per Framework

**Using agent-browser:**
```bash
#!/bin/bash
set -e
cleanup() { agent-browser close 2>/dev/null || true; }
trap cleanup EXIT

agent-browser open http://localhost:3000

# Check elements via snapshot
agent-browser snapshot -i

# Execute feature flow
agent-browser fill @email-input "test@example.com"
agent-browser click @submit-btn
agent-browser wait text "Success"

echo "PASS: Feature E2E test"
```

**Using Playwright:**
```typescript
import { test, expect } from '@playwright/test';

test('Feature: user flow', async ({ page }) => {
  await page.goto('/');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.click('[data-testid="submit"]');
  await expect(page.locator('.success')).toBeVisible();
});
```

**Using Cypress:**
```typescript
describe('Feature', () => {
  it('completes the user flow', () => {
    cy.visit('/');
    cy.get('[data-testid="email"]').type('test@example.com');
    cy.get('[data-testid="submit"]').click();
    cy.contains('Success').should('be.visible');
  });
});
```

### Step 4: Run Tests
```bash
# agent-browser
bash e2e/test_feature.sh

# Playwright
npx playwright test e2e/feature.spec.ts

# Cypress
npx cypress run --spec "cypress/e2e/feature.cy.ts"
```

### Step 5: Debug on Failure
```bash
# Capture screenshot
agent-browser screenshot ./e2e/debug.png

# Re-run in headed mode
agent-browser open http://localhost:3000 --headed

# Check console errors
agent-browser console --error
```

## Test Checklist
- [ ] Happy path (normal flow) passes
- [ ] Error cases (invalid input, network errors) handled
- [ ] Page navigation/routing works correctly
- [ ] UI state changes (loading, success, failure) display correctly
- [ ] Works in mobile viewport (if applicable)

## Verification Loop
On test failure:
1. Identify root cause via screenshots/logs
2. Fix code
3. Re-run `/verify` (prevent regressions)
4. Re-run E2E tests
5. Repeat until all pass
