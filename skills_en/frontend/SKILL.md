---
name: frontend
description: |
  Big-tech style (Stripe, Vercel, Apple) UI development. From planning to implementation in one go.
  Triggers: "frontend", "create UI", "create page", "create component", "landing page", "dashboard UI"
  Anti-triggers: "backend API", "database", "CLI tools"
user-invocable: true
disable-model-invocation: false
context: fork
agent: frontend-developer
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Frontend UI Development

Builds big-tech style (Stripe, Vercel, Apple) frontend UI from **planning to implementation** in one go.

## Workflow

```
/frontend [requirements]
    |
1. Write design specification (planning)
    |
2. User confirmation
    |
3. Implement with frontend-developer agent
    |
4. Verify results
```

## Phase 1: Planning

### Design Style Selection
| Style | Characteristics | Suitable For |
|-------|----------------|--------------|
| **Stripe** | Gradients, bright tones, subtle animations | Payments, SaaS, landing |
| **Vercel** | Dark mode, minimal, monotone | Developer tools |
| **Apple** | Wide margins, typography emphasis | Product showcase |
| **Linear** | Dark, purple accents | Productivity apps |
| **Notion** | Bright tones, icon usage | Docs/collaboration |

### Specification Template
```markdown
## [Project Name] Design Spec

### Style: [Selected Style]

### Colors
- Primary: #[hex]
- Background: #[hex]
- Text: #[hex]
- Border: #[hex]
- Accent: #[hex]

### Typography
- Display: [font] / [size]
- Body: [font] / [size]

### Components
1. [Component1]: [description]
2. [Component2]: [description]

### Layout
- Max width: [px]
- Main structure: [description]
```

## Phase 2: Implementation

Calls the `frontend-developer` agent for implementation.

### Implementation Order
1. CSS variables (globals.css)
2. Utilities (lib/utils.ts)
3. UI components (components/ui/)
4. Layout (components/layout/)
5. Feature components
6. Page assembly
7. Animations

### Required Dependencies
```bash
npm install tailwindcss @tailwindcss/typography
npm install clsx tailwind-merge
npm install framer-motion
npm install lucide-react
npx shadcn@latest init
```

## Phase 3: Verification

After implementation:
- [ ] No TypeScript errors
- [ ] Build succeeds
- [ ] Responsive verified
- [ ] Accessibility verified

## Usage Examples

```
/frontend Create a login page. Vercel style, with email/password input form and social login buttons.
```

```
/frontend Create a dashboard. Stripe style, with sidebar + main content area + chart cards.
```
