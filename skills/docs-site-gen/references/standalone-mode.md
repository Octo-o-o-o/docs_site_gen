# Standalone Mode: Projects Without a Frontend

When a project has **no web frontend** (Frontend Level F3 from Phase 1 Step 1.0), the skill operates in standalone mode. This reference covers frontend detection, output strategy, template selection, color scheme generation, and demo HTML preview.

## When This Mode Applies

- Backend-only projects (API servers, microservices)
- CLI tools and terminal utilities
- Libraries, SDKs, and packages (npm, PyPI, crates, etc.)
- Infrastructure tools (Terraform modules, Docker images, GitHub Actions)
- Data pipelines, ML models, or scripts
- Any project where Step 1.0 glob patterns find no web framework indicators

## Phase 1 Behavior (F3)

Skip Steps 1.1-1.4 entirely. At CP1, report:

```
## Design System Detection Results

**Frontend Level**: F3 — No web frontend detected
**Design System Level**: N/A — No frontend code to analyze

This project has no web frontend. You will choose:
1. An output strategy (how docs are built/hosted)
2. A documentation layout template
3. A color scheme

Proceeding to content discovery...
```

Also present the **Output Strategy** choice at CP1 (see below), since it affects Phase 4 file generation.

## Output Strategy

Ask the user to choose how the docs site will be built:

**Option 1: Scaffold a Next.js docs app** (recommended)
- Create a `docs-site/` directory in the project root
- Initialize minimal Next.js: `package.json`, `next.config.ts`, `app/layout.tsx`, `tailwind.config.ts`, `tsconfig.json`
- Generate docs pages following the normal Phase 4 rules inside `docs-site/app/docs/`
- Supports i18n, search, dark mode, all standard features
- Deploy to Vercel / Netlify / Cloudflare Pages
- Best for: ongoing maintenance, projects that will grow

**Option 2: Generate static HTML**
- Generate self-contained HTML + CSS files in a `docs/` directory (or `_site/`, user's choice)
- No build step — open files directly or deploy to any static host (GitHub Pages, S3, etc.)
- Single CSS file with all styles; one HTML file per page; inline JavaScript for interactions (dark mode toggle, search, copy buttons)
- i18n via separate HTML files per language (e.g., `docs/en/index.html`, `docs/zh/index.html`)
- Best for: simple projects, zero-dependency setups, quick one-time generation

**Option 3: User's preferred framework**
- Ask what framework: Astro, Gatsby, Hugo, VitePress, Docusaurus, MkDocs, etc.
- Adapt generation rules to that framework's conventions (file format, routing, templating)
- Best for: users with existing preferences or toolchain constraints

Present all three options at CP1. Default recommendation is Option 1 for developer-audience projects, Option 2 for ultra-simple projects.

---

## Phase 3 Step 3.1: Template & Color Selection (F3)

### Template Selection

Present these 4 layout templates. Each is derived from the style presets but curated for standalone docs:

---

**Template A: Developer Minimal**
- Inspired by: Vercel Docs, shadcn/ui, Next.js Docs
- Layout: Sidebar navigation (240px) + content area (max 65ch) + right-side TOC
- Typography: Geist / Inter variable, monospace for code (Geist Mono / IBM Plex Mono)
- Characteristics:
  - Monochrome base with single accent color for links/CTAs
  - CMD+K search at top of sidebar
  - Code blocks dominate — docs feel like an extension of the codebase
  - Dark mode as primary experience
  - Clean tables, no heavy borders
  - Previous/Next navigation at page bottom
- Best for: Developer tools, libraries, CLIs, open-source frameworks
- Visual feel: Precise, minimal, modern — lets the content breathe

---

**Template B: Enterprise Structured**
- Inspired by: Stripe Docs, GitHub Docs
- Layout: Three-column — sidebar groups (260px) + content (720px max) + mini-TOC (200px)
- Typography: Refined sans-serif (Inter / system), semibold headings, 16px body
- Characteristics:
  - Card-based sections with subtle shadows
  - Multi-language tabbed code blocks (Python, Node, Go, cURL)
  - Five-tier callout system (Note / Tip / Important / Warning / Caution)
  - Breadcrumb navigation on every sub-page
  - Version badges where applicable
  - Generous whitespace and padding
- Best for: API platforms, B2B SaaS, enterprise tools, multi-product platforms
- Visual feel: Professional, authoritative, information-dense yet scannable

---

**Template C: Bold Modern**
- Inspired by: Supabase Docs, Linear Docs
- Layout: Product-organized sidebar + wide content area with card grids
- Typography: Inter / system sans, `scroll-mt-24` on headings
- Characteristics:
  - Dark-first design with vibrant accent color used sparingly
  - Hero sections with subtle gradients
  - Card grids for overview/landing pages
  - Generous whitespace, clean feel
  - Mobile-first responsive collapse
  - Skeleton loading states for perceived performance
- Best for: Modern SaaS, developer platforms, dark-mode-first products
- Visual feel: Bold, contemporary, startup energy — stands out from traditional docs

---

**Template D: Friendly Guide**
- Inspired by: Notion Help, Anthropic Docs
- Layout: Category-based sidebar + centered content (wide prose width)
- Typography: Warm sans-serif (Inter) or serif body (Georgia/Cambria for Anthropic style)
- Characteristics:
  - Warm background tones (cream, off-white)
  - Illustration-ready with large hero imagery slots
  - FAQ-heavy with collapsible sections
  - Emoji category markers in navigation (optional, user preference)
  - Community links, "What's New" sections
  - Long-form prose optimized for reading comfort
- Best for: Products targeting mixed audiences, consumer tools, educational projects, AI/ML products
- Visual feel: Approachable, warm, like a well-written guidebook

---

### Color Scheme Generation

When no project design system exists, generate **3-4 color schemes** for the user to choose from.

**Generation process**:
1. Read the project's domain from Phase 2B.5 (e.g., "AI agent platform", "CLI build tool", "payment SDK")
2. Read the target audience (developers, operators, business users, consumers)
3. Generate schemes that match the domain's visual expectations while feeling premium
4. Ensure significant visual differences between schemes to aid comparison

**Scheme token requirements** (each scheme defines all of these):

| Token | Purpose | Example |
|-------|---------|---------|
| `background` | Page background (light + dark) | `#F8FAFC` / `#0B0F1A` |
| `surface` | Card/panel backgrounds | `#FFFFFF` / `#1A1D2E` |
| `text-primary` | Main text | `#0F172A` / `#F1F5F9` |
| `text-secondary` | Muted text, descriptions | `#64748B` / `#94A3B8` |
| `accent` | Links, CTAs, active states | `#6366F1` |
| `accent-hover` | Hover state for accent | `#4F46E5` |
| `accent-soft` | Subtle accent backgrounds | `rgba(99,102,241,0.1)` |
| `border` | Dividers, card borders | `#E2E8F0` / `#1E293B` |
| `code-bg` | Code block backgrounds | `#F1F5F9` / `#1E293B` |
| `success` | Positive indicators | `#10B981` |
| `warning` | Warning callouts | `#F59E0B` |
| `danger` | Error/caution indicators | `#EF4444` |

**Quality rules**:
- All schemes must pass **WCAG AA** contrast ratios (4.5:1 for body text, 3:1 for large text)
- Use sophisticated, desaturated tones — avoid oversaturated primary colors
- Accent colors should be distinctive but not overwhelming
- Dark mode variants should feel intentional, not just "inverted light mode"
- Each scheme should evoke a different emotional tone (e.g., warm vs cool, playful vs serious)

**Example schemes for an "AI Agent Management Platform" project**:

**Scheme 1: Midnight Indigo** — Tech-forward, premium
| Token | Light | Dark |
|-------|-------|------|
| background | `#F8FAFC` | `#0B0F1A` |
| surface | `#FFFFFF` | `#151B2B` |
| text-primary | `#0F172A` | `#F1F5F9` |
| text-secondary | `#64748B` | `#94A3B8` |
| accent | `#6366F1` | `#818CF8` |
| border | `#E2E8F0` | `#1E293B` |

**Scheme 2: Terra Warmth** — Research-oriented, humanistic
| Token | Light | Dark |
|-------|-------|------|
| background | `#FFFBF5` | `#1C1917` |
| surface | `#FFFFFF` | `#292524` |
| text-primary | `#1C1917` | `#F5F5F4` |
| text-secondary | `#78716C` | `#A8A29E` |
| accent | `#D97706` | `#FBBF24` |
| border | `#E7E5E4` | `#44403C` |

**Scheme 3: Arctic Clarity** — Clean, precise, modern
| Token | Light | Dark |
|-------|-------|------|
| background | `#FFFFFF` | `#0F172A` |
| surface | `#F8FAFC` | `#1E293B` |
| text-primary | `#0F172A` | `#F8FAFC` |
| text-secondary | `#475569` | `#94A3B8` |
| accent | `#0EA5E9` | `#38BDF8` |
| border | `#E2E8F0` | `#334155` |

**Scheme 4: Forest Protocol** — Growth, reliability, calm
| Token | Light | Dark |
|-------|-------|------|
| background | `#FAFDFB` | `#0A0A0A` |
| surface | `#FFFFFF` | `#171717` |
| text-primary | `#0A0A0A` | `#FAFAFA` |
| text-secondary | `#525252` | `#A3A3A3` |
| accent | `#10B981` | `#34D399` |
| border | `#E5E7EB` | `#262626` |

Present each scheme with its full token table AND a brief tone description so the user can visualize the feel.

---

## Demo HTML Generation (Optional)

When the user requests demo HTML previews:

### What to Generate

1. Generate **1 self-contained HTML file** per template × color combo the user wants to preview
   - If 4 templates × 4 colors = 16 combos, ask the user to pick 3-4 combos to preview (don't generate all 16)
   - Alternatively, generate 4 files (one per template) using the user's top color choice, so they can compare layouts
2. Each HTML file includes:
   - **All CSS inlined** in a `<style>` tag (no external dependencies)
   - **Mock docs structure**: navigation sidebar/header, hero section with project name and pitch (from Phase 2B.5), 2 content sections with headings, a code block, 2-3 feature cards, a callout, and a footer
   - **Dark/light mode toggle** button (JavaScript inlined)
   - **Responsive design** (works on mobile + desktop)
   - Total file size: ~15-25KB each (lightweight, instant load)

### File Placement

Save demo files to a temporary preview directory:
```
{project-root}/_docs-preview/
├── template-a-midnight-indigo.html
├── template-b-midnight-indigo.html
├── template-c-arctic-clarity.html
└── template-d-terra-warmth.html
```

Tell the user:
```
Demo HTML files generated in _docs-preview/:
- template-a-midnight-indigo.html (Developer Minimal + Midnight Indigo)
- template-b-midnight-indigo.html (Enterprise Structured + Midnight Indigo)
- ...

Open any file in your browser to preview. Once you've decided, let me know your choice and I'll continue.
```

### CRITICAL: Pause After Demo Generation

After generating demo HTML, **STOP and wait for the user to respond** with their selection. Do NOT proceed to Step 3.2 until the user confirms which template + color scheme they want.

### Cleanup

After the user confirms their selection and Phase 4 generation is complete, suggest removing the preview directory:
```
The _docs-preview/ directory is no longer needed. You can safely delete it.
```

---

## Phase 4 Adjustments for F3

### Output Strategy: Next.js Scaffold (Option 1)

Generate the following minimal project structure:

```
docs-site/
├── package.json          # Next.js + Tailwind + TypeScript deps
├── next.config.ts        # Minimal config
├── tsconfig.json         # Standard Next.js tsconfig
├── tailwind.config.ts    # Theme from selected color scheme
├── postcss.config.js     # Standard PostCSS for Tailwind
├── public/
│   ├── llms.txt
│   └── llms-full.txt
└── app/
    ├── globals.css       # CSS variables from color scheme + Tailwind base
    ├── layout.tsx        # Root layout with fonts, metadata, theme provider
    └── docs/             # Normal Phase 4 page structure
        ├── layout.tsx    # Docs navigation layout (per template choice)
        ├── page.tsx
        ├── content.tsx
        └── ...
```

- `package.json` should include exact version numbers for `next`, `react`, `tailwindcss`, `typescript`
- `globals.css` maps the selected color scheme tokens to CSS custom properties
- `layout.tsx` includes the selected fonts and basic metadata
- All docs pages follow standard Phase 4 generation rules from `references/generation-rules.md`
- Add a `README.md` inside `docs-site/` with build/deploy instructions

### Output Strategy: Static HTML (Option 2)

Generate self-contained HTML files:

```
docs/
├── index.html            # Overview / landing page
├── getting-started.html  # Getting started
├── features.html         # Features
├── style.css             # Shared stylesheet (color scheme + layout)
├── script.js             # Shared interactions (dark mode, search, copy)
└── assets/               # Any images or icons
```

- Each HTML file includes: `<!DOCTYPE html>`, full `<head>` with meta tags, `<link>` to `style.css`, and `<script src="script.js">`
- `style.css` contains all CSS custom properties from the color scheme, responsive breakpoints, and component styles
- `script.js` handles: dark mode toggle (with `localStorage` persistence), code block copy buttons, search (client-side, optional), smooth scroll to anchors
- Navigation between pages via standard `<a>` tags
- i18n (if needed): duplicate file structure under language subdirectories (`docs/en/`, `docs/zh/`)
- All files should validate as valid HTML5

### Output Strategy: User Framework (Option 3)

Adapt the generation output to the user's chosen framework:
- Ask about the framework's file conventions, routing pattern, and component format
- Map the Phase 4 structure to that framework's equivalent
- Follow the framework's standard project layout
