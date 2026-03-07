# Code Conventions Reference

This document captures code patterns and style conventions for generating documentation pages. These patterns are extracted from real Next.js projects and serve as the DEFAULT when the project has no explicit design system.

**IMPORTANT**: Always run design system detection first (see SKILL.md Phase 1). If the project has its own design tokens, CSS variables, or component library, those take priority over everything in this file.

## File Header Pattern

```tsx
"use client";

import Link from "next/link";
import { useState } from "react";
import { useTranslation } from "@/i18n";
import { ThemeToggle } from "@/components/shell/theme-toggle";
import { LanguageSwitcher } from "@/components/shell/language-switcher";
```

**Rules:**
- Add `"use client"` as the first line of `content.tsx` files (they use hooks like `useState`). Do NOT add it to `page.tsx` — that must remain a Server Component for metadata exports.
- Use `@/` path alias for project imports (verify alias exists in `tsconfig.json`)
- Import `Link` from `next/link` for internal navigation
- Import `useTranslation` from the project's i18n module (detect actual import path in Phase 1)
- Import `ThemeToggle` and `LanguageSwitcher` only if they exist in the project

## Design System Detection Checklist

Before using the CSS variables and classes below, verify they exist in the project:

1. **Read `globals.css`** (or equivalent) — search for CSS custom properties (`--bg`, `--text-1`, etc.)
2. **Read Tailwind config** (`tailwind.config.*`) — check for custom theme extensions
3. **Read existing pages** — check what variables/classes are actually used in `style={{}}` and `className`
4. **If variables differ**, create a mapping from detected variables to the template variables below

## CSS Variable System (Default)

All styling uses CSS custom properties via inline `style={{}}`. Never hardcode colors.

| Variable | Purpose | Verify in `globals.css` |
|----------|---------|------------------------|
| `var(--bg)` | Page background | Required |
| `var(--bg-elevated)` | Elevated surface (cards, table headers) | Required |
| `var(--text-1)` | Primary text (headings) | Required |
| `var(--text-2)` | Secondary text (body) | Required |
| `var(--text-3)` | Tertiary text (captions, hints) | Required |
| `var(--accent)` | Brand accent color | Required |
| `var(--accent-soft)` | Light accent background | Optional |
| `var(--border)` | Border color | Required |
| `var(--green)` | Success state | Optional |
| `var(--r-md)` | Medium border radius | Optional (fallback: `8px`) |
| `var(--r-lg)` | Large border radius | Optional (fallback: `12px`) |

## Layout Classes (Default)

These are project-specific utility classes. Verify they exist before using:

| Class | Purpose | Fallback if missing |
|-------|---------|-------------------|
| `landing-card-shell` | Card container with border and background | Use inline styles: `border: 1px solid var(--border); background: var(--bg-elevated); border-radius: var(--r-md)` |
| `landing-btn-primary` | Primary button style | Use inline styles with accent color |
| `landing-btn-secondary` | Secondary/outline button style | Use inline styles with border |
| `landing-cta-panel` | Call-to-action panel background | Use inline styles with accent-soft |

## Required Icon Definitions

All page templates reference these inline SVG icons. Include them at the top of each page file:

```tsx
/* ---- Icons (24px stroke-based) ---- */

function CopyIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <rect x="9" y="9" width="13" height="13" rx="2" />
      <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
    </svg>
  );
}

function CheckIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}

function ChevronIcon(p: React.SVGProps<SVGSVGElement> & { open?: boolean }) {
  const { open, ...rest } = p;
  return (
    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={2} strokeLinecap="round" strokeLinejoin="round"
         style={{ transform: open ? "rotate(90deg)" : "rotate(0deg)", transition: "transform 0.2s" }} {...rest}>
      <polyline points="9 18 15 12 9 6" />
    </svg>
  );
}

function ArrowLeftIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <line x1="19" y1="12" x2="5" y2="12" />
      <polyline points="12 19 5 12 12 5" />
    </svg>
  );
}

function BookIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={24} height={24} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <path d="M4 19.5A2.5 2.5 0 016.5 17H20" />
      <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" />
    </svg>
  );
}
```

**Custom icon pattern** (for adding page-specific icons):

```tsx
function IconName(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={24} height={24} viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth={1.5} strokeLinecap="round"
         strokeLinejoin="round" {...props}>
      {/* SVG paths from Feather Icons, Lucide, or similar stroke-based icon set */}
    </svg>
  );
}
```

**Rules:**
- 24x24 viewBox for section icons, 16x16 for inline/utility icons
- Stroke-based (not fill), strokeWidth 1.5 (section) or 2 (utility)
- Spread `...props` or `...p` to allow style overrides
- Define at the top of the file, before components
- Source SVG paths from [Lucide Icons](https://lucide.dev) or [Feather Icons](https://feathericons.com) for consistency

## Reusable Section Components

### CodeBlock (with copy button)

Depends on: `CopyIcon`, `CheckIcon` (defined above)

```tsx
function CodeBlock({ code, lang = "bash" }: { code: string; lang?: string }) {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  return (
    <div className="relative group rounded-[var(--r-md)] overflow-hidden"
         style={{ background: "var(--bg)" }}>
      <div className="flex items-center justify-between px-4 py-2 text-xs"
           style={{ color: "var(--text-3)", borderBottom: "1px solid var(--border)" }}>
        <span>{lang}</span>
        <button onClick={copy} className="flex items-center gap-1 px-2 py-1 rounded transition-colors"
                style={{ color: copied ? "var(--green)" : "var(--text-3)" }}>
          {copied ? <CheckIcon /> : <CopyIcon />}
          {copied ? "Copied" : "Copy"}
        </button>
      </div>
      <pre className="p-4 overflow-x-auto text-sm leading-relaxed"
           style={{ color: "var(--text-2)" }}>
        <code>{code}</code>
      </pre>
    </div>
  );
}
```

### FaqItem (Collapsible)

Depends on: `ChevronIcon` (defined above)

```tsx
function FaqItem({ q, a }: { q: string; a: string }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="rounded-[var(--r-md)] transition-colors"
         style={{ border: "1px solid var(--border)" }}>
      <button onClick={() => setOpen(!open)}
              className="w-full flex items-center gap-3 px-5 py-4 text-left font-medium"
              style={{ color: "var(--text-1)" }}>
        <ChevronIcon open={open} />
        {q}
      </button>
      {open && <div className="px-5 pb-4 text-sm leading-relaxed"
                    style={{ color: "var(--text-2)" }}>{a}</div>}
    </div>
  );
}
```

### StepCard (Numbered Steps)

```tsx
function StepCard({ num, title, children }: { num: number; title: string; children: React.ReactNode }) {
  return (
    <div className="landing-card-shell p-6">
      <div className="flex items-center gap-3 mb-4">
        <span className="flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold"
              style={{ background: "var(--accent-soft)", color: "var(--accent)" }}>{num}</span>
        <h3 className="text-lg font-semibold" style={{ color: "var(--text-1)" }}>{title}</h3>
      </div>
      {children}
    </div>
  );
}
```

### FeatureCard (Icon + Title + Description)

```tsx
function FeatureCard({ icon, title, desc }: { icon: React.ReactNode; title: string; desc: string }) {
  return (
    <div className="landing-card-shell p-6">
      <div className="flex items-center gap-3 mb-3">
        <span style={{ color: "var(--accent)" }}>{icon}</span>
        <h3 className="text-base font-semibold" style={{ color: "var(--text-1)" }}>{title}</h3>
      </div>
      <p className="text-sm leading-relaxed" style={{ color: "var(--text-2)" }}>{desc}</p>
    </div>
  );
}
```

Usage: `<FeatureCard icon={<ShieldCheckIcon />} title={t("docs.feature1Title")} desc={t("docs.feature1Desc")} />`

### Callout (Note / Tip / Warning / Caution)

Use for important information that should stand out from the main text. Maps to GitHub-style admonition levels.

```tsx
function Callout({ type = "note", children }: {
  type?: "note" | "tip" | "warning" | "caution";
  children: React.ReactNode;
}) {
  const config = {
    note:    { icon: "ℹ", bg: "var(--accent-soft)", border: "var(--accent)", label: "Note" },
    tip:     { icon: "💡", bg: "var(--accent-soft)", border: "var(--green, var(--accent))", label: "Tip" },
    warning: { icon: "⚠", bg: "rgba(234,179,8,0.1)", border: "rgb(234,179,8)", label: "Warning" },
    caution: { icon: "🔴", bg: "rgba(239,68,68,0.1)", border: "rgb(239,68,68)", label: "Caution" },
  }[type];
  return (
    <div className="rounded-[var(--r-md)] px-5 py-4 text-sm leading-relaxed my-4"
         style={{ background: config.bg, borderLeft: `3px solid ${config.border}`, color: "var(--text-2)" }}>
      <div className="font-semibold mb-1" style={{ color: "var(--text-1)" }}>
        {config.icon} {config.label}
      </div>
      {children}
    </div>
  );
}
```

Usage:
```tsx
<Callout type="warning">{t("docs.selfHost.rootWarning")}</Callout>
<Callout type="tip">{t("docs.overview.protocolTip")}</Callout>
```

### Breadcrumbs (Multi-Page Navigation)

Renders a breadcrumb trail for multi-page docs. Helps users orient when landing mid-site.

```tsx
function Breadcrumbs({ items }: { items: { label: string; href?: string }[] }) {
  return (
    <nav className="flex items-center gap-1.5 text-xs mb-6" style={{ color: "var(--text-3)" }}>
      {items.map((item, i) => (
        <span key={i} className="flex items-center gap-1.5">
          {i > 0 && <span>/</span>}
          {item.href ? (
            <Link href={item.href} className="hover:underline" style={{ color: "var(--text-3)" }}>
              {item.label}
            </Link>
          ) : (
            <span style={{ color: "var(--text-2)" }}>{item.label}</span>
          )}
        </span>
      ))}
    </nav>
  );
}
```

Usage:
```tsx
<Breadcrumbs items={[
  { label: t("docs.backHome"), href: "/" },
  { label: t("docs.nav.overview"), href: "/docs" },
  { label: t("docs.nav.architecture") },
]} />
```

## Page Structure Template (Single-Page Docs)

Use this skeleton when generating a **single standalone docs page** (no shared layout). It includes its own sticky nav. For **multi-page docs** (2+ pages), use the DocsLayout from `references/templates.md` instead — individual pages then omit the nav and start with `<main>` directly.

Replace `PageIcon` with an appropriate icon for the page topic.

Depends on: `ArrowLeftIcon`, page-specific icon (e.g., `BookIcon`)

```tsx
export default function PageName() {
  const { t } = useTranslation();

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)", color: "var(--text-2)" }}>
      {/* Sticky nav */}
      <nav className="sticky top-0 z-50 flex items-center justify-between px-6 py-3"
           style={{
             background: "color-mix(in srgb, var(--bg) 85%, transparent)",
             backdropFilter: "blur(12px)",
             borderBottom: "1px solid var(--border)"
           }}>
        <div className="flex items-center gap-4">
          <Link href="/" className="flex items-center gap-2 text-sm"
                style={{ color: "var(--text-3)" }}>
            <ArrowLeftIcon /> {t("docs.backHome")}
          </Link>
        </div>
        <div className="flex items-center gap-2">
          <LanguageSwitcher />
          <ThemeToggle />
        </div>
      </nav>

      <main className="max-w-[800px] mx-auto px-6 py-12">
        {/* Hero */}
        <div className="mb-12">
          <div className="flex items-center gap-3 mb-4">
            <BookIcon style={{ color: "var(--accent)" }} />
            <span className="text-xs font-semibold tracking-wider uppercase"
                  style={{ color: "var(--accent)" }}>{t("docs.page.badge")}</span>
          </div>
          <h1 className="text-3xl md:text-4xl font-bold mb-4"
              style={{ color: "var(--text-1)" }}>{t("docs.page.title")}</h1>
          <p className="text-lg leading-relaxed"
             style={{ color: "var(--text-2)" }}>{t("docs.page.subtitle")}</p>
        </div>

        {/* Content sections */}
        <section className="mb-12">
          <h2 className="text-xl font-semibold mb-4"
              style={{ color: "var(--text-1)" }}>{t("docs.page.sectionTitle")}</h2>
          {/* Section content */}
        </section>

        {/* CTA */}
        <section className="landing-cta-panel p-8 text-center rounded-[var(--r-lg)]">
          {/* Call to action */}
        </section>

        {/* Footer */}
        <footer className="mt-16 pt-8 text-center text-xs"
                style={{ color: "var(--text-3)", borderTop: "1px solid var(--border)" }}>
          <p>{t("docs.page.footer")}</p>
        </footer>
      </main>
    </div>
  );
}
```

## i18n Key Structure

The project uses **separate files** for each language. Generate keys in BOTH files simultaneously.

**en-US.json** example:
```json
{
  "docs": {
    "backHome": "Back to Home",
    "nav": {
      "overview": "Overview",
      "features": "Features",
      "architecture": "Architecture",
      "selfHost": "Self-Host",
      "api": "API Reference"
    },
    "overview": {
      "badge": "DOCUMENTATION",
      "title": "Agent Planet Documentation",
      "subtitle": "Everything you need to know about the unified agent control plane.",
      "whatIsTitle": "What is Agent Planet?",
      "whatIsP1": "...",
      "featuresTitle": "Key Features",
      "feature1Title": "Agent Registry",
      "feature1Desc": "..."
    }
  }
}
```

**zh-CN.json** example (same keys, Chinese values):
```json
{
  "docs": {
    "backHome": "返回首页",
    "nav": {
      "overview": "概览",
      "features": "功能",
      "architecture": "架构",
      "selfHost": "自部署",
      "api": "API 参考"
    },
    "overview": {
      "badge": "文档",
      "title": "Agent Planet 文档",
      "subtitle": "关于统一 Agent 控制平面的全面指南。",
      "whatIsTitle": "什么是 Agent Planet？",
      "whatIsP1": "...",
      "featuresTitle": "核心功能",
      "feature1Title": "Agent 注册中心",
      "feature1Desc": "..."
    }
  }
}
```

**Key naming rules:**
- Detect existing key structure first — if the project uses top-level keys (e.g., `selfHost.*`), follow that pattern
- Section name as key prefix: `docs.overview.*`, `docs.features.*`
- Descriptive, camelCase key names
- Suffix pattern: `Title`, `Desc`, `P1`/`P2` (paragraphs), `Badge`, `Note`
- Lists use numbered suffixes: `feature1Title`, `feature2Title`, etc.
- Both language files must have **exactly matching keys** — verify with project's i18n check command if available

## Responsive Design Patterns

- **Max width**: `max-w-[800px]` for content pages (verify Tailwind config for custom values)
- **Grid**: `grid grid-cols-1 sm:grid-cols-2 gap-4` for two-column layouts
- **Triple grid**: `grid grid-cols-1 sm:grid-cols-3 gap-3`
- **Hidden on mobile**: `hidden sm:table-cell` or `hidden sm:block`
- **Padding**: `px-6 py-12` for main, `p-4` to `p-6` for cards
- **Spacing**: `mb-12` between sections, `mb-4` between heading and content, `space-y-2` for lists
- **Breakpoints**: `sm:` = 640px, `md:` = 768px, `lg:` = 1024px (verify in Tailwind config)

## Docs Layout Template (Multi-Page)

When generating 2+ docs pages, create a shared `app/docs/layout.tsx` with sidebar navigation. See `references/templates.md` for the full layout template code.

**Key points**: Sticky top nav with blur backdrop, active route highlighting via `usePathname()`, responsive (mobile hides nav links). Individual pages omit their own nav and use `<main>` directly.

## Search Component (CMD+K)

When generating 2+ docs pages, include a CMD+K search component. See `references/templates.md` for complete SearchDialog, SearchButton, search index, and integration code.

**Key points**: Zero-dependency client-side search, indexes from i18n keys, ESC to close, max 8 results. Skip if only generating 1 page. Use project's existing search library (Algolia, etc.) if present.

---

## AI-Friendly Patterns

### SectionHeading (with anchor and hover link)

REQUIRED for all `<h2>` and `<h3>` elements. Enables AI tools and humans to deep-link to specific sections.

```tsx
function SectionHeading({ id, children, as: Tag = "h2" }: {
  id: string;
  children: React.ReactNode;
  as?: "h2" | "h3";
}) {
  const sizeClass = Tag === "h2" ? "text-xl font-semibold" : "text-lg font-semibold";
  return (
    <Tag id={id} className={`${sizeClass} mb-4 group scroll-mt-20`}
         style={{ color: "var(--text-1)" }}>
      <a href={`#${id}`} className="no-underline" style={{ color: "inherit" }}>
        {children}
        <span className="opacity-0 group-hover:opacity-100 ml-2 transition-opacity text-sm font-normal"
              style={{ color: "var(--text-3)" }}>#</span>
      </a>
    </Tag>
  );
}
```

Usage:
```tsx
<SectionHeading id="key-features">{t("docs.overview.featuresTitle")}</SectionHeading>
<SectionHeading id="protocols" as="h3">{t("docs.overview.protocolsTitle")}</SectionHeading>
```

**ID naming rules:**
- Lowercase, hyphen-separated: `key-features`, `how-it-works`, `tech-stack`
- Derive from the English i18n value (not the key name or Chinese text)
- `scroll-mt-20` accounts for sticky nav height when clicking anchor links
- Every page should use `SectionHeading` for ALL section headings (not bare `<h2>` tags)

### SSR Compatibility Rules

Next.js renders both Server Components and Client Components ("use client") on the server. This means `curl` gets full HTML. But follow these rules to ensure AI tools can read the content:

1. **DO**: Put metadata in `page.tsx` (Server Component), interactive content in `content.tsx` (Client Component)
2. **DO**: Use `useTranslation()` normally — SSR renders with the default locale
3. **DO NOT**: Fetch documentation text in `useEffect` — it won't be in the initial HTML
4. **DO NOT**: Conditionally render sections based on client-only state (e.g., `window.innerWidth`)
5. **DO NOT**: Use `dynamic(() => import(...), { ssr: false })` for documentation content

The content.tsx client component is fine because Next.js SSR renders it. The key rule: **all documentation text must be present in the initial render, not loaded asynchronously.**

### Server/Client Split Template

```tsx
// app/docs/page-name/page.tsx — Server Component (SEO + metadata)
import type { Metadata } from "next";
import { PageContent } from "./content";

export const metadata: Metadata = {
  title: "Page Title — Project Name",
  description: "Concise SEO description under 160 chars, with primary keywords.",
  openGraph: {
    title: "Page Title — Project Name",
    description: "Short OG description under 200 chars.",
    type: "website",
    // siteName: "Project Name",  // uncomment and fill
  },
  twitter: {
    card: "summary_large_image",
    title: "Page Title — Project Name",
    description: "Short Twitter card description.",
  },
  alternates: {
    canonical: "/docs/page-name",
  },
};

export default function Page() {
  return <PageContent />;
}
```

```tsx
// app/docs/page-name/content.tsx — Client Component (interactive)
"use client";

import { useState } from "react";
import { useTranslation } from "@/i18n";
// ... all interactive page content with SectionHeading, CodeBlock, etc.
```

### llms.txt Files

When docs pages are generated, also update these public files:

**`public/llms.txt`** — Summary index (~30-50 lines):
```markdown
# Project Name

> One-line description

## Docs

- [Overview](https://domain.com/docs): Project introduction and features
- [Overview#key-features](https://domain.com/docs#key-features): Feature list
- [Self-Host Guide](https://domain.com/docs/self-host): Deploy on your server
- [Full Documentation for LLMs](https://domain.com/llms-full.txt): Complete text

## API

- [OpenAPI Spec](https://domain.com/api/openapi.json): Machine-readable API
```

**`public/llms-full.txt`** — Complete content in English (~200-500 lines):
```markdown
# Project Name — Full Documentation

> Description

---

## Overview

[All text content from /docs page, section by section]

### Key Features

[Feature descriptions...]

---

## Self-Host Guide

[All text content from /docs/self-host page]

---
```

**Root layout verification** — Ensure this exists in `<head>`:
```html
<link rel="llms-txt" type="text/plain" href="/llms.txt" />
```
