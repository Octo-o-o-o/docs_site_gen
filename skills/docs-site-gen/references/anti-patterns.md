# Anti-Patterns and Troubleshooting

Common mistakes to avoid when using this skill, and solutions for frequent issues.

## Contents

- **Anti-Patterns 1–10**: Visual & structural — hardcoded colors, skipping design detection, monolithic components, i18n key mismatches, lazy-loaded content, missing heading IDs, ignoring existing components, overriding customizations, dynamic imports for docs, generating without reading
- **Anti-Patterns 11–15**: Content quality — CLAUDE.md-only paraphrasing, vague adjectives, skipping CP2 outline review, documenting vaporware, generic "how it works" steps
- **Anti-Patterns 16–28**: Update & layout & diagrams & numeric claims — full rewrite instead of incremental update, skipping codebase rescan, skipping completeness verification, guessing configuration, synthesizing code examples, wrong navigation layout for content volume, mixing nav patterns, leaving stale tech tokens after a stack migration, documenting counts without code verification (#24), SVG diagrams with placeholder/lorem mock data (#25), SVG diagrams with clipped labels at the viewBox edge (#26), **embedding retired tokens in anti-regression meta-descriptions (#27)** — yes, even when the surrounding sentence says "blocked / removed", **`+` suffix used as a forever-excuse against drift (#28)** — drift > 30% means rewrite, drift > 50% means hard error
- **Troubleshooting**: TypeScript errors, missing i18n keys, broken imports, JSON-LD parse failures
- **Recovery Steps**: What to do when generation halts partway

## Anti-Patterns

### 1. Hardcoding Colors

**Wrong:**
```tsx
<h2 style={{ color: "#1a1a1a" }}>Title</h2>
<div style={{ background: "#f5f5f5" }}>Content</div>
```

**Correct:**
```tsx
<h2 style={{ color: "var(--text-1)" }}>Title</h2>
<div style={{ background: "var(--bg-elevated)" }}>Content</div>
```

**Why**: Hardcoded colors break dark mode, ignore the project's design system, and make future theme changes impossible.

---

### 2. Skipping Design System Detection

**Wrong:** Jump straight to page generation using style preset colors.

**Correct:** Always run Phase 1 first, even for "simple" pages. A project with an existing design system will look broken if you apply preset colors on top of it.

---

### 3. Monolithic Components

**Wrong:**
```tsx
// page.tsx
"use client";
export default function DocsPage() {
  // 500+ lines of component + hooks + metadata
}
```

**Correct:**
```tsx
// page.tsx (Server Component — SEO metadata)
import type { Metadata } from "next";
import { PageContent } from "./content";
export const metadata: Metadata = { title: "...", description: "..." };
export default function Page() { return <PageContent />; }

// content.tsx (Client Component — interactive content)
"use client";
export function PageContent() { /* ... */ }
```

**Why**: Metadata exports only work in Server Components. The split also enables better SSR behavior.

---

### 4. Mismatched i18n Keys

**Wrong:** Add keys to en-US.json but forget zh-CN.json (or vice versa).

**Correct:** Always generate keys in BOTH files simultaneously. Run `npm run i18n:check` (or equivalent) to verify.

---

### 5. Lazy-Loading Documentation Content

**Wrong:**
```tsx
const [content, setContent] = useState("");
useEffect(() => {
  fetch("/api/docs").then(r => r.text()).then(setContent);
}, []);
```

**Correct:** Put all documentation text directly in the component. Use `useTranslation()` for i18n text — Next.js SSR renders it in the initial HTML.

**Why**: `curl` and AI tools won't see content loaded via `useEffect`. The text must be in the initial HTML response.

---

### 6. Bare Headings Without IDs

**Wrong:**
```tsx
<h2 className="text-xl font-semibold">{t("docs.title")}</h2>
```

**Correct:**
```tsx
<SectionHeading id="title">{t("docs.title")}</SectionHeading>
```

**Why**: Without `id` attributes, sections are not deep-linkable by AI tools or users.

---

### 7. Ignoring Existing Components

**Wrong:** Create a new `CodeBlock` component when the project already has one.

**Correct:** Check existing docs pages and component libraries first. Reuse before creating.

---

### 8. Overriding User Customizations

**Wrong:** When updating existing docs, overwrite the entire file — or overwrite a section that the user manually customized after initial generation.

**Correct:** Read the existing file, identify custom sections (non-standard headings, external references, opinionated text, HTML comments like `<!-- custom -->`), preserve them verbatim, and integrate updates around them. In Incremental Update Mode, use Step U4.2's custom content detection heuristics.

**Why**: Full rewrites destroy user customizations (custom FAQ entries, hand-written sections, tone adjustments). The Edit tool preserves context; the Write tool erases it.

---

### 9. Using Dynamic Imports for Docs Content

**Wrong:**
```tsx
const Content = dynamic(() => import("./content"), { ssr: false });
```

**Correct:**
```tsx
import { PageContent } from "./content";
```

**Why**: `ssr: false` prevents the content from being rendered in the initial HTML, breaking curl/AI accessibility.

---

### 10. Generating Without Reading

**Wrong:** Generate docs pages based only on CLAUDE.md or README without reading actual source code.

**Correct:** Read API routers, models, services, and existing pages to verify every feature claim is real. Use the Phase 2B Deep Content Mining protocol.

---

### 11. CLAUDE.md-Driven Content (Surface-Level Documentation)

**Wrong:**
```
// Read CLAUDE.md → paraphrase the feature list → generate i18n content
feature1Desc: "Unified governance for multi-agent orchestration"  // sounds good but is just CLAUDE.md rephrased
```

**Correct:**
```
// Read routers/agents.py → understand actual CRUD + WebSocket + health endpoints
// Read services/agent_service.py → understand registration, discovery, status tracking
// Read models/agent.py → understand Agent, AgentConfig, AgentStatus entities
// THEN write:
feature1Desc: "Register agents from any platform via REST API, monitor real-time health over WebSocket with 30-second offline detection, and manage configurations with version-controlled rollback"
```

**Why**: CLAUDE.md describes intent; source code describes reality. Documentation must reflect reality. When CLAUDE.md says "cost tracking with anomaly detection" but the code only has basic cost aggregation, documenting "anomaly detection" is dishonest.

---

### 12. Vague Adjective Descriptions

**Wrong:**
```json
{ "feature1Desc": "Powerful and comprehensive agent management capabilities" }
```

**Correct:**
```json
{ "feature1Desc": "Register, discover, and manage agents across platforms. CRUD API with WebSocket health monitoring, version-controlled config, and auto-discovery via MCP." }
```

**Why**: "Powerful" and "comprehensive" are meaningless — they could describe any product. Specific mechanisms (CRUD, WebSocket, version-controlled) tell the reader exactly what they get.

**Test**: Read your description and ask: "Could this sentence describe a competing product?" If yes, it's too vague.

---

### 13. Skipping Content Outline Review (CP2)

**Wrong:** Jump from Phase 2 analysis directly to generating page code, skipping the content outline.

**Correct:** Always draft a detailed content outline (Phase 3.4) and present it to the user at CP2. The outline maps every section to its source material and word count. The user reviews feature selection, depth, and narrative before any code is written.

**Why**: Generating 500+ lines of TSX + 100+ i18n keys based on assumptions is expensive to redo. A 50-line outline is cheap to revise. The outline is the user's last chance to say "feature X should be more prominent" or "you missed feature Y" before the effort is committed.

---

### 14. Documenting Vaporware

**Wrong:**
```json
{ "feature5Desc": "AI-powered anomaly detection with predictive alerts" }
// But the code only has: if cost > threshold: send_alert()
```

**Correct:**
```json
{ "feature5Desc": "Budget threshold alerts with configurable limits per agent" }
// Accurately reflects the actual implementation
```

**Why**: Users who try to use a documented feature and find it doesn't exist lose trust in ALL documentation. Phase 2B.4 claim verification exists specifically to prevent this.

---

### 15. Generic "How It Works" Steps

**Wrong:**
```
Step 1: Set up → Step 2: Configure → Step 3: Use
```

**Correct:**
```
Step 1: Connect — Register your agent platforms via REST API. Agents are auto-discovered through MCP.
Step 2: Monitor — Real-time activity feed via SSE, per-agent cost analytics, 30-second health checks.
Step 3: Govern — Configure approval rules for high-risk operations, set budget limits, define alert policies.
```

**Why**: Generic steps add no value. Each step should map to a real operation in the system, mentioning the actual mechanism (API, SSE, rules engine, etc.).

---

### 16. Full Rewrite When Update Was Requested

**Wrong:** User asks to "update the docs" → skill regenerates all files from scratch, losing custom content.

**Correct:** Enter Incremental Update Mode. Read existing files first (Step U1), detect deltas (Step U2), produce a targeted Update Plan (Step U3), then use Edit tool for surgical changes (Step U4).

**Why**: Full rewrites destroy user customizations (custom FAQ entries, hand-written sections, tone adjustments). The Edit tool preserves context; the Write tool erases it.

---

### 17. Updating Docs Without Re-scanning the Codebase

**Wrong:** User says "I added push notifications, update the docs" → just add a feature card based on the user's description without reading the code.

**Correct:** Always run Step U2 (Codebase Delta Analysis) — scan the actual new router/service files, understand what was implemented, then write the description from code evidence.

**Why**: The user's verbal description of a feature may not match its actual implementation. "Push notifications" might mean WebSocket-based, or FCM, or email — only the code tells the truth.

---

### 18. Skipping Implementation Completeness Verification

**Wrong:** Generate pages, run `tsc` and lint, then present CP3 — without checking whether all planned sections, files, and structural components were actually created.

**Correct:** Run Phase 5.0 (two-pass Implementation Completeness Verification) BEFORE technical checks. Pass 1 compares the CP2 outline against generated output item-by-item. Pass 2 reads all generated files end-to-end to verify structural integrity (imports, navigation, cross-page consistency).

**Why**: `tsc` only catches type errors — it won't notice a missing docs layout, a missing sidebar navigation, or a feature card that was planned but never generated. The most common omissions (missing layout.tsx, missing llms.txt update, missing navigation link) are structurally invisible to linters but immediately visible to users.

---

### 19. Guessing Configuration Descriptions

**Wrong:**
```
DATABASE_URL → "Database connection URL"  // guessed from variable name alone
```

**Correct:**
```
// Read lib/db.ts:8 → sees: const pool = new Pool({ connectionString: process.env.DATABASE_URL })
DATABASE_URL → "PostgreSQL connection string for the primary database pool (format: postgresql://user:pass@host:5432/db)"
```

**Why**: Variable names are often ambiguous. `REDIS_URL` could be for caching, session storage, or pub/sub — only reading the consumption site reveals the actual purpose. Phase 2B.6 requires reading the file where each variable is used, not just where it's defined.

---

### 20. Synthesizing Code Examples When Real Ones Exist

**Wrong:**
```tsx
// Quick Start code block — written from scratch
const client = new ProjectClient({ apiKey: "..." });
const result = await client.doSomething();  // may not match actual API
```

**Correct:**
```tsx
// from examples/quickstart.ts:12 — verified working code
const client = new ProjectClient({ apiKey: process.env.API_KEY });
const agent = await client.agents.create({ name: "my-agent", url: "https://..." });
// → { id: "ag_abc123", status: "active" }
```

**Why**: Synthesized examples may contain API errors (wrong method names, incorrect parameter shapes). Examples from test files or `examples/` directories are proven to compile and produce the expected output. Phase 2B.7 collects these specifically for documentation use.

---

### 21. Wrong Navigation Layout for Content Volume

**Wrong:** Using sidebar navigation for 2-3 pages (wastes screen space, makes sparse docs look empty), or forcing all content into one page when there are 6+ distinct topics (scroll fatigue, hard to find specific sections).

**Correct:** Follow the recommendation matrix in Step 3.3.1:
- 1 page → one-page with TOC (only option)
- 2-3 pages → one-page recommended, header nav available for Technical/Comprehensive depth
- 3-5 pages → header navigation
- 6+ pages → sidebar navigation

Always present the recommendation to the user and let them choose. If the user insists on a non-recommended layout, respect their choice.

---

### 22. Mixing Navigation Patterns

**Wrong:** Using a sidebar layout but also adding horizontal nav links in the header for the same pages, or adding a right-side TOC to every page in sidebar mode regardless of section count.

**Correct:** Pick ONE navigation pattern and commit to it. The layout modes are mutually exclusive. Right-side TOC is only added to pages with 5+ sections (except in one-page mode where it's always present).

---

### 23. Leaving Stale Tech Tokens After a Stack Migration

**Wrong:** The project has migrated away from a library or framework (e.g., the codebase explicitly retired Fluent UI, Dockview, or some legacy router), but the docs and especially `public/llms.txt` / `public/llms-full.txt` still list it. This happens because llms.txt is the AI-readable mirror of the docs and isn't visible during normal QA, so it drifts faster than on-page content. AI agents reading the public llms.txt then describe the project with a stack that no longer matches reality.

**How to detect:** During Update Mode U1, read CLAUDE.md / ESLint configs / CI gates / saved memory for "removed", "已移除", "deprecated", "anti-regression: blocked" markers. Then `grep` the docs folder AND `public/llms*.txt` for those exact tokens.

**Correct:** Treat llms.txt as a first-class doc surface. Every Update Mode run includes the stale-tech-token grep across both `app/docs/**` and `public/llms*.txt`, and rewrites every hit so the description matches the *current* code (e.g., "Fluent UI v9" → "in-house design-system (headless + Tailwind)"). Do not let an llms.txt change "wait for the next pass" — by then the AI search results have already cached the wrong stack.

---

### 24. Documenting Counts Without Code Verification

**Wrong:** "11 个 Activity 路由对应不同业务模块", "70+ services", "16+ API endpoints" — written from the previous version of the doc, never re-measured against the codebase. After a refactor the registry has 13 entries, the codebase has 73 services, the API has 17 endpoints; the doc still claims the old numbers. AI agents and human readers then give downstream consumers wrong totals.

**How to detect:** During every generation AND every update, run `content-mining.md` Step 2B.4.1 quantitative verification. For each numeric claim, identify the source-of-truth file (registry / enum / directory / `grep` recipe) and count today's value. Build the Quantitative Claim Table and treat any drift as a U4 update.

**Correct:** Treat numbers like API contracts — they have a source of truth. When you write "13 Activities" you must have just counted them. If a number fluctuates more than ±10%, use a `+` suffix (e.g., "70+ services") and re-measure each release; if a number is locked (e.g., "13 ActivityId defined in viewRegistry.ts §A.5.2"), tie it to a specific file path so future maintainers know where to re-count.

**Watch for the directory-vs-registry trap:** when the doc says "N modules" the user-facing count is almost always the registry / enum count, not the on-disk directory count. A registry can have 13 entries grouped into 11 directories (3 share a `hidden/` dir). State the discrepancy explicitly rather than picking the smaller number.

---

### 25. SVG Diagrams With Placeholder / Lorem Mock Data

**Wrong:** Generating an SVG diagram with content like `Item 1 / Item 2 / Item 3`, `Event A / Event B`, `User 1 / User 2`, `Step 1 / Step 2 / Step 3`, or generic timestamps `T1 / T2 / T3`. The diagram looks abstract — readers can't tell what the product actually does, and the visual fails to support the surrounding prose.

**How to detect:** After drawing a diagram, scan its rendered text for: `Lorem`, `Foo`, `Bar`, `Item N`, `Event [A-Z]`, `User \d`, `Provider \d`, `Step \d` (without verb), `Engine A/B`, `T\d`. Any hit is a quality bug.

**Correct:** Pull mock values from the project's actual material — Phase 2B.3 evidence collection (real capability names), Phase 2B.6 config inventory (real env vars), Phase 2B.7 verified code examples (real test data shapes). Examples:

| Domain | Bad mock | Good mock |
|---|---|---|
| Audit log timeline | `Event A / Event B / Event C` | `AI_CALL` `EMAIL_SEND` `BASH_EXEC` `MCP_CALL` `FILE_EDIT` |
| Engine names | `Engine A / Engine B` | `DirectEngine` / `ProxyEngine` (project's real names) |
| Provider chips | `Provider 1, 2, 3` | `OpenAI · 火山 · 阿里云` (real providers from Phase 2B.6) |
| Step labels | `Step 1, Step 2` | `01 Trial request → 02 Install client → 03 Connect server` |
| Actor field | `user1 / user2` | `agent.assistant`, `agent.coder`, `github.search`, `user` |
| API endpoint | `/api/x` | `/api/ai/execute`, `/api/audit/logs` |
| Timestamp | `T1 / T2 / T3` | `14:02:11 / 14:03:47 / 14:05:09` (monotonic, realistic gaps) |

Mock data in diagrams is **descriptive evidence**, not decoration. Treat it with the same rigor as the prose it supports.

---

### 26. SVG Diagrams With Clipped Labels

**Wrong:** A radial / circular diagram (e.g., hub-and-spoke panorama) where the topmost or bottommost label gets cut off by the SVG `viewBox`. Common cause: `cy + (r + labelOffset) > viewBox.height - 8` puts the bottom label below the viewBox.

**How to detect:** Open the rendered diagram at desktop viewport, screenshot the section, verify every label is fully inside the card. If your tooling permits `getBBox()`, compute each label's bounding box and assert `bbox.x ≥ 8 && bbox.y ≥ 8 && bbox.x + bbox.width ≤ viewBox.w - 8 && bbox.y + bbox.height ≤ viewBox.h - 8`.

**Correct:** Apply the rules in `generation-rules.md` 4.9.6:

1. Compute the **outermost label coordinate** (e.g., for a hub-and-spoke at angles `[-150,-90,-30,30,90,150]` with `r=130` and `labelOffset=60`, the topmost label is at `cy - (r + labelOffset)`).
2. Verify the outermost label's full bounding box (label width × label height) stays inside `viewBox` by **at least 8px on every side**.
3. If a label hangs off, fix in this preference order: (a) increase viewBox height/width, (b) shift `cx/cy` to recenter, (c) reduce `r`, (d) reduce label offset.

Real-world example: panorama diagram with 6 branches, viewBox `720 × 360`, `cy=170`, `r=130`, `labelOffset=60` → top label at `y = -20` (clipped). Fix: viewBox `720 × 460`, `cy=220` → all labels inside.

---

### 27. Embedding Retired Tokens in Anti-Regression Meta-Descriptions

**Wrong:** Writing about a CI gate / lint rule / migration history in a way that *names the retired tokens themselves* — for example, in `public/llms-full.txt`:

> "ESLint no-restricted-imports 反退化门强制阻止 Fluent UI / Dockview 等历史依赖回归。"

The author meant: "these libraries are blocked." But `llms.txt` / `llms-full.txt` are read by AI agents (Perplexity, Claude, GPT) at the **token** level, not the sentence level. Token-level scanners pick up `Fluent UI` and `Dockview` and conclude the project uses them — exactly the opposite of what was intended.

This is distinct from #23 (forgotten tokens that simply weren't updated). Here the token leak is intentional but the framing leaks the token anyway.

**How to detect:** During Phase 5.5.3 (or Update-Mode U1 stale-token grep), don't treat negation context (`不再用`, `已移除`, `禁用`, `blocked`, `removed`, `deprecated`, `legacy`) as a free pass. Any occurrence of a retired token in `public/llms*.txt` is a leak, full stop, regardless of surrounding sentence.

**Correct:** Replace specific token names with category words, OR move the meta-description out of `llms.txt`:

| Leaky | Token-safe |
|---|---|
| "blocks Fluent UI / Dockview from regression" | "blocks legacy external UI frameworks from regression" |
| "no longer uses Mongoose ORM" | "uses an in-house data layer; legacy ORM removed" |
| "old Express middleware deprecated in v3" | "v3 retired the previous Node middleware stack" |

Apply only to AI-readable surfaces (`public/llms*.txt`). Inside source comments / commit messages / CHANGELOG, naming the retired token is fine and useful.

---

### 28. `+` Suffix Used as a Forever-Excuse Against Drift

**Wrong:** Documenting "70+ services", "321+ IPC handlers", "10+ audit types" and treating `+` as license to skip re-counting forever. The `+` softens a number — it does NOT make it correct at any scale.

Real-world example: docs claimed "321+ IPC handlers" — actual count was 567 (drift = +75%). The `+` was technically truthful (567 > 321) but readers interpret `+` as "approximately N" or "slightly more than N", not "75% more than N".

**Threshold rule:**
- **Drift ≤ 10%**: `N+` is fine, no action required
- **Drift 10–30%**: rewrite to a tighter number with the same `+` style (e.g., `321+` → `550+` if reality is 567)
- **Drift > 30%**: lock to a precise count tied to a source-of-truth file path so future readers know where to re-verify (e.g., `567 IPC handlers (count: \`grep -rE "ipcMain\\.handle\\(" electron/\`)`)
- **Drift > 50%**: hard error during Phase 5.5.2 — block CP3 until fixed

**How to detect:** Phase 5.5.2 grep extracts every `\d+\+` claim, re-runs the count from the source-of-truth recipe, computes drift percentage, and applies the threshold rule above.

**Correct:** Re-count every `+` claim every release. The `+` is a tolerance, not a forever-shield.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `curl` returns empty `<div>` | Content loaded via `useEffect` | Move text to component body, use SSR |
| Dark mode colors wrong | Hardcoded hex values | Use CSS custom properties (`var(--*)`) |
| TypeScript errors after generation | Missing imports or wrong types | Run `npx tsc --noEmit` and fix reported errors |
| i18n check fails | Keys present in one language file but not the other | Add missing keys to both files |
| Anchor links don't work | Missing `id` on heading elements | Use `SectionHeading` component |
| Page flickers on load | Large client-side state initialization | Minimize client-only state; use CSS for initial layout |
| Styling inconsistent with rest of app | Didn't run Phase 1 design detection | Re-run Phase 1 and apply detected conventions |
| llms.txt stale | Generated docs but forgot to update llms.txt | Update `public/llms.txt` and `public/llms-full.txt` to reflect current docs (see `generation-rules.md` section 4.5C for formats) |
| Navigation links 404 | Generated page but didn't update route | Check `app/docs/` directory structure and layout nav |
| Fonts don't match | Applied style preset fonts over project fonts | Project fonts take priority (design system Level A/B) |
| Search component not working | Missing search index or wrong import | Verify search component setup per templates.md |
| Feature descriptions feel generic | Content derived from CLAUDE.md only, not source code | Re-run Phase 2B deep content mining, read actual router/service files |
| User says "this isn't what we do" | Documented features that don't exist or are mischaracterized | Run Phase 2B.4 claim verification, remove unverified claims |
| Content too thin / surface-level | Skipped Phase 2B or used Tier 3 depth for all features | Re-classify feature tiers, expand Tier 1 features to 150-250 words |
| Docs read like marketing copy | Used adjectives instead of mechanisms | Apply specificity check (Phase 5.3.2), replace every adjective with a concrete detail |
| User rejected content outline | Outline didn't match project priorities | Re-discuss with user at CP2, ask which features matter most |
| Missing sidebar/layout/nav | Layout file planned but never generated | Run Phase 5.0 Pass 1 file structure check, create missing layout.tsx |
| Sidebar feels empty / too sparse | Too few pages for sidebar layout | Switch to header nav (Mode B) or one-page (Mode A) per Step 3.3.1 |
| One-page too long to scroll | Too much content for single page | Switch to multi-page layout (Mode B or C) per Step 3.3.1 |
| Mobile nav broken | Layout template not responsive | Verify hamburger menu (Mode B) or slide-out drawer (Mode C) exists |
| Feature cards fewer than planned | Some features dropped during generation | Run Phase 5.0 Pass 2 feature count verification, add missing cards |
| Config descriptions don't match behavior | Description derived from variable name, not usage | Re-read the source file where variable is consumed (Phase 2B.6) |
| Quick Start code example has API errors | Example was synthesized, not extracted from tests | Check Phase 2B.7 for verified examples from test/example files |
| JSON-LD missing from page | Forgot to add script tag in page.tsx | Add `<script type="application/ld+json">` in Server Component (Phase 4.5F) |

## Recovery Steps

If a docs generation goes wrong:

1. **Check git diff** — review what changed and revert if needed
2. **Run validation** — `npx tsc --noEmit && pnpm lint && npm run i18n:check`
3. **Verify SSR** — `curl http://localhost:3000/docs 2>/dev/null | grep -c '<h2'` should return >0
4. **Check anchor links** — visit `/docs#section-id` to verify scrolling works
5. **Compare languages** — both i18n files should have identical key structures
