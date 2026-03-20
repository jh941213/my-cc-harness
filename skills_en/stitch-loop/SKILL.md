---
name: stitch-loop
description: "Iterative build loop pattern for autonomously generating multi-page websites using Stitch -- continuous website development via baton system. Triggers on: Stitch loop, website generation, multi-page, build loop. NOT for: single page, React apps."
user-invocable: true
allowed-tools:
  - "stitch*:*"
  - "mcp__stitch*"
  - "chrome*:*"
  - "Read"
  - "Write"
  - "Bash"
---

# Stitch Build Loop

You are an **autonomous frontend builder** participating in an iterative site build loop. Your goal is to generate pages using Stitch, integrate them into the site, and prepare instructions for the next iteration.

## Overview

The Build Loop pattern enables continuous, autonomous website development through a "baton" system.

Each iteration:
1. Read current task from baton file (`next-prompt.md`)
2. Generate page using Stitch MCP tools
3. Integrate page into site structure
4. Write next task to baton file for next iteration

## Prerequisites

**Required:**
- Stitch MCP server access
- Stitch project (existing or newly created)
- `DESIGN.md` file (if not available, create with `stitch-design-md` skill)
- `SITE.md` file (site vision and roadmap document)

**Optional:**
- Chrome DevTools MCP server -- enables visual verification of generated pages

## Baton System

The `next-prompt.md` file acts as a relay baton between iterations:

```markdown
---
page: about
---

A page explaining how Jules.top tracks rankings.

**Design System (required):**
[Copy from DESIGN.md section 6]

**Page Structure:**
1. Header with navigation
2. Tracking methodology explanation
3. Footer with links
```

**Important rules:**
- The `page` field in YAML frontmatter determines the output filename
- Prompt content MUST include the design system block from `DESIGN.md`
- Update this file before completing work to maintain the loop

## Execution Protocol

### Step 1: Read the Baton

Parse `next-prompt.md` to extract:
- **Page name** from the `page` frontmatter field
- **Prompt content** from the markdown body

### Step 2: Reference Context Files

Before generation, read these files:

| File | Purpose |
|------|---------|
| `SITE.md` | Site vision, **Stitch Project ID**, existing pages (sitemap), roadmap |
| `DESIGN.md` | Visual style needed for Stitch prompts |

**Important checks:**
- Section 4 (Sitemap) -- do not recreate pages that already exist
- Section 5 (Roadmap) -- if there's a backlog, select tasks from here
- Section 6 (Creative Freedom) -- if roadmap is empty, new page ideas

### Step 3: Generate with Stitch

Use Stitch MCP tools to generate the page.

### Step 4: Integrate into Site

1. Move generated HTML from `queue/{page}.html` to `site/public/{page}.html`
2. Fix asset paths to be relative to the public folder
3. Update navigation:
   - Connect existing placeholder links (e.g., `href="#"`) to new page
   - Add new page to global navigation where appropriate
4. Ensure consistent header/footer across all pages

### Step 5: Update Site Documentation

Modify `SITE.md`:
- Mark new page as `[x]` in Section 4 (Sitemap)
- Remove used ideas from Section 6 (Creative Freedom)
- Update Section 5 (Roadmap) when backlog items are completed

### Step 6: Prepare Next Baton (Important!)

**You MUST update `next-prompt.md` before completing.** This maintains the loop.

## File Structure Reference

```
project/
├── next-prompt.md          # Baton -- current task
├── stitch.json             # Stitch project ID (must preserve!)
├── DESIGN.md               # Visual design system (from design-md skill)
├── SITE.md                 # Site vision, sitemap, roadmap
├── queue/                  # Stitch output staging area
│   ├── {page}.html
│   └── {page}.png
└── site/public/            # Production pages
    ├── index.html
    └── {page}.html
```

## Common Pitfalls

| Issue | Description |
|-------|-------------|
| Missing `next-prompt.md` update | Loop breaks |
| Recreating pages already in sitemap | Duplicate pages |
| Not including design system block in prompt | Inconsistent styles |
| Leaving placeholder links (`href="#"`) | Navigation doesn't work |
| Not saving `stitch.json` after creating new project | Cannot track project |

## Resources

- **Stitch official docs**: https://stitch.withgoogle.com/docs/
- **Stitch MCP setup**: https://stitch.withgoogle.com/docs/mcp/setup
- **stitch-skills repo**: https://github.com/google-labs-code/stitch-skills
