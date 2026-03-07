# Phase 2B: Deep Content Mining

**CRITICAL**: This is where documentation content quality is determined. Do NOT skip or abbreviate these steps. The goal is to build a **verified feature inventory** — not by summarizing CLAUDE.md, but by reading actual source code.

## Step 2B.1: Feature Inventory Scan

Use the **Agent tool** (subagent_type: `Explore`) to perform a thorough codebase scan. Choose the scan profile that matches the project type:

**Profile A: Full-Stack / Backend-Heavy Projects** (has API routers, models, services):

Give the agent this prompt template (adapt paths to the project):

```
Scan this project's codebase and build a Feature Inventory Table. For each feature area, extract:

1. Backend routers/controllers (e.g., routers/*.py, routes/*.ts, controllers/*.ts):
   - Route prefix, all endpoints (HTTP method + path), docstrings
   - Count total endpoints per router
   - Key operations: CRUD, streaming (SSE/WebSocket), batch, webhooks

2. Data models/schemas (e.g., models/*.py, prisma/schema.prisma, entities/*.ts):
   - Table/collection name, key fields, relationships
   - API schemas: field names, types, validation rules

3. Service files (e.g., services/*.py, services/*.ts):
   - Business logic functions and purposes
   - External integrations (email, push, third-party APIs)
   - Background tasks, scheduled jobs

4. Frontend navigation and pages:
   - Menu items in shell/sidebar layout → user-visible feature areas
   - Page components and routes → the UX surface

Return results as a markdown table with columns:
| # | Feature Area | Backend Source | Endpoints | Key Operations | Data Models | Frontend Pages |
```

**Profile B: Frontend-Only Projects** (component libraries, static sites, frontend apps with no backend):

Give the agent this prompt template:

```
Scan this frontend project and build a Feature Inventory Table. For each feature area, extract:

1. Pages/routes (e.g., app/*/page.tsx, pages/*.tsx, src/routes/*):
   - Route path, page purpose, key components used

2. Components (e.g., components/*.tsx, src/components/**):
   - Component name, props interface, purpose
   - Complexity: simple (<50 lines) / medium (50-150) / complex (150+)

3. Hooks and utilities (e.g., hooks/*.ts, utils/*.ts, lib/*.ts):
   - Hook/utility name, what it does, which components use it

4. Configuration and build (e.g., next.config.*, vite.config.*, tailwind.config.*):
   - Key configuration choices, plugins, custom setup

Return results as a markdown table with columns:
| # | Feature Area | Source Files | Components | Key Functionality | Complexity | Pages Using It |
```

Compile results into a **Feature Inventory Table**:

```
| # | Feature Area | Backend Source | Endpoints | Key Operations | Data Models | Frontend Pages |
|---|---|---|---|---|---|---|
| 1 | Agent Registry | routers/agents.py | 12 | CRUD + WS + health | Agent, AgentConfig | /agents, /agents/[id] |
| 2 | Approvals | routers/approvals.py | 8 | Create + Review | ApprovalRequest, Rule | /approvals |
| 3 | Audit Trail | routers/audit.py | 5 | Search + Export | AuditEvent | /audit |
| ... | ... | ... | ... | ... | ... | ... |
```

## Step 2B.2: Feature Depth Classification

Classify each feature from the inventory into documentation depth tiers:

| Tier | Criteria | Docs Treatment |
|------|----------|---------------|
| **Tier 1: Hero Feature** | 8+ endpoints, complex data model, or core differentiator | Full section: 150-250 words, diagram or code example, explain the mechanism |
| **Tier 2: Core Feature** | 4-7 endpoints, clear user value | Feature card: 50-100 words, explain what + why, link to detail |
| **Tier 3: Supporting** | 1-3 endpoints, utility/config nature | Feature card: 20-40 words, brief mention |
| **Omit** | Internal-only, admin debug, or incomplete | Do NOT document — avoid documenting vaporware |

**Tier classification signals**:
- A feature with its own frontend page = at least Tier 2
- A feature mentioned in CLAUDE.md as a core value prop = at least Tier 1
- A feature with only GET endpoints and no dedicated UI = likely Tier 3
- A feature with `# TODO` or `# WIP` comments = Omit

## Step 2B.3: Content Evidence Collection

For each **Tier 1** and **Tier 2** feature, read the actual source code and collect:

1. **Verified capabilities** — list ONLY things the code actually implements:
   - Read the router file: what endpoints exist and what do they do?
   - Read the service file: what business logic runs?
   - Read the model: what data is stored?

2. **User-facing behavior** — how does the end user experience this feature?
   - What does the frontend page show?
   - What actions can the user take?
   - What is the workflow (input → processing → output)?

3. **Technical mechanism** — how does it work under the hood? (for architecture docs)
   - What protocols are used? (REST, WebSocket, SSE, etc.)
   - What external services are called?
   - What are the key data flows?

4. **Unique differentiators** — what makes this feature special compared to alternatives?
   - Cross-reference with CLAUDE.md value propositions
   - Note integration points between features (e.g., approvals + audit trail)

**Output format per feature**:
```
### Feature: [Name]
- Tier: [1/2/3]
- Source: [router file path]
- Verified capabilities: [bullet list of ONLY code-confirmed capabilities]
- User workflow: [1-2 sentence description of user experience]
- Technical detail: [mechanism, protocols, data flow]
- Differentiator: [what's special about this implementation]
- i18n content draft:
  - Title (en/zh): "..." / "..."
  - Description (en/zh): "..." / "..."
```

## Step 2B.4: Claim Verification

**MANDATORY before proceeding**: Cross-check ALL content from CLAUDE.md/README.md against code evidence:

| Claim from docs | Evidence in code | Status |
|-----------------|-----------------|--------|
| "anomaly detection" | `services/cost.py:AnomalyDetector` | Verified |
| "budget circuit-breakers" | `services/cost.py:check_budget_limit()` | Verified |
| "model routing optimization" | no matching code found | REMOVE |

Rules:
- **Verified**: Claim stays in documentation, reference the code path
- **Partial**: Rephrase to match what actually exists (e.g., "budget alerts" instead of "budget circuit-breakers" if only alerts exist)
- **Unverified**: REMOVE from documentation entirely — do not document features that don't exist
- **Planned**: If a feature is clearly planned (has TODO/WIP markers), mention it in a "Roadmap" section only, never in feature descriptions

## Step 2B.5: Project Identity Extraction

Beyond features, extract the project's identity for the docs narrative:

1. **One-line pitch**: What is this project in one sentence? (from CLAUDE.md or README)
2. **Problem statement**: What pain point does it solve? (derive from value proposition)
3. **Solution differentiator**: Why this project and not alternatives? (from CLAUDE.md + code analysis)
4. **Target audience**: Who uses this? (infer from frontend complexity, API design, deployment model)
5. **Maturity signal**: Is this alpha/beta/GA? (from version numbers, TODO density, test coverage)

## Step 2B.6: Configuration & Environment Scanning

Scan the project for all configuration points. This data feeds the optional **Configuration Reference** page (see Phase 3.3) — one of the most valuable pages for developers setting up the project.

1. **Environment variables**:
   - Read `.env.example`, `.env.local.example`, `.env.sample` — extract variable names, inline comments, default values
   - Grep `process.env.` and `import.meta.env.` across source files — extract variable names and the file+line where each is used
   - Read `docker-compose.yml` / `docker-compose.*.yml` — extract `environment:` blocks

2. **Config schemas** (if present):
   - Zod schemas (`z.object({...})`) in config/env files
   - Joi schemas (`Joi.object({...})`)
   - TypeScript interfaces/types explicitly named `*Config` or `*Options`
   - CLI argument definitions (yargs, commander, minimist)

3. **Build Configuration Inventory**:

```
| Variable / Option | Type | Default | Required | Source | Description |
|---|---|---|---|---|---|
| DATABASE_URL | string | — | Yes | .env.example:3, lib/db.ts:8 | PostgreSQL connection string |
| REDIS_URL | string | localhost:6379 | No | .env.example:5, lib/cache.ts:4 | Redis connection for caching |
| PORT | number | 3000 | No | server.ts:12 | HTTP server port |
```

**Extraction rules**:
- **Description**: Derive from variable name + usage context (read the file where it's consumed, not just where it's defined)
- **Type**: Infer from usage (`parseInt()` → number, URL pattern → string, `=== true` / `=== "true"` → boolean)
- **Required**: If no default exists AND the code throws or exits on missing value → required
- **Grouping**: Organize by category — Database, Authentication, External Services, Server, Feature Flags

**Skip this step if**: The project has fewer than 3 configuration points total.

## Step 2B.7: Verified Code Examples

Scan test files and example directories for real, working code snippets that can enhance documentation. These are preferred over synthesized examples because they are **proven to work** (they pass tests).

1. **Scan sources** (in priority order):
   - `examples/` or `example/` directory — purpose-built usage examples
   - `tests/` or `__tests__/` — test cases with clear input → output patterns
   - `README.md` code blocks — if they reference actual project APIs

2. **Selection criteria** — only extract examples that:
   - Demonstrate a Tier 1 or Tier 2 feature's primary use case
   - Have clear input and expected output (assertions count as output)
   - Are self-contained (don't require complex test fixtures or mocking)
   - Are short enough for documentation (≤15 lines of meaningful code)

3. **Output format**:

```
### Verified Code Examples

| Feature | Source | Code Snippet (summary) | Output / Assertion |
|---------|--------|----------------------|-------------------|
| Auth login | tests/auth.test.ts:47 | `await auth.login({email, password})` | `{ token: "eyJ...", expiresIn: 3600 }` |
| Agent register | examples/quickstart.ts:12 | `await api.agents.create({name, url})` | `{ id: "ag_...", status: "active" }` |
```

**Skip this step if**: The project has no test files and no `examples/` directory.

## Phase 2 Output: Content Discovery Report

Present a structured report to the user (NOT just "here's a summary"):

```
## Content Discovery Report

### Project Identity
- **Pitch**: [one-line]
- **Problem**: [one-line]
- **Differentiator**: [one-line]
- **Audience**: [inferred]
- **Maturity**: [alpha/beta/GA]

### Feature Inventory ([N] features discovered)

| # | Feature | Tier | Endpoints | Source | Verified Capabilities |
|---|---------|------|-----------|--------|----------------------|
| 1 | ... | T1 | 12 | routers/agents.py | CRUD, WebSocket health, auto-discovery |
| 2 | ... | T2 | 8 | routers/approvals.py | Create, review, escalate, audit |
| ... |

### Claim Verification
- [N] claims verified against code
- [N] claims removed (no code evidence)
- [N] claims rephrased (partial implementation)

### Configuration Inventory ([N] variables found)
| Variable | Type | Default | Required | Category |
|---|---|---|---|---|
| DATABASE_URL | string | — | Yes | Database |
| ... |

*(Omitted if <3 configuration points)*

### Verified Code Examples ([N] examples extracted)
| Feature | Source | Snippet Summary |
|---|---|---|
| Auth login | tests/auth.test.ts:47 | `await auth.login({...})` → token |
| ... |

*(Omitted if no test/example files found)*

### Content Gaps
- [Any important features that exist in code but are NOT mentioned in CLAUDE.md/README]
```

This report feeds directly into Phase 3 planning and Phase 4 content generation.
