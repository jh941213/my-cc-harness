---
name: stitch-design-md
description: "Analyzes a Stitch project to generate a DESIGN.md file -- documents the design system in semantic, natural language to support consistent UI generation. Triggers on: Stitch, design system, DESIGN.md, Stitch design analysis. NOT for: React component conversion, code implementation."
user-invocable: true
allowed-tools:
  - "stitch*:*"
  - "mcp__stitch*"
  - "Read"
  - "Write"
  - "mcp__tavily__tavily_extract"
---

# Stitch DESIGN.md Skill

You are a professional design system leader. Your goal is to analyze a Stitch project's technical assets and synthesize them into a `DESIGN.md` file as a semantic design system.

## Overview

This skill creates a `DESIGN.md` file that serves as the "source of truth" so that when Stitch generates new screens, they perfectly match the existing design language.

Stitch interprets designs through "visual descriptions" backed by specific color values.

## Prerequisites

- Stitch MCP server access
- A Stitch project with at least one designed screen
- Access to Stitch effective prompting guide: https://stitch.withgoogle.com/docs/learn/prompting/

## Discovery and Networking

To analyze a Stitch project, use Stitch MCP server tools to retrieve screen metadata and design assets:

### 1. Namespace Discovery

```bash
# Run list_tools to find the Stitch MCP prefix
# Use this prefix (e.g., mcp_stitch:) for all subsequent calls
```

### 2. Project Query (if Project ID is unknown)

```
Call [prefix]:list_projects (filter: "view=owned")
-> Identify the target project by title or URL pattern
-> Extract Project ID from the name field (e.g., projects/13534454087919359824)
```

### 3. Screen Query (if Screen ID is unknown)

```
Call [prefix]:list_screens (projectId: numeric ID only)
-> Review screen titles to identify the target screen (e.g., "Home", "Landing Page")
-> Extract Screen ID from the screen's name field
```

### 4. Retrieve Metadata

```
Call [prefix]:get_screen (projectId, screenId: both numeric IDs only)
Returned information:
- screenshot.downloadUrl: Visual reference of the design
- htmlCode.downloadUrl: Full HTML/CSS source code
- width, height, deviceType: Screen dimensions and target platform
- designTheme: Color and style information
```

### 5. Download Assets

```
Download HTML code from htmlCode.downloadUrl via web_fetch or read_url_content
Optionally download screenshot from screenshot.downloadUrl
Parse HTML to extract Tailwind classes, custom CSS, component patterns
```

## Analysis and Synthesis Guidelines

### 1. Extract Project Identity

- Find the project title
- Find the specific Project ID (from the `name` field in JSON)

### 2. Define the Mood

Evaluate screenshots and HTML structure to capture the overall "mood".
Use adjectives that describe the mood:
- "Airy"
- "Dense"
- "Minimalist"
- "Utilitarian"

### 3. Color Palette Mapping

Identify the system's core colors. For each color, provide:

| Item | Description |
|------|-------------|
| Descriptive name | Natural language name conveying personality (e.g., "Deep Muted Teal-Navy") |
| Hex code | Precise color code (e.g., "#294056") |
| Functional role | Purpose of use (e.g., "Used for primary actions") |

### 4. Geometry and Shape Translation

Convert technical `border-radius` values to physical descriptions:

| Tailwind Class | Description |
|----------------|-------------|
| `rounded-full` | Pill-shaped |
| `rounded-lg` | Subtly rounded corners |
| `rounded-xl` | Generously rounded corners |
| `rounded-none` | Sharp right-angle corners |

### 5. Depth and Elevation Description

Describe how the UI handles layers:

- "Flat"
- "Whisper-soft diffused shadows"
- "Heavy, high-contrast drop shadows"

## Output Guidelines

- **Language**: Use descriptive design terminology and natural language
- **Format**: Create a clean Markdown file following the structure below
- **Precision**: Include exact hex codes alongside descriptive names
- **Context**: Explain not just "what" but "why"

## Output Format (DESIGN.md Structure)

```markdown
# Design System: [Project Title]

**Project ID:** [project ID]

## 1. Visual Theme and Mood

(Description of mood, density, aesthetic philosophy)

## 2. Color Palette and Roles

| Name | Hex Code | Role |
|------|----------|------|
| Deep Ocean Blue | #0077B6 | Primary action buttons |
| Whisper Gray | #F5F5F5 | Background color |
| Midnight Text | #1A1A1A | Body text |

## 3. Typography Rules

(Description of font families, weight usage for headers vs body, spacing characteristics)

## 4. Component Styling

### Buttons
- Shape: Pill-shaped, generous padding
- Color: Primary - Deep Ocean Blue, lightens on hover
- Behavior: Subtle elevation effect

### Cards/Containers
- Corners: Softly rounded (8px)
- Background: Pure white
- Shadow: Whisper-soft diffused shadow

### Inputs/Forms
- Border: 1px Whisper Gray
- Background: Pure white
- Focus: Deep Ocean Blue border

## 5. Layout Principles

(Description of whitespace strategy, margins, grid alignment)

## 6. Design System Notes for Stitch Generation

**[Copy this section into your stitch-loop skill prompt]**

```
Visual style: [mood description]
Primary color: [name] (#hex) - [role]
Secondary color: [name] (#hex) - [role]
Background: [name] (#hex)
Text: [name] (#hex)
Button style: [shape, color, behavior]
Card style: [corners, shadow]
Overall feel: [2-3 sentence summary]
```
```

## Best Practices

| Principle | Description |
|-----------|-------------|
| Be descriptive | Use "Ocean-deep Cerulean (#0077B6)" instead of "blue" |
| Be functional | Always explain the purpose of each design element |
| Be consistent | Use the same terminology throughout the document |
| Be visual | Help readers visualize the design through descriptions |
| Be precise | Include exact values after natural language descriptions |

## Pitfalls to Avoid

- Do not use technical terms without translation (e.g., use "generously rounded corners" instead of "rounded-xl")
- Do not omit color codes or use only descriptive names
- Do not omit functional role descriptions of design elements
- Mood descriptions should not be too vague
- Do not ignore subtle design details like shadows and spacing patterns

## Resources

- **Stitch official docs**: https://stitch.withgoogle.com/docs/
- **Effective prompting guide**: https://stitch.withgoogle.com/docs/learn/prompting/
- **Stitch MCP server**: https://github.com/google-labs-code/stitch-skills
