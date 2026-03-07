# Anti-Patterns and Troubleshooting

Common mistakes to avoid when using this skill, and solutions for frequent issues.

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
| llms.txt stale | Generated docs but forgot to update llms.txt | Re-run Phase 4.5C after any docs changes |
| Navigation links 404 | Generated page but didn't update route | Check `app/docs/` directory structure and layout nav |
| Fonts don't match | Applied style preset fonts over project fonts | Project fonts take priority (design system Level A/B) |
| Search component not working | Missing search index or wrong import | Verify search component setup per conventions.md |
| Feature descriptions feel generic | Content derived from CLAUDE.md only, not source code | Re-run Phase 2B deep content mining, read actual router/service files |
| User says "this isn't what we do" | Documented features that don't exist or are mischaracterized | Run Phase 2B.4 claim verification, remove unverified claims |
| Content too thin / surface-level | Skipped Phase 2B or used Tier 3 depth for all features | Re-classify feature tiers, expand Tier 1 features to 150-250 words |
| Docs read like marketing copy | Used adjectives instead of mechanisms | Apply specificity check (Phase 5.3.2), replace every adjective with a concrete detail |
| User rejected content outline | Outline didn't match project priorities | Re-discuss with user at CP2, ask which features matter most |
| Missing sidebar/layout/nav | Layout file planned but never generated | Run Phase 5.0 Pass 1 file structure check, create missing layout.tsx |
| Feature cards fewer than planned | Some features dropped during generation | Run Phase 5.0 Pass 2 feature count verification, add missing cards |

## Recovery Steps

If a docs generation goes wrong:

1. **Check git diff** — review what changed and revert if needed
2. **Run validation** — `npx tsc --noEmit && pnpm lint && npm run i18n:check`
3. **Verify SSR** — `curl http://localhost:3000/docs 2>/dev/null | grep -c '<h2'` should return >0
4. **Check anchor links** — visit `/docs#section-id` to verify scrolling works
5. **Compare languages** — both i18n files should have identical key structures
