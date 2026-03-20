---
name: e2e-agent-browser
description: >
  E2E test automation using agent-browser CLI. Performs stable browser tests with snapshot-based accessibility trees and the ref system.
  Triggers: "E2E", "browser testing", "agent-browser", "write e2e tests", "E2E testing", "browser automation"
  Anti-triggers: "unit tests", "API tests", "pytest", "Jest tests only", "use Playwright directly"
user-invocable: false
---

# E2E Testing with agent-browser

Comprehensive guide for writing and running E2E tests using `agent-browser`, a headless browser automation CLI for AI agents.

## When to Use This Skill

- Writing E2E tests for web applications
- Testing login/registration flows
- Testing form input and submission
- Testing navigation and routing
- Testing UI interactions (click, hover, scroll)
- Verifying visual state (element existence, text content)
- Running browser tests in CI/CD pipelines

## Installation

```bash
# Install via npm (recommended)
npm install -g agent-browser

# Download Chromium browser
agent-browser setup

# For Linux, install additional system dependencies
agent-browser setup --with-deps
```

## Core Concepts

### 1. Snapshot + Ref Workflow

The core of agent-browser is the **Accessibility Tree** and **ref system**.

```bash
# 1. Open page
agent-browser open https://example.com

# 2. Get accessibility snapshot (with refs)
agent-browser snapshot -i
# Output:
# - heading "Example Domain" [ref=e1] [level=1]
# - button "Submit" [ref=e2]
# - textbox "Email" [ref=e3]
# - link "Learn more" [ref=e4]

# 3. Use refs to interact with elements
agent-browser click @e2        # Click button
agent-browser fill @e3 "test@example.com"  # Enter text
agent-browser text @e1         # Get text
```

### 2. Snapshot Options

```bash
# Full accessibility tree
agent-browser snapshot

# Interactive elements only (buttons, inputs, links)
agent-browser snapshot -i

# Compact mode (remove empty structural elements)
agent-browser snapshot -c

# Depth limit
agent-browser snapshot -d 3

# Scope by CSS selector
agent-browser snapshot -s "#main"

# Combine options
agent-browser snapshot -i -c -d 5
```

### 3. JSON Mode (for AI agents)

```bash
# Return parseable JSON output
agent-browser snapshot --json
# {"success":true,"data":{"snapshot":"...","refs":{"e1":{"role":"heading","name":"Title"},...}}}
```

## E2E Test Patterns

### Pattern 1: Basic Page Test

```bash
#!/bin/bash
# test_homepage.sh

set -e  # Stop immediately on error

# Open page
agent-browser open https://myapp.com

# Verify page title
TITLE=$(agent-browser title)
if [[ "$TITLE" != "My App" ]]; then
  echo "FAIL: Expected title 'My App', got '$TITLE'"
  exit 1
fi

# Verify key elements exist
agent-browser snapshot -i | grep -q "button.*Login" || {
  echo "FAIL: Login button not found"
  exit 1
}

echo "PASS: Homepage test"
agent-browser close
```

### Pattern 2: Login Flow Test

```bash
#!/bin/bash
# test_login.sh

set -e

# Open login page
agent-browser open https://myapp.com/login

# Check element refs via snapshot
agent-browser snapshot -i
# - textbox "Email" [ref=e1]
# - textbox "Password" [ref=e2]
# - button "Sign In" [ref=e3]

# Enter email
agent-browser fill @e1 "test@example.com"

# Enter password
agent-browser fill @e2 "password123"

# Click login button
agent-browser click @e3

# Wait for URL change
agent-browser wait url "**/dashboard"

# Verify dashboard
URL=$(agent-browser url)
if [[ "$URL" != *"dashboard"* ]]; then
  echo "FAIL: Not redirected to dashboard"
  exit 1
fi

echo "PASS: Login flow"
agent-browser close
```

### Pattern 3: Form Input and Validation Test

```bash
#!/bin/bash
# test_form_validation.sh

set -e

agent-browser open https://myapp.com/register

# Check form elements via snapshot
agent-browser snapshot -i

# Attempt to submit empty form
agent-browser click @submit-btn

# Wait for error message
agent-browser wait text "Email is required"

# Verify error message
agent-browser snapshot -i | grep -q "Email is required" || {
  echo "FAIL: Validation error not shown"
  exit 1
}

# Enter valid email
agent-browser fill @email "valid@example.com"

# Verify email error message disappears
agent-browser snapshot -i | grep -q "Email is required" && {
  echo "FAIL: Email error should be gone"
  exit 1
}

echo "PASS: Form validation"
agent-browser close
```

### Pattern 4: Navigation Test

```bash
#!/bin/bash
# test_navigation.sh

set -e

agent-browser open https://myapp.com

# Click navigation menu
agent-browser click role:link "About"
agent-browser wait url "**/about"

# Go back
agent-browser back
agent-browser wait url "**/home"

# Go forward
agent-browser forward
agent-browser wait url "**/about"

echo "PASS: Navigation test"
agent-browser close
```

### Pattern 5: Modal/Dialog Test

```bash
#!/bin/bash
# test_modal.sh

set -e

agent-browser open https://myapp.com

# Click modal trigger button
agent-browser click @open-modal-btn

# Wait for modal to appear
agent-browser wait @modal-dialog

# Check modal content
agent-browser snapshot -s "[role=dialog]" -i

# Close modal
agent-browser click @close-modal-btn

# Verify modal is gone (using isvisible)
VISIBLE=$(agent-browser isvisible @modal-dialog 2>/dev/null || echo "false")
if [[ "$VISIBLE" == "true" ]]; then
  echo "FAIL: Modal should be closed"
  exit 1
fi

echo "PASS: Modal test"
agent-browser close
```

### Pattern 6: Drag and Drop Test

```bash
#!/bin/bash
# test_dnd.sh

set -e

agent-browser open https://myapp.com/kanban

# Execute drag and drop
agent-browser drag @task-1 @column-done

# Verify result
agent-browser snapshot -s "#column-done" | grep -q "Task 1" || {
  echo "FAIL: Task not moved"
  exit 1
}

echo "PASS: Drag and drop test"
agent-browser close
```

### Pattern 7: File Upload Test

```bash
#!/bin/bash
# test_upload.sh

set -e

agent-browser open https://myapp.com/upload

# Upload file
agent-browser upload @file-input "./test-file.pdf"

# Wait for upload completion
agent-browser wait text "Upload complete"

echo "PASS: File upload test"
agent-browser close
```

## Advanced Features

### Persistent Authentication Sessions

```bash
# Maintain login state with profile directory
agent-browser open https://myapp.com --profile ~/.browser-profile/myapp

# Configure via environment variable
export AGENT_BROWSER_PROFILE=~/.browser-profile/myapp
agent-browser open https://myapp.com
```

### Session Separation

```bash
# Parallel testing with independent sessions
AGENT_BROWSER_SESSION=test1 agent-browser open https://myapp.com &
AGENT_BROWSER_SESSION=test2 agent-browser open https://myapp.com &
wait

# List sessions
agent-browser sessions
```

### Network Interception

```bash
# Block specific requests
agent-browser block "*.png"
agent-browser block "*analytics*"

# Mock API responses
agent-browser mock "/api/users" '{"users": [{"id": 1, "name": "Test"}]}'

# Monitor network requests
agent-browser requests
```

### Screenshots and PDF

```bash
# Screenshot current view
agent-browser screenshot ./screenshot.png

# Full page screenshot
agent-browser screenshot ./full.png --full

# Save as PDF
agent-browser pdf ./page.pdf
```

### JavaScript Execution

```bash
# Execute JS code
agent-browser eval "document.title"
agent-browser eval "window.localStorage.getItem('token')"

# Complex scripts
agent-browser eval "
  const items = document.querySelectorAll('.item');
  return items.length;
"
```

## Test Runner Script

### Node.js Test Runner

```javascript
// e2e/runner.js
const { execSync } = require('child_process');

const tests = [
  'test_homepage.sh',
  'test_login.sh',
  'test_form_validation.sh',
  'test_navigation.sh',
];

let passed = 0;
let failed = 0;

for (const test of tests) {
  console.log(`Running ${test}...`);
  try {
    execSync(`bash e2e/${test}`, { stdio: 'inherit' });
    passed++;
  } catch (error) {
    failed++;
    console.error(`FAILED: ${test}`);
  }
}

console.log(`\nResults: ${passed} passed, ${failed} failed`);
process.exit(failed > 0 ? 1 : 0);
```

### npm Scripts

```json
{
  "scripts": {
    "test:e2e": "node e2e/runner.js",
    "test:e2e:headed": "AGENT_BROWSER_HEADED=1 npm run test:e2e"
  }
}
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Install agent-browser
        run: |
          npm install -g agent-browser
          agent-browser setup --with-deps

      - name: Start app
        run: |
          npm run build
          npm run start &
          sleep 5

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload screenshots on failure
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-screenshots
          path: e2e/screenshots/
```

### Cloud Browser (Browserbase)

```yaml
# .github/workflows/e2e-cloud.yml
jobs:
  e2e:
    runs-on: ubuntu-latest
    env:
      AGENT_BROWSER_PROVIDER: browserbase
      BROWSERBASE_API_KEY: ${{ secrets.BROWSERBASE_API_KEY }}
      BROWSERBASE_PROJECT_ID: ${{ secrets.BROWSERBASE_PROJECT_ID }}

    steps:
      - uses: actions/checkout@v4
      - run: npm run test:e2e
```

## Debugging

### Headed Mode

```bash
# Show browser window
agent-browser open https://myapp.com --headed
```

### Element Highlighting

```bash
# Highlight elements
agent-browser highlight @button
```

### Console Log Inspection

```bash
# View browser console logs
agent-browser console

# Error logs only
agent-browser console --error
```

### Trace Recording

```bash
# Start trace
agent-browser trace start

# Run tests
agent-browser open https://myapp.com
agent-browser click @button
# ...

# Save trace
agent-browser trace stop ./trace.zip
```

## Selector Guide

### Ref-Based (Recommended)

```bash
# Use refs obtained from snapshots
agent-browser click @e1
agent-browser fill @e2 "text"
```

### CSS Selectors

```bash
agent-browser click "#submit-btn"
agent-browser fill ".email-input" "test@example.com"
agent-browser click "div > button.primary"
```

### Semantic Locators

```bash
# Role-based
agent-browser click role:button "Submit"
agent-browser fill role:textbox "Email" "test@example.com"

# Text-based
agent-browser click text:label "Remember me"
agent-browser click text: "Sign Up"

# data-testid based
agent-browser click testid:submit-form
```

## Wait Strategies

```bash
# Wait for element
agent-browser wait @element

# Wait for text
agent-browser wait text "Success"

# Wait for URL pattern
agent-browser wait url "**/dashboard"

# Wait for time (ms)
agent-browser wait 2000

# Wait for load state
agent-browser wait load          # load event
agent-browser wait domcontentloaded
agent-browser wait networkidle   # network stabilization

# Wait for JS condition
agent-browser wait js "window.appReady === true"
```

## Best Practices

### 1. Snapshot-First Approach

```bash
# Always check current state via snapshot
agent-browser snapshot -i

# Then interact using refs
agent-browser click @e1
```

### 2. Stable Waits

```bash
# Use conditional waits instead of hardcoded sleeps
# BAD: agent-browser wait 5000
# GOOD:
agent-browser wait @loading-spinner
agent-browser wait text "Data loaded"
```

### 3. Error Handling

```bash
#!/bin/bash
cleanup() {
  agent-browser close 2>/dev/null || true
}
trap cleanup EXIT

set -e
# Test code...
```

### 4. Environment-Specific Configuration

```bash
# .env.test
AGENT_BROWSER_PROFILE=~/.browser-test
AGENT_BROWSER_HEADED=0
BASE_URL=http://localhost:3000
```

### 5. Test Isolation

```bash
# Clear cookies/storage before each test
agent-browser cookies clear
agent-browser local clear
agent-browser session clear
```

## Useful Command Summary

| Command | Description |
|---------|-------------|
| `agent-browser open <url>` | Open page |
| `agent-browser snapshot -i` | Interactive element snapshot |
| `agent-browser click @ref` | Click |
| `agent-browser fill @ref "text"` | Enter text |
| `agent-browser text @ref` | Get text |
| `agent-browser wait text "msg"` | Wait for text |
| `agent-browser wait url "**/path"` | Wait for URL |
| `agent-browser screenshot ./ss.png` | Screenshot |
| `agent-browser isvisible @ref` | Check visibility |
| `agent-browser close` | Close browser |

## Resources

- **agent-browser docs**: https://agent-browser.dev
- **GitHub**: https://github.com/vercel-labs/agent-browser
- **Playwright (used internally)**: https://playwright.dev
