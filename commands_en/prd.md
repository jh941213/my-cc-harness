# PRD Generation — Idea to Product Deliverables

Analyzes the user's idea and generates PRD + SPEC in one go.
Creates complete planning deliverables that can be directly used with `/tth`.

Input: $ARGUMENTS

## Deliverable Structure

```
prd/
├── CPS.md          ← Context-Problem-Solution alignment
├── PRD.md          ← Core strategy (one-liner + insights + strategy + MVP)
├── MARKET.md       ← Competitors + open source + market landscape
├── USERS.md        ← Personas + needs + "says vs does"
├── FEATURES.md     ← Feature user stories + acceptance criteria + MoSCoW
├── RISKS.md        ← Risks + mitigation + success metrics + pivot criteria
├── SPEC.md         ← Technical spec (stack + API + DB + architecture)
└── APPENDIX.md     ← Convergence board + research sources + interview summary + glossary
```

---

## Phase 0: Input Reception + Complexity Gate

**First check**: If `prd/` directory exists → "Would you like to continue from the previous session?"
If it does not exist, start fresh.

Upon receiving user input, **determine complexity** and initialize the convergence board:

```
Low  (simple feature/tool/CLI): Skip Phase 1, reduce Phase 2 to 2 rounds, simplify SPEC
Mid  (new module/service/library): Reduce Phase 1 (1 sub-agent), Phase 2 to 3 rounds
High (new product/SaaS/platform): Execute full flow
```

After determining complexity, notify the user. Accept adjustment requests.

**Convergence board initialization**:
```
| Dimension | Status | Remaining |
|-----------|--------|-----------|
| CPS alignment | 🔴 | - |
| Terminology alignment | 🔴 | - |
| Structure (W6H) | 🔴 | 7 unconfirmed |
| Depth (assumption validation) | 🔴 | - |
| Consistency (contradictions) | 🔴 | - |
| Robustness (counterarguments) | 🔴 | - |
| Market context | 🔴 | - |
```

---

## Phase 0.5: CPS (Context-Problem-Solution) Documentation

Before starting interviews, quickly organize the CPS frame from user input.
CPS is higher level than PRD — serves as the project's "worldview alignment".

**Confirm with AskUserQuestion:**

1. **Context**: "What situation/environment makes this project necessary?"
2. **Problem**: "What specific problem are you experiencing? Any quantitative metrics?"
3. **Solution**: "What state should be achieved when this project succeeds?"

After CPS is confirmed, save immediately to `prd/CPS.md`.

Convergence board update: `CPS alignment → 🟢 Confirmed`

---

## Phase 1 + Phase 2 Round 1: Parallel Start

**Execute simultaneously** (Round 1 does not require research results):

### [Parallel A] Market Research Sub-agent (background: true)

Adapts by complexity:
- **High**: 3 sub-agents in parallel
- **Mid**: 1 sub-agent
- **Low**: Skip

**Sub-agent A: Competitors & Similar Products** (subagent_type: general-purpose)
- Search for 5-10 similar products/services using Tavily + Gemini CLI (cross-validation)
- Key focus: **Identify what all competitors commonly miss**

**Sub-agent B: Open Source & Tech Ecosystem** (subagent_type: general-purpose)
- Search GitHub for similar projects via Exa + supplement with tech trends via Gemini CLI
- Key focus: **Open source limitations = our opportunity**

**Sub-agent C: User Pain Points & Market Trends** (subagent_type: general-purpose)
- Search Reddit, HN, community complaints/needs via Tavily + Gemini CLI
- Key focus: **Extract recurring complaint patterns** and **unresolved needs**

### [Parallel B] Round 1: Terminology Alignment + Structure Scan (Main Session)

Start immediately without research results:
- **[Terminology]** Detect ambiguous terms → force definitions
- **[Structure:W6H]** Ask via AskUserQuestion about the empty dimensions among the 7
- **Convergence condition**: Core terms locked + W6H 7/7

---

## Phase 2: Adaptive Interview (From Round 2, Main Session)

Continue after research results merge. Hard cap: Low 2 rounds, Mid 3 rounds, High 5 rounds.

| Round | Framework | Purpose | Convergence Condition |
|-------|-----------|---------|----------------------|
| 2 | Methodical Doubt + White/Red Hat | Assumption validation + depth | Core dimensions 🟢, 🟡 ≤ 2 |
| 3 | Contradiction Detection + Black/Green Hat | Contradictions + blind spots | 0 critical contradictions |
| 4 | Counterargument Hardening + Yellow/Blue Hat | Counterarg-response pairs | Pairs recorded |
| 5 | Meta Summary (High only) | Truth of priorities | Entire board 🟢 |

Low → End after Round 2, Mid → End after Round 3.

### Interview Operating Rules

- **Question tags**: `[Structure:Who]`, `[Doubt:Assumption]`, `[Contradiction]`, `[Counterargument]`, `[Coherence]`, `[Blind Spot]`
- **Layer merging**: Process multiple layers simultaneously in one question set
- **Graceful Exit**: "Continue/Wrap up" option after each round
  - Mid-session exit → Save current results to `prd/` directory
- **"I don't know"**: 1 time → Present options, 3 times → Suggest research/prototype, "Later" → TODO
- **Regression cap**: Same dimension 2 times, total 3 times → If exceeded, tag as TODO
- Convergence board: Update only changed dimensions at the start of each round

---

## Phase 3: Technical Interview (for SPEC)

After PRD interview completion, proceed with **technical detail interview** in the same session.

**Announce to user**: "Product planning is organized. Now I'll confirm a few technical implementation details."

Technical interview areas:

1. **Tech stack** — Already decided vs needs selection
2. **Architecture** — Monolith/microservice, API style (REST/GraphQL)
3. **Data model** — Core entities, relationships, constraints
4. **Auth/Security** — Auth method, permission model
5. **Infra/Deploy** — Hosting, CI/CD, environment separation
6. **Tradeoffs** — Time vs quality, simplicity vs extensibility

**Question rules:**
- Don't ask about what's already clear from CPS and FEATURES.md
- Skip the obvious ("Should we use TypeScript?" → already decidable)
- 1-2 questions at a time
- Low complexity → 3-5 questions reduced
- High complexity → In-depth interview (10-15 questions)

---

## Phase 4-6: Delegate to prd-planner Sub-agent

After all interviews complete, **spawn a prd-planner sub-agent** for document generation:

```
Agent call:
  subagent_type: prd-planner
  prompt: |
    Please generate documents in the prd/ directory based on the data below.

    ## Complexity: [Low/Mid/High]

    ## CPS
    [CPS content]

    ## Research Results
    [Sub-agent A/B/C result summary]

    ## PRD Interview Results
    [Q&A summary by round]

    ## Technical Interview Results
    [Technical Q&A summary]

    ## Current Convergence Board State
    [Convergence board table]

    Generate 8 files in the prd/ directory:
    CPS.md, PRD.md, MARKET.md, USERS.md, FEATURES.md, RISKS.md, SPEC.md, APPENDIX.md
```

Tasks performed by prd-planner:
- Phase 4: Six Hats cross-analysis → PRD.md + MARKET.md
- Phase 5: Strategic scoping → FEATURES.md + RISKS.md + USERS.md
- Phase 6: Technical specification → SPEC.md
- Appendix → APPENDIX.md

---

## Phase 7: Self-Verification (Main Session)

Read the files generated by prd-planner and perform final verification:

- Are CPS (Context-Problem-Solution) and PRD coherent?
- Does every feature have a supporting insight?
- Are the top 3 risky assumptions stated?
- Are anti-features defined?
- Are metrics substantive (not vanity metrics)?
- Does SPEC have tech stack + API + data model?
- Is every feature in FEATURES technically backed in SPEC?
- Is the entire convergence board 🟢 or TODO?

On verification failure → Request corrections from prd-planner (resume).

On completion:
```
✅ prd/ directory generation complete (8 files)

📄 CPS.md      — Worldview alignment
📄 PRD.md      — Core strategy + insights
📄 MARKET.md   — Market analysis
📄 USERS.md    — User understanding
📄 FEATURES.md — Feature specification
📄 RISKS.md    — Risks + success metrics
📄 SPEC.md     — Technical specification
📄 APPENDIX.md — Appendix

👉 Next step: /tth read prd/ and implement
```

## Important Rules

- No interview entry without Phase 0.5 CPS confirmation
- Phase 1 research + Phase 2 Round 1 **must start in parallel**
- Phase 3 technical interview proceeds **in the same session** right after PRD interview
- Phase 4-6 are **delegated to the prd-planner sub-agent** (protect main context)
- Use only AskUserQuestion for questions
- **Never assume** — if ambiguous, ask
- Use research results as leverage for questions
- Confront contradictions head-on when found
- Deliverables saved in **prd/ directory** (no single file)
- Search: Web → Tavily MCP / Gemini CLI, Code → Exa MCP, Docs → Context7 MCP
- Graceful Exit: Exit at any time, save current results to prd/
