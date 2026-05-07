# Phase 4: Page Generation Rules

Detailed rules for Phase 4 page generation. Read this file before starting Phase 4. Covers file structure per layout mode, design system application, reusable components, AI-friendly/SEO requirements, evidence-based content writing, i18n key naming, and navigation updates.

Generate pages following the resolved design conventions. Apply these rules:

## Contents

- **4.1 File Structure** — Mode A (one-page), Mode B (header nav), Mode C (sidebar nav); Server/Client split rules
- **4.2 Design System Application** — How Level A/B/C maps to component styling decisions
- **4.3 Code Conventions** — Match existing imports, CSS approach, component patterns
- **4.4 Reusable Components** — Reuse existing → import from existing docs → create new last
- **4.5 AI-Friendly Documentation (REQUIRED)** — SSR, heading IDs, llms.txt, JSON-LD, hreflang, AI crawlers, SEO toggle, static-export awareness
- **4.6 Evidence-Based Content Generation** — Tier-driven word counts, specificity over adjectives, verified code examples
- **4.7 i18n Key Naming Convention** — Match project conventions; one rule per i18n level
- **4.8 Navigation Updates** — Update homepage links + footer + docs internal nav
- **4.9 Visual Diagrams (Server-Safe SVG)** — When to draw, how to match brand, mock data quality, viewBox safety, per-page archetype recommendations

## 4.1 File Structure

The file structure depends on the **navigation layout** chosen in Step 3.3.1. All layouts share the Server/Client split pattern from `references/conventions.md`: `page.tsx` exports `Metadata` (Server Component), `content.tsx` has `"use client"` with interactive content.

### Layout Mode A: One-page + Sticky TOC

All content consolidates into a single docs page. No shared layout file.

```
app/docs/
├── page.tsx          # Server component (metadata + JSON-LD)
├── content.tsx       # Client component (all sections + right-side TOC)
└── sections/         # Split when content.tsx exceeds ~400 lines
    ├── hero.tsx
    ├── features.tsx
    ├── architecture.tsx
    └── getting-started.tsx
```

- **Right-side TOC is mandatory** — one-page always has enough sections to warrant it. Use two-column grid: content (left) + TableOfContents (right). See `references/templates.md`.
- **Smooth scroll**: Add `scroll-behavior: smooth` to the docs container or use `<html>` style.
- **Section anchors**: Each major section acts as a "virtual page" with its own anchor (e.g., `/docs#features`, `/docs#architecture`). Use `SectionHeading` with descriptive IDs.
- **No layout.tsx, no SearchDialog**: Browser's Ctrl+F is sufficient for single-page search.
- **Navigation links from homepage** point to `/docs` (optionally with anchor: `/docs#getting-started`).

### Layout Mode B: Header Navigation

Multiple pages with a horizontal nav bar in a sticky top header.

```
app/docs/
├── layout.tsx        # Header nav layout (see templates.md "Docs Layout Template (Header Nav)")
├── page.tsx          # Overview page (server component)
├── content.tsx       # Overview content (client component)
├── features/
│   ├── page.tsx
│   └── content.tsx
├── architecture/
│   ├── page.tsx
│   └── content.tsx
└── getting-started/
    ├── page.tsx
    └── content.tsx
```

- **`layout.tsx`**: Sticky top bar with horizontal nav links, search button, back-to-home link. See `references/templates.md` "Docs Layout Template (Header Nav)".
- **Nav items**: Flat list of page links — no grouping needed (header space is limited).
- **Mobile**: Hamburger menu → dropdown/sheet with all nav items.
- **CMD+K search**: In the header bar, right side.
- **Right-side TOC**: Optional per page (include when page has 5+ sections).
- **Breadcrumbs**: On sub-pages, below the header bar.
- **PrevNextNav**: At the bottom of each page.

### Layout Mode C: Sidebar Navigation

Multiple pages with a persistent left sidebar showing the full navigation tree.

```
app/docs/
├── layout.tsx        # Sidebar layout (see templates.md "Sidebar Nav Layout")
├── page.tsx          # Overview page
├── content.tsx
├── features/
│   ├── page.tsx
│   └── content.tsx
├── architecture/
│   ├── page.tsx
│   └── content.tsx
└── ...
```

- **`layout.tsx`**: Left sidebar (240-280px) + content area. See `references/templates.md` "Docs Layout Template (Sidebar Nav)".
- **Sidebar content**: Grouped navigation items (from Step 3.3.1 page grouping). Group headings are non-clickable labels; page links are indented below.
- **Active page highlight**: Current page link has accent color + accent-soft background.
- **Mobile**: Hamburger button in a slim top bar → slide-out drawer overlay with the sidebar content.
- **CMD+K search**: At the top of the sidebar.
- **Three-column option**: When a page has 5+ sections, use three-column grid: sidebar (260px) | content | TOC (200px). TOC is hidden on screens < 1280px.
- **Breadcrumbs**: Optional (sidebar already shows location, but include for SEO `BreadcrumbList` JSON-LD).
- **PrevNextNav**: At the bottom of each page.
- **Sticky sidebar**: `position: sticky; top: 0; height: 100vh; overflow-y: auto`.

### Common rules (all layouts)

**Large page split rule**: If a `content.tsx` will exceed ~400 lines, split into section components:
```
sections/
├── hero.tsx          # export function HeroSection()
├── features.tsx      # export function FeaturesSection()
└── how-it-works.tsx  # export function HowItWorksSection()
```
Each section file exports a named component, imported by `content.tsx`. Keep shared sub-components (CodeBlock, SectionHeading, icons) in `content.tsx` or a shared `components.tsx`.

**i18n keys**: Generate in all detected language files (see Phase 2A.3 i18n level).

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

1. **Title format**: Primary keyword near the front. Format: `"{Primary Keyword} — {Project Name}"` (e.g., `"AI Agent Management Platform — AgentPlanet"`, `"Self-Host Guide — AgentPlanet"`). Derive from the keyword map (Step 3.2.1) + Phase 3.4 outline. Keep under 60 characters.
2. **Description**: One sentence answering the user's likely search query. Under 160 characters. Include primary keyword + 1 secondary keyword naturally. No generic filler — each page's description must be unique and compelling enough to click.
3. **OpenGraph**: Include `title`, `description`, `type: "website"`, and `siteName` (project name). If the project has an OG image, include `images` (recommended: 1200×630px).
4. **Twitter card**: Include `card: "summary_large_image"`, `title`, and `description`.
5. **Canonical URL**: Set `alternates.canonical` to the page's path (e.g., `"/docs"`, `"/docs/self-host"`).
6. **Rich snippet robots** (when SEO = Yes): Add `robots` metadata to enable maximum preview in search results:
   ```typescript
   robots: {
     index: true,
     follow: true,
     "max-snippet": -1,           // Allow full-length text snippet
     "max-image-preview": "large", // Allow large image preview
     "max-video-preview": -1,      // Allow full video preview
   }
   ```
7. **`hreflang` for bilingual docs** (when i18n-Multi is detected): Set `alternates.languages` so Google knows about language variants:
   ```typescript
   alternates: {
     canonical: "/docs",
     languages: {
       "en-US": "/en/docs",  // Adjust to project's i18n URL structure
       "zh-CN": "/zh/docs",
     },
   }
   ```
   Adapt URL patterns to match the project's actual i18n routing (path-based `/en/docs`, subdomain-based `en.domain.com/docs`, or query-based `?lang=en`). If the project uses a single URL with client-side locale switching, omit `alternates.languages` and rely on the `<html lang>` attribute instead.

**Keyword placement rules** (when SEO = Yes and keyword map exists from Step 3.2.1):

These rules apply the keyword map to actual page content. All placement must feel natural — never force keywords at the cost of readability.

1. **Title tag**: Primary keyword near the beginning (see rule 1 above).
2. **Meta description**: Primary + 1 secondary keyword, phrased as a compelling answer to the search query.
3. **H1** (hero title): Contains primary keyword. Only ONE `<h1>` per page.
4. **H2 headings**: Each major section heading should incorporate a secondary keyword or feature name where natural (e.g., "Key Features" → "Core Features for AI Agent Management").
5. **First 100 words**: Include the primary keyword naturally in the opening paragraph ("What is [Project]?" section).
6. **URL slug**: Short, lowercase, keyword-containing (e.g., `/docs/getting-started` not `/docs/initial-setup-and-configuration-guide-for-new-users`).
7. **Image alt text**: When docs include screenshots or diagrams, write descriptive alt text that includes relevant keywords (e.g., `alt="AgentPlanet architecture diagram showing MCP protocol flow"` not `alt="diagram"`).
8. **Internal link anchor text**: Use descriptive text containing the target page's primary keyword (e.g., `<Link href="/docs/architecture">system architecture and protocol design</Link>` not `<Link href="/docs/architecture">click here</Link>`).

**Favicon and site-level metadata** — check the project's root `layout.tsx` (or `app/layout.tsx`):
- If favicon/icons are already configured → do NOT modify
- If missing → note in CP3 output as a recommendation (do not auto-generate favicons, as they require design assets)
- Verify `<link rel="llms-txt">` tag exists (from step C above)

**E. Search Engine Discoverability (conditional on SEO toggle from Step 3.2)**

The SEO toggle controls whether docs pages are actively made discoverable by Google and other search engines. This affects sitemap, robots, and metadata behavior.

**If SEO = Yes (default)**:

1. **`app/sitemap.ts`** — Generate or update the dynamic sitemap to include all docs pages:
   ```typescript
   // app/sitemap.ts
   import type { MetadataRoute } from "next";

   export default function sitemap(): MetadataRoute.Sitemap {
     const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://your-domain.com";

     // ... existing sitemap entries ...

     const docsPages = [
       { url: `${baseUrl}/docs`, lastModified: new Date(), changeFrequency: "weekly" as const, priority: 0.8 },
       // Add one entry per generated docs page:
       // { url: `${baseUrl}/docs/features`, lastModified: new Date(), changeFrequency: "weekly" as const, priority: 0.7 },
       // { url: `${baseUrl}/docs/architecture`, lastModified: new Date(), changeFrequency: "monthly" as const, priority: 0.6 },
     ];

     return [...existingEntries, ...docsPages];
   }
   ```
   - If `app/sitemap.ts` already exists: **append** docs entries (use Edit tool, do NOT overwrite)
   - If no sitemap exists: create `app/sitemap.ts` with docs entries
   - Priority: `/docs` overview = 0.8, sub-pages = 0.6-0.7
   - `changeFrequency`: "weekly" for overview, "monthly" for architecture/API reference

2. **`app/robots.ts`** — Ensure robots.txt allows crawling `/docs` for both search engines and AI crawlers:
   ```typescript
   // app/robots.ts
   import type { MetadataRoute } from "next";

   export default function robots(): MetadataRoute.Robots {
     const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://your-domain.com";
     return {
       rules: [
         { userAgent: "*", allow: "/" },
         // Explicitly allow AI crawlers to index documentation
         { userAgent: "GPTBot", allow: "/docs" },
         { userAgent: "ChatGPT-User", allow: "/docs" },
         { userAgent: "Claude-Web", allow: "/docs" },
         { userAgent: "Amazonbot", allow: "/docs" },
         { userAgent: "CCBot", allow: "/docs" },
       ],
       sitemap: `${baseUrl}/sitemap.xml`,
     };
   }
   ```
   - If `app/robots.ts` already exists: verify `/docs` is not in a `disallow` list. If it is, remove it. Append AI crawler rules if missing.
   - If no robots file exists: create `app/robots.ts` with the above template.
   - If a static `public/robots.txt` exists instead: check it allows `/docs`, add `Sitemap:` directive and AI crawler rules if missing.

3. **Page metadata**: Use enhanced metadata as defined in section 4.5D above (includes rich snippet robots and hreflang when applicable).

**Static export awareness** (when project uses `output: 'export'` in `next.config.*`):

If the project has Next.js static export enabled, all `app/sitemap.ts`, `app/robots.ts`, JSON-LD blocks and `Metadata` exports still work — they are pre-rendered to static files at build time (`out/sitemap.xml`, `out/robots.txt`). However:

- **`app/sitemap.ts` and `app/robots.ts` MUST opt into static rendering** with `export const dynamic = 'force-static'` at the top of the file. Without it, `next dev` returns a 500 error and the build fails with: `"export const dynamic = \"force-static\" / export const revalidate not configured on route \"/robots.txt\" with \"output: export\""`. Apply the same to `app/manifest.ts` if generated.
- Do NOT use `revalidate`, dynamic-fetch behaviour, or `headers()`/`cookies()` server functions (unsupported in export mode)
- Dynamic route segments require `generateStaticParams()` returning all paths at build time
- Skip route handlers (`route.ts`) and middleware — they are not emitted in export mode
- `<Image>` from `next/image` requires `images.unoptimized: true` (already typical for export builds)
- After build, verify the docs pages exist as `out/docs/index.html`, `out/docs/<sub>/index.html`, etc. — if `trailingSlash: true` is set in `next.config`, sub-routes appear as directories with `index.html`

If `output: 'export'` is NOT set, no special handling needed.

**If SEO = No**:

1. **Skip sitemap generation** — Do NOT add docs pages to `app/sitemap.ts`.
2. **Skip robots.txt changes** — Do NOT modify `app/robots.ts` or `public/robots.txt`.
3. **Add noindex to each page's Metadata**:
   ```typescript
   export const metadata: Metadata = {
     title: "Documentation — ProjectName",
     description: "...",
     robots: { index: false, follow: false },
     // ... rest of metadata (OG, Twitter, canonical still included for link previews)
   };
   ```
   This tells Google not to index these pages while still allowing rich link previews when shared directly.

**F. JSON-LD Structured Data (per page)**

Add Schema.org structured data to each `page.tsx` for search engine rich results. This completes the discoverability stack (llms.txt for AI tools, JSON-LD for search engines).

**SEO conditionality**:
- **Basic JSON-LD** (`TechArticle` or `HowTo` as primary schema) — always generate, regardless of SEO toggle. Supports AI readability and basic search presence.
- **Rich additional schemas** (`BreadcrumbList`, `FAQPage`, `SoftwareApplication`) — only generate when **SEO = Yes**. These enable search engine rich snippets that have no value when pages are noindexed.

**Base rules**:
1. Render `<script type="application/ld+json">` tag(s) in each `page.tsx` (Server Component) alongside `<PageContent />`
2. `headline` and `description` must match the page's `Metadata` export values
3. `author.name` should be the project name or organization (from Phase 2B.5)
4. Only include fields with known, factual values — do not fabricate URLs or dates
5. A page can have **multiple** JSON-LD blocks (e.g., TechArticle + BreadcrumbList)

**Schema type selection per page**:

| Page Type | Primary Schema | Additional Schemas |
|-----------|---------------|-------------------|
| Overview / Landing (`/docs`) | `TechArticle` | `SoftwareApplication` + `BreadcrumbList` |
| Features | `TechArticle` | `BreadcrumbList` |
| Architecture | `TechArticle` | `BreadcrumbList` |
| Getting Started | `HowTo` (with `HowToStep` items) | `BreadcrumbList` |
| API Reference | `TechArticle` | `BreadcrumbList` |
| Configuration | `TechArticle` | `BreadcrumbList` |
| FAQ (or any page with FaqItem components) | `FAQPage` | `BreadcrumbList` |

**Schema templates**:

a. **`BreadcrumbList`** — REQUIRED for every sub-page in multi-page docs. Generates rich breadcrumb trails in Google results:
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://domain.com" },
    { "@type": "ListItem", "position": 2, "name": "Documentation", "item": "https://domain.com/docs" },
    { "@type": "ListItem", "position": 3, "name": "Architecture", "item": "https://domain.com/docs/architecture" }
  ]
}
```

b. **`FAQPage`** — When a page contains FaqItem/collapsible Q&A components. Enables rich FAQ snippets in Google search (expandable answers directly in results):
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How do I deploy ProjectName?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You can deploy ProjectName using Docker..."
      }
    }
  ]
}
```
Extract Q&A pairs from the i18n content used by FaqItem components. `text` values must match the actual rendered answer text.

c. **`SoftwareApplication`** — For the main docs overview page (`/docs`) only. Enables rich product info in search results:
```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "ProjectName",
  "description": "One-line pitch from Phase 2B.5",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Cross-platform",
  "url": "https://domain.com",
  "author": { "@type": "Organization", "name": "OrgName" },
  "license": "https://opensource.org/licenses/MIT"
}
```
Only include `offers` if pricing is verified. Only include `license` if detected in `package.json` or `LICENSE` file.

d. **`HowTo`** — For Getting Started / tutorial pages. Use proper `HowToStep` items instead of generic text:
```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "Getting Started with ProjectName",
  "description": "...",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Install dependencies",
      "text": "Run npm install project-name to install..."
    },
    {
      "@type": "HowToStep",
      "name": "Configure environment",
      "text": "Copy .env.example to .env and set..."
    }
  ]
}
```
Extract steps from the actual Getting Started content. Each step's `text` must match the rendered content.

**JSON-LD helper component pattern (recommended)**:

When generating 3+ docs pages, do NOT inline raw `<script type="application/ld+json">` blocks in every `page.tsx` — that's repetitive, hard to keep in sync, and error-prone for the BASE_URL constant. Instead create a small server-safe helper file under `app/docs/_components/JsonLd.tsx` (or equivalent path) that exports one component per schema type:

```tsx
// app/docs/_components/JsonLd.tsx — server-safe, no "use client"
const BASE_URL = 'https://your-domain.com'

export function BreadcrumbsJsonLd({ items }: { items: { name: string; href: string }[] }) {
  const data = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, idx) => ({
      '@type': 'ListItem', position: idx + 1, name: item.name, item: `${BASE_URL}${item.href}`,
    })),
  }
  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }} />
}

export function TechArticleJsonLd({ headline, description, path }: { headline: string; description: string; path: string }) {
  const data = {
    '@context': 'https://schema.org',
    '@type': 'TechArticle',
    headline, description,
    url: `${BASE_URL}${path}`,
    inLanguage: 'zh-CN', // adapt to project's primary locale; for i18n-Multi, omit and let metadata.alternates.languages cover it
    isPartOf: { '@type': 'WebSite', name: 'ProjectName', url: BASE_URL },
    publisher: { '@type': 'Organization', name: 'OrgName', url: BASE_URL },
  }
  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }} />
}
// Add SoftwareApplicationJsonLd / FAQPageJsonLd / HowToJsonLd as needed.
```

Each `page.tsx` then composes the schemas it needs:

```tsx
export default function ArchitecturePage() {
  return (
    <>
      <BreadcrumbsJsonLd items={[
        { name: '首页', href: '/' },
        { name: '技术文档', href: '/docs' },
        { name: '系统架构', href: '/docs/architecture' },
      ]} />
      <TechArticleJsonLd headline="..." description="..." path="/docs/architecture" />
      <ArchitectureContent />
    </>
  )
}
```

This keeps the BASE_URL in one place, makes `page.tsx` files declarative, and lets you add new schemas (e.g., `FAQPageJsonLd`) by extending the helper rather than editing every page.

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
- **i18n-None**: Use inline text directly in JSX. Skip all i18n key generation. **Match the project's content language** — if existing pages use Chinese (or any non-English language) in their inline strings, all generated section titles, body copy, button labels, callouts, and JSX text MUST be in that same language. Do not silently fall back to English. Detect the language by sampling 2-3 existing page files for their dominant text language.

## 4.8 Navigation Updates

After generating pages, update navigation:
1. Find the homepage file (e.g., `page.tsx`) — locate the `DOCS_URL` constant or equivalent
2. Update docs link from `/docs/self-host` (or current) to `/docs` (new landing page)
3. Update footer docs links similarly
4. If a docs layout with nav was created, ensure all sub-pages are listed

## 4.9 Visual Diagrams (Server-Safe Inline SVG)

Long stretches of prose, multi-component architectures, and multi-step flows benefit from visual diagrams. Generate them as **inline server-safe React SVG components** — not external images, not Mermaid (which requires client JS), not screenshots (which become stale). See `references/templates.md` → "Diagram Templates" for 5 ready-to-adapt archetypes.

### 4.9.1 When to Generate a Diagram

Add a diagram to a section when ANY of:

- The section is **3+ paragraphs of dense prose** with no other visual element (table, card grid, code block)
- The content describes a **multi-component system** (≥3 components with relationships) — show layout, not list
- The content describes a **flow with ≥3 steps** — show as horizontal/vertical timeline, not numbered paragraphs alone
- The content describes a **branching decision** (e.g., dual-engine routing) — show both paths in parallel
- The content lists **≥4 integration partners / sources** — show as hub-and-spoke panorama
- The content is a **time-series record** (audit log, event log) — show as timeline with mock event chips

Skip diagrams when the section already has a card grid, comparison table, or code block carrying the structural load — adding another visual creates noise.

### 4.9.2 Visual Style — Match the Project

Before drawing a single SVG, **read 2-3 existing illustrations** in the project's homepage / marketing pages (e.g., feature vignettes, product screenshots-as-SVG). Extract:

- **Palette**: primary brand color, secondary accent, faint stroke, card background. Use the same hex values — don't pick fresh colors. Check `tailwind.config.*` and `src/styles/tokens.css` first; fall back to reading rendered illustrations.
- **Stroke weight**: 1.4 / 1.6 / 2 — pick one and stick to it across all diagrams in this round
- **Card backdrop**: cream / white / tinted — match the homepage card fill
- **Stroke style for connectors**: solid / dashed / dotted — match existing flow lines
- **Typography**: same `font-family` (often `var(--font-sans)` and `var(--font-mono)`)
- **Border radius**: 6 / 10 / 14 — match the homepage card radius

If the project has 0 illustrations (greenfield), use the style preset's palette (`references/style-presets.md`).

### 4.9.3 Component Pattern

Centralize all diagrams in **one file**: `app/docs/_components/Diagrams.tsx` (or framework-equivalent). Each archetype is a **named export** that takes optional `className`:

```tsx
// app/docs/_components/Diagrams.tsx — server-safe, NO "use client"

const BRAND_PRIMARY = '#2A4032'  // from tailwind.config.ts
const BRAND_SECONDARY = '#5D7052'
const BRAND_TERTIARY = '#8A9B85'
const CARD_BG = '#FDFCF8'
const STROKE_FAINT = 'rgba(42,64,50,0.18)'

interface DiagramProps { className?: string }

export function HorizontalStepFlow({ className = '' }: DiagramProps) {
  const steps = [
    { num: '01', title: '试用申请', sub: '提交企业信息' },
    // ... rest of mock data
  ]
  return (
    <div className={`card !p-6 md:!p-8 overflow-hidden ${className}`}>
      <svg viewBox="0 0 720 200" className="w-full h-auto" role="img" aria-label="部署 5 步流程示意图">
        {/* connectors + step nodes + labels */}
      </svg>
    </div>
  )
}
```

**Why server-safe:** static export (`output: 'export'`) and Next.js streaming SSR both work cleanly when the SVG renders during server pass. Avoid `useState`/`useEffect`; avoid framer-motion; avoid `client-only` libraries — they break SSR or pull in client bundles needlessly.

**Why centralized:** brand color constants live in one place; if the project's tokens shift, you update once. Every consumer page does `import { Foo } from '../_components/Diagrams'`.

### 4.9.4 Mandatory Accessibility

Every `<svg>` MUST have:

- `role="img"` — tells AT it's a graphic, not an icon group
- `aria-label="<concrete description>"` — used by screen readers AND by AI tools (Claude / Perplexity / GPT) when summarizing the page

Bad: `aria-label="diagram"`. Good: `aria-label="千手三层加密架构示意图"` (specific, project-named).

Page-level test: every diagram on the page must produce a unique `aria-label`. Two diagrams with the same label is a bug.

### 4.9.5 Mock Data Quality (CRITICAL)

The whole point of "with mock data" is that the diagram looks like a screenshot of real product output. **Never** use placeholder lorem ipsum, "Item 1 / Item 2 / Item 3", or empty boxes.

**Use realistic, project-specific mock values:**

| Visualization Type | Bad mock | Good mock |
|---|---|---|
| Audit timeline | "Event A / Event B / Event C" | `AI_CALL` `EMAIL_SEND` `BASH_EXEC` `MCP_CALL` `FILE_EDIT` |
| Timestamp axis | "T1 / T2 / T3" | `14:02:11 / 14:03:47 / 14:05:09` (monotonic, realistic gaps) |
| Actor field | "user1 / user2" | `agent.assistant`, `agent.coder`, `github.search`, `user` |
| API endpoint chip | "/api/x" | `/api/ai/execute`, `/api/audit/logs` |
| Engine / model name | "Engine A / Engine B" | `DirectEngine` / `ProxyEngine` (real engine names from Phase 2B.3) |
| Provider list | "Provider 1, 2, 3" | `OpenAI · 火山 · 阿里云` (real providers from `tech stack` table) |
| Step labels | "Step 1, Step 2" | `01 试用申请 → 02 客户端安装 → 03 服务端连接` (action verbs from getting-started page) |
| Token / id | "abc123" | `token #1024`, `agent.coder` |

**Sources for realistic mock:** Phase 2B.3 evidence collection (capabilities, code paths), Phase 2B.6 config inventory (env vars), Phase 2B.7 verified code examples (real test data shapes). Do NOT invent — pull from material you've already mined.

### 4.9.6 ViewBox Sizing — Avoid Label Clipping

Common bug: labels at the extreme top/bottom/left/right of a circular or radial layout get clipped because the SVG `viewBox` doesn't account for the label box's full extent. Always:

1. Compute the **outermost label coordinate** (e.g., for a hub-and-spoke at angles `[-150,-90,-30,30,90,150]` with `r=130` and `labelOffset=60`, the topmost label is at `cy - (r + labelOffset)`).
2. Verify the outermost label's bounding box (including its own height/width) stays inside `viewBox` by **at least 8px on every side**.
3. If a label hangs off, fix by either: (a) increasing viewBox dimensions, (b) moving `cy/cx` to recenter, (c) reducing `r`, OR (d) reducing label offset — in that order of preference.

Test: open the rendered diagram at desktop viewport, take a screenshot, and verify every label is fully visible. If you can't take a screenshot, mentally trace each label's bounding box vs. viewBox.

### 4.9.7 Per-Page Recommendations & Cap

For per-page archetype recommendations, see `references/page-templates.md` → "Recommended diagram per page type" table. **Cap: 1–2 diagrams per page max.** More creates noise; if a page seems to need 3+, the page is doing too many things — split it.

### 4.9.8 Validation

After generating diagrams, verify (Phase 5.2 already covers this):

- [ ] Every diagram has `role="img"` + unique `aria-label`
- [ ] Every diagram renders during SSR (no white-on-load — check by `curl <page> | grep -c '<svg'`)
- [ ] All labels visible at desktop viewport (no clipping)
- [ ] No `lorem` / `placeholder` / `Foo Bar` mock values
- [ ] Brand colors match existing project palette (no fresh hex values)
- [ ] Centralized in `_components/Diagrams.tsx` (or equivalent), not scattered inline
