# Documentation Page Templates

Skeleton outlines for common documentation page types. Use these as starting points, then fill in project-specific content from codebase analysis.

## 1. Overview / Landing Page (`/docs`)

The docs entry point. Should give visitors a complete understanding of the project in one page.

### Section Structure

```
1. Hero
   - Badge: "DOCUMENTATION" / "文档"
   - Title: Project name + one-line description
   - Subtitle: 1-2 sentence value proposition

2. What is [Project]?
   - Problem statement (what pain does it solve?)
   - Solution overview (how does it solve it?)
   - Key differentiator (why this over alternatives?)
   - Optional: architecture diagram (ASCII or visual)

3. Core Concepts
   - 3-5 concept cards explaining fundamental ideas
   - Example: "Agent Registry", "MCP Protocol", "Audit Trail"
   - Each card: icon + title + 2-3 sentence description

4. Key Features (grid)
   - 6-8 feature cards linking to detail sections or pages
   - Each card: icon + title + one-line description
   - Use FeatureCard component pattern

5. How It Works
   - 3-5 step flow showing user journey
   - Use StepCard component pattern
   - "Register Agent → Set Permissions → Monitor & Audit"

6. Tech Stack / Architecture
   - Brief overview of the technical architecture
   - Table format: Layer | Technology
   - Link to full architecture page if available

7. Quick Start
   - 3 steps max to get started
   - Code blocks with copy buttons
   - Link to full getting-started or self-host page

8. Documentation Navigation
   - Grid of links to all docs sub-pages
   - Icon + title + brief description for each

9. CTA
   - "Get Started" / "Star on GitHub" / "Try Cloud Version"
   - Two buttons: primary action + secondary action

10. Footer
    - Copyright, version info, last updated
```

### Content Sources — Deep Extraction Guide

For each section, where to get accurate content AND how to extract it:

| Section | Primary Source | How to Extract | Verification |
|---------|---------------|----------------|--------------|
| Hero | `CLAUDE.md` overview + Phase 2B.5 pitch | Extract the one-line value proposition. Keep under 30 words. | Must match project's actual scope |
| What is [Project]? | `CLAUDE.md` + Phase 2B.5 identity | Write 3 paragraphs: problem → solution → differentiator. Every claim must be from Phase 2B.4 verified list. | Grep each capability claim |
| Core Concepts | Domain models + Phase 2B.3 evidence | Each concept maps to a real entity in the codebase (model, protocol, or architectural pattern). Name = model/class name. Description = what it does from reading the source. | Each concept must have a corresponding file:line reference |
| Key Features | Phase 2B.2 Tier 1 + Tier 2 features | Use the verified capabilities from Phase 2B.3. Tier 1: 150-250 words with mechanism detail. Tier 2: 50-100 words with one concrete detail. | Cross-reference against Phase 2B.4 claim verification table |
| How It Works | Router endpoints + service orchestration | Trace the actual user journey through the code: what API calls happen, what state changes occur. Steps should map to real operations. | Each step should reference an actual endpoint or service function |
| Tech Stack | `CLAUDE.md` tech stack table + `package.json` / `pyproject.toml` | Direct transcription — this section is factual. Verify versions match actual dependencies. | Check package.json versions match |
| Quick Start | Existing deploy guide + `docker-compose.yml` | Extract the minimal steps from the deploy guide. Commands must be copy-pasteable and correct. | Verify commands work by reading deploy scripts |

## 2. Features Page (`/docs/features`)

### Section Structure

```
1. Hero
   - Badge: "FEATURES" / "功能特性"
   - Title: "Everything you need to [goal]"

2. Feature Sections (repeat for each Tier 1 feature from Phase 2B.2)
   - Title + description (150-250 words)
   - Key capabilities (bullet points — from Phase 2B.3 verified list)
   - Technical detail: protocol, data flow, or architecture note
   - Code example or API usage snippet (from actual endpoints)
   - "Learn more" link to API docs

3. Feature Grid (for Tier 2 features)
   - Card layout: icon + title + 50-100 word description
   - Grouped by category if >6 features

4. Comparison Table (optional)
   - Feature matrix: this project vs alternatives
   - Use ✓ / ✗ or similar indicators

5. Roadmap Preview (optional — for features that failed Phase 2B.4 verification but are planned)
   - Clearly labeled as "Coming Soon" or "Planned"
   - Link to GitHub issues/milestones

6. CTA
```

### Feature Discovery

Features are sourced from the **Phase 2B Feature Inventory** (see SKILL.md). The inventory table is the PRIMARY source for this page — each row maps to a feature section or card.

## 3. Architecture Page (`/docs/architecture`)

### Section Structure

```
1. Hero
   - Badge: "ARCHITECTURE" / "技术架构"

2. System Overview
   - High-level diagram (ASCII art in code block)
   - Component descriptions

3. Tech Stack Details
   - Table: Layer | Technology | Purpose
   - Why each technology was chosen

4. Protocol Layer (if applicable)
   - MCP, A2A, or other protocols
   - How they integrate
   - Data flow diagrams

5. Security Model
   - Authentication & authorization
   - Multi-tenancy / isolation
   - Data encryption

6. Infrastructure
   - Deployment architecture
   - Scaling considerations
   - Monitoring & observability
```

## 4. Getting Started Page (`/docs/getting-started`)

### Section Structure

```
1. Hero
   - Badge: "GETTING STARTED" / "快速开始"

2. Choose Your Path
   - Cloud version (link to login/register)
   - Self-hosted (link to self-host page)

3. First Steps (for cloud version)
   - Step 1: Create account
   - Step 2: Register your first agent
   - Step 3: Set permissions
   - Step 4: Start monitoring

4. Key Concepts Quick Reference
   - Brief explanations of terms users will encounter
   - Links to detailed docs

5. Next Steps
   - Links to feature-specific guides
   - Community / support links
```

## 5. API Reference Page (`/docs/api`)

### Section Structure

```
1. Hero
   - Badge: "API REFERENCE" / "API 参考"

2. Authentication
   - How to get API tokens
   - Header format

3. Endpoints by Category
   - For each router:
     - Section title
     - Table: Method | Path | Description
     - Example request/response in CodeBlock

4. Error Handling
   - Common error codes
   - Error response format

5. Rate Limiting (if applicable)

6. Link to interactive API docs (FastAPI /docs)
```

### API Discovery Method

Read API router files to extract:
1. Route decorators (`@router.get("/path")`, `@router.post("/path")`)
2. Path parameters and query parameters
3. Request/response schemas (Pydantic models)
4. Docstrings for descriptions

## Style Preset Influence on Templates

Each style preset (from `references/style-presets.md`) modifies templates differently:

| Preset | Layout Impact | Content Pattern Impact |
|--------|--------------|----------------------|
| **Stripe Premium** | Add right-side TOC, tabbed code blocks | Multi-language code tabs, parameter tables |
| **Vercel Monochrome** | Previous/Next links, CMD+K search | Minimal color usage, code-dominant |
| **Tailwind Utility** | Numbered steps grid (01, 02, 03) | Tab system for methods, monospace labels |
| **GitHub System** | Three-column, breadcrumbs | Five-tier callouts (Note/Tip/Important/Warning/Caution) |
| **Supabase Bold** | Card grids for landing, skeleton loaders | Migration guides, icon panels |
| **Linear Minimal** | No right TOC, generous whitespace | ImageCard navigation, minimal callouts |
| **Anthropic Warm** | Paper-like reading layout | Long-form prose, warm inline code |
| **Notion Friendly** | Emoji category markers, hero images | FAQ-heavy, community links, illustrations |

## Content Generation Guidelines

Content quality rules (evidence-based writing, specificity, tier-based depth) are defined in SKILL.md Phase 4.6. This section provides **page-type-specific** generation guidance.

### Page-Specific Notes

**Overview page** (`/docs`): The most important page. Content flows from the Phase 3.4 Content Outline (see SKILL.md). The Section Structure above defines the skeleton; the Content Sources table defines where each section's data comes from. Section-by-section generation details are in SKILL.md Step 3.4.

**Features page**: One section per Tier 1 feature with 150-250 word descriptions + bullet list of verified capabilities + API endpoint examples. Tier 2 features go in a card grid (50-100 words each).

**Architecture page**: System diagram (ASCII art in CodeBlock), component responsibilities mapped to actual services, data flow tracing a real request (router → service → model → response), protocol explanations from actual code.

---

## General Tips for All Pages

1. **Every section needs an i18n key**: Even "small" text like badges and notes.
2. **Consistency across pages**: If one page uses `mb-12` between sections, all pages should.
3. **Link between pages**: Use `Link` from `next/link` for internal links.
4. **Structural components**: For multi-page docs, include Breadcrumbs (top of sub-pages), PrevNextNav (bottom of each page), and TableOfContents (right-side, for pages with 5+ sections). Use Callout for important notes/warnings. See SKILL.md Phase 4.4 for conditions and `references/conventions.md` / `references/templates.md` for component code.
