# docs-site-gen

[English](README.md) | [中文](README.zh-CN.md)

A universal AI coding skill that generates production-quality documentation websites by reading your actual source code — not paraphrasing your README.

You've shipped the product. Now ship the docs in minutes, not days.

## The Problem

You built your project with Claude Code or Codex in record time. But the docs site? That's still a manual grind — writing copy, designing layouts, keeping content in sync with code, supporting i18n, making it AI-readable. It's the unglamorous last mile that eats hours.

## What This Skill Does

`docs-site-gen` is an [AI coding skill](https://docs.anthropic.com/en/docs/claude-code/skills) that generates and maintains full documentation websites integrated into your existing web app. It works in 5 phases:

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

- An AI coding client that supports the [SKILL.md format](#supported-clients)
- A web frontend project (Next.js App Router recommended)
- Node.js + pnpm/npm for validation commands

## Installation

### One-command install (recommended)

```bash
git clone https://github.com/Octo-o-o-o/docs_site_gen.git
cd docs_site_gen
./install.sh
```

The installer auto-detects which AI clients you have installed and sets up the skill for all of them.

```
$ ./install.sh

docs-site-gen — skill installer
────────────────────────────────────

[done] Installed for claude → ~/.claude/skills/docs-site-gen
[done] Installed for cursor → ~/.cursor/skills/docs-site-gen
[done] Installed for gemini → ~/.gemini/skills/docs-site-gen
[skip] codex not detected
[skip] continue not detected

Installed for 3 client(s), skipped 2.
Restart your AI client to activate the skill.
```

### Install for a specific client

```bash
./install.sh --client claude    # Claude Code only
./install.sh --client cursor    # Cursor only
./install.sh --list             # See all supported clients
```

### Manual install

```bash
# For any client, the pattern is:
mkdir -p ~/.<CLIENT>/skills/docs-site-gen
cp skills/docs-site-gen/SKILL.md ~/.<CLIENT>/skills/docs-site-gen/
cp -r skills/docs-site-gen/references ~/.<CLIENT>/skills/docs-site-gen/
```

### Uninstall

```bash
./install.sh --uninstall
```

## Supported Clients

This skill uses the universal [SKILL.md format](https://docs.anthropic.com/en/docs/claude-code/skills) — a cross-client standard adopted by 13+ AI coding assistants.

| Client | Status | Install Path |
|--------|--------|-------------|
| Claude Code | Full Support | `~/.claude/skills/docs-site-gen/` |
| Cursor | Full Support | `~/.cursor/skills/docs-site-gen/` |
| Gemini CLI | Full Support | `~/.gemini/skills/docs-site-gen/` |
| Codex | Full Support | `~/.codex/skills/docs-site-gen/` |
| Continue | Full Support | `~/.continue/skills/docs-site-gen/` |
| OpenCode | Full Support | `~/.config/opencode/skills/docs-site-gen/` |
| OpenClaw | Full Support | `~/.openclaw/skills/docs-site-gen/` |
| Kilocode | Full Support | `~/.kilocode/skills/docs-site-gen/` |
| AdaL CLI | Full Support | `~/.adal/skills/docs-site-gen/` |
| CodeBuddy | Full Support | `~/.codebuddy/skills/docs-site-gen/` |
| FactoryAI Droid | Full Support | `~/.factory/skills/docs-site-gen/` |
| Pi Agent | Full Support | `~/.pi/skills/docs-site-gen/` |

## Not Another Generic Docs Template

Most docs generators produce cookie-cutter sites that look nothing like your project. This skill works differently:

1. **Reads your design system first** — It inspects your `globals.css`, Tailwind config, CSS variables, color tokens, font stack, and existing pages before generating anything. The output matches your project's visual identity, not a generic template.
2. **Three maturity levels** — If your project has a full design system (10+ CSS variables, design tokens), the skill uses it directly. If you have partial conventions, it fills the gaps. If you're starting from scratch, pick one of the 8 style presets.
3. **Your project, your look** — Dark mode support, custom fonts, brand colors, component patterns — all detected and carried through to the docs pages.

## Usage

This skill supports three modes of operation:

### 1. Generate New Docs

Build a complete docs site from scratch for a project that doesn't have one yet.

```
"Generate a docs site for this project"
"Create a /docs page"
```

**Typical flow:**

```
You: "Generate a docs site for this project"

AI:
  → Phase 1: Detects your design system (Tailwind + CSS variables, dark mode support)
  → CP1: "I found these design conventions. Which style preset do you prefer?"
  → Phase 2: Reads 12 API routers, 8 models, 5 services — builds feature inventory
  → Phase 3: Produces content outline with sources
  → CP2: "Here's the planned content with navigation layout. Each feature maps to verified code. Approve?"
  → Phase 4: Generates page.tsx + content.tsx + i18n keys + llms.txt
  → Phase 5: Runs tsc, lint, i18n check, completeness audit
  → CP3: "Done. Here's what was generated. Run `pnpm build` to verify."
```

### 2. Update Docs After Code Changes

When you ship new features, the skill incrementally updates your existing docs — no full rewrite needed.

```
"I added push notifications — update the docs"
"We added a new billing module, update the docs to include it"
```

The skill enters **Incremental Update Mode**: scans the new code, detects what changed, produces a targeted update plan, then uses surgical edits to update only the affected sections. Your custom content is preserved.

### 3. Restyle Existing Docs

Unhappy with how your current docs look? Keep the content, change the presentation.

```
"Restyle the docs page with a Vercel-inspired look"
"The docs feel outdated — regenerate with a cleaner style but keep the content"
```

The skill re-reads your existing docs content, applies a new style preset (or your updated design system), and regenerates the pages while preserving your verified content and custom sections.

## File Structure

```
docs-site-gen/
├── skills/
│   └── docs-site-gen/
│       ├── SKILL.md                      # Main skill (execution workflow)
│       └── references/
│           ├── content-mining.md         # Phase 2B deep content mining workflow
│           ├── generation-rules.md       # Phase 4 page generation rules
│           ├── validation-rules.md       # Phase 5 validation workflow
│           ├── update-mode.md            # Incremental update mode
│           ├── conventions.md            # Code patterns, components, i18n
│           ├── templates.md              # Large code templates (layout, search, TOC)
│           ├── page-templates.md         # Section skeletons per page type
│           ├── style-presets.md          # 8 curated style presets
│           └── anti-patterns.md          # Common mistakes & troubleshooting
├── .claude-plugin/
│   └── plugin.json                       # Claude Code marketplace metadata
├── install.sh                            # One-command installer
├── README.md
├── README.zh-CN.md
└── LICENSE
```

`skills/docs-site-gen/` is the canonical source. The installer copies SKILL.md and references/ to each client's skill directory. References are loaded on-demand to minimize token cost.

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

Contributions are welcome. This is an AI coding skill, so the "source code" is structured Markdown + code templates.

Key files to understand:
- `skills/docs-site-gen/SKILL.md` — The execution workflow (5 phases, checkpoints)
- `skills/docs-site-gen/references/` — Detailed rules loaded on-demand per phase
- `skills/docs-site-gen/references/anti-patterns.md` — What NOT to do (useful for understanding design decisions)

## License

[Apache-2.0](LICENSE)
