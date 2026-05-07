# Phase 5: Validation Rules

Detailed checklist for Phase 5 validation. Read this file before starting Phase 5. Covers the two-pass completeness audit (5.0), TypeScript/lint checks (5.1), AI-friendly/SEO validation (5.2), content quality audit (5.3), and the visual review prompt (5.4).

After generation, run ALL checks in order. Do not skip any.

## Contents

- **5.0 Implementation Completeness Verification** — Two-pass self-audit (Pass 1 plan-vs-output, Pass 2 structural integrity)
- **5.1 Technical Validation** — TypeScript check, lint, i18n key consistency
- **5.2 AI-Friendly & SEO Validation** — Heading IDs, llms.txt, Server/Client split, JSON-LD, sitemap/robots, hreflang
- **5.3 Content Quality Audit** — Re-verify claims, check specificity, bilingual quality
- **5.4 Visual Review Prompt** — Tell user how to launch dev server and preview
- **5.5 Cross-Cutting Guards** — Final sweep before CP3: diagram validation (format + content authenticity), quantitative claim re-verification (with drift threshold + aggregate consistency), stale tech token sweep (incl. negation-context leaks)

## 5.0 Implementation Completeness Verification

**This step runs FIRST in Phase 5 — before any other validation.** Its purpose is to catch structural omissions (missing files, missing sections, missing navigation) that technical checks like `tsc` won't detect. This is split into two passes for thoroughness.

### Pass 1: Plan-vs-Output Audit

Compare the approved Content Outline (from CP2) and Phase 4 plan against what was actually generated. Check **every** item in this table:

```
## Implementation Audit — Pass 1: Plan vs Output

### File Structure
| Planned | Expected File | Exists? | Status |
|---------|--------------|---------|--------|
| Overview page | app/docs/page.tsx | ✅/❌ | |
| Overview content | app/docs/content.tsx | ✅/❌ | |
| Docs layout (if 2+ pages) | app/docs/layout.tsx | ✅/❌ | |
| Sub-page: Self-Host | app/docs/self-host/page.tsx | ✅/❌ | |
| ... (all planned pages) | | | |

### Content Sections & Feature Completeness (per page)
For each page, verify every section from the CP2 outline exists AND feature descriptions meet tier-appropriate depth:
| Page | Section from Outline | In Generated Code? | Tier | Word Count | Status |
|------|---------------------|-------------------|------|------------|--------|
| /docs | Hero (badge + title + subtitle) | ✅/❌ | — | — | |
| /docs | "What is [Project]?" | ✅/❌ | — | [N] words | |
| /docs | Core Concepts ([N] cards) | ✅/❌ | — | — | |
| /docs | Feature: Agent Registry | ✅/❌ | T1 | [N] words (need 150-250) | ✅/⚠️ |
| /docs | Feature: Approvals | ✅/❌ | T1 | [N] words (need 150-250) | ✅/⚠️ |
| /docs | Feature: Config Mgmt | ✅/❌ | T2 | [N] words (need 50-100) | ✅/⚠️ |
| /docs | How It Works ([N] steps) | ✅/❌ | |
| /docs | Tech Stack table | ✅/❌ | |
| /docs | Quick Start | ✅/❌ | |
| /docs | Documentation Navigation | ✅/❌ | |
| /docs | CTA | ✅/❌ | |
| /docs | Footer | ✅/❌ | |

### Navigation Layout (from Step 3.3.1)
| Check | Condition | Status |
|-------|-----------|--------|
| Layout mode matches choice | Mode A/B/C from CP2 | ✅/❌ |
| layout.tsx exists | Mode B or C only | ✅/❌/N/A |
| layout.tsx type correct | Header nav (B) or Sidebar nav (C) | ✅/❌/N/A |
| Mobile navigation works | Mode B: hamburger→dropdown; Mode C: hamburger→drawer | ✅/❌/N/A |
| Sidebar page grouping matches plan | Mode C only | ✅/❌/N/A |

### Structural Components
| Component | Condition | Exists? | Status |
|-----------|-----------|---------|--------|
| CMD+K search component | Mode B or C (skip for Mode A) | ✅/❌/N/A | |
| SectionHeading usage | All h2/h3 tags | ✅/❌ | |
| On-page TOC (right-side) | Mode A: always; Mode B/C: pages with 5+ sections | ✅/❌ | |
| Breadcrumbs | Mode B/C, sub-pages | ✅/❌/N/A | |
| Prev/Next navigation | Mode B/C | ✅/❌/N/A | |
| Callout components | Warnings/tips in content | ✅/❌ | |
| Navigation links updated | Homepage docs link points to /docs | ✅/❌ | |
| Page metadata (title + description + OG + Twitter) | Every page.tsx | ✅/❌ | |
| Canonical URLs | Every page.tsx | ✅/❌ | |
| JSON-LD structured data | Every page.tsx | ✅/❌ | |

### Ancillary Files
| File | Required | Exists & Updated? | Status |
|------|----------|-------------------|--------|
| public/llms.txt | Always | ✅/❌ | |
| public/llms-full.txt | Always | ✅/❌ | |
| <link rel="llms-txt"> in root layout | Always | ✅/❌ | |
| app/sitemap.ts (docs entries) | SEO = Yes | ✅/❌/N/A | |
| app/robots.ts (allows /docs + AI crawlers) | SEO = Yes | ✅/❌/N/A | |
| BreadcrumbList JSON-LD (sub-pages) | SEO = Yes | ✅/❌/N/A | |
| FAQPage JSON-LD (pages with FaqItem) | SEO = Yes, if applicable | ✅/❌/N/A | |
| SoftwareApplication JSON-LD (/docs) | SEO = Yes | ✅/❌/N/A | |
| hreflang in metadata | SEO = Yes + i18n-Multi | ✅/❌/N/A | |
| robots: { index: false } in metadata | SEO = No | ✅/❌/N/A | |

### i18n Completeness
| Check | Status |
|-------|--------|
| All sections have i18n keys (no hardcoded text) | ✅/❌ |
| Keys in en-US.json | ✅/❌ |
| Keys in zh-CN.json | ✅/❌ |
| Key counts match between files | ✅/❌ |
```

**Action on ❌**: For each missing item, immediately generate/fix it before proceeding to Pass 2. This includes creating missing files, adding missing sections to existing files, and updating navigation.

### Pass 2: Structural Integrity Check

After Pass 1 gaps are fixed, verify the generated output works as a coherent whole. This pass catches integration issues that Pass 1's item-by-item check misses.

1. **Read every generated file end-to-end** — not just spot-checking sections. Verify:
   - Imports are complete (no missing component references)
   - Components referenced in JSX are defined or imported
   - i18n keys used in `t("...")` calls exist in the language files
   - Internal `<Link href="...">` targets exist as actual routes

2. **Navigation coherence** (layout-specific):
   - **Mode A (one-page)**: Right-side TOC lists all major sections? Anchor IDs match TOC items? Smooth scroll works?
   - **Mode B (header nav)**: Header lists ALL generated pages? Mobile hamburger menu includes all pages? Active page highlighting works?
   - **Mode C (sidebar nav)**: Sidebar groups include ALL generated pages? Page grouping matches Step 3.3.1 plan? Mobile drawer includes all groups? Active page highlighting works?
   - All layouts: "Back to Home" link points to valid route? Nav order is logical (Overview first, then by importance)?

3. **Cross-page consistency**:
   - Do all pages use the same spacing convention (e.g., `mb-12` between sections)?
   - Do all pages use `SectionHeading` for h2/h3 (not bare `<h2>` tags)?
   - Is the nav order logical and matches PrevNextNav link order?

4. **Feature card count verification**:
   - Count feature cards in generated code vs planned count in outline
   - If mismatch: identify which features were dropped and add them

```
## Implementation Audit — Pass 2: Structural Integrity

| Check | Result | Action |
|-------|--------|--------|
| All imports resolve | ✅/❌ — [details] | [fix if needed] |
| All t() keys exist in i18n | ✅/❌ — [N] keys checked | [add missing] |
| All internal links valid | ✅/❌ — [details] | [fix routes] |
| Layout nav lists all pages | ✅/❌ — [N] pages in nav vs [N] generated | [add missing] |
| SectionHeading on all h2/h3 | ✅/❌ — [N] headings checked | [replace bare h2] |
| Feature card count matches | ✅/❌ — [N] planned vs [N] generated | [add missing] |
| Cross-page spacing consistent | ✅/❌ | [standardize] |
```

**Action on ❌**: Fix each issue immediately. After all fixes, do NOT re-run the full audit — proceed to 5.1 Technical Validation, which will catch any remaining code errors.

**IMPORTANT**: Do NOT present Pass 1/Pass 2 results to the user as a checkpoint. This is an internal self-check. Fix issues silently and proceed. The user sees results at CP3.

## 5.1 Technical Validation

1. **TypeScript check**: Run `npx tsc --noEmit` (or project's typecheck command from CLAUDE.md)
2. **Lint check**: Run the project's lint command
3. **i18n check**:
   - Run project's i18n check script if available (e.g., `npm run i18n:check`)
   - If no script: manually verify both language files have matching keys

## 5.2 AI-Friendly & SEO Validation

**AI-readability checks** (always run):

1. Verify all `<h2>`/`<h3>` tags have `id` attributes
2. Verify `public/llms.txt` and `public/llms-full.txt` exist and reflect the new docs
3. Verify `<link rel="llms-txt">` exists in root layout's `<head>`
4. Verify the page is a Server/Client split (page.tsx exports metadata, content.tsx has "use client")
5. Verify each `page.tsx` contains `<script type="application/ld+json">` tag(s) with valid JSON-LD (`@context`, `@type`, `headline`, `description` fields present)

**SEO checks** (conditional on Step 3.2 toggle):

**If SEO = Yes** — full discoverability validation:

6. **Sitemap**: Verify `app/sitemap.ts` exists and includes entries for ALL generated docs pages (count must match).
7. **Robots**: Verify `app/robots.ts` (or `public/robots.txt`) does not disallow `/docs`. Verify AI crawler rules (GPTBot, ChatGPT-User, etc.) are present.
8. **Metadata completeness** per page — verify each `page.tsx` has:
   - Title under 60 chars, containing primary keyword from keyword map
   - Description under 160 chars, containing primary + secondary keyword
   - `robots` with `"max-snippet": -1, "max-image-preview": "large"`
   - Page metadata does NOT contain `index: false`
9. **Keyword placement** — for each page, verify:
   - H1 (hero title) contains primary keyword (only ONE h1 per page)
   - Primary keyword appears in the first 100 words of body content
   - URL slug is short and keyword-containing
10. **hreflang** (when i18n-Multi): Verify `alternates.languages` is set in Metadata with correct locale-URL mappings.
11. **Structured data richness** — verify:
    - Sub-pages have `BreadcrumbList` JSON-LD with correct hierarchy
    - Pages with FaqItem components have `FAQPage` JSON-LD with matching Q&A pairs
    - Overview page (`/docs`) has `SoftwareApplication` JSON-LD
    - Getting Started page has `HowTo` JSON-LD with `HowToStep` items
12. **Internal link quality**: Verify anchor text on internal `<Link>` tags is descriptive (not "click here" or "learn more" without context).

**If SEO = No**:

6. Verify every docs `page.tsx` has `robots: { index: false, follow: false }` in its Metadata export.
7. Verify docs pages are NOT listed in `app/sitemap.ts`.
8. Verify no BreadcrumbList/FAQPage/SoftwareApplication JSON-LD was generated (skip rich structured data when noindex).
9. Verify each docs `page.tsx` still has basic JSON-LD (`TechArticle` or `HowTo` primary schema) — required regardless of SEO toggle for AI readability (see `generation-rules.md` section 4.5F).

## 5.3 Content Quality Audit

**This is REQUIRED — not optional.** Technical validation catches code errors; content audit catches documentation errors.

### 5.3.1 Claim Verification Sweep

Re-verify ALL feature claims in the generated i18n content against the codebase:

1. Extract every capability claim from the generated en-US.json docs section
2. For each claim, Grep the codebase for evidence (function name, class, endpoint)
3. Report results:

```
## Content Verification Results

| Claim | Search Term | Found In | Status |
|-------|------------|----------|--------|
| "SSE event streaming" | "SSE\|EventSource\|text/event-stream" | routers/events.py:45 | ✅ |
| "budget circuit-breakers" | "circuit.break\|budget.limit" | services/cost.py:89 | ✅ |
| "model routing optimization" | "model.rout\|routing.optim" | — | ❌ REMOVE |
```

Fix any ❌ claims: remove from i18n content or rephrase to match reality.

### 5.3.2 Content Specificity Check

Scan generated descriptions for vague language. Flag any description that:
- Uses only adjectives without concrete details ("powerful", "comprehensive", "robust", "seamless")
- Doesn't mention at least one specific mechanism, number, or protocol
- Could apply to ANY product (not specific to THIS project)

For each flagged description, enrich with a specific detail from the codebase.

### 5.3.3 Bilingual / Single-Language Quality Check

**For i18n-Multi (zh-CN translations)**:
- Verify translations are natural Chinese, not word-for-word machine translation
- Technical terms should use industry-standard Chinese translations (e.g., "审计追踪" not "审核小道")
- Product names and protocol names (MCP, A2A, SSE) should remain in English
- Verify zh-CN descriptions convey the same meaning as en-US (not just similar)

**For i18n-None (inline text)**: confirm every generated string matches the project's primary content language. If existing pages use Chinese, every new section title / body / button / callout must be Chinese — never silently fall back to English. Quick check: `grep -E '[一-龥]' app/docs/**/content.tsx | wc -l` should return a non-trivial count when the project is Chinese-first.

## 5.4 Visual Review Prompt

Tell the user to run `pnpm dev` and:
- Visit `/docs` to preview the page
- Run `curl http://localhost:3000/docs 2>/dev/null | grep -c '<h2'` to verify SSR renders headings
- Check that anchor links work (e.g., `/docs#key-features`)

Report any errors and fix them before completing.

## 5.5 Cross-Cutting Guards (Final Sweep)

These guards lift specific Phase 4 / Update-Mode rules into Phase 5 so they're enforced even when first-time generation accidentally skips them. Run AFTER 5.0–5.3 and BEFORE the visual review prompt.

### 5.5.1 Diagram Validation

For every `<svg>` exported from `app/docs/_components/Diagrams.tsx` (or equivalent) and consumed on a page, verify:

**Format checks:**
- [ ] Has `role="img"` attribute
- [ ] Has a unique, project-specific `aria-label` (NOT "diagram", NOT lorem)
- [ ] Renders during SSR (test: `curl <docs-page> 2>/dev/null | grep -c '<svg' > 0`)
- [ ] Mock data has NO `Lorem`, `Foo`, `Bar`, `Item N`, `Event [A-Z]`, `Step \d` (without verb), `Engine A/B`, `T\d` placeholders — re-check against the bad/good table in `references/anti-patterns.md` #25
- [ ] Uses brand colors that match the project's existing palette (no fresh hex values; verify against `tailwind.config.*` or design tokens file)
- [ ] No labels clipped at viewBox edges (especially for radial / hub-and-spoke layouts at angles `±90°`). See `references/generation-rules.md` §4.9.6 for the verification recipe and `anti-patterns.md` #26 for the fix pattern.
- [ ] Centralized in `_components/Diagrams.tsx` — not scattered as inline `<svg>` blocks across `content.tsx` files

**Content authenticity checks** (this is critical — diagrams are documentation, not decoration):

For every text label rendered inside the SVG — every node title, chip label, actor name, endpoint string, provider name, event type, header bar, footer caption — verify it traces to a Phase 2B.3 evidence entry. A diagram with format-clean mock that names fictional services is worse than no diagram, because the visual is more memorable than the surrounding prose.

- [ ] Each engine / service / module name in the SVG appears in the project's actual source (grep the codebase to confirm)
- [ ] Each provider / vendor name (e.g., `OpenAI · 火山 · 阿里云`) reflects the **current** Phase 2B.6 config inventory — not aspirational integrations
- [ ] Each protocol / endpoint string (e.g., `/api/ai/execute`) is a route that currently exists in the project
- [ ] Each event-type chip (e.g., `AI_CALL`, `EMAIL_SEND`) maps to a real audit-action enum or audit-category from `shared/types/audit.ts` (or equivalent)
- [ ] Step labels in `HorizontalStepFlow` mirror the action verbs from the corresponding text content on the same page (`/docs/getting-started`)

**When this guard catches an issue, fix immediately** — don't defer to "next pass". Diagrams without a11y, with placeholder mock data, or with fictional node labels fail three downstream consumers at once: screen-reader users, AI-summarization tools, and human readers building a mental model of the system.

### 5.5.2 Quantitative Claim Re-Verification

Even if Phase 2B.4.1 already produced a Quantitative Claim Table, run it ONCE more against the **rendered** docs (not the planning doc).

**Step 1 — Extract every numeric claim** (use a generous unit list to catch project-specific terms):

```bash
grep -oE '[0-9]+\+?\s*(个|services|activities|handlers|API|endpoints|types?|primitives|Activity|ActivityId|Store|切片|审计类型|端点|组件|路由|插槽|插件|connectors?|providers?|agents?|tiers?|layers?)' \
  app/docs/**/content.tsx public/llms*.txt
```

Adapt the unit list to the project's actual vocabulary — sample the rendered docs to see what counter words appear, then expand the regex.

**Step 2 — For each match, identify the source-of-truth file** (`src/app/viewRegistry.ts`, `electron/services/builtinAgents.ts`, the IPC handler grep recipe, etc.). If no source-of-truth exists for a claim, the claim is fabricated and must be removed.

**Step 3 — Re-run the count** using the recipes in `content-mining.md` Step 2B.4.1.

**Step 4 — Apply the drift threshold to each claim.** The `+` suffix is a tolerance, not a forever-shield — re-count every release.

| Drift (`actual / claimed - 1`) | Action |
|---|---|
| ≤ 10% | OK — no change |
| 10–30% | Rewrite the number to fit (keep `+` suffix if originally used) |
| > 30% | Lock to a precise count, embed the source-of-truth path in a comment so future maintainers know where to re-count |
| > 50% | **HARD ERROR** — block CP3 until fixed; surface in CP3 output as a blocker |

**Step 5 — Aggregate consistency check** — when ANY single-item count drifts (e.g., "fileService ~20 IPC handlers" found drift), immediately re-count the related aggregate (e.g., total IPC handlers across the project). Aggregates almost always drift in the same direction:

| Single-item drift detected | Aggregate to re-verify |
|---|---|
| Per-service IPC handler count | Total IPC handlers (`grep -rE 'ipcMain\.handle\(' electron/`) |
| Per-API-group endpoint count | Total API endpoints (`grep -rE '\.(get\|post\|put\|delete\|patch)\(' server/src/api/`) |
| Per-Activity description | Total Activity count (registry / enum count) |
| Per-store entry list | Total store count (`find src/stores -name '*.ts' -not -name '*.test.*' \| wc -l`) |
| Per-feature service-tier listing | Total service count |

Real-world examples this check has caught: docs claimed "11 个 Activity" → reality 13 (drift +18%, → rewrite). Docs claimed "321+ IPC handlers" → reality 567 (drift +75%, → HARD ERROR, locked to "550+"). Both came to light only because Step 5 aggregate consistency was triggered after a single-item drift was found.

### 5.5.3 Stale Tech Token Sweep

For each token the project has explicitly retired (sources: `CLAUDE.md` "已移除"/"removed"/"deprecated" markers, ESLint `no-restricted-imports`, anti-regression CI gate workflows, saved memory entries), grep both code-generated docs AND `public/llms*.txt`:

```bash
# Replace TOKEN with each retired library/framework name
grep -rin 'TOKEN' app/docs/ public/llms*.txt
```

Any hit must be rewritten to reflect the **current** stack before publishing. Pay special attention to `public/llms.txt` and `public/llms-full.txt` — they're the AI-readable mirror of the docs and aren't visible in normal QA, so they drift fastest.

**Negation context is NOT a free pass** (see `anti-patterns.md` #23). Even if the sentence says "blocked", "removed", "已禁用", or "anti-regression", the token still leaks into AI-agent token-level scanners. Rewrite to category words (e.g., "blocks legacy external UI frameworks" instead of "blocks Fluent UI / Dockview"). In source comments / CHANGELOG the explicit name is fine — only `llms*.txt` is the AI-token surface.

## CP3 Output

**CHECKPOINT CP3**: Present the full validation results (technical + content audit + cross-cutting guards) to the user with preview instructions. Include:
- Technical check results (pass/fail)
- Content verification table (claims checked, any removed)
- Specificity improvements made
- **Diagram a11y + mock-data sweep results**
- **Quantitative claim re-verification table** (claims, source-of-truth, current count, status)
- **Stale tech token sweep** (tokens checked, any hits found and fixed)
- Preview instructions for visual review

This is the final checkpoint — the user should visually review the docs before accepting.
