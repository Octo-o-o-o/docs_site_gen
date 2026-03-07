# docs-site-gen

[English](README.md) | [中文](README.zh-CN.md)

A Claude Code skill that generates production-quality documentation websites by reading your actual source code — not paraphrasing your README.

You've shipped the product. Now ship the docs in minutes, not days.

## The Problem

You built your project with Claude Code or Codex in record time. But the docs site? That's still a manual grind — writing copy, designing layouts, keeping content in sync with code, supporting i18n, making it AI-readable. It's the unglamorous last mile that eats hours.

## What This Skill Does

`docs-site-gen` is a [Claude Code Skill](https://docs.anthropic.com/en/docs/claude-code/skills) that generates and maintains full documentation websites integrated into your existing web app. It works in 5 phases:

1. **Design System Detection** — Reads your `globals.css`, Tailwind config, and existing pages to match your project's visual identity. No generic templates that look out of place.
2. **Deep Content Mining** — Reads your routers, models, and services to build a verified feature inventory. Every claim in the docs traces back to real code.
3. **Content Planning (with your approval)** — Produces a detailed content outline mapping each section to its source file. You review and approve before any code is generated.
4. **Page Generation** — Outputs Next.js page components with full i18n, SEO metadata, section anchors, and `llms.txt` for AI readability.
5. **Validation** — Two-pass completeness audit + `tsc` + lint + i18n key consistency checks.

### Key Features

- **Evidence-based content**: Reads actual source code (routers, models, services) — not CLAUDE.md/README summaries. Feature descriptions include real mechanisms (protocols, data flows, API endpoints), not marketing adjectives.
- **8 curated style presets**: Inspired by Stripe, Vercel, Tailwind, GitHub, Supabase, Linear, Anthropic, and Notion docs. Or auto-detects your project's existing design system.
- **AI-friendly by default**: SSR-rendered content accessible via `curl`. Section anchors on all headings. Auto-generated `llms.txt` and `llms-full.txt` so other AI tools can read your docs.
- **Bilingual i18n**: Generates both `en-US` and `zh-CN` (or adapts to your project's language setup). Every string goes through i18n — no hardcoded text.
- **Incremental updates**: When your code changes, update the docs surgically with the Edit tool instead of regenerating everything. Preserves your custom content.
- **Full SEO metadata**: Title, description, OpenGraph, Twitter cards, canonical URLs — generated per page from project context.
- **Structural components**: On-page Table of Contents, Breadcrumbs, Prev/Next navigation, Callout/Admonition blocks — included automatically based on page structure.
- **3 user checkpoints**: You approve the design direction (CP1), content outline (CP2), and final output (CP3). Nothing ships without your sign-off.

## Requirements

- **Claude Code** (or any environment that supports Claude Code Skills)
- A web frontend project (Next.js App Router recommended)
- Node.js + pnpm/npm for validation commands

## Installation

### Option A: Claude Code CLI

```bash
claude skill install /path/to/docs-site-gen
```

### Option B: Manual

Copy the `SKILL.md` and `references/` directory into your Claude Code skills directory:

```bash
# Clone the repo
git clone https://github.com/Octo-o-o-o/docs_site_gen.git

# Copy to your Claude Code skills directory
mkdir -p ~/.claude/skills/docs-site-gen
cp docs_site_gen/SKILL.md ~/.claude/skills/docs-site-gen/
cp -r docs_site_gen/references ~/.claude/skills/docs-site-gen/
```

## Usage

Once installed, the skill triggers automatically when you say things like:

```
"Generate a docs site for this project"
"Create a /docs page"
"Update the docs to reflect recent changes"
"Add a features page to the documentation"
```

### Typical Workflow

```
You: "Generate a docs site for this project"

Claude Code:
  → Phase 1: Detects your design system (Tailwind + CSS variables, dark mode support)
  → Phase 2: Reads 12 API routers, 8 models, 5 services — builds feature inventory
  → CP1: "I found these design conventions and features. Which style preset do you prefer?"
  → Phase 3: Produces content outline with sources
  → CP2: "Here's the planned content. Each feature maps to verified code. Approve?"
  → Phase 4: Generates page.tsx + content.tsx + i18n keys + llms.txt
  → Phase 5: Runs tsc, lint, i18n check, completeness audit
  → CP3: "Done. Here's what was generated. Run `pnpm build` to verify."
```

### Updating Existing Docs

```
"I added push notifications — update the docs"
```

The skill enters **Incremental Update Mode**: scans the new code, detects what changed, produces a targeted update plan, then uses surgical edits to update only the affected sections. Your custom content is preserved.

## File Structure

```
docs-site-gen/
├── SKILL.md                          # Main skill file (execution workflow)
└── references/
    ├── conventions.md                # Code patterns, components, i18n templates
    ├── templates.md                  # Large code templates (layout, search, TOC, nav)
    ├── page-templates.md             # Section structure skeletons per page type
    ├── style-presets.md              # 8 curated style presets with color palettes
    └── anti-patterns.md              # Common mistakes and troubleshooting guide
```

`SKILL.md` is loaded on every invocation. Reference files are loaded on-demand to minimize token cost.

## Style Presets

| Preset | Inspired By | Vibe |
|--------|-------------|------|
| Stripe Premium | Stripe Docs | Purple gradients, tabbed code blocks, polished |
| Vercel Monochrome | Vercel Docs | Black & white, code-dominant, CMD+K search |
| Tailwind Utility | Tailwind Docs | Numbered steps, utility-first, sky blue accents |
| GitHub System | GitHub Docs | Three-column, five-tier callouts, systematic |
| Supabase Bold | Supabase Docs | Card grids, emerald green, bold typography |
| Linear Minimal | Linear Docs | Generous whitespace, minimal color, elegant |
| Anthropic Warm | Anthropic Docs | Paper-like reading, warm tones, long-form prose |
| Notion Friendly | Notion Guides | Emoji markers, hero images, community-oriented |

Or skip presets entirely — if your project has an established design system, the skill uses that directly.

## Generated Output

For a typical project, the skill generates:

- `app/docs/page.tsx` + `content.tsx` — Overview/landing page
- `app/docs/layout.tsx` — Shared navigation with CMD+K search (multi-page)
- `app/docs/self-host/page.tsx` + `content.tsx` — Self-hosting guide
- `app/docs/features/page.tsx` + `content.tsx` — Feature deep-dive (optional)
- i18n keys in `en-US.json` and `zh-CN.json`
- `public/llms.txt` — AI-readable summary index
- `public/llms-full.txt` — Full documentation in plain markdown

Each page includes: SEO metadata, OpenGraph tags, Twitter cards, canonical URLs, section anchors, and responsive layouts with dark mode support.

## AI-Friendly Documentation

Every generated docs site is designed to be consumed by both humans and AI:

| Feature | Why It Matters |
|---------|----------------|
| **SSR-rendered** | `curl https://yoursite.com/docs` returns full HTML with all content — no client-side rendering gaps |
| **Section anchors** | Every `<h2>` and `<h3>` has an `id` attribute for deep linking (`/docs#key-features`) |
| **llms.txt** | Standardized AI-readable index at `/llms.txt` — lets AI tools discover and understand your docs |
| **llms-full.txt** | Complete plain-text documentation at `/llms-full.txt` — full content without HTML parsing |
| **Semantic HTML** | Proper heading hierarchy, landmark elements, structured content |

## Contributing

Contributions are welcome. This is a Claude Code Skill, so the "source code" is structured Markdown + code templates.

Key files to understand:
- `SKILL.md` — The execution workflow (5 phases, checkpoints, update mode)
- `references/conventions.md` — Code patterns and component definitions
- `references/anti-patterns.md` — What NOT to do (useful for understanding design decisions)

## License

[Apache-2.0](LICENSE)
