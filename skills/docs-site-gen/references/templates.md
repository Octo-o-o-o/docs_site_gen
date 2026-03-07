# Code Templates

Large, copy-paste-ready code templates for docs generation. Referenced by `conventions.md` and SKILL.md at specific steps — only read this file when generating multi-page docs or when a specific template is needed.

## Docs Layout Template (Multi-Page)

When generating multiple docs pages, create a shared layout with sidebar navigation:

```tsx
// app/docs/layout.tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
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

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { t } = useTranslation();

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
        </div>
        <div className="flex items-center gap-2">
          <LanguageSwitcher />
          <ThemeToggle />
        </div>
      </nav>

      {children}
    </div>
  );
}
```

**When to use**: Create this layout when generating 2+ docs pages. Individual pages then omit their own nav and use `<main>` directly.

**Search integration**: When generating 2+ pages, also include the SearchButton and SearchDialog below in this layout.

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

- **Always include** when generating 2+ documentation pages
- **Skip** when generating a single standalone docs page (no multi-page navigation)
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
