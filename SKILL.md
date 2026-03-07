---
name: docs-site-gen
description: Generates and maintains documentation website pages for any project. Analyzes project structure, architecture, and features to produce high-quality, bilingual documentation pages integrated into the existing web app. Use when creating, updating, or expanding project documentation sites, or when the user mentions "docs page", "docs site", "/docs route", or "project introduction page". Supports Next.js App Router with i18n. Offers 8 curated doc styles and auto-detects project design systems.
license: Apache-2.0
compatibility: Requires a web frontend project (Next.js recommended). Node.js and pnpm/npm for validation.
metadata:
  author: Octo-o-o-o
  version: "2.0.0"
---

# docs-site-gen — Documentation Site Generator

## Overview

This skill generates production-quality documentation website pages by deeply analyzing a project's codebase, architecture, and features. It produces Next.js page components (or adapts to the project's framework) with full bilingual i18n support, following the project's existing design system and code conventions.

**Key capabilities**:
- Auto-detects the project's UI and design specifications
- Deep content mining: reads actual source code (routers, models, services) to build verified feature inventories — not just paraphrasing README
- Content outline with user review: the user approves the exact feature selection, depth, and narrative before any code is generated
- Offers 8 curated style presets inspired by industry-leading documentation sites
- AI-friendly by default: SSR-rendered content, section anchors, llms.txt generation

## When to Use This Skill

Trigger this skill when:
- User asks to "generate docs", "create documentation site/pages", "build a docs page"
- User wants to add/expand/update documentation pages in their web app
- User mentions "/docs" route, "docs site", or "project introduction page"
- User says "update docs to reflect recent changes"

Do NOT trigger when:
- User wants to write README.md or markdown docs (not web pages)
- User asks about API documentation generation (e.g., Swagger/OpenAPI — suggest FastAPI's built-in `/docs` instead)
- User ONLY wants to generate `llms.txt` without docs pages (but when generating docs, llms.txt IS auto-generated as part of Phase 4)

## Execution Workflow

Follow these 5 phases strictly in order. Do NOT skip phases.

```
Phase 1: Design System Detection → Phase 2: Project & Content Discovery → Phase 3: Style, Audience & Planning → Phase 4: Page Generation → Phase 5: Validation
      ↓ CP1                              ↓ (report)                         ↓ CP2 (outline review)                                       ↓ CP3
```

---

### Phase 1: Design System Detection

**This phase runs FIRST — before any content analysis.** Its output determines how all subsequent phases handle visual design.

#### Step 1.1: Search for Explicit UI/Design Specifications

Search the project for dedicated design system files:

```
Glob patterns to check:
- **/design-tokens.json, **/design-tokens.ts
- **/style-guide.md, **/design-system.md
- **/theme.ts, **/theme.js, **/theme.config.*
- **/tokens.css, **/variables.css
- **/.figma-export/*, **/figma-tokens.*
- **/tailwind.config.*
- **/globals.css, **/global.css, **/app.css
```

Also check CLAUDE.md and README.md for design/UI section references.

#### Step 1.2: Analyze Existing Frontend Implementation

If no explicit design spec is found, analyze the actual frontend code to derive conventions:

1. **Read `globals.css`** (or equivalent CSS entry point):
   - Extract all CSS custom properties (`--variable-name`)
   - Note color values, spacing tokens, border-radius values
   - Identify light/dark mode setup (media queries, data attributes, class toggles)

2. **Read 2-3 representative pages** (homepage, any existing docs page, a feature page):
   - What CSS variables are actually used in `style={{}}`?
   - What Tailwind classes are used? Any custom utility classes?
   - What component patterns appear (cards, buttons, nav)?
   - What icon approach is used (inline SVG, icon library, sprite)?

3. **Read the root layout** (`layout.tsx` / `_app.tsx`):
   - Fonts loaded (custom fonts, Google Fonts, system stack)
   - Metadata and provider setup
   - Global wrappers (theme provider, i18n provider)

4. **Read Tailwind config** (if exists):
   - Custom colors, spacing, breakpoints
   - Plugin usage
   - Theme extensions

#### Step 1.3: Classify Design System Maturity

Based on Steps 1.1-1.2, classify the project into one of three levels:

| Level | Criteria | What to do |
|-------|----------|------------|
| **A: Full Design System** | Has design tokens file, or 10+ CSS variables with clear naming, or documented style guide | Use project's design system directly. Style preset only influences content structure. |
| **B: Implicit Conventions** | Has `globals.css` with some variables, consistent patterns in existing pages, but no formal spec | Extract conventions from code. Use them as primary, fill gaps with style preset. |
| **C: No Design System** | Minimal or no CSS variables, no consistent patterns, greenfield | Apply style preset fully as the design foundation. |

#### Step 1.4: Produce Design System Summary

Output a summary for the user:

```
## Design System Detection Results

**Level**: [A/B/C] — [Full Design System / Implicit Conventions / No Design System]

**Detected tokens**:
- Colors: --bg (#fff), --text-1 (#1a1a1a), --accent (#6366f1), ...
- Spacing: --r-md (8px), --r-lg (12px), ...
- Fonts: Outfit (sans), IBM Plex Mono (mono)

**Detected components**: CodeBlock, FaqItem, StepCard (from /docs/self-host)
**Detected layout classes**: landing-card-shell, landing-btn-primary
**Dark mode**: Yes, via CSS variables with data-theme attribute
**i18n**: useTranslation() from @/i18n, separate zh-CN/en-US files

[If Level B or C]: → Recommend style preset selection in Phase 3
```

**CHECKPOINT CP1**: Present this summary to the user and wait for acknowledgment before proceeding.

---

### Phase 2: Project & Content Discovery

**This phase is the content backbone of the entire skill.** Phase 1 determines HOW the docs look; Phase 2 determines WHAT the docs say. Treat content discovery with the same rigor as design system detection — every feature claim must be traceable to actual code.

Phase 2 has two sub-phases: **2A** (Project Context) and **2B** (Deep Content Mining).

#### Phase 2A: Project Context

Gather structural information about the project:

1. **Read project root files**:
   - `CLAUDE.md` or `README.md` for project overview, value proposition, and architecture
   - `package.json` / `pyproject.toml` for tech stack signals
   - Existing documentation in `docs/` directory

2. **Identify web framework and conventions**:
   - Locate the web app entry point (e.g., `apps/web/`, `src/`, `frontend/`)
   - Determine routing system (Next.js App Router, Pages Router, Vite, etc.)
   - Find existing docs pages (e.g., `app/docs/*/page.tsx`)

3. **Analyze i18n setup**:
   - Locate i18n files (e.g., `src/i18n/en-US.json`, `zh-CN.json`)
   - Detect translation function import path (e.g., `from "@/i18n"` vs `from "react-i18next"`)
   - Note existing key structure and naming conventions
   - Verify: separate files per language, or single file with nested locales?
   - **Classify i18n level**:

   | Level | Criteria | Phase 4 Behavior |
   |-------|----------|-----------------|
   | **i18n-Multi** | 2+ language files with translation function | Generate keys in ALL detected language files simultaneously |
   | **i18n-Single** | 1 language file or single-locale setup | Generate keys in that file only; skip bilingual checks |
   | **i18n-None** | No i18n files, no translation function, inline text throughout | Use inline text directly in components; skip all i18n key generation. Offer to set up i18n as a separate step (ask user, don't force). |

4. **Check homepage navigation**:
   - Find docs links in navigation (file path, line number, current URL)
   - Note footer docs links
   - Identify where to add/update navigation entries

5. **Assess docs scope**:
   - Does the project already have docs pages? Which ones?
   - First-time docs generation or incremental update?
   - **Route conflict check**: If the planned docs route (e.g., `/docs`) already exists, read the existing page. If it serves a non-documentation purpose (API docs UI, document management feature, etc.), propose an alternative route (`/documentation`, `/guide`, `/learn`) or ask the user to choose.

#### Phase 2B: Deep Content Mining

**CRITICAL**: This is where documentation content quality is determined. Do NOT skip or abbreviate these steps. The goal is to build a **verified feature inventory** — not by summarizing CLAUDE.md, but by reading actual source code.

##### Step 2B.1: Feature Inventory Scan

Use the **Agent tool** (subagent_type: `Explore`) to perform a thorough codebase scan. Choose the scan profile that matches the project type:

**Profile A: Full-Stack / Backend-Heavy Projects** (has API routers, models, services):

Give the agent this prompt template (adapt paths to the project):

```
Scan this project's codebase and build a Feature Inventory Table. For each feature area, extract:

1. Backend routers/controllers (e.g., routers/*.py, routes/*.ts, controllers/*.ts):
   - Route prefix, all endpoints (HTTP method + path), docstrings
   - Count total endpoints per router
   - Key operations: CRUD, streaming (SSE/WebSocket), batch, webhooks

2. Data models/schemas (e.g., models/*.py, prisma/schema.prisma, entities/*.ts):
   - Table/collection name, key fields, relationships
   - API schemas: field names, types, validation rules

3. Service files (e.g., services/*.py, services/*.ts):
   - Business logic functions and purposes
   - External integrations (email, push, third-party APIs)
   - Background tasks, scheduled jobs

4. Frontend navigation and pages:
   - Menu items in shell/sidebar layout → user-visible feature areas
   - Page components and routes → the UX surface

Return results as a markdown table with columns:
| # | Feature Area | Backend Source | Endpoints | Key Operations | Data Models | Frontend Pages |
```

**Profile B: Frontend-Only Projects** (component libraries, static sites, frontend apps with no backend):

Give the agent this prompt template:

```
Scan this frontend project and build a Feature Inventory Table. For each feature area, extract:

1. Pages/routes (e.g., app/*/page.tsx, pages/*.tsx, src/routes/*):
   - Route path, page purpose, key components used

2. Components (e.g., components/*.tsx, src/components/**):
   - Component name, props interface, purpose
   - Complexity: simple (<50 lines) / medium (50-150) / complex (150+)

3. Hooks and utilities (e.g., hooks/*.ts, utils/*.ts, lib/*.ts):
   - Hook/utility name, what it does, which components use it

4. Configuration and build (e.g., next.config.*, vite.config.*, tailwind.config.*):
   - Key configuration choices, plugins, custom setup

Return results as a markdown table with columns:
| # | Feature Area | Source Files | Components | Key Functionality | Complexity | Pages Using It |
```

Compile results into a **Feature Inventory Table**:

```
| # | Feature Area | Backend Source | Endpoints | Key Operations | Data Models | Frontend Pages |
|---|---|---|---|---|---|---|
| 1 | Agent Registry | routers/agents.py | 12 | CRUD + WS + health | Agent, AgentConfig | /agents, /agents/[id] |
| 2 | Approvals | routers/approvals.py | 8 | Create + Review | ApprovalRequest, Rule | /approvals |
| 3 | Audit Trail | routers/audit.py | 5 | Search + Export | AuditEvent | /audit |
| ... | ... | ... | ... | ... | ... | ... |
```

##### Step 2B.2: Feature Depth Classification

Classify each feature from the inventory into documentation depth tiers:

| Tier | Criteria | Docs Treatment |
|------|----------|---------------|
| **Tier 1: Hero Feature** | 8+ endpoints, complex data model, or core differentiator | Full section: 150-250 words, diagram or code example, explain the mechanism |
| **Tier 2: Core Feature** | 4-7 endpoints, clear user value | Feature card: 50-100 words, explain what + why, link to detail |
| **Tier 3: Supporting** | 1-3 endpoints, utility/config nature | Feature card: 20-40 words, brief mention |
| **Omit** | Internal-only, admin debug, or incomplete | Do NOT document — avoid documenting vaporware |

**Tier classification signals**:
- A feature with its own frontend page = at least Tier 2
- A feature mentioned in CLAUDE.md as a core value prop = at least Tier 1
- A feature with only GET endpoints and no dedicated UI = likely Tier 3
- A feature with `# TODO` or `# WIP` comments = Omit

##### Step 2B.3: Content Evidence Collection

For each **Tier 1** and **Tier 2** feature, read the actual source code and collect:

1. **Verified capabilities** — list ONLY things the code actually implements:
   - Read the router file: what endpoints exist and what do they do?
   - Read the service file: what business logic runs?
   - Read the model: what data is stored?

2. **User-facing behavior** — how does the end user experience this feature?
   - What does the frontend page show?
   - What actions can the user take?
   - What is the workflow (input → processing → output)?

3. **Technical mechanism** — how does it work under the hood? (for architecture docs)
   - What protocols are used? (REST, WebSocket, SSE, etc.)
   - What external services are called?
   - What are the key data flows?

4. **Unique differentiators** — what makes this feature special compared to alternatives?
   - Cross-reference with CLAUDE.md value propositions
   - Note integration points between features (e.g., approvals + audit trail)

**Output format per feature**:
```
### Feature: [Name]
- Tier: [1/2/3]
- Source: [router file path]
- Verified capabilities: [bullet list of ONLY code-confirmed capabilities]
- User workflow: [1-2 sentence description of user experience]
- Technical detail: [mechanism, protocols, data flow]
- Differentiator: [what's special about this implementation]
- i18n content draft:
  - Title (en/zh): "..." / "..."
  - Description (en/zh): "..." / "..."
```

##### Step 2B.4: Claim Verification

**MANDATORY before proceeding**: Cross-check ALL content from CLAUDE.md/README.md against code evidence:

| Claim from docs | Evidence in code | Status |
|-----------------|-----------------|--------|
| "anomaly detection" | `services/cost.py:AnomalyDetector` | Verified |
| "budget circuit-breakers" | `services/cost.py:check_budget_limit()` | Verified |
| "model routing optimization" | no matching code found | REMOVE |

Rules:
- **Verified**: Claim stays in documentation, reference the code path
- **Partial**: Rephrase to match what actually exists (e.g., "budget alerts" instead of "budget circuit-breakers" if only alerts exist)
- **Unverified**: REMOVE from documentation entirely — do not document features that don't exist
- **Planned**: If a feature is clearly planned (has TODO/WIP markers), mention it in a "Roadmap" section only, never in feature descriptions

##### Step 2B.5: Project Identity Extraction

Beyond features, extract the project's identity for the docs narrative:

1. **One-line pitch**: What is this project in one sentence? (from CLAUDE.md or README)
2. **Problem statement**: What pain point does it solve? (derive from value proposition)
3. **Solution differentiator**: Why this project and not alternatives? (from CLAUDE.md + code analysis)
4. **Target audience**: Who uses this? (infer from frontend complexity, API design, deployment model)
5. **Maturity signal**: Is this alpha/beta/GA? (from version numbers, TODO density, test coverage)

#### Phase 2 Output: Content Discovery Report

Present a structured report to the user (NOT just "here's a summary"):

```
## Content Discovery Report

### Project Identity
- **Pitch**: [one-line]
- **Problem**: [one-line]
- **Differentiator**: [one-line]
- **Audience**: [inferred]
- **Maturity**: [alpha/beta/GA]

### Feature Inventory ([N] features discovered)

| # | Feature | Tier | Endpoints | Source | Verified Capabilities |
|---|---------|------|-----------|--------|----------------------|
| 1 | ... | T1 | 12 | routers/agents.py | CRUD, WebSocket health, auto-discovery |
| 2 | ... | T2 | 8 | routers/approvals.py | Create, review, escalate, audit |
| ... |

### Claim Verification
- [N] claims verified against code
- [N] claims removed (no code evidence)
- [N] claims rephrased (partial implementation)

### Content Gaps
- [Any important features that exist in code but are NOT mentioned in CLAUDE.md/README]
```

This report feeds directly into Phase 3 planning and Phase 4 content generation.

---

### Phase 3: Style, Audience & Documentation Planning

This phase combines style selection, audience confirmation, and detailed content planning. It produces a **Content Outline** that the user must approve before any code is generated.

#### Step 3.1: Style Direction

**If Design System Level A (Full)**:
- Skip style preset selection
- Inform user: "Your project has a complete design system. Docs will follow your existing visual language."
- Style preset can still be selected for **content structure and layout** only (not colors/fonts)

**If Design System Level B (Implicit) or C (None)**:
- Present style presets to user for selection. Use `AskUserQuestion` with these options:

```
Question: "Which documentation style best fits your project?"
Options:
1. Stripe Premium — Professional, navy + violet, API-centric (recommended for developer platforms)
2. Vercel Monochrome — Minimal black/white, code-first (recommended for open-source/frameworks)
3. Tailwind Utility — Cyan accent, numbered steps, utility-focused
4. GitHub System — Token-based, 5-tier callouts, accessible (recommended for multi-product platforms)
5. Supabase Bold — Vibrant green, dark-first, modern SaaS
6. Linear Minimal — Dark-first, desaturated indigo, calm authority
7. Anthropic Warm — Terra cotta + cream, serif body, humanistic
8. Notion Friendly — Warm grays, emoji nav, non-developer friendly
```

See `references/style-presets.md` for full details of each preset.

**Style Application Priority (final)**:

```
┌─────────────────────────────────────────────────┐
│  HIGHEST PRIORITY                               │
│  1. Project's explicit design tokens/spec       │
│  2. Project's existing frontend code patterns   │
│  3. User-selected style preset                  │
│  LOWEST PRIORITY                                │
└─────────────────────────────────────────────────┘
```

- Colors/fonts: Project spec > Project code > Style preset
- Layout structure: Style preset influences (project can override)
- Content patterns: Style preset provides defaults
- Component style: Project components > Style preset suggestions

#### Step 3.2: Content Direction Confirmation

Use `AskUserQuestion` to confirm the content approach. This prevents generating docs that miss the user's intent.

```
Question 1: "Who is the primary audience for this documentation?"
Options:
- Developers integrating with the API (Recommended) — Technical depth, code examples, endpoint references
- Operators deploying & managing — Deployment guides, monitoring, troubleshooting
- Decision-makers evaluating the product — Value proposition, comparisons, architecture overview
- All audiences — Balanced mix of all above

Question 2: "What content depth do you prefer for the overview page?"
Options:
- Product overview (~800 words) — High-level value proposition, feature highlights, quick start links
- Technical introduction (~1500 words) (Recommended) — Architecture details, protocol explanations, code examples
- Comprehensive guide (~2500 words) — Both above + getting started tutorial, detailed feature walkthrough
```

Store the audience and depth selections — they determine content generation parameters in Phase 4.

#### Step 3.3: Documentation Planning

Based on Phase 2 findings AND Step 3.2 audience/depth selections, plan the documentation structure:

1. **Determine page set** — Common documentation pages include:

   | Page | Route | Purpose |
   |------|-------|---------|
   | Overview | `/docs` | Project introduction, value proposition, architecture |
   | Getting Started | `/docs/getting-started` | Quick start guide for new users |
   | Features | `/docs/features` | Detailed feature walkthrough |
   | Architecture | `/docs/architecture` | Technical architecture, protocols |
   | Self-Host | `/docs/self-host` | Self-hosting deployment guide |
   | API Reference | `/docs/api` | API endpoints and usage |
   | FAQ | `/docs/faq` | Frequently asked questions |

2. **Scope decision**:
   - First-time generation: Recommend starting with the **Overview** page (`/docs`) as the docs landing page
   - Incremental update: Identify what needs updating (see Incremental Update Mode below)

3. **Check for existing pages** — If pages already exist, plan updates rather than overwrites

4. **Determine if docs layout is needed** — If generating 2+ pages, plan a shared `app/docs/layout.tsx` with navigation (see `references/conventions.md` for template)

#### Step 3.4: Content Outline Draft

**This is the most critical planning step.** For each page to be generated, produce a **detailed content outline** that maps each section to its source material from Phase 2B.

For the Overview page (`/docs`), the outline format is:

```
## Content Outline: Overview Page (/docs)

### 1. Hero
- Badge: "DOCUMENTATION" / "文档"
- Title: [from Phase 2B.5 one-line pitch]
- Subtitle: [from Phase 2B.5 problem statement, 1-2 sentences]

### 2. What is [Project]? (~[word count based on depth selection])
- Paragraph 1: Problem statement — [specific pain points from Phase 2B.5]
- Paragraph 2: Solution — [how the project solves it, from Phase 2B.5 differentiator]
- Paragraph 3: Standards/protocols — [if applicable, from code evidence]
- Source: CLAUDE.md + verified against [specific files]

### 3. Core Concepts ([N] cards)
For each concept:
- [Concept Name] — [one-sentence explanation]
  Source: [model file or service file that implements this concept]
  Evidence: [specific class/function name]

### 4. Key Features ([N] cards, based on Tier 1 + Tier 2 features)
For each feature:
- [Feature Name] — [description draft, word count varies by tier]
  Tier: [1/2]
  Source: [router file:line]
  Verified capabilities: [list from Phase 2B.3]
  EXCLUDED capabilities: [any claims removed in Phase 2B.4]

### 5. How It Works ([N] steps)
- Step 1: [action] — [mechanism from code]
- Step 2: [action] — [mechanism from code]
- Step 3: [action] — [mechanism from code]

### 6. Tech Stack (table)
- [from Phase 2A project root files]

### 7. Quick Start
- Option A: [Cloud / SaaS if applicable]
- Option B: [Self-host / local if applicable]

### 8. Documentation Navigation
- [list of sub-pages with brief descriptions]

### 9. CTA
- Primary: [action]
- Secondary: [action]

### Estimated total: ~[word count] words
### i18n keys to generate: ~[count] keys × 2 languages
```

**Rules for the outline**:
- Every feature card MUST reference a source file from Phase 2B
- Every capability claim MUST have been verified in Phase 2B.4
- Word counts per section MUST respect the user's depth selection from Step 3.2
- Tier 1 features get 150-250 word descriptions; Tier 2 get 50-100 words; Tier 3 get 20-40 words

**CHECKPOINT CP2**: Present the complete plan (style direction + audience + content outline with sources) to the user and wait for approval.

The user should review:
1. **Is the feature selection correct?** — Are the right features highlighted? Any missing? Any that should be removed?
2. **Is the depth appropriate?** — Too technical? Too marketing-oriented?
3. **Is the narrative accurate?** — Does the "What is [Project]?" section capture the project's essence?
4. **Are the content sources trustworthy?** — The outline shows which code files back each claim

The user may:
- Approve as-is → proceed to Phase 4
- Request changes → modify outline and re-present
- Add custom content → note user-provided text to integrate verbatim in Phase 4

---

### Phase 4: Page Generation

Generate pages following the resolved design conventions. Apply these rules:

#### 4.1 File Structure

For each page, create:
- `app/docs/{page-name}/page.tsx` — Server component with metadata export
- `app/docs/{page-name}/content.tsx` — Client component with actual page content (if page uses hooks)
- i18n keys in all detected language files (see Phase 2A.3 i18n level)
- If generating 2+ pages: `app/docs/layout.tsx` with shared navigation and CMD+K search (see `references/templates.md`)

**Large page split rule**: If a `content.tsx` will exceed ~400 lines, split into section components:
```
app/docs/page-name/
├── page.tsx          # Server component (metadata)
├── content.tsx       # Client component (assembles sections)
└── sections/
    ├── hero.tsx      # Hero section
    ├── features.tsx  # Feature cards grid
    └── how-it-works.tsx  # Step cards
```
Each section file exports a named component (e.g., `export function FeaturesSection()`), imported by `content.tsx`. Keep shared sub-components (CodeBlock, SectionHeading, icons) in `content.tsx` or a shared `components.tsx`.

Use the **Server/Client split pattern** from `references/conventions.md`: `page.tsx` exports `Metadata` (Server Component), `content.tsx` has `"use client"` with interactive content.

#### 4.2 Design System Application

Apply the resolved design system from Phase 1 and Phase 3:

- **Level A**: Use project's CSS variables and component classes directly
- **Level B**: Use detected conventions, fill gaps with style preset tokens
- **Level C**: Map style preset tokens to CSS variables in the page's styles

When the style preset specifies colors but the project has its own:
- Use PROJECT colors for all visual elements
- Use PRESET patterns for layout structure and content organization only

#### 4.3 Code Conventions

Match the existing codebase style. Key things to detect and follow:
- **"use client"** directive usage (only in content.tsx, not page.tsx)
- **Import style** (named vs default, path aliases like `@/`)
- **Component pattern** (function components, inline icons)
- **CSS approach** (CSS variables via `style={{}}`, Tailwind classes, or both)
- **i18n usage** (`const { t } = useTranslation()` or equivalent)

Refer to `references/conventions.md` for detailed patterns including all required icon definitions.

#### 4.4 Reusable Components

Priority order for components:
1. **Reuse** existing project components (if CodeBlock, FaqItem, etc. already exist)
2. **Import** from existing docs pages if defined inline there
3. **Create** new inline components following project style + conventions.md patterns

If creating new components, include all required icon definitions from `references/conventions.md`.

**Structural components** — include these based on the conditions below:

| Component | When to Include | Source |
|-----------|----------------|--------|
| **TableOfContents** (right-side TOC) | Page has 5+ `SectionHeading` elements | `references/templates.md` — use two-column grid layout |
| **Breadcrumbs** | Multi-page docs, on every sub-page (not the root `/docs` page) | `references/conventions.md` — place at top of `<main>` |
| **PrevNextNav** | Multi-page docs (2+ pages with shared layout) | `references/templates.md` — place at bottom of each page, before footer |
| **Callout** | Content includes important notes, warnings, prerequisites, or tips | `references/conventions.md` — use appropriate type (note/tip/warning/caution) |

#### 4.5 AI-Friendly Documentation (REQUIRED)

Every generated docs page MUST be AI-readable. This is not optional.

**A. Server-Side Rendering (SSR) for curl accessibility**

All documentation content must be present in the initial HTML response so that `curl https://domain.com/docs` returns the full text. Next.js App Router SSR handles this automatically, but follow these rules:

- Use the Server/Client split pattern (4.1): `page.tsx` is a Server Component, `content.tsx` is a Client Component. Next.js SSR renders both on the server, so `curl` gets full HTML.
- Do NOT lazy-load critical text content (no `useEffect` → `fetch` for documentation text).
- Do NOT conditionally render documentation sections based on client-only state. Interactive elements (FAQ toggle, code copy) are fine — the TEXT must always render.
- i18n content is OK in client components because Next.js SSR renders them with the default locale.

**B. Section anchors on ALL headings**

Every `<h2>` and `<h3>` MUST have an `id` attribute for deep linking. This allows both AI and humans to reference specific sections (e.g., `/docs#key-features`, `/docs/architecture#protocols`).

Use the `SectionHeading` component from `references/conventions.md` (supports both `h2` and `h3` via the `as` prop). Every `<h2>` and `<h3>` in docs must use this component.

ID naming rules:
- Lowercase, hyphen-separated: `key-features`, `how-it-works`, `tech-stack`
- Derive from the English i18n value (not the key name)
- `scroll-mt-20` is built into the component (accounts for sticky nav height)

**C. llms.txt generation (auto-update)**

After generating docs pages, update (or create) the project's LLM-readable files. See `references/conventions.md` for file templates.

1. **`public/llms.txt`** — Summary index (≤50 lines) with links to all docs pages and API endpoints
2. **`public/llms-full.txt`** — Complete content from ALL docs pages in plain English markdown
3. **Verify `<link rel="llms-txt">` tag** exists in root layout's `<head>` — add if missing
4. **Multi-language**: Both files are in English; note localized web page availability if applicable

**D. Page metadata and SEO (per page)**

Each `page.tsx` MUST export a complete `Metadata` object. Use the enhanced template from `references/conventions.md` (Server/Client Split Template). Rules:

1. **Title format**: `"{Page Title} — {Project Name}"` (e.g., `"Documentation — AgentPlanet"`, `"Self-Host Guide — AgentPlanet"`). Derive page title from the Phase 3.4 content outline's Hero section. Keep under 60 characters.
2. **Description**: One sentence summarizing the page content. Under 160 characters. Include primary keywords from Phase 2B.5 project identity. No generic filler — each page's description must be unique.
3. **OpenGraph**: Include `title`, `description`, `type: "website"`, and `siteName` (project name). If the project has an OG image, include `images`.
4. **Twitter card**: Include `card: "summary_large_image"`, `title`, and `description`.
5. **Canonical URL**: Set `alternates.canonical` to the page's path (e.g., `"/docs"`, `"/docs/self-host"`).

**Favicon and site-level metadata** — check the project's root `layout.tsx` (or `app/layout.tsx`):
- If favicon/icons are already configured → do NOT modify
- If missing → note in CP3 output as a recommendation (do not auto-generate favicons, as they require design assets)
- Verify `<link rel="llms-txt">` tag exists (from step C above)

#### 4.6 Evidence-Based Content Generation

**This is the core content generation step.** Use the approved Content Outline from CP2 as a strict blueprint. Do NOT deviate from it without reason.

##### 4.6.1 Content Writing Rules

For each section in the outline:

1. **Write from evidence, not imagination**: Every capability claim must trace to a verified source from Phase 2B.3. If the outline says "CRUD + WebSocket health" for Agent Registry, the description must mention those specific capabilities — not generic marketing language.

2. **Match depth to tier**:
   - **Tier 1 features** (150-250 words): Explain WHAT it does, HOW it works (mechanism), and WHY it matters (user benefit). Include at least one specific technical detail (protocol, data structure, workflow step).
   - **Tier 2 features** (50-100 words): Explain WHAT it does and WHY it matters. One concrete detail.
   - **Tier 3 features** (20-40 words): Brief statement of capability.

3. **Match tone to audience** (from Step 3.2):
   - **Developers**: Technical precision, mention protocols/APIs, include code snippets
   - **Operators**: Operational benefits, monitoring/alerting specifics, deployment details
   - **Decision-makers**: Business value, risk reduction, compliance benefits
   - **All audiences**: Lead with value, follow with technical detail

4. **Specificity over adjectives**:
   - WRONG: "Powerful real-time monitoring capabilities"
   - RIGHT: "Live event streaming via SSE with per-agent filtering, 30-second offline detection, and daily digest summaries"

5. **Content per section word count guidance** (for "Technical introduction" depth ~1500 words):
   - Hero (title + subtitle): ~30 words
   - "What is [Project]?": ~150-200 words (3 paragraphs)
   - Core Concepts: ~200 words (4-5 cards × 40-50 words each)
   - Key Features: ~400-500 words (6-8 cards, Tier-based word counts)
   - How It Works: ~120 words (3 steps × 40 words)
   - Tech Stack: table (no prose needed)
   - Quick Start: ~80 words
   - CTA: ~30 words

   Adjust proportionally for "Product overview" (~800 words) or "Comprehensive guide" (~2500 words).

##### 4.6.2 Content Quality Checklist

Before finalizing i18n content, verify each item:

- [ ] **Bilingual**: All user-visible text goes through i18n. Keys in BOTH zh-CN and en-US files. Keys match exactly.
- [ ] **Accurate**: Every feature mentioned has a verified code path from Phase 2B.4.
- [ ] **Specific**: Each feature description contains at least one concrete detail (number, mechanism, or protocol), not just adjectives.
- [ ] **Differentiated**: The "What is [Project]?" section clearly states what makes this project unique in ≤3 sentences.
- [ ] **Complete**: All Tier 1 and Tier 2 features from the approved outline are included. No Tier 1 feature is reduced to a Tier 3 description.
- [ ] **No vaporware**: No feature is documented that failed verification in Phase 2B.4.
- [ ] **Structured**: Follows style preset's content pattern (Hero → Sections → CTA → Footer).
- [ ] **Visual**: Uses icons, cards, tables, and code blocks to break up text.
- [ ] **Responsive**: All layouts work on mobile (use sm:/md: breakpoints).
- [ ] **Accessible**: Semantic HTML, proper heading hierarchy (h1 → h2 → h3, no skips).
- [ ] **Linkable**: Internal links between docs pages using `<Link>`, external links to GitHub.
- [ ] **AI-readable**: All headings have anchor IDs, content SSR-rendered, llms.txt updated (see 4.5).

#### 4.7 i18n Key Naming Convention

**IMPORTANT**: First detect the existing key structure in the project's i18n files. Do NOT impose a new namespace if the project already uses a different pattern.

Adapt to the i18n level detected in Phase 2A.3:
- **i18n-Multi**: Generate keys in ALL language files simultaneously. See `references/conventions.md` for i18n examples.
- **i18n-Single**: Generate keys in the single language file only.
- **i18n-None**: Use inline text directly in JSX. Skip all i18n key generation.

#### 4.8 Navigation Updates

After generating pages, update navigation:
1. Find the homepage file (e.g., `page.tsx`) — locate the `DOCS_URL` constant or equivalent
2. Update docs link from `/docs/self-host` (or current) to `/docs` (new landing page)
3. Update footer docs links similarly
4. If a docs layout with nav was created, ensure all sub-pages are listed

---

### Phase 5: Validation

After generation, run ALL checks in order. Do not skip any.

#### 5.0 Implementation Completeness Verification

**This step runs FIRST in Phase 5 — before any other validation.** Its purpose is to catch structural omissions (missing files, missing sections, missing navigation) that technical checks like `tsc` won't detect. This is split into two passes for thoroughness.

##### Pass 1: Plan-vs-Output Audit

Compare the approved Content Outline (from CP2) and Phase 4 plan against what was actually generated. Check **every** item in this table:

```
## Implementation Audit — Pass 1: Plan vs Output

### File Structure
| Planned | Expected File | Exists? | Status |
|---------|--------------|---------|--------|
| Overview page | app/docs/page.tsx | ✅/❌ | |
| Overview content | app/docs/content.tsx | ✅/❌ | |
| Docs layout (if 2+ pages) | app/docs/layout.tsx | ✅/❌ | |
| Sub-page: Self-Host | app/docs/self-host/page.tsx | ✅/❌ | |
| ... (all planned pages) | | | |

### Content Sections & Feature Completeness (per page)
For each page, verify every section from the CP2 outline exists AND feature descriptions meet tier-appropriate depth:
| Page | Section from Outline | In Generated Code? | Tier | Word Count | Status |
|------|---------------------|-------------------|------|------------|--------|
| /docs | Hero (badge + title + subtitle) | ✅/❌ | — | — | |
| /docs | "What is [Project]?" | ✅/❌ | — | [N] words | |
| /docs | Core Concepts ([N] cards) | ✅/❌ | — | — | |
| /docs | Feature: Agent Registry | ✅/❌ | T1 | [N] words (need 150-250) | ✅/⚠️ |
| /docs | Feature: Approvals | ✅/❌ | T1 | [N] words (need 150-250) | ✅/⚠️ |
| /docs | Feature: Config Mgmt | ✅/❌ | T2 | [N] words (need 50-100) | ✅/⚠️ |
| /docs | How It Works ([N] steps) | ✅/❌ | |
| /docs | Tech Stack table | ✅/❌ | |
| /docs | Quick Start | ✅/❌ | |
| /docs | Documentation Navigation | ✅/❌ | |
| /docs | CTA | ✅/❌ | |
| /docs | Footer | ✅/❌ | |

### Structural Components
| Component | Condition | Exists? | Status |
|-----------|-----------|---------|--------|
| Docs layout with sidebar/nav | 2+ pages planned | ✅/❌ | |
| CMD+K search component | 2+ pages planned | ✅/❌ | |
| SectionHeading usage | All h2/h3 tags | ✅/❌ | |
| On-page TOC (right-side) | Page has 5+ sections | ✅/❌ | |
| Breadcrumbs | 2+ pages, sub-pages | ✅/❌ | |
| Prev/Next navigation | 2+ pages planned | ✅/❌ | |
| Callout components | Warnings/tips in content | ✅/❌ | |
| Navigation links updated | Homepage docs link points to /docs | ✅/❌ | |
| Page metadata (title + description + OG + Twitter) | Every page.tsx | ✅/❌ | |
| Canonical URLs | Every page.tsx | ✅/❌ | |

### Ancillary Files
| File | Required | Exists & Updated? | Status |
|------|----------|-------------------|--------|
| public/llms.txt | Always | ✅/❌ | |
| public/llms-full.txt | Always | ✅/❌ | |
| <link rel="llms-txt"> in root layout | Always | ✅/❌ | |

### i18n Completeness
| Check | Status |
|-------|--------|
| All sections have i18n keys (no hardcoded text) | ✅/❌ |
| Keys in en-US.json | ✅/❌ |
| Keys in zh-CN.json | ✅/❌ |
| Key counts match between files | ✅/❌ |
```

**Action on ❌**: For each missing item, immediately generate/fix it before proceeding to Pass 2. This includes creating missing files, adding missing sections to existing files, and updating navigation.

##### Pass 2: Structural Integrity Check

After Pass 1 gaps are fixed, verify the generated output works as a coherent whole. This pass catches integration issues that Pass 1's item-by-item check misses.

1. **Read every generated file end-to-end** — not just spot-checking sections. Verify:
   - Imports are complete (no missing component references)
   - Components referenced in JSX are defined or imported
   - i18n keys used in `t("...")` calls exist in the language files
   - Internal `<Link href="...">` targets exist as actual routes

2. **Navigation coherence**:
   - If docs layout exists: does it list ALL generated sub-pages in its nav items?
   - Does each sub-page render correctly within the layout (no duplicate nav, no missing wrapper)?
   - Do "Back to Home" and docs nav links point to valid routes?

3. **Cross-page consistency**:
   - Do all pages use the same spacing convention (e.g., `mb-12` between sections)?
   - Do all pages use `SectionHeading` for h2/h3 (not bare `<h2>` tags)?
   - Is the docs layout nav order logical (Overview first, then by importance)?

4. **Feature card count verification**:
   - Count feature cards in generated code vs planned count in outline
   - If mismatch: identify which features were dropped and add them

```
## Implementation Audit — Pass 2: Structural Integrity

| Check | Result | Action |
|-------|--------|--------|
| All imports resolve | ✅/❌ — [details] | [fix if needed] |
| All t() keys exist in i18n | ✅/❌ — [N] keys checked | [add missing] |
| All internal links valid | ✅/❌ — [details] | [fix routes] |
| Layout nav lists all pages | ✅/❌ — [N] pages in nav vs [N] generated | [add missing] |
| SectionHeading on all h2/h3 | ✅/❌ — [N] headings checked | [replace bare h2] |
| Feature card count matches | ✅/❌ — [N] planned vs [N] generated | [add missing] |
| Cross-page spacing consistent | ✅/❌ | [standardize] |
```

**Action on ❌**: Fix each issue immediately. After all fixes, do NOT re-run the full audit — proceed to 5.1 Technical Validation, which will catch any remaining code errors.

**IMPORTANT**: Do NOT present Pass 1/Pass 2 results to the user as a checkpoint. This is an internal self-check. Fix issues silently and proceed. The user sees results at CP3.

#### 5.1 Technical Validation

1. **TypeScript check**: Run `npx tsc --noEmit` (or project's typecheck command from CLAUDE.md)
2. **Lint check**: Run the project's lint command
3. **i18n check**:
   - Run project's i18n check script if available (e.g., `npm run i18n:check`)
   - If no script: manually verify both language files have matching keys

#### 5.2 AI-Friendly Validation

1. Verify all `<h2>`/`<h3>` tags have `id` attributes
2. Verify `public/llms.txt` and `public/llms-full.txt` exist and reflect the new docs
3. Verify `<link rel="llms-txt">` exists in root layout's `<head>`
4. Verify the page is a Server/Client split (page.tsx exports metadata, content.tsx has "use client")

#### 5.3 Content Quality Audit

**This is new and REQUIRED — not optional.** Technical validation catches code errors; content audit catches documentation errors.

##### 5.3.1 Claim Verification Sweep

Re-verify ALL feature claims in the generated i18n content against the codebase:

1. Extract every capability claim from the generated en-US.json docs section
2. For each claim, Grep the codebase for evidence (function name, class, endpoint)
3. Report results:

```
## Content Verification Results

| Claim | Search Term | Found In | Status |
|-------|------------|----------|--------|
| "SSE event streaming" | "SSE\|EventSource\|text/event-stream" | routers/events.py:45 | ✅ |
| "budget circuit-breakers" | "circuit.break\|budget.limit" | services/cost.py:89 | ✅ |
| "model routing optimization" | "model.rout\|routing.optim" | — | ❌ REMOVE |
```

Fix any ❌ claims: remove from i18n content or rephrase to match reality.

##### 5.3.2 Content Specificity Check

Scan generated descriptions for vague language. Flag any description that:
- Uses only adjectives without concrete details ("powerful", "comprehensive", "robust", "seamless")
- Doesn't mention at least one specific mechanism, number, or protocol
- Could apply to ANY product (not specific to THIS project)

For each flagged description, enrich with a specific detail from the codebase.

##### 5.3.3 Bilingual Quality Check

For zh-CN translations:
- Verify translations are natural Chinese, not word-for-word machine translation
- Technical terms should use industry-standard Chinese translations (e.g., "审计追踪" not "审核小道")
- Product names and protocol names (MCP, A2A, SSE) should remain in English
- Verify zh-CN descriptions convey the same meaning as en-US (not just similar)

#### 5.4 Visual Review Prompt

Tell the user to run `pnpm dev` and:
- Visit `/docs` to preview the page
- Run `curl http://localhost:3000/docs 2>/dev/null | grep -c '<h2'` to verify SSR renders headings
- Check that anchor links work (e.g., `/docs#key-features`)

Report any errors and fix them before completing.

**CHECKPOINT CP3**: Present the full validation results (technical + content audit) to the user with preview instructions. Include:
- Technical check results (pass/fail)
- Content verification table (claims checked, any removed)
- Specificity improvements made
- Preview instructions for visual review

This is the final checkpoint — the user should visually review the docs before accepting.

---

## Incremental Update Mode

When the skill is invoked on a project that **already has docs pages** (whether generated by this skill or hand-crafted), the workflow changes significantly. Instead of the full 5-phase flow, incremental mode uses a specialized detection → diff → targeted update pipeline.

### Detecting Update Mode

The skill automatically enters Incremental Update Mode when **both** conditions are true:

1. Docs pages already exist (e.g., `app/docs/page.tsx`, `app/docs/content.tsx`, or `app/docs/*/page.tsx`)
2. User's request implies updating rather than creating from scratch

**Trigger phrases** (in addition to the standard triggers):
- "Update docs", "refresh docs", "sync docs with code changes"
- "Improve the docs page", "docs content is outdated"
- "I added a new feature, update the docs"
- "Optimize the existing documentation"
- "Make the docs better" / "docs need polishing"

### Two Update Scenarios

Incremental updates fall into two categories. The skill MUST identify which scenario applies (or both) before proceeding. **The scenario determines which steps to run.**

#### Scenario A: Content Refinement (Project Unchanged)

**When**: The project's features haven't changed, but the existing docs need quality improvement.

Common reasons:
- Docs were generated by an earlier version of this skill (e.g., v1.1.0) with less rigorous content mining
- Descriptions are too vague or marketing-oriented (the "adjective problem")
- Content was originally drafted quickly and needs depth
- User feedback: "the docs are correct but feel thin/generic"
- Missing sections (e.g., no "How It Works", no architecture diagram)
- Bilingual quality issues (zh-CN translations are awkward)

**Workflow shortcut**: Skip Step U2.1 (fresh feature scan) — the codebase hasn't changed, so the existing Feature Inventory is still valid. Go directly to U1 → U2.2 (quality-focused delta using existing docs only) → U3 → U4 → U5.

#### Scenario B: Feature Sync (Project Changed)

**When**: The project has changed — features added, modified, or removed — and docs need to reflect reality.

Common reasons:
- New API routers/endpoints added
- Existing features gained new capabilities
- Features were removed or deprecated
- Data models changed (renamed fields, new entities)
- Tech stack changed (new dependency, version upgrade)
- Deployment process changed

**Workflow**: Run the full U1 → U2.1 (fresh scan) → U2.2 → U2.3 → U3 → U4 → U5 pipeline. The fresh scan is essential to detect what changed.

#### Scenario A+B: Both

When both content quality AND feature changes are needed, run the full Scenario B pipeline but include Scenario A's quality flags in Step U2.2.

### Incremental Update Workflow

```
Step U1: Existing Docs Audit → Step U2: Codebase Delta Analysis → Step U3: Update Plan → Step U4: Targeted Updates → Step U5: Validation
                                                                       ↓ CP-U (user reviews update plan)
```

#### Step U1: Existing Docs Audit

Read all existing docs pages and extract their current content inventory:

1. **Read all docs page files** (`app/docs/**/content.tsx`, `app/docs/**/page.tsx`)
2. **Read all docs-related i18n keys** from both language files
3. **Build a Current Content Inventory**:

```
## Current Docs Content Inventory

### Pages
| Page | Route | File | Sections | i18n Key Count |
|------|-------|------|----------|----------------|
| Overview | /docs | app/docs/content.tsx | Hero, What Is, Concepts(5), Features(8), How It Works(3), Tech Stack, Quick Start, Nav, CTA | 52 keys |
| Self-Host | /docs/self-host | app/docs/self-host/content.tsx | Hero, Prerequisites, Steps(4), Config, HTTPS, FAQ(5) | 38 keys |

### Feature Claims in Current Docs
Extract every feature/capability claim from i18n content:
| # | Feature Claimed | i18n Key | Current Description | Word Count |
|---|----------------|----------|---------------------|------------|
| 1 | Agent Registry | docs.overview.feature1Desc | "Single control plane for multi-agent orchestration..." | 18 |
| 2 | Real-Time Activity | docs.overview.feature2Desc | "Live event streaming via SSE..." | 15 |
| ... |

### Content Quality Flags
For each existing description, flag:
- [ ] Vague/adjective-only (no specific mechanism mentioned)
- [ ] Potentially outdated (references old API patterns)
- [ ] Too brief for feature importance
- [ ] zh-CN translation quality issues
```

#### Step U2: Codebase Delta Analysis

Run the same **Phase 2B Deep Content Mining** as the full workflow, then compare against the Current Content Inventory from Step U1.

##### U2.1: Fresh Feature Inventory

Use the Agent tool (subagent_type: `Explore`) to scan the current codebase — same process as Phase 2B.1. Build a fresh Feature Inventory Table.

##### U2.2: Delta Detection

Compare the fresh inventory against the current docs content:

```
## Content Delta Report

### New Features (in code, NOT in docs)
| Feature | Source | Endpoints | Why Missing |
|---------|--------|-----------|-------------|
| Web Push Notifications | routers/devices.py | 6 | Added after docs were generated |
| Feature Flags | routers/feature_flags.py | 4 | New module |

### Removed/Deprecated Features (in docs, NOT in code)
| Feature Claimed | i18n Key | Status |
|----------------|----------|--------|
| "model routing optimization" | docs.overview.feature3Desc | Code not found — REMOVE |

### Modified Features (in both, but description is stale)
| Feature | What Changed | Current Docs Say | Code Now Does |
|---------|-------------|-----------------|---------------|
| Cost Tracking | Added budget alerts | "Per-agent cost attribution" | "Per-agent cost + budget threshold alerts + daily digest" |
| Approvals | Added mobile push | "One-click approve/deny" | "Approve/deny via web + mobile push notification" |

### Content Quality Issues (Scenario A — refinement needed)
| Feature | Issue | Current | Suggested Improvement |
|---------|-------|---------|----------------------|
| Unified Governance | Vague description | "Single control plane for multi-agent orchestration" | Should mention specific mechanisms: REST API registration, WebSocket health, config versioning |
| Audit Search | Too brief | "Full-text search across audit events" (7 words) | Tier 1 feature deserves 150+ words with trace chain detail |

### Structural Issues
- [ ] Missing "How It Works" detail (steps are too generic)
- [ ] No architecture diagram
- [ ] Core Concepts section could use [N] more entries
- [ ] llms.txt / llms-full.txt are stale
```

##### U2.3: Claim Re-verification

For ALL existing claims that remain in docs, re-run Phase 2B.4 Claim Verification against the current codebase. This catches features that were removed or renamed since docs were last generated.

#### Step U3: Update Plan (with CP-U Checkpoint)

Based on the Delta Report, produce an **Update Plan** that clearly categorizes every change:

```
## Docs Update Plan

### Summary
- Scenario: [A: Refinement / B: Feature Sync / Both A+B]
- Pages affected: [list]
- Estimated changes: [N] i18n keys modified, [N] added, [N] removed

### Additions (new content)
| # | What | Where | Tier | Words |
|---|------|-------|------|-------|
| 1 | Web Push Notifications feature card | /docs → Key Features section | T2 | ~60 |
| 2 | Feature Flags feature card | /docs → Key Features section | T3 | ~30 |
| 3 | New "Notifications" section | /docs/features (if exists) | — | ~150 |

### Modifications (existing content updated)
| # | What | Current Issue | Proposed Change |
|---|------|--------------|-----------------|
| 1 | Cost Tracking description | Missing budget alerts | Add "budget threshold alerts with configurable limits" |
| 2 | Approvals description | No mobile mention | Add "with mobile push notification support" |
| 3 | "How It Works" Step 1 | Too generic ("Connect") | Rewrite: "Register agent platforms via REST API, auto-discover agents through MCP" |
| 4 | 6 feature descriptions | Vague adjectives | Enrich each with specific mechanism from code |

### Removals (stale content)
| # | What | Why |
|---|------|-----|
| 1 | "model routing optimization" claim | No code evidence |

### Page Deletions (if applicable)
| # | Page | Route | Why | Cleanup Steps |
|---|------|-------|-----|--------------|
| 1 | API Reference | /docs/api | Feature deprecated | Delete files, remove i18n keys, remove from layout nav, update llms.txt, fix cross-page links |

When deleting a page: (1) delete the page directory (`app/docs/api/`), (2) remove all its i18n keys from both language files, (3) remove from layout nav items array, (4) remove from search index entries, (5) update llms.txt and llms-full.txt, (6) find and remove any `<Link href="/docs/api">` references in other docs pages.

### Preserved (no changes)
| # | What | Why |
|---|------|-----|
| 1 | Self-Host page | Deploy process unchanged |
| 2 | Tech Stack table | Dependencies unchanged |
| 3 | User's custom FAQ entries | Custom content detected |

### Files to modify
- [ ] `app/docs/content.tsx` — update feature cards, how-it-works steps
- [ ] `src/i18n/en-US.json` — modify [N] keys, add [N] keys, remove [N] keys
- [ ] `src/i18n/zh-CN.json` — same changes
- [ ] `public/llms.txt` — regenerate
- [ ] `public/llms-full.txt` — regenerate
```

**CHECKPOINT CP-U**: Present the Update Plan to the user and wait for approval.

The user should review:
1. **Are the additions correct?** — Should these new features be documented? At the right tier?
2. **Are the modifications accurate?** — Do the proposed improvements match reality?
3. **Are the removals safe?** — Is any removed content actually still valid?
4. **Is anything missing?** — Any changes the user knows about that weren't detected?
5. **Preserved content** — Confirm custom sections should indeed be kept

The user may:
- Approve as-is → proceed to Step U4
- Add items → "also update the FAQ section" / "add a new page for feature X"
- Remove items → "don't change the How It Works section, I like it as-is"
- Provide custom text → "for the new push notification feature, use this description: ..."

#### Step U4: Targeted Updates

Execute the approved Update Plan. Key rules:

##### U4.1: Surgical Editing (Not Full Rewrites)

- **Use the Edit tool** for modifications — do NOT rewrite entire files
- **Read the existing file first** — understand its structure before changing it
- Modify only the affected sections, leaving everything else untouched
- When adding a new feature card, insert it in the logical position (after related features, or at the end of the grid)

##### U4.2: Custom Content Preservation

Before editing any file, identify and protect custom content:

1. **Detect custom sections**: Content that doesn't follow the standard template structure, or text that can't be derived from code analysis alone
2. **Mark custom sections** mentally: these are user-written and must be preserved verbatim
3. **Never overwrite** custom content — integrate updates around it

**Detection heuristics for custom content**:
- Sections with non-standard headings (not from the page-templates.md structure)
- Paragraphs that reference external resources, blog posts, or community links
- Descriptions that are clearly hand-written (more nuanced/opinionated than code-derived text)
- Sections with custom components not from conventions.md
- Any content with HTML comments like `<!-- custom -->` or `<!-- do not edit -->`

##### U4.3: i18n Key Management

When updating i18n files:

- **Modified keys**: Update the value in BOTH language files simultaneously
- **New keys**: Add to BOTH files. Place new keys near related existing keys (not at the end of the file)
- **Removed keys**: Delete from BOTH files. Also remove any references in TSX files
- **Never change key names** of existing keys (breaks references) — only change values
- **Run i18n check** after changes to verify both files match

##### U4.4: Content Quality Standards

All updated/new content must meet the same standards as fresh generation:
- Evidence-based (Phase 2B.3 verified capabilities)
- Specific (mechanisms, not adjectives)
- Tier-appropriate depth
- Audience-appropriate tone (maintain the same audience targeting as the original docs)

##### U4.5: Ancillary Updates

After content changes, also update:
- **llms.txt** and **llms-full.txt** — regenerate to reflect updated content
- **Navigation** — if new pages were added, update docs layout nav items
- **Search index** — if multi-page docs with search, add new content to the search index

#### Step U5: Validation

Run the same Phase 5 validation as the full workflow, with these incremental-specific additions:

1. **Update Completeness Verification** — adapted from Phase 5.0:
   - **Pass 1 (Plan-vs-Output)**: For each item in the Update Plan's Additions / Modifications / Removals tables, verify it was executed. Use this table:
     ```
     | # | Planned Change | Executed? | Verified? |
     |---|---------------|-----------|-----------|
     | 1 | Add Web Push feature card | ✅ Added to content.tsx | ✅ i18n keys in both files |
     | 2 | Enrich Cost Tracking description | ✅ Updated | ✅ Now mentions budget alerts |
     | 3 | Remove "model routing" claim | ✅ Removed from i18n | ✅ No references in TSX |
     | 4 | Regenerate llms-full.txt | ✅ Updated | ✅ Reflects new features |
     ```
     Also verify ancillary updates (llms.txt, navigation, search index) were completed.
   - **Pass 2 (Structural Integrity)**: Read all modified files end-to-end. Verify imports resolve, new i18n keys are used in TSX, new feature cards are positioned correctly, navigation lists all pages, and unchanged sections still render correctly (regression check).
   - Fix any gaps before proceeding.

2. **All Phase 5 checks** (5.1-5.4: TypeScript, lint, i18n, AI-friendly, content audit, visual review prompt)

**CHECKPOINT CP3**: Same as full workflow — present validation results and preview instructions.

### Phase Skipping Rules for Updates

Not all phases from the full workflow are needed for incremental updates:

| Full Workflow Phase | Incremental Update | Skip/Run? |
|--------------------|--------------------|-----------|
| Phase 1: Design System Detection | Already detected in initial generation | **Skip** — unless user reports styling issues |
| Phase 2A: Project Context | Already known | **Skip** — unless project structure changed |
| Phase 2B: Deep Content Mining | **ALWAYS RUN** — this is how deltas are detected | **Run** (as Step U2.1) |
| Phase 3: Style Selection | Already selected | **Skip** |
| Phase 3: Audience Confirmation | Already confirmed | **Skip** — unless user wants to change audience |
| Phase 3: Content Outline | Replaced by Update Plan | **Run** (as Step U3) |
| Phase 4: Page Generation | Replaced by Targeted Updates | **Run** (as Step U4) |
| Phase 5: Validation | Same | **Run** (as Step U5) |

### Handling Docs Not Generated by This Skill

When docs pages exist but were **NOT generated by this skill** (hand-crafted, or from another tool):

1. **Do NOT assume any structure** — read every file carefully before modifying
2. **Run Phase 1** (Design System Detection) — the existing docs may use different conventions
3. **Build the Content Inventory** (Step U1) with extra care:
   - Map the existing page structure (may not follow this skill's templates)
   - Identify the i18n approach (may use a different library or inline text)
   - Note component patterns (may have custom CodeBlock, FAQ, etc.)
4. **Propose an approach** to the user before editing:
   - Option A: "Refine in place" — keep the existing structure, only update content
   - Option B: "Migrate to standard" — restructure to follow this skill's conventions (more invasive)
5. **Default to Option A** unless the user explicitly requests Option B
6. **If inline text** (no i18n): Offer to migrate to i18n as part of the update, but ask first — don't force it

## Portability

Optimized for **Next.js App Router** (auto-detected via `next.config.*` and `app/` directory). Adapts to Pages Router, Vite+React, or other setups — ask the user to confirm conventions when working with non-Next.js projects.

## User Interaction Checkpoints

This skill has **3 mandatory checkpoints** for first-time generation and **2 checkpoints** for incremental updates. You MUST pause and wait for user input at each. Do NOT proceed past these points without user acknowledgment.

**First-time generation checkpoints:**

| Checkpoint | Phase | What to Present | Why |
|------------|-------|-----------------|-----|
| **CP1: Design System Report** | End of Phase 1 | Design system level (A/B/C), detected tokens, fonts, components | User must verify detection accuracy before design decisions |
| **CP2: Content Outline Approval** | End of Phase 3 | Style direction + audience + **detailed content outline with source references** for each page section | **This is the most critical checkpoint.** The user reviews the exact features, descriptions, depth, and narrative structure BEFORE any code is generated. Prevents generating docs that miss the project's intent or contain inaccurate claims. |
| **CP3: Validation Summary** | End of Phase 5 | Technical checks (pass/fail) + content verification table + completeness check + preview instructions | User reviews both code quality AND content accuracy before accepting |

**Incremental update checkpoints:**

| Checkpoint | Step | What to Present | Why |
|------------|------|-----------------|-----|
| **CP-U: Update Plan Approval** | End of Step U3 | Content Delta Report + categorized Update Plan (additions, modifications, removals, preserved) | User verifies which changes to make, protects custom content, and can add/remove items before editing starts |
| **CP3: Validation Summary** | End of Step U5 | Same as full workflow + delta verification table | User confirms all planned changes were executed correctly |

**CP2 (first-time) and CP-U (updates) are the content quality gates.** If the user provides feedback (e.g., "feature X should be more prominent", "add a section about Y", "the tone is too technical", "don't change the FAQ"), revise the plan and re-present it. Do NOT proceed to generation/editing until approved.

**Language matching**: At all checkpoints and any other user-facing interaction (e.g., `AskUserQuestion`), respond in the same language the user used in their most recent message. If the user wrote in Chinese, present checkpoints in Chinese. If in English, use English. Do NOT default to a fixed language.

**Anti-pattern**: Do NOT add extra confirmations within phases (e.g., "Should I start Phase 4 now?"). The 3 checkpoints above are sufficient. Between checkpoints, work autonomously.

## Anti-Patterns

See `references/anti-patterns.md` for the full list of 18 anti-patterns with examples and troubleshooting guide.

## References

- [conventions.md](references/conventions.md) — Code conventions, icon definitions, component patterns, i18n examples, AI-friendly patterns (rules & small components)
- [templates.md](references/templates.md) — Large copy-paste code templates: DocsLayout, SearchDialog, SearchButton, TableOfContents, PrevNextNav (read only when generating multi-page docs or pages with 5+ sections)
- [page-templates.md](references/page-templates.md) — Skeleton templates for documentation page types, content generation guidelines, style influence matrix
- [style-presets.md](references/style-presets.md) — 8 curated style presets with color palettes, typography, layout patterns, and selection guide
- [anti-patterns.md](references/anti-patterns.md) — Common mistakes and how to avoid them, troubleshooting guide
