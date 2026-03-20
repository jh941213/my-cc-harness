---
name: stitch-enhance-prompt
description: "Transforms vague UI ideas into detailed prompts optimized for Stitch -- enhances specificity, adds UI/UX keywords, injects design system context. Triggers on: prompt enhancement, Stitch prompt, UI idea, prompt improvement. NOT for: direct coding, React implementation."
user-invocable: true
allowed-tools:
  - "Read"
  - "Write"
  - "mcp__tavily__tavily_extract"
---

# Stitch Prompt Enhancer

Transforms vague UI ideas into detailed, structured prompts optimized for Stitch.

## Overview

Stitch produces better results from detailed, specific prompts. This skill:

1. **Enhances specificity**: Converts vague descriptions into detailed specifications
2. **Adds UI/UX keywords**: Injects design terminology that Stitch understands
3. **Design system context**: Integrates style information from `DESIGN.md`
4. **Structured output**: Structures prompts for optimal generation results

## Stitch Prompting Principles

### 3 Elements of an Effective Prompt

| Element | Description | Example |
|---------|-------------|---------|
| **Content** | What to show | "User profile card" |
| **Style** | How it looks | "Minimal, rounded corners, soft shadows" |
| **Layout** | How it's arranged | "Center-aligned, 3-column grid" |

### Prompt Quality Spectrum

```
Bad prompt: "login page"

Okay prompt: "Login page with email and password fields"

Good prompt: "
Minimal login page:
- Center-aligned card-style login form
- Logo and welcome message at top
- Email input field (with icon)
- Password input field (show/hide toggle)
- Blue primary button 'Login'
- 'Forgot password' link
- 'Create account' secondary button
- Soft gradient background
"
```

## Enhancement Process

### Step 1: Input Analysis

Analyze the user's original idea:

```
Input: "Make a dashboard"

Analysis:
- Type: Dashboard (admin/analytics UI)
- Missing information:
  - What data?
  - What style?
  - Key features?
```

### Step 2: Context Gathering

Collect relevant information:

1. **Check DESIGN.md** (if available)
   - Color palette
   - Typography rules
   - Component styles

2. **Domain inference**
   - Identify domain from user mentions
   - Apply common patterns

### Step 3: Prompt Expansion

#### Expansion Checklist

- [ ] **Page purpose**: What is the main goal of this page?
- [ ] **User type**: Who uses this page?
- [ ] **Key elements**: What elements must be included?
- [ ] **Layout structure**: What sections is it composed of?
- [ ] **Interactions**: What are the main actions?
- [ ] **Visual style**: What mood does it convey?

### Step 4: Generate Structured Output

## Enhancement Template

### Basic Template

```markdown
## [Page Type]: [Page Name]

### Overview
[1-2 sentence description of purpose and main function]

### Visual Style
- **Mood**: [adjectives - e.g., modern, minimal, professional]
- **Colors**: [main color description or DESIGN.md reference]
- **Typography**: [font style description]

### Layout Structure
1. **Header**: [header components]
2. **Main Section**: [main content area]
3. **Sidebar** (optional): [auxiliary information]
4. **Footer**: [footer components]

### Key Elements
- [Element 1]: [description]
- [Element 2]: [description]
- [Element 3]: [description]

### Interactions
- [Action 1]: [behavior description]
- [Action 2]: [behavior description]

### Design System
[Copy DESIGN.md section 6 or style guide]
```

## UI/UX Keyword Dictionary

Keywords that improve prompts:

### Layout Keywords
| Keyword | Use |
|---------|-----|
| centered | Center alignment |
| grid layout | Grid layout |
| split view | Split view |
| sidebar | Sidebar |
| sticky header | Fixed header |
| card layout | Card layout |
| masonry | Masonry layout |

### Style Keywords
| Keyword | Use |
|---------|-----|
| minimal | Minimal |
| modern | Modern |
| clean | Clean |
| rounded corners | Rounded corners |
| soft shadows | Soft shadows |
| subtle gradient | Subtle gradient |
| glassmorphism | Glass effect |
| frosted glass | Frosted glass effect |

### Component Keywords
| Keyword | Use |
|---------|-----|
| pill button | Pill-shaped button |
| avatar | Profile image |
| badge | Badge/tag |
| tooltip | Tooltip |
| dropdown | Dropdown |
| modal | Modal |
| toast | Toast notification |
| skeleton | Loading skeleton |

### State Keywords
| Keyword | Use |
|---------|-----|
| hover effect | Hover effect |
| active state | Active state |
| disabled | Disabled |
| loading | Loading |
| empty state | Empty state |
| error state | Error state |

## Things to Avoid

| Avoid | Do This Instead |
|-------|-----------------|
| "Pretty page" | "Minimal and modern, with ample whitespace" |
| "Good colors" | "#2563EB blue primary button, #10B981 success indicator" |
| "Big button" | "Height 48px, padding 24px, rounded corners" |
| "Logo somewhere" | "Logo in upper-left corner, height 32px" |
| "Some cards" | "3-column grid, each card with icon, title, description" |

## Reference Resources

- **Stitch prompting guide**: https://stitch.withgoogle.com/docs/learn/prompting/
- **Stitch gallery** (for inspiration): https://stitch.withgoogle.com/gallery
- **UI pattern reference**: https://ui-patterns.com/
