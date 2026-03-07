# docs-site-gen

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

---

# docs-site-gen

一个 Claude Code 技能，通过阅读你的实际源代码来生成生产级文档网站 —— 而不是复述你的 README。

你已经发布了产品，现在用几分钟而不是几天来完成文档站。

## 问题

你用 Claude Code 或 Codex 以创纪录的速度构建了项目。但文档站呢？这仍然是一项手动苦差事 —— 撰写文案、设计布局、保持内容与代码同步、支持国际化、让 AI 也能读懂。这是最不起眼却最耗时的最后一公里。

## 这个技能做什么

`docs-site-gen` 是一个 [Claude Code 技能](https://docs.anthropic.com/en/docs/claude-code/skills)，用于生成和维护集成到你现有 Web 应用中的完整文档网站。它分 5 个阶段工作：

1. **设计系统检测** —— 读取你的 `globals.css`、Tailwind 配置和现有页面，匹配你项目的视觉风格。不会生成格格不入的通用模板。
2. **深度内容挖掘** —— 读取你的路由、模型和服务，构建经过验证的功能清单。文档中的每一项声明都可以追溯到真实代码。
3. **内容规划（需你审批）** —— 生成详细的内容大纲，将每个章节映射到其源文件。你审核通过后才会生成代码。
4. **页面生成** —— 输出 Next.js 页面组件，包含完整的 i18n、SEO 元数据、章节锚点和 `llms.txt`（AI 可读性）。
5. **验证** —— 两轮完整性审计 + `tsc` + lint + i18n 键值一致性检查。

### 核心特性

- **基于证据的内容**：读取实际源代码（路由、模型、服务）—— 而非 CLAUDE.md/README 摘要。功能描述包含真实机制（协议、数据流、API 端点），不是营销形容词。
- **8 种精选风格预设**：灵感来自 Stripe、Vercel、Tailwind、GitHub、Supabase、Linear、Anthropic 和 Notion 的文档站。或者自动检测你项目现有的设计系统。
- **默认 AI 友好**：通过 SSR 渲染的内容可用 `curl` 访问。所有标题都有章节锚点。自动生成 `llms.txt` 和 `llms-full.txt`，让其他 AI 工具可以阅读你的文档。
- **双语 i18n**：同时生成 `en-US` 和 `zh-CN`（或适配你项目的语言设置）。所有文本都通过 i18n —— 无硬编码文字。
- **增量更新**：当代码变更时，使用 Edit 工具精准更新文档，而非重新生成所有内容。保留你的自定义内容。
- **完整 SEO 元数据**：标题、描述、OpenGraph、Twitter 卡片、规范 URL —— 根据项目上下文按页面生成。
- **结构化组件**：页内目录、面包屑导航、上一页/下一页、提示/警告框 —— 根据页面结构自动包含。
- **3 个用户检查点**：你审批设计方向（CP1）、内容大纲（CP2）和最终产出（CP3）。没有你的认可，什么都不会发布。

## 环境要求

- **Claude Code**（或任何支持 Claude Code 技能的环境）
- Web 前端项目（推荐 Next.js App Router）
- Node.js + pnpm/npm（用于验证命令）

## 安装

### 方式 A：Claude Code CLI

```bash
claude skill install /path/to/docs-site-gen
```

### 方式 B：手动安装

将 `SKILL.md` 和 `references/` 目录复制到你的 Claude Code 技能目录：

```bash
# 克隆仓库
git clone https://github.com/Octo-o-o-o/docs_site_gen.git

# 复制到 Claude Code 技能目录
mkdir -p ~/.claude/skills/docs-site-gen
cp docs_site_gen/SKILL.md ~/.claude/skills/docs-site-gen/
cp -r docs_site_gen/references ~/.claude/skills/docs-site-gen/
```

## 使用方法

安装后，当你说以下内容时技能会自动触发：

```
"帮我生成一个文档站"
"创建一个 /docs 页面"
"更新文档以反映最近的变更"
"给文档添加一个功能特性页面"
```

### 典型工作流

```
你: "帮我生成一个文档站"

Claude Code:
  → 阶段 1：检测你的设计系统（Tailwind + CSS 变量，支持暗色模式）
  → 阶段 2：读取 12 个 API 路由、8 个模型、5 个服务 —— 构建功能清单
  → CP1："我发现了这些设计规范和功能。你偏好哪种风格预设？"
  → 阶段 3：生成内容大纲，标注来源
  → CP2："这是计划的内容。每项功能都映射到已验证的代码。是否批准？"
  → 阶段 4：生成 page.tsx + content.tsx + i18n 键值 + llms.txt
  → 阶段 5：运行 tsc、lint、i18n 检查、完整性审计
  → CP3："完成。以下是生成的内容。运行 `pnpm build` 验证。"
```

### 更新已有文档

```
"我加了推送通知功能 —— 更新文档"
```

技能进入**增量更新模式**：扫描新代码，检测变更，生成针对性的更新计划，然后用精准编辑只更新受影响的部分。你的自定义内容会被保留。

## 文件结构

```
docs-site-gen/
├── SKILL.md                          # 主技能文件（执行工作流）
└── references/
    ├── conventions.md                # 代码模式、组件、i18n 模板
    ├── templates.md                  # 大型代码模板（布局、搜索、目录、导航）
    ├── page-templates.md             # 各页面类型的章节结构骨架
    ├── style-presets.md              # 8 种精选风格预设及配色方案
    └── anti-patterns.md              # 常见错误和故障排除指南
```

`SKILL.md` 在每次调用时加载。参考文件按需加载，以最小化 token 开销。

## 风格预设

| 预设 | 灵感来源 | 风格 |
|------|----------|------|
| Stripe Premium | Stripe 文档 | 紫色渐变，标签页代码块，精致 |
| Vercel Monochrome | Vercel 文档 | 黑白配色，代码主导，CMD+K 搜索 |
| Tailwind Utility | Tailwind 文档 | 编号步骤，实用优先，天蓝色点缀 |
| GitHub System | GitHub 文档 | 三栏布局，五级提示框，系统化 |
| Supabase Bold | Supabase 文档 | 卡片网格，翡翠绿，粗体排版 |
| Linear Minimal | Linear 文档 | 大留白，极简用色，优雅 |
| Anthropic Warm | Anthropic 文档 | 纸质阅读感，暖色调，长篇散文 |
| Notion Friendly | Notion 指南 | Emoji 标记，封面图，社区导向 |

或者完全跳过预设 —— 如果你的项目有成熟的设计系统，技能会直接使用它。

## 生成产出

对于一个典型项目，技能会生成：

- `app/docs/page.tsx` + `content.tsx` —— 概览/着陆页
- `app/docs/layout.tsx` —— 带 CMD+K 搜索的共享导航（多页面）
- `app/docs/self-host/page.tsx` + `content.tsx` —— 自托管指南
- `app/docs/features/page.tsx` + `content.tsx` —— 功能详解（可选）
- `en-US.json` 和 `zh-CN.json` 中的 i18n 键值
- `public/llms.txt` —— AI 可读的摘要索引
- `public/llms-full.txt` —— 纯 Markdown 格式的完整文档

每个页面包含：SEO 元数据、OpenGraph 标签、Twitter 卡片、规范 URL、章节锚点，以及支持暗色模式的响应式布局。

## AI 友好的文档

每个生成的文档站都设计为人类和 AI 双重可读：

| 特性 | 为什么重要 |
|------|-----------|
| **SSR 渲染** | `curl https://yoursite.com/docs` 返回包含所有内容的完整 HTML —— 没有客户端渲染空白 |
| **章节锚点** | 每个 `<h2>` 和 `<h3>` 都有 `id` 属性，支持深度链接（`/docs#key-features`） |
| **llms.txt** | 标准化的 AI 可读索引位于 `/llms.txt` —— 让 AI 工具发现并理解你的文档 |
| **llms-full.txt** | 完整的纯文本文档位于 `/llms-full.txt` —— 无需解析 HTML |
| **语义化 HTML** | 正确的标题层级、地标元素、结构化内容 |

## 贡献

欢迎贡献。这是一个 Claude Code 技能，所以"源代码"是结构化的 Markdown + 代码模板。

需要了解的关键文件：
- `SKILL.md` —— 执行工作流（5 个阶段、检查点、更新模式）
- `references/conventions.md` —— 代码模式和组件定义
- `references/anti-patterns.md` —— 不应该做的事（有助于理解设计决策）

## 许可证

[Apache-2.0](LICENSE)
