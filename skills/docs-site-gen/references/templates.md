# Code Templates

Large, copy-paste-ready code templates for docs generation. Referenced by `conventions.md` and SKILL.md at specific steps — only read this file when generating multi-page docs or when a specific template is needed.

## Contents

- **Docs Layout Templates** — Header Nav (Mode B) and Sidebar Nav (Mode C) full layout files
- **Search Component (CMD+K)** — SearchDialog + SearchButton with keyboard handling
- **On-Page Table of Contents (Right-Side TOC)** — Sticky TOC with active-section highlighting via IntersectionObserver
- **Previous/Next Page Navigation** — Cross-page nav links derived from sidebar/header order
- **Diagram Templates (Server-Safe SVG)** — 5 archetypes for inline SVG illustrations:
  - HorizontalStepFlow (Getting Started, 5 numbered steps)
  - LayeredArchitecture (Security/Architecture, 3 layered columns with cross-arrows)
  - DualPathDecision (Architecture, request → router → 2 parallel paths → sink)
  - HubAndSpokePanorama (Integrations, central node + 6 radial branches; viewBox safety guidance for top/bottom labels)
  - EventTimeline (Audit/Activity, horizontal timeline with N event cards + actor/timestamp)

## Docs Layout Templates

Two layout templates for multi-page docs, selected based on Step 3.3.1 navigation layout choice. For one-page mode (Layout Mode A), no `layout.tsx` is needed.

### Docs Layout Template (Header Nav) — Layout Mode B

Horizontal nav links in a sticky top bar. Best for 3-5 pages with distinct topics.

```tsx
// app/docs/layout.tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { useTranslation } from "@/i18n";
import { ThemeToggle } from "@/components/shell/theme-toggle";
import { LanguageSwitcher } from "@/components/shell/language-switcher";

const NAV_ITEMS = [
  { href: "/docs", key: "docs.nav.overview" },
  { href: "/docs/features", key: "docs.nav.features" },
  { href: "/docs/architecture", key: "docs.nav.architecture" },
  { href: "/docs/self-host", key: "docs.nav.selfHost" },
  { href: "/docs/api", key: "docs.nav.api" },
];

function MenuIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={20} height={20} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <line x1="3" y1="6" x2="21" y2="6" /><line x1="3" y1="12" x2="21" y2="12" /><line x1="3" y1="18" x2="21" y2="18" />
    </svg>
  );
}

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { t } = useTranslation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      {/* Top nav */}
      <nav className="sticky top-0 z-50 flex items-center justify-between px-6 py-3"
           style={{
             background: "color-mix(in srgb, var(--bg) 85%, transparent)",
             backdropFilter: "blur(12px)",
             borderBottom: "1px solid var(--border)"
           }}>
        <div className="flex items-center gap-6">
          <Link href="/" className="text-sm" style={{ color: "var(--text-3)" }}>
            {t("docs.backHome")}
          </Link>
          {/* Desktop nav */}
          <div className="hidden sm:flex items-center gap-1">
            {NAV_ITEMS.map((item) => (
              <Link key={item.href} href={item.href}
                    className="px-3 py-1.5 rounded-md text-sm transition-colors"
                    style={{
                      color: pathname === item.href ? "var(--accent)" : "var(--text-3)",
                      background: pathname === item.href ? "var(--accent-soft)" : "transparent"
                    }}>
                {t(item.key)}
              </Link>
            ))}
          </div>
          {/* Mobile hamburger */}
          <button className="sm:hidden p-1" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                  style={{ color: "var(--text-2)" }}>
            <MenuIcon />
          </button>
        </div>
        <div className="flex items-center gap-2">
          {/* SearchButton goes here */}
          <LanguageSwitcher />
          <ThemeToggle />
        </div>
      </nav>

      {/* Mobile dropdown menu */}
      {mobileMenuOpen && (
        <div className="sm:hidden px-4 py-2" style={{ background: "var(--bg-elevated)", borderBottom: "1px solid var(--border)" }}>
          {NAV_ITEMS.map((item) => (
            <Link key={item.href} href={item.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className="block px-3 py-2 rounded-md text-sm no-underline"
                  style={{
                    color: pathname === item.href ? "var(--accent)" : "var(--text-2)",
                    background: pathname === item.href ? "var(--accent-soft)" : "transparent"
                  }}>
              {t(item.key)}
            </Link>
          ))}
        </div>
      )}

      {children}
    </div>
  );
}
```

**When to use**: Layout Mode B — 3-5 docs pages with horizontal navigation.

### Docs Layout Template (Sidebar Nav) — Layout Mode C

Persistent left sidebar with grouped navigation tree. Best for 6+ pages or deep documentation.

```tsx
// app/docs/layout.tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { useTranslation } from "@/i18n";

// Group pages by category — adapt to project's actual page set
const NAV_GROUPS = [
  {
    labelKey: "docs.nav.group.gettingStarted",
    items: [
      { href: "/docs", key: "docs.nav.overview" },
      { href: "/docs/getting-started", key: "docs.nav.gettingStarted" },
    ],
  },
  {
    labelKey: "docs.nav.group.guides",
    items: [
      { href: "/docs/features", key: "docs.nav.features" },
      { href: "/docs/architecture", key: "docs.nav.architecture" },
      { href: "/docs/self-host", key: "docs.nav.selfHost" },
    ],
  },
  {
    labelKey: "docs.nav.group.reference",
    items: [
      { href: "/docs/api", key: "docs.nav.api" },
      { href: "/docs/configuration", key: "docs.nav.configuration" },
    ],
  },
];

function MenuIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={20} height={20} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <line x1="3" y1="6" x2="21" y2="6" /><line x1="3" y1="12" x2="21" y2="12" /><line x1="3" y1="18" x2="21" y2="18" />
    </svg>
  );
}

function SidebarContent({ pathname, t }: { pathname: string; t: (key: string) => string }) {
  return (
    <div className="space-y-6 py-6 px-4">
      <Link href="/" className="flex items-center gap-2 text-sm px-3 py-2 rounded-md no-underline transition-colors"
            style={{ color: "var(--text-3)" }}>
        <span>←</span> {t("docs.backHome")}
      </Link>

      {/* SearchButton goes here */}

      {NAV_GROUPS.map((group) => (
        <div key={group.labelKey}>
          <div className="text-xs font-semibold uppercase tracking-wider px-3 mb-2"
               style={{ color: "var(--text-3)" }}>
            {t(group.labelKey)}
          </div>
          <ul className="space-y-0.5">
            {group.items.map((item) => (
              <li key={item.href}>
                <Link href={item.href}
                      className="block px-3 py-1.5 rounded-md text-sm transition-colors no-underline"
                      style={{
                        color: pathname === item.href ? "var(--accent)" : "var(--text-2)",
                        background: pathname === item.href ? "var(--accent-soft)" : "transparent",
                        fontWeight: pathname === item.href ? 500 : 400,
                      }}>
                  {t(item.key)}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { t } = useTranslation();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      {/* Mobile top bar */}
      <div className="lg:hidden sticky top-0 z-50 flex items-center justify-between px-4 py-3"
           style={{
             background: "color-mix(in srgb, var(--bg) 85%, transparent)",
             backdropFilter: "blur(12px)",
             borderBottom: "1px solid var(--border)"
           }}>
        <button onClick={() => setSidebarOpen(true)} className="p-1.5 rounded-md"
                style={{ color: "var(--text-2)" }}>
          <MenuIcon />
        </button>
        <Link href="/docs" className="text-sm font-medium no-underline" style={{ color: "var(--text-1)" }}>
          {t("docs.title")}
        </Link>
        <div className="w-8" /> {/* Spacer for centering */}
      </div>

      {/* Mobile sidebar drawer */}
      {sidebarOpen && (
        <div className="lg:hidden fixed inset-0 z-[60]" onClick={() => setSidebarOpen(false)}>
          <div className="absolute inset-0" style={{ background: "rgba(0,0,0,0.4)" }} />
          <aside className="relative w-72 h-full overflow-y-auto"
                 style={{ background: "var(--bg)", borderRight: "1px solid var(--border)" }}
                 onClick={(e) => e.stopPropagation()}>
            <SidebarContent pathname={pathname} t={t} />
          </aside>
        </div>
      )}

      {/* Desktop: sidebar + content grid */}
      <div className="lg:grid lg:grid-cols-[260px_1fr]">
        <aside className="hidden lg:block sticky top-0 h-screen overflow-y-auto"
               style={{ borderRight: "1px solid var(--border)" }}>
          <SidebarContent pathname={pathname} t={t} />
        </aside>
        <main className="min-w-0">
          {children}
        </main>
      </div>
    </div>
  );
}
```

**When to use**: Layout Mode C — 6+ docs pages or deep hierarchical content.

**Customization notes**:
- Adapt `NAV_GROUPS` to match the project's actual page set and groupings from Step 3.3.1.
- If the project has ThemeToggle / LanguageSwitcher, add them to the sidebar bottom or mobile top bar.
- For three-column layout (sidebar + content + right TOC), the individual page's `content.tsx` handles the content + TOC grid — the layout only provides the sidebar.

**Search integration**: Include SearchButton + SearchDialog in both layout templates. Place SearchButton in the header (Mode B) or at the top of the sidebar (Mode C).

## Search Component (CMD+K)

When generating multi-page documentation, include a search component that allows users to quickly find content across all docs pages.

### SearchDialog Component

A lightweight, zero-dependency client-side search dialog. No external search service required — indexes docs content at build time or at page load.

```tsx
"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import Link from "next/link";
import { useTranslation } from "@/i18n";

interface SearchItem {
  title: string;
  section: string;
  href: string;
  content: string;
}

function SearchIcon(p: React.SVGProps<SVGSVGElement>) {
  return (
    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor"
         strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" {...p}>
      <circle cx="11" cy="11" r="8" />
      <line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
  );
}

function SearchDialog({ items, open, onClose }: {
  items: SearchItem[];
  open: boolean;
  onClose: () => void;
}) {
  const [query, setQuery] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (open) {
      setQuery("");
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [open]);

  const results = query.length < 2 ? [] : items.filter((item) => {
    const q = query.toLowerCase();
    return item.title.toLowerCase().includes(q) ||
           item.content.toLowerCase().includes(q) ||
           item.section.toLowerCase().includes(q);
  }).slice(0, 8);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100]" onClick={onClose}>
      <div className="absolute inset-0" style={{ background: "rgba(0,0,0,0.5)" }} />
      <div className="relative max-w-lg mx-auto mt-[15vh]"
           onClick={(e) => e.stopPropagation()}>
        <div className="rounded-xl overflow-hidden shadow-2xl"
             style={{ background: "var(--bg)", border: "1px solid var(--border)" }}>
          {/* Search input */}
          <div className="flex items-center gap-3 px-4 py-3"
               style={{ borderBottom: "1px solid var(--border)" }}>
            <SearchIcon style={{ color: "var(--text-3)", flexShrink: 0 }} />
            <input ref={inputRef} type="text" value={query}
                   onChange={(e) => setQuery(e.target.value)}
                   placeholder="Search docs..."
                   className="flex-1 bg-transparent outline-none text-sm"
                   style={{ color: "var(--text-1)" }} />
            <kbd className="text-xs px-1.5 py-0.5 rounded"
                 style={{ background: "var(--bg-elevated)", color: "var(--text-3)",
                          border: "1px solid var(--border)" }}>ESC</kbd>
          </div>

          {/* Results */}
          {results.length > 0 && (
            <div className="max-h-80 overflow-y-auto py-2">
              {results.map((item, i) => (
                <Link key={i} href={item.href} onClick={onClose}
                      className="block px-4 py-3 transition-colors no-underline"
                      style={{ color: "var(--text-2)" }}
                      onMouseEnter={(e) => e.currentTarget.style.background = "var(--bg-elevated)"}
                      onMouseLeave={(e) => e.currentTarget.style.background = "transparent"}>
                  <div className="text-sm font-medium" style={{ color: "var(--text-1)" }}>
                    {item.title}
                  </div>
                  <div className="text-xs mt-0.5" style={{ color: "var(--text-3)" }}>
                    {item.section}
                  </div>
                </Link>
              ))}
            </div>
          )}

          {/* Empty state */}
          {query.length >= 2 && results.length === 0 && (
            <div className="px-4 py-8 text-center text-sm"
                 style={{ color: "var(--text-3)" }}>
              No results found.
            </div>
          )}

          {/* Hint */}
          {query.length < 2 && (
            <div className="px-4 py-6 text-center text-sm"
                 style={{ color: "var(--text-3)" }}>
              Type at least 2 characters to search...
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
```

### Search Trigger Button

Place this in the docs layout nav bar:

```tsx
function SearchButton({ onClick }: { onClick: () => void }) {
  const { t } = useTranslation();

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        onClick();
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [onClick]);

  return (
    <button onClick={onClick}
            className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-colors"
            style={{ color: "var(--text-3)", border: "1px solid var(--border)",
                     background: "var(--bg-elevated)" }}>
      <SearchIcon />
      <span className="hidden sm:inline">{t("docs.search")}</span>
      <kbd className="hidden sm:inline text-xs px-1 rounded"
           style={{ background: "var(--bg)", border: "1px solid var(--border)" }}>⌘K</kbd>
    </button>
  );
}
```

### Search Index Construction

Build the search index from i18n keys and page structure. Include this in the docs layout:

```tsx
// Build search index from docs structure
const SEARCH_INDEX: SearchItem[] = [
  // Overview page
  { title: t("docs.overview.title"), section: t("docs.nav.overview"),
    href: "/docs", content: t("docs.overview.whatIsP1") },
  { title: t("docs.overview.featuresTitle"), section: t("docs.nav.overview"),
    href: "/docs#key-features", content: t("docs.overview.feature1Desc") },
  // Self-Host page
  { title: t("docs.selfHost.title"), section: t("docs.nav.selfHost"),
    href: "/docs/self-host", content: t("docs.selfHost.subtitle") },
  // ... add entries for each section of each page
];
```

### Integration in Docs Layout

Add SearchButton + SearchDialog to the docs layout:

```tsx
export default function DocsLayout({ children }: { children: React.ReactNode }) {
  const [searchOpen, setSearchOpen] = useState(false);
  // ... existing layout code

  return (
    <div className="min-h-screen" style={{ background: "var(--bg)" }}>
      <nav>
        {/* ... existing nav items ... */}
        <SearchButton onClick={() => setSearchOpen(true)} />
      </nav>
      {children}
      <SearchDialog items={SEARCH_INDEX} open={searchOpen}
                     onClose={() => setSearchOpen(false)} />
    </div>
  );
}
```

### i18n Keys for Search

```json
// en-US.json
{ "docs": { "search": "Search docs...", "searchNoResults": "No results found." } }

// zh-CN.json
{ "docs": { "search": "搜索文档...", "searchNoResults": "未找到结果。" } }
```

### When to Include Search

- **Layout Mode A (one-page)**: Skip — browser Ctrl+F and right-side TOC are sufficient
- **Layout Mode B (header nav)**: Include — place SearchButton in the top header bar
- **Layout Mode C (sidebar nav)**: Include — place SearchButton at the top of the sidebar
- **Consider alternatives**: If the project already uses a search library (e.g., Algolia, Meilisearch), integrate with that instead of adding a new component

---

## On-Page Table of Contents (Right-Side TOC)

A sticky right-side TOC that displays all sections on the current page with active-section highlighting. Industry standard for pages with 5+ sections (Stripe, Vercel, Tailwind all use this pattern).

**When to include**: Any docs page with 5+ `SectionHeading` elements. Skip for short pages.

```tsx
"use client";

import { useState, useEffect } from "react";

interface TocItem {
  id: string;
  label: string;
  level: "h2" | "h3";
}

function TableOfContents({ items }: { items: TocItem[] }) {
  const [activeId, setActiveId] = useState<string>("");

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries.filter((e) => e.isIntersecting);
        if (visible.length > 0) {
          setActiveId(visible[0].target.id);
        }
      },
      { rootMargin: "-80px 0px -60% 0px", threshold: 0.1 }
    );

    items.forEach(({ id }) => {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });

    return () => observer.disconnect();
  }, [items]);

  return (
    <nav className="hidden lg:block sticky top-24 max-h-[calc(100vh-8rem)] overflow-y-auto">
      <div className="text-xs font-semibold uppercase tracking-wider mb-3"
           style={{ color: "var(--text-3)" }}>
        On this page
      </div>
      <ul className="space-y-1.5 text-sm">
        {items.map(({ id, label, level }) => (
          <li key={id}>
            <a href={`#${id}`}
               className="block py-0.5 transition-colors no-underline"
               style={{
                 paddingLeft: level === "h3" ? "1rem" : "0",
                 color: activeId === id ? "var(--accent)" : "var(--text-3)",
                 borderLeft: activeId === id ? "2px solid var(--accent)" : "2px solid transparent",
               }}>
              {label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
```

### Layout Integration for TOC

When using the TOC, the page content layout changes from single-column to a two-column grid:

```tsx
// In content.tsx — wrap <main> with a grid when TOC is needed
const TOC_ITEMS: TocItem[] = [
  { id: "what-is", label: "What is Project?", level: "h2" },
  { id: "core-concepts", label: "Core Concepts", level: "h2" },
  { id: "key-features", label: "Key Features", level: "h2" },
  { id: "how-it-works", label: "How It Works", level: "h2" },
  { id: "tech-stack", label: "Tech Stack", level: "h2" },
  { id: "quick-start", label: "Quick Start", level: "h2" },
];

// Layout: content (left) + TOC (right)
<div className="max-w-[1100px] mx-auto px-6 py-12 lg:grid lg:grid-cols-[1fr_200px] lg:gap-12">
  <main>
    {/* All page sections */}
  </main>
  <TableOfContents items={TOC_ITEMS} />
</div>
```

**Notes**:
- Max width increases from `800px` to `1100px` to accommodate the TOC column
- TOC is hidden on mobile (`hidden lg:block`) — only shows on ≥1024px screens
- `top-24` positions below the sticky nav; adjust if nav height differs
- The `IntersectionObserver` highlights the section currently in view

---

## Previous/Next Page Navigation

Bottom navigation links connecting docs pages in reading order. Industry standard for multi-page docs.

**When to include**: Any multi-page docs (2+ pages with shared layout).

```tsx
function PrevNextNav({ prev, next }: {
  prev?: { href: string; label: string };
  next?: { href: string; label: string };
}) {
  return (
    <nav className="flex items-center justify-between mt-16 pt-8"
         style={{ borderTop: "1px solid var(--border)" }}>
      {prev ? (
        <Link href={prev.href} className="group flex items-center gap-2 text-sm no-underline"
              style={{ color: "var(--text-3)" }}>
          <span className="transition-transform group-hover:-translate-x-0.5">←</span>
          <div>
            <div className="text-xs" style={{ color: "var(--text-3)" }}>Previous</div>
            <div className="font-medium" style={{ color: "var(--text-1)" }}>{prev.label}</div>
          </div>
        </Link>
      ) : <div />}
      {next ? (
        <Link href={next.href} className="group flex items-center gap-2 text-sm no-underline text-right"
              style={{ color: "var(--text-3)" }}>
          <div>
            <div className="text-xs" style={{ color: "var(--text-3)" }}>Next</div>
            <div className="font-medium" style={{ color: "var(--text-1)" }}>{next.label}</div>
          </div>
          <span className="transition-transform group-hover:translate-x-0.5">→</span>
        </Link>
      ) : <div />}
    </nav>
  );
}
```

### Usage

Place at the bottom of each page's content, before the footer:

```tsx
// In /docs content.tsx (Overview page)
<PrevNextNav
  next={{ href: "/docs/features", label: t("docs.nav.features") }}
/>

// In /docs/features content.tsx
<PrevNextNav
  prev={{ href: "/docs", label: t("docs.nav.overview") }}
  next={{ href: "/docs/architecture", label: t("docs.nav.architecture") }}
/>

// In /docs/api content.tsx (last page)
<PrevNextNav
  prev={{ href: "/docs/self-host", label: t("docs.nav.selfHost") }}
/>
```

### i18n Keys for Prev/Next

```json
// en-US.json
{ "docs": { "prevPage": "Previous", "nextPage": "Next" } }

// zh-CN.json
{ "docs": { "prevPage": "上一页", "nextPage": "下一页" } }
```

**Page order**: Follow the same order as the docs layout NAV_ITEMS array. Overview → Features → Architecture → Self-Host → API (or whatever the project uses).

## Diagram Templates (Server-Safe SVG)

Five archetypes to drop into `app/docs/_components/Diagrams.tsx`. See `generation-rules.md` 4.9 for when to use each. All templates are **server-safe** (no `"use client"`, no hooks, no third-party deps), accept an optional `className`, and ship with realistic mock data placeholders that you should replace with project-specific values from Phase 2B.

**Color constants** (paste once at the top of `Diagrams.tsx`, replace hex values with the project's brand tokens):

```tsx
const BRAND_PRIMARY = '#2A4032'    // primary brand
const BRAND_SECONDARY = '#5D7052'  // secondary accent
const BRAND_TERTIARY = '#8A9B85'   // tertiary / muted callouts
const CARD_BG = '#FDFCF8'          // cream card backdrop
const STROKE_FAINT = 'rgba(42,64,50,0.18)'
const STROKE_MEDIUM = 'rgba(42,64,50,0.35)'
const TEXT_FAINT = 'rgba(42,64,50,0.55)'

interface DiagramProps { className?: string }
```

### 1. HorizontalStepFlow — Getting Started Pages

5 numbered circular nodes connected horizontally with a track + arrow markers. Card above each circle holds the step's title + sub-label; STEP `NN` label sits below.

```tsx
export function HorizontalStepFlow({ className = '' }: DiagramProps) {
  // Replace with project-specific deployment / setup steps
  const steps = [
    { num: '01', title: 'Trial request', sub: 'Submit company info' },
    { num: '02', title: 'Install client', sub: 'macOS / Win / Linux' },
    { num: '03', title: 'Connect server', sub: 'JWT auth' },
    { num: '04', title: 'Wire data', sub: 'Files + email' },
    { num: '05', title: 'First AI call', sub: 'SSE streaming' },
  ]
  return (
    <div className={`card !p-6 md:!p-8 overflow-hidden ${className}`}>
      <svg viewBox="0 0 720 200" className="w-full h-auto" role="img" aria-label="Deployment 5-step flow diagram">
        <line x1="60" y1="100" x2="660" y2="100" stroke={STROKE_FAINT} strokeWidth="2" />
        {steps.map((s, i) => {
          const x = 60 + i * 150
          return (
            <g key={s.num}>
              <circle cx={x} cy="100" r="26" fill={i === 0 ? BRAND_PRIMARY : CARD_BG} stroke={BRAND_PRIMARY} strokeWidth="1.6" />
              <text x={x} y="105" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="13" fontWeight="700" fill={i === 0 ? CARD_BG : BRAND_PRIMARY}>{s.num}</text>
              <rect x={x - 60} y="30" width="120" height="44" rx="10" fill={CARD_BG} stroke={STROKE_FAINT} />
              <text x={x} y="50" textAnchor="middle" fontFamily="var(--font-sans)" fontSize="11" fontWeight="600" fill={BRAND_PRIMARY}>{s.title}</text>
              <text x={x} y="66" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="9" fill={TEXT_FAINT}>{s.sub}</text>
              <text x={x} y="148" textAnchor="middle" fontFamily="var(--font-sans)" fontSize="10" fontWeight="600" fill={BRAND_SECONDARY}>STEP {s.num}</text>
              {i < steps.length - 1 && (
                <path d={`M ${x + 30} 100 L ${x + 116} 100 M ${x + 110} 96 L ${x + 116} 100 L ${x + 110} 104`} fill="none" stroke={BRAND_TERTIARY} strokeWidth="1.4" />
              )}
            </g>
          )
        })}
      </svg>
    </div>
  )
}
```

**ViewBox safety**: 5 steps × 150px stride + 60px left padding = 810px usable; viewBox is 720 — adjust to `60 + (n-1)*stride` if you have more/fewer steps.

### 2. LayeredArchitecture — Security / Architecture Pages

3 columns of layered components (e.g., encryption layers, trust boundaries). Each column has a colored header strip + 3 stacked items inside soft chips. Cross-column arrows imply data flow.

```tsx
export function LayeredArchitecture({ className = '' }: DiagramProps) {
  // Replace with project-specific layers + items
  const layers = [
    { title: 'Local store', tone: BRAND_PRIMARY, items: [
      { k: 'API keys', v: 'safeStorage (Keychain)' },
      { k: 'Sessions', v: 'credentialStore' },
      { k: 'Email body', v: 'AES-256 (crypto-js)' },
    ]},
    { title: 'Transport', tone: BRAND_SECONDARY, items: [
      { k: 'Client ↔ Server', v: 'HTTPS / TLS 1.3' },
      { k: 'Auth', v: 'JWT access + refresh' },
      { k: 'AI streaming', v: 'SSE over HTTPS' },
    ]},
    { title: 'Server', tone: BRAND_TERTIARY, items: [
      { k: 'Password hash', v: 'bcrypt (cost=12)' },
      { k: 'Sensitive cols', v: 'AES-256 (crypto-js)' },
      { k: 'Upstream API key', v: 'Server-only persistence' },
    ]},
  ]
  return (
    <div className={`card !p-6 md:!p-8 overflow-hidden ${className}`}>
      <svg viewBox="0 0 720 280" className="w-full h-auto" role="img" aria-label="Three-layer encryption architecture diagram">
        {layers.map((layer, i) => {
          const x = 30 + i * 230
          return (
            <g key={layer.title}>
              <rect x={x} y={30} width="200" height="220" rx="14" fill={CARD_BG} stroke={STROKE_FAINT} />
              <rect x={x} y={30} width="200" height="34" rx="14" fill={layer.tone} />
              <text x={x + 38} y={52} fontFamily="var(--font-sans)" fontSize="12" fontWeight="700" fill={CARD_BG}>{layer.title}</text>
              {layer.items.map((item, j) => (
                <g key={item.k} transform={`translate(${x + 16},${82 + j * 50})`}>
                  <text x="0" y="0" fontFamily="var(--font-sans)" fontSize="10" fontWeight="600" fill={BRAND_PRIMARY}>{item.k}</text>
                  <rect x="0" y="8" width="168" height="22" rx="6" fill="rgba(42,64,50,0.05)" />
                  <text x="8" y="22" fontFamily="var(--font-mono)" fontSize="9" fill={TEXT_FAINT}>{item.v}</text>
                </g>
              ))}
              {i < layers.length - 1 && (
                <path d={`M ${x + 200} 140 L ${x + 224} 140 M ${x + 218} 136 L ${x + 224} 140 L ${x + 218} 144`} fill="none" stroke={BRAND_TERTIARY} strokeWidth="1.4" strokeDasharray="4 3" />
              )}
            </g>
          )
        })}
      </svg>
    </div>
  )
}
```

### 3. DualPathDecision — Architecture Pages with Branching

A request → router diamond → two parallel paths → unified output. Each path has its own colored header. Useful for engine routing, traffic splits, A/B paths.

```tsx
export function DualPathDecision({ className = '' }: DiagramProps) {
  return (
    <div className={`card !p-6 md:!p-8 overflow-hidden ${className}`}>
      <svg viewBox="0 0 720 320" className="w-full h-auto" role="img" aria-label="Dual-engine routing diagram">
        {/* Source */}
        <g transform="translate(20,124)">
          <rect width="120" height="72" rx="14" fill={CARD_BG} stroke={STROKE_FAINT} />
          <text x="60" y="28" textAnchor="middle" fontFamily="var(--font-sans)" fontSize="11" fontWeight="600" fill={BRAND_PRIMARY}>User request</text>
        </g>
        {/* Router */}
        <g transform="translate(180,140)">
          <path d="M 40,0 L 80,40 L 40,80 L 0,40 Z" fill={CARD_BG} stroke={BRAND_PRIMARY} strokeWidth="1.6" />
          <text x="40" y="46" textAnchor="middle" fontFamily="var(--font-sans)" fontSize="10" fontWeight="600" fill={BRAND_PRIMARY}>Router</text>
        </g>
        {/* Top path */}
        <g transform="translate(308,32)">
          <rect width="200" height="100" rx="14" fill={CARD_BG} stroke={BRAND_PRIMARY} strokeWidth="1.4" />
          <rect width="200" height="22" rx="14" fill={BRAND_PRIMARY} />
          <text x="100" y="15" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="10" fontWeight="700" fill={CARD_BG}>DirectEngine</text>
          <text x="14" y="44" fontFamily="var(--font-sans)" fontSize="10" fontWeight="600" fill={BRAND_PRIMARY}>User-owned model</text>
          <text x="14" y="62" fontFamily="var(--font-mono)" fontSize="9" fill={TEXT_FAINT}>safeStorage / Keychain</text>
        </g>
        {/* Bottom path */}
        <g transform="translate(308,196)">
          <rect width="200" height="100" rx="14" fill={CARD_BG} stroke={BRAND_SECONDARY} strokeWidth="1.4" />
          <rect width="200" height="22" rx="14" fill={BRAND_SECONDARY} />
          <text x="100" y="15" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="10" fontWeight="700" fill={CARD_BG}>ProxyEngine</text>
          <text x="14" y="44" fontFamily="var(--font-sans)" fontSize="10" fontWeight="600" fill={BRAND_PRIMARY}>Org-managed model</text>
          <text x="14" y="62" fontFamily="var(--font-mono)" fontSize="9" fill={TEXT_FAINT}>/api/ai/execute</text>
        </g>
        {/* Connectors source → router → paths */}
        <path d="M 140,160 L 180,180" fill="none" stroke={BRAND_TERTIARY} strokeWidth="1.4" strokeDasharray="4 3" />
        <path d="M 260,170 C 280,140 290,100 308,82" fill="none" stroke={BRAND_PRIMARY} strokeWidth="1.4" strokeDasharray="4 3" />
        <path d="M 260,210 C 280,230 290,250 308,246" fill="none" stroke={BRAND_SECONDARY} strokeWidth="1.4" strokeDasharray="4 3" />
        {/* Sink */}
        <g transform="translate(548,124)">
          <rect width="152" height="72" rx="14" fill={CARD_BG} stroke={STROKE_FAINT} />
          <text x="76" y="22" textAnchor="middle" fontFamily="var(--font-sans)" fontSize="11" fontWeight="600" fill={BRAND_PRIMARY}>SSE streaming</text>
        </g>
        <path d="M 508,82 C 540,82 540,150 548,150" fill="none" stroke={BRAND_PRIMARY} strokeWidth="1.4" strokeDasharray="4 3" />
        <path d="M 508,246 C 540,246 540,170 548,170" fill="none" stroke={BRAND_SECONDARY} strokeWidth="1.4" strokeDasharray="4 3" />
      </svg>
    </div>
  )
}
```

### 4. HubAndSpokePanorama — Integration Pages

Central node + radial spokes to N integration partners. Each spoke has a small dot at the orbit + an off-orbit label card.

**ViewBox safety (CRITICAL):** Top label at angle `-90°` and bottom label at angle `+90°` are the most likely to clip. With `cy + (r + labelOffset) > viewBox.height - 8`, the bottom label clips. Always verify visually after generating. The default below uses `cy = viewBox.height/2 + 30` to leave more room below for the "annotation badge".

```tsx
export function HubAndSpokePanorama({ className = '' }: DiagramProps) {
  // Distribute N branches around the circle, biased so labels fit
  const branches = [
    { angle: -150, label: 'Upstream AI', sub: 'OpenAI / VolcEngine', tone: BRAND_PRIMARY },
    { angle: -90,  label: 'MCP protocol', sub: 'GitHub / Notion / internal', tone: BRAND_SECONDARY },
    { angle: -30,  label: 'OAuth', sub: 'Google / Microsoft', tone: BRAND_PRIMARY },
    { angle: 30,   label: 'Presenton', sub: 'PPT engine', tone: BRAND_TERTIARY },
    { angle: 90,   label: 'Remote OctoReport', sub: 'integration_key server-only', tone: BRAND_SECONDARY },
    { angle: 150,  label: 'Web tools', sub: 'webSearch / urlFetch', tone: BRAND_TERTIARY },
  ]
  const cx = 360
  const cy = 220   // shifted DOWN so the top label has headroom
  const r = 130
  const labelOffset = 60
  return (
    <div className={`card !p-6 md:!p-8 overflow-hidden ${className}`}>
      <svg viewBox="0 0 720 460" className="w-full h-auto" role="img" aria-label="Integration panorama">
        <circle cx={cx} cy={cy} r={r + 8} fill="none" stroke={STROKE_FAINT} strokeDasharray="3 4" />
        {branches.map((b) => {
          const rad = (b.angle * Math.PI) / 180
          const x = cx + Math.cos(rad) * r
          const y = cy + Math.sin(rad) * r
          const labelX = cx + Math.cos(rad) * (r + labelOffset)
          const labelY = cy + Math.sin(rad) * (r + labelOffset)
          return (
            <g key={b.label}>
              <line x1={cx} y1={cy} x2={x} y2={y} stroke={b.tone} strokeWidth="1.4" strokeDasharray="4 3" opacity="0.7" />
              <circle cx={x} cy={y} r="8" fill={CARD_BG} stroke={b.tone} strokeWidth="1.6" />
              <circle cx={x} cy={y} r="3" fill={b.tone} />
              <g transform={`translate(${labelX},${labelY})`}>
                <rect x="-72" y="-22" width="144" height="40" rx="10" fill={CARD_BG} stroke={STROKE_FAINT} />
                <text x="0" y="-5" textAnchor="middle" fontFamily="var(--font-sans)" fontSize="10" fontWeight="700" fill={BRAND_PRIMARY}>{b.label}</text>
                <text x="0" y="11" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="8" fill={TEXT_FAINT}>{b.sub}</text>
              </g>
            </g>
          )
        })}
        <circle cx={cx} cy={cy} r="50" fill={BRAND_PRIMARY} />
        <text x={cx} y={cy - 4} textAnchor="middle" fontFamily="var(--font-sans)" fontSize="14" fontWeight="700" fill={CARD_BG}>ProductName</text>
        <text x={cx} y={cy + 14} textAnchor="middle" fontFamily="var(--font-mono)" fontSize="9" fill={CARD_BG} opacity="0.85">desktop client</text>
      </svg>
    </div>
  )
}
```

### 5. EventTimeline — Audit / Activity Log Pages

Horizontal timeline with N event cards along a baseline. Each card shows a typed header (event type), an actor, and 3 mock detail bars. Time labels sit below. Legend explains the color coding.

```tsx
export function EventTimeline({ className = '' }: DiagramProps) {
  // Replace with project-specific event types + realistic timestamps
  const events = [
    { t: '14:02:11', type: 'AI_CALL',     actor: 'agent.assistant', tone: BRAND_PRIMARY },
    { t: '14:03:47', type: 'EMAIL_SEND',  actor: 'user',            tone: BRAND_SECONDARY },
    { t: '14:05:09', type: 'BASH_EXEC',   actor: 'agent.coder',     tone: BRAND_PRIMARY },
    { t: '14:08:33', type: 'MCP_CALL',    actor: 'github.search',   tone: BRAND_TERTIARY },
    { t: '14:11:02', type: 'FILE_EDIT',   actor: 'user',            tone: BRAND_SECONDARY },
  ]
  return (
    <div className={`card !p-6 md:!p-8 overflow-hidden ${className}`}>
      <svg viewBox="0 0 720 240" className="w-full h-auto" role="img" aria-label="Audit event timeline">
        <text x="20" y="22" fontFamily="var(--font-sans)" fontSize="11" fontWeight="600" fill={BRAND_PRIMARY}>/api/audit/logs · 2026-05-07</text>
        <text x="20" y="38" fontFamily="var(--font-mono)" fontSize="9" fill={TEXT_FAINT}>mock — full request/response captured</text>
        <line x1="60" y1="140" x2="700" y2="140" stroke={STROKE_FAINT} strokeWidth="1.4" />
        {events.map((e, i) => {
          const x = 90 + i * 130
          return (
            <g key={e.t}>
              <line x1={x} y1="135" x2={x} y2="145" stroke={e.tone} strokeWidth="1.6" />
              <rect x={x - 56} y="58" width="112" height="68" rx="10" fill={CARD_BG} stroke={STROKE_FAINT} />
              <rect x={x - 56} y="58" width="112" height="18" rx="10" fill={e.tone} />
              <text x={x} y="71" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="9" fontWeight="700" fill={CARD_BG}>{e.type}</text>
              <text x={x} y="92" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="9" fill={BRAND_PRIMARY}>{e.actor}</text>
              <rect x={x - 40} y="100" width="80" height="3" rx="1.5" fill={STROKE_FAINT} />
              <rect x={x - 40} y="108" width="56" height="3" rx="1.5" fill={STROKE_FAINT} />
              <rect x={x - 40} y="116" width="68" height="3" rx="1.5" fill={STROKE_FAINT} />
              <line x1={x} y1="126" x2={x} y2="135" stroke={STROKE_MEDIUM} strokeWidth="1.2" strokeDasharray="2 2" />
              <text x={x} y="160" textAnchor="middle" fontFamily="var(--font-mono)" fontSize="9" fill={TEXT_FAINT}>{e.t}</text>
            </g>
          )
        })}
      </svg>
    </div>
  )
}
```

### Per-Page Insertion

After exporting from `Diagrams.tsx`, import into the corresponding `content.tsx`:

```tsx
import { HorizontalStepFlow } from '../_components/Diagrams'

// inside the section:
<SectionHeading id="five-steps">5 步部署流程</SectionHeading>
<div className="mt-8">
  <HorizontalStepFlow />
</div>
```

For pages with multiple diagrams (e.g., security: encryption layers + audit timeline), import multiple named exports — they share the color constants, no per-import drift.
