# Phase 4: Page Generation Rules

Generate pages following the resolved design conventions. Apply these rules:

## 4.1 File Structure

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

## 4.2 Design System Application

Apply the resolved design system from Phase 1 and Phase 3:

- **Level A**: Use project's CSS variables and component classes directly
- **Level B**: Use detected conventions, fill gaps with style preset tokens
- **Level C**: Map style preset tokens to CSS variables in the page's styles

When the style preset specifies colors but the project has its own:
- Use PROJECT colors for all visual elements
- Use PRESET patterns for layout structure and content organization only

## 4.3 Code Conventions

Match the existing codebase style. Key things to detect and follow:
- **"use client"** directive usage (only in content.tsx, not page.tsx)
- **Import style** (named vs default, path aliases like `@/`)
- **Component pattern** (function components, inline icons)
- **CSS approach** (CSS variables via `style={{}}`, Tailwind classes, or both)
- **i18n usage** (`const { t } = useTranslation()` or equivalent)

Refer to `references/conventions.md` for detailed patterns including all required icon definitions.

## 4.4 Reusable Components

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

## 4.5 AI-Friendly Documentation (REQUIRED)

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

**E. JSON-LD Structured Data (per page)**

Add Schema.org structured data to each `page.tsx` for search engine rich results. This completes the discoverability stack (llms.txt for AI tools, JSON-LD for search engines). See `references/conventions.md` for the code template.

1. Render a `<script type="application/ld+json">` tag in each `page.tsx` (Server Component) alongside `<PageContent />`
2. Use `TechArticle` for reference/architecture docs, `HowTo` for getting-started/tutorial pages
3. `headline` and `description` must match the page's `Metadata` export values
4. `author.name` should be the project name or organization (from Phase 2B.5)
5. Only include fields with known, factual values — do not fabricate URLs or dates

## 4.6 Evidence-Based Content Generation

**This is the core content generation step.** Use the approved Content Outline from CP2 as a strict blueprint. Do NOT deviate from it without reason.

### 4.6.1 Content Writing Rules

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

5. **Prefer verified code examples**: When Quick Start or code example sections need code snippets, check Phase 2B.7's extracted examples first. If a real, working example exists for that feature, use it (with attribution comment `// from tests/auth.test.ts:47`) instead of writing a new example from scratch. Synthesized examples may contain errors; test-extracted examples are proven to work.

6. **Content per section word count guidance** (for "Technical introduction" depth ~1500 words):
   - Hero (title + subtitle): ~30 words
   - "What is [Project]?": ~150-200 words (3 paragraphs)
   - Core Concepts: ~200 words (4-5 cards × 40-50 words each)
   - Key Features: ~400-500 words (6-8 cards, Tier-based word counts)
   - How It Works: ~120 words (3 steps × 40 words)
   - Tech Stack: table (no prose needed)
   - Quick Start: ~80 words
   - CTA: ~30 words

   Adjust proportionally for "Product overview" (~800 words) or "Comprehensive guide" (~2500 words).

### 4.6.2 Content Quality Checklist

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

## 4.7 i18n Key Naming Convention

**IMPORTANT**: First detect the existing key structure in the project's i18n files. Do NOT impose a new namespace if the project already uses a different pattern.

Adapt to the i18n level detected in Phase 2A.3:
- **i18n-Multi**: Generate keys in ALL language files simultaneously. See `references/conventions.md` for i18n examples.
- **i18n-Single**: Generate keys in the single language file only.
- **i18n-None**: Use inline text directly in JSX. Skip all i18n key generation.

## 4.8 Navigation Updates

After generating pages, update navigation:
1. Find the homepage file (e.g., `page.tsx`) — locate the `DOCS_URL` constant or equivalent
2. Update docs link from `/docs/self-host` (or current) to `/docs` (new landing page)
3. Update footer docs links similarly
4. If a docs layout with nav was created, ensure all sub-pages are listed
