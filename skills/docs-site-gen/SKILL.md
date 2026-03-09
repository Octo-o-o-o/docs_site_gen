---
name: docs-site-gen
description: Generates and maintains documentation website pages for any project. Analyzes project structure, architecture, and features to produce high-quality, bilingual documentation pages integrated into the existing web app. Use when creating, updating, or expanding project documentation sites, or when the user mentions "docs page", "docs site", "/docs route", or "project introduction page". Supports Next.js App Router with i18n. Offers 8 curated doc styles and auto-detects project design systems.
license: Apache-2.0
compatibility: Requires a web frontend project (Next.js recommended). Node.js and pnpm/npm for validation.
metadata:
  author: Octo-o-o-o
  version: "2.2.0"
---

# docs-site-gen — Documentation Site Generator

## Overview

This skill generates production-quality documentation website pages by deeply analyzing a project's codebase, architecture, and features. It produces Next.js page components (or adapts to the project's framework) with full bilingual i18n support, following the project's existing design system and code conventions.

**Key capabilities**:
- Auto-detects the project's UI and design specifications
- Deep content mining: reads actual source code (routers, models, services) to build verified feature inventories — not just paraphrasing README
- Configuration reference: auto-scans environment variables and config schemas to generate structured reference pages
- Verified code examples: extracts real, working code snippets from test files and examples/ directories
- Content outline with user review: the user approves the exact feature selection, depth, and narrative before any code is generated
- Offers 8 curated style presets inspired by industry-leading documentation sites
- AI-friendly by default: SSR-rendered content, section anchors, llms.txt generation, JSON-LD structured data

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

**This phase is the content backbone of the entire skill.** Phase 1 determines HOW the docs look; Phase 2 determines WHAT the docs say. Phase 2 has two sub-phases: **2A** (Project Context) and **2B** (Deep Content Mining).

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
   - **Route conflict check**: If the planned docs route (e.g., `/docs`) already exists, read the existing page. If it serves a non-documentation purpose, propose an alternative route or ask the user.

#### Phase 2B: Deep Content Mining

**Read `references/content-mining.md` for the complete mining workflow before starting this phase.**

Phase 2B builds a **verified feature inventory** by scanning actual source code — not by summarizing CLAUDE.md. It includes 7 steps:

1. **Feature Inventory Scan** — Use Agent tool (Explore) to scan routers, models, services, or frontend components
2. **Feature Depth Classification** — Classify each feature as Tier 1 (hero), Tier 2 (core), or Tier 3 (supporting)
3. **Content Evidence Collection** — Read source code to collect verified capabilities, user workflows, technical mechanisms
4. **Claim Verification** — Cross-check ALL CLAUDE.md/README claims against code. Remove unverified claims.
5. **Project Identity Extraction** — One-line pitch, problem statement, differentiator, audience, maturity
6. **Configuration & Environment Scanning** — Extract env variables, config schemas, build config
7. **Verified Code Examples** — Extract working code snippets from test files and examples/

The output is a **Content Discovery Report** covering project identity, feature inventory, claim verification, configuration inventory, code examples, and content gaps. Present this report to the user (no checkpoint — it's informational).

---

### Phase 3: Style, Audience & Documentation Planning

This phase combines style selection, audience confirmation, and detailed content planning. It produces a **Content Outline** that the user must approve before any code is generated.

#### Step 3.1: Style Direction

**If Design System Level A (Full)**:
- Skip style preset selection
- Inform user: "Your project has a complete design system. Docs will follow your existing visual language."

**If Design System Level B (Implicit) or C (None)**:
- Present style presets to user for selection. See `references/style-presets.md` for full details.
- Options: Stripe Premium, Vercel Monochrome, Tailwind Utility, GitHub System, Supabase Bold, Linear Minimal, Anthropic Warm, Notion Friendly

**Style Application Priority**:
1. Project's explicit design tokens/spec (highest)
2. Project's existing frontend code patterns
3. User-selected style preset (lowest)

#### Step 3.2: Content Direction Confirmation

Use `AskUserQuestion` to confirm:
1. **Audience**: Developers / Operators / Decision-makers / All audiences
2. **Content depth**: Product overview (~800 words) / Technical introduction (~1500 words) / Comprehensive guide (~2500 words)
3. **Search engine visibility** (SEO toggle): Whether docs pages should be discoverable by Google and AI search engines. Default: Yes.
   - **Yes (recommended)**: Full SEO stack — keyword strategy, sitemap.xml, robots.txt, hreflang, rich structured data (BreadcrumbList, FAQPage, SoftwareApplication), AI crawler allowance.
   - **No**: Adds `robots: { index: false, follow: false }` to each page's Metadata, skips sitemap/keyword/structured-data generation. Use for internal/private docs.

#### Step 3.2.1: SEO Keyword Strategy (when SEO = Yes)

If the user selected SEO = Yes, build a keyword strategy before the content outline. This step ensures docs pages rank for the terms users actually search for.

1. **Extract seed keywords** from Phase 2B.5 project identity:
   - Project name and common variants (e.g., "AgentPlanet", "Agent Planet", "agent-planet")
   - Problem domain terms (e.g., "AI agent management", "LLM orchestration")
   - Core technology terms from tech stack (e.g., "MCP server", "A2A protocol", "Next.js")
   - Target audience search terms (e.g., "deploy AI agents", "manage LLM costs")

2. **Research related search terms** (use WebSearch):
   - Search for `"{problem domain}" open source` to find how competitors describe the space
   - Search for `"{core feature}" tutorial OR guide OR documentation` to find terms users actually search for
   - Identify 2-3 long-tail phrases per planned page (e.g., "how to self-host AI agent platform")

3. **Produce a Keyword Map** — assign primary and secondary keywords per page:

   | Page | Primary Keyword | Secondary Keywords | Long-tail Phrases |
   |------|----------------|-------------------|-------------------|
   | /docs | {project name} documentation | {domain terms} | "what is {project name}" |
   | /docs/getting-started | {project} setup guide | install, deploy, configure | "how to set up {project}" |
   | /docs/features | {project} features | {top feature names} | "{project} vs {competitor}" |
   | /docs/architecture | {project} architecture | tech stack, {protocol names} | "how {project} works" |

This keyword map feeds into Step 3.4 (content outline includes keyword assignments) and Phase 4 (keyword placement in metadata, headings, and body text). See `references/generation-rules.md` section 4.5D for placement rules.

#### Step 3.3: Documentation Planning

Based on Phase 2 findings and audience/depth selections:

1. **Determine page set**: Which pages are applicable — Overview, Getting Started, Features, Architecture, Self-Host, API Reference, FAQ, Configuration
2. **Scope**: First-time → start with Overview page. Incremental → identify updates needed.
3. **Check for existing pages** — plan updates rather than overwrites
4. **Route conflict check**: If the planned route already exists for a non-doc purpose, propose an alternative or ask the user.

#### Step 3.3.1: Navigation Layout Strategy

After determining the page set (Step 3.3), choose a navigation layout based on content volume. This decision shapes the entire docs architecture.

**Estimate content volume** from the planned page count + content depth (Step 3.2):

| Planned Pages | Content Depth | Recommendation |
|---------------|---------------|----------------|
| 1 page | Any | **One-page** (only option) |
| 2-3 pages | Overview (~800w) | **One-page** — consolidate into single scrollable page with section anchors |
| 2-3 pages | Technical (~1500w) | **One-page** (recommended) or **Header nav** |
| 3-5 pages | Technical/Comprehensive | **Header nav** (recommended) — clean horizontal navigation |
| 6+ pages | Any | **Sidebar nav** (recommended) — full navigation tree |

**Three layout modes**:

**A. One-page + Sticky TOC** — All content in a single scrollable page.
- Right-side TOC for quick section jumping (mandatory)
- Anchor-based navigation via SectionHeading IDs
- No `layout.tsx` needed, simplest URL structure (`/docs#features`, `/docs#architecture`)
- Best for: compact docs where users benefit from seeing everything in context
- Reference style: Linear product pages, simple project landing docs

**B. Header Navigation** — Horizontal nav links in a sticky top bar.
- Each page is a top-level link in the header
- Clean and unobtrusive, pages are self-contained
- Individual pages can have right-side TOC
- CMD+K search in header bar
- Mobile: hamburger menu → dropdown
- Best for: 3-5 distinct topics, each page is a complete unit
- Reference style: Notion help center, Linear developer docs

**C. Sidebar Navigation** — Persistent left sidebar with full page tree.
- Sidebar (240-280px) shows all pages grouped by category
- Content area fills remaining width
- Optional right-side TOC (three-column layout: sidebar | content | TOC)
- CMD+K search at top of sidebar
- Mobile: slide-out drawer (hamburger button)
- Best for: deep documentation with many sections, frequent cross-referencing
- Reference style: Stripe docs, Vercel docs, Next.js docs

**When sidebar is chosen**, also plan **page grouping** for the sidebar:
```
Example groupings:
- Getting Started: Overview, Quick Start
- Guides: Features, Architecture, Self-Host
- Reference: API, Configuration
```

Present the recommendation to the user with `AskUserQuestion`:
- If 1 page: inform user it will be one-page (no choice needed)
- If 2-3 pages: recommend one-page, but offer header nav for Technical/Comprehensive depth
- If 3+ pages: recommend a layout, let user choose between the applicable options
- Include this choice in the CP2 checkpoint presentation

See `references/generation-rules.md` section 4.1 for layout-specific file structures and `references/templates.md` for layout code templates.

#### Step 3.4: Content Outline Draft

**This is the most critical planning step.** For each page (or for each section if one-page mode), produce a **detailed content outline** mapping each section to its source material from Phase 2B. See `references/page-templates.md` for section structures per page type.

Each outline entry must include:
- Section name and purpose
- Source file(s) from Phase 2B
- Verified capabilities to mention
- Approximate word count (based on tier and depth selection)

**Rules for the outline**:
- Every feature card MUST reference a source file from Phase 2B
- Every capability claim MUST have been verified in Phase 2B.4
- Tier 1 features: 150-250 words; Tier 2: 50-100 words; Tier 3: 20-40 words

**CHECKPOINT CP2**: Present the complete plan to the user and wait for approval: style direction + audience + **navigation layout** + content outline with sources. The user reviews feature selection, depth, layout choice, narrative accuracy, and content sources.

---

### Phase 4: Page Generation

**Read `references/generation-rules.md` for detailed generation rules before starting this phase.**

Generate pages following the resolved design conventions. Key areas covered:

1. **File Structure** — Layout-specific: one-page with TOC (Mode A), header nav (Mode B), or sidebar nav (Mode C). Server/Client split, large page splitting
2. **Design System Application** — Apply Level A/B/C design conventions from Phase 1
3. **Code Conventions** — Match existing codebase style (imports, CSS approach, component patterns)
4. **Reusable Components** — Reuse existing > import from existing docs > create new. Include TableOfContents, Breadcrumbs, PrevNextNav, Callout as needed
5. **AI-Friendly & SEO Documentation (REQUIRED)** — SSR rendering, section anchors on all h2/h3, llms.txt generation, keyword-optimized metadata, rich JSON-LD (BreadcrumbList/FAQPage/SoftwareApplication/HowTo), hreflang for bilingual, AI crawler allowance, sitemap/robots
6. **Evidence-Based Content** — Write from verified evidence, match depth to tier, specificity over adjectives, prefer verified code examples
7. **i18n Key Generation** — Adapt to detected i18n level (Multi/Single/None)
8. **Navigation Updates** — Update homepage and footer docs links

Also refer to: `references/conventions.md` for code patterns and components, `references/templates.md` for layout/search/TOC templates.

---

### Phase 5: Validation

**Read `references/validation-rules.md` for detailed validation steps before starting this phase.**

After generation, run ALL checks in order:

1. **Implementation Completeness Verification (5.0)** — Two-pass self-audit:
   - Pass 1: Compare approved outline (CP2) against generated output. Check every file, section, component, and i18n key.
   - Pass 2: Read every generated file end-to-end. Verify imports, i18n keys, internal links, navigation coherence, cross-page consistency.
   - Fix gaps silently before proceeding (this is an internal check, not a user checkpoint).
2. **Technical Validation (5.1)** — TypeScript check, lint, i18n key consistency
3. **AI-Friendly Validation (5.2)** — Verify heading IDs, llms.txt files, Server/Client split, JSON-LD
4. **Content Quality Audit (5.3)** — Re-verify claims against code, check content specificity, bilingual quality
5. **Visual Review Prompt (5.4)** — Tell user to run `pnpm dev` and preview `/docs`

**CHECKPOINT CP3**: Present full validation results (technical + content audit) with preview instructions.

---

## Incremental Update Mode

**Read `references/update-mode.md` for the complete incremental update workflow.**

When invoked on a project that **already has docs pages**, the skill uses a specialized workflow instead of the full 5-phase flow:

1. **Detection** — Automatically enters update mode when docs pages exist AND user implies updating
2. **Two scenarios**:
   - **Scenario A (Content Refinement)**: Project unchanged, docs need quality improvement. Skips fresh feature scan.
   - **Scenario B (Feature Sync)**: Project changed, docs need feature updates. Runs fresh codebase scan.
3. **Workflow**: U1 (Existing Docs Audit) → U2 (Codebase Delta Analysis) → U3 (Update Plan + **CP-U** checkpoint) → U4 (Targeted Updates via Edit tool) → U5 (Validation + **CP3**)
4. **Key principles**: Surgical editing (not full rewrites), custom content preservation, i18n key management (both files simultaneously)

## Portability

Optimized for **Next.js App Router** (auto-detected via `next.config.*` and `app/` directory). Adapts to Pages Router, Vite+React, or other setups — ask the user to confirm conventions when working with non-Next.js projects.

## User Interaction Checkpoints

This skill has **3 mandatory checkpoints** for first-time generation and **2 checkpoints** for incremental updates. You MUST pause and wait for user input at each. Do NOT proceed past these points without user acknowledgment.

**First-time generation checkpoints:**

| Checkpoint | Phase | What to Present | Why |
|------------|-------|-----------------|-----|
| **CP1: Design System Report** | End of Phase 1 | Design system level (A/B/C), detected tokens, fonts, components | User must verify detection accuracy before design decisions |
| **CP2: Content Outline Approval** | End of Phase 3 | Style direction + audience + **detailed content outline with source references** for each page section | **Most critical checkpoint.** User reviews features, descriptions, depth, and narrative BEFORE code is generated. |
| **CP3: Validation Summary** | End of Phase 5 | Technical checks (pass/fail) + content verification table + completeness check + preview instructions | User reviews code quality AND content accuracy before accepting |

**Incremental update checkpoints:**

| Checkpoint | Step | What to Present | Why |
|------------|------|-----------------|-----|
| **CP-U: Update Plan Approval** | End of Step U3 | Content Delta Report + categorized Update Plan (additions, modifications, removals, preserved) | User verifies which changes to make, protects custom content |
| **CP3: Validation Summary** | End of Step U5 | Same as full workflow + delta verification table | User confirms all planned changes were executed |

**Language matching**: At all checkpoints, respond in the same language the user used in their most recent message.

**Anti-pattern**: Do NOT add extra confirmations within phases. The checkpoints above are sufficient. Between checkpoints, work autonomously.

## Anti-Patterns

See `references/anti-patterns.md` for the full list of common mistakes with examples and troubleshooting guide.

## References

- [content-mining.md](references/content-mining.md) — Phase 2B deep content mining: feature inventory scan, evidence collection, claim verification, configuration scanning, code examples
- [generation-rules.md](references/generation-rules.md) — Phase 4 page generation: file structure, design application, AI-friendly requirements, content writing rules, quality checklist
- [validation-rules.md](references/validation-rules.md) — Phase 5 validation: completeness audit, technical checks, content quality audit
- [update-mode.md](references/update-mode.md) — Incremental Update Mode: existing docs audit, delta detection, targeted update workflow
- [conventions.md](references/conventions.md) — Code conventions, icon definitions, component patterns, i18n examples, AI-friendly patterns
- [templates.md](references/templates.md) — Large code templates: DocsLayout, SearchDialog, SearchButton, TableOfContents, PrevNextNav
- [page-templates.md](references/page-templates.md) — Section skeletons for 6 page types, content source mapping, style influence matrix
- [style-presets.md](references/style-presets.md) — 8 curated style presets with colors, typography, layout patterns
- [anti-patterns.md](references/anti-patterns.md) — Common mistakes and troubleshooting guide
