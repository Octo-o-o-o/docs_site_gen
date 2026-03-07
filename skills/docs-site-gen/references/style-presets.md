# Documentation Style Presets

Curated style presets inspired by iconic documentation websites. Each preset defines visual direction, layout structure, and content organization patterns.

## How Style Presets Work

### Priority Rules (Highest to Lowest)

1. **Project's explicit UI/design spec** — design-tokens.json, style-guide.md, Figma export → ALWAYS wins
2. **Project's existing frontend code** — globals.css, existing pages, component patterns → STRONG preference
3. **User-selected style preset** → fills gaps not covered by 1 & 2

### What Presets Control

| Aspect | When project HAS design system | When project HAS NO design system |
|--------|-------------------------------|-----------------------------------|
| Colors | Project's colors (preset ignored) | Preset's color palette applied |
| Typography | Project's fonts (preset ignored) | Preset's font recommendations |
| Layout structure | Preset's layout (can augment) | Preset's layout applied |
| Content organization | Preset's structure applied | Preset's structure applied |
| Component style | Project's components (preset influences) | Preset's component style applied |
| Visual tone | Blended — project + preset | Preset defines tone |

**Key insight**: Style presets ALWAYS influence layout and content structure. They only influence visual design (colors, fonts) when the project lacks its own design system.

---

## Preset 1: Stripe Premium

**Inspired by**: Stripe Docs (docs.stripe.com)
**Best for**: Fintech, B2B SaaS, enterprise products, API-heavy platforms
**Tone**: Professional, authoritative, premium

### Visual Direction
| Token | Light Mode | Description |
|-------|-----------|-------------|
| Background | `#F6F9FC` | Blue-tinted off-white |
| Surface | `#FFFFFF` | Pure white cards |
| Text Primary | `#0A2540` | Deep navy |
| Text Secondary | `#425466` | Muted navy |
| Accent | `#635BFF` | Indigo/violet |
| Border | `#E3E8EE` | Subtle blue-gray |

### Typography
- Sans-serif with refined letter-spacing
- Semibold headings, regular body at 16px, line-height 1.6
- Monospace for code with distinct background

### Layout Structure
- Three-column: sidebar nav (260px) | content (720px max) | right TOC
- Generous whitespace and padding
- Card-based sections with subtle shadows

### Content Patterns
- Multi-language tabbed code blocks (Python, Node, Go, etc.)
- Color-coded callouts (blue info, yellow warning, red error)
- Interactive parameter tables for API endpoints
- Step-by-step guides with numbered cards

### When to Apply
- Product has API endpoints that need documentation
- Target audience is developers integrating with the product
- Brand needs to convey "trustworthy and premium"

---

## Preset 2: Vercel Monochrome

**Inspired by**: Next.js Docs (nextjs.org/docs), Vercel, shadcn/ui
**Best for**: Developer tools, frameworks, open-source projects
**Tone**: Minimal, elegant, modern

### Visual Direction
| Token | Light Mode | Dark Mode | Description |
|-------|-----------|-----------|-------------|
| Background | `#FFFFFF` | `#000000` | Pure contrast |
| Text Primary | `#000000` | `#FFFFFF` | Inverted |
| Text Secondary | `#666666` | `#A1A1A1` | Medium gray |
| Accent | `#0070F3` | `#0070F3` | Blue (links/CTAs only) |
| Border | `#EAEAEA` | `#333333` | Subtle dividers |

### Typography
- Geist or Inter variable font, clean geometry
- Font weight as primary hierarchy signal (not size or color)
- Monospaced Geist Mono or IBM Plex Mono for code

### Layout Structure
- Three-column with equal emphasis on nav and TOC
- Content width constrained to ~65ch for readability
- Sticky header with command palette (CMD+K) search
- Previous/Next page links at bottom

### Content Patterns
- Minimal use of color — mainly gray scale with blue accents for links
- Code blocks dominate — the docs ARE the product demo
- Clean tables without heavy borders
- Breadcrumbs for deep navigation

### When to Apply
- Product is a developer tool or framework
- Target audience appreciates minimalism
- Dark mode is equally important as light mode
- The codebase IS the product (open-source)

---

## Preset 3: Tailwind Utility

**Inspired by**: Tailwind CSS Docs (tailwindcss.com/docs)
**Best for**: CSS/frontend frameworks, utility libraries, code-centric tools
**Tone**: Code-first, practical, vibrant accent

### Visual Direction
| Token | Light Mode | Dark Mode | Description |
|-------|-----------|-----------|-------------|
| Background | `#FFFFFF` | `#0F172A` | White / slate-900 |
| Text Primary | `#0F172A` | `#F8FAFC` | High contrast |
| Text Secondary | `#475569` | `#94A3B8` | Slate tones |
| Accent | `#38BDF8` | `#38BDF8` | Cyan/sky blue |
| Border | `#E2E8F0` | `rgba(255,255,255,0.1)` | Subtle |

### Typography
- Inter for body, IBM Plex Mono for code
- Monospace uppercase labels for categories (distinctive pattern)
- `tracking-tight` on headings, `tracking-widest` on labels

### Layout Structure
- Left sidebar with grouped categories
- Content area with `max-w-3xl` prose
- Numbered step-by-step installation flows (01, 02, 03...)
- Tab system for installation methods

### Content Patterns
- Numbered steps with grid layout (01-06)
- Tab navigation for multiple approaches (Vite, PostCSS, CLI, CDN)
- Code blocks with language labels and copy buttons
- "Utility class" reference pattern — searchable index pages

### When to Apply
- Product is a utility library or framework
- Documentation is primarily "how to use this API"
- Users copy-paste code frequently
- Multiple integration methods exist

---

## Preset 4: GitHub System

**Inspired by**: GitHub Docs (docs.github.com)
**Best for**: Platforms with multiple products, enterprise with accessibility needs
**Tone**: Systematic, accessible, comprehensive

### Visual Direction
| Token | Light Mode | Dark Mode | Description |
|-------|-----------|-----------|-------------|
| Background | `#FFFFFF` | `#0D1117` | Clean / dark |
| Text Primary | `#1F2328` | `#E6EDF3` | Near-black / light |
| Text Secondary | `#656D76` | `#8B949E` | Medium gray |
| Accent | `#0969DA` | `#58A6FF` | Blue |
| Success | `#1A7F37` | `#3FB950` | Green |
| Warning | `#9A6700` | `#D29922` | Yellow |
| Danger | `#CF222E` | `#F85149` | Red |

### Typography
- System font stack (no custom fonts — faster loading)
- Clear weight hierarchy for scanning
- Sufficient line-height for accessibility

### Layout Structure
- Three-column: sidebar | content | mini-TOC
- Product-organized sidebar sections
- Breadcrumb navigation at top

### Content Patterns
- Five-tier callout system:
  - **Note** (blue): Supplementary information
  - **Tip** (green): Helpful suggestions
  - **Important** (purple): Key information
  - **Warning** (yellow): Potential issues
  - **Caution** (red): Destructive actions
- Tabbed content for platform variants (Web, CLI, API)
- Version/plan badges (Free, Pro, Enterprise)

### When to Apply
- Platform has multiple products/plans
- Accessibility is a priority (WCAG compliance)
- Content needs to serve both beginners and advanced users
- Multiple interface methods (web, CLI, API) for same actions

---

## Preset 5: Supabase Bold

**Inspired by**: Supabase Docs (supabase.com/docs)
**Best for**: Database/backend platforms, BaaS products, modern SaaS
**Tone**: Bold, modern, developer-friendly

### Visual Direction
| Token | Light Mode | Dark Mode | Description |
|-------|-----------|-----------|-------------|
| Background | `#F8F9FA` | `#171717` | Light gray / near-black |
| Surface | `#FFFFFF` | `#1C1C1C` | Cards |
| Text Primary | `#171717` | `#EDEDED` | High contrast |
| Accent | `#3ECF8E` | `#3ECF8E` | Vibrant green |
| Border | `#E5E7EB` | `#2D2D2D` | Standard |

### Typography
- Inter or system sans-serif
- Prose max-width ~80ch for optimal reading
- `scroll-mt-24` on headings for smooth anchor scroll

### Layout Structure
- Three-column with responsive collapse
- Product-organized sidebar (Database, Auth, Storage, etc.)
- Card grids for overview/landing pages

### Content Patterns
- Bold accent color used sparingly but effectively
- Migration guides comparing with competitors
- Icon panels with product feature descriptions
- Skeleton loading states for perceived performance

### When to Apply
- Product is a developer platform or BaaS
- Dark mode is the PRIMARY mode (not secondary)
- Green/growth-oriented brand identity
- Product competes with established players (migration guides useful)

---

## Preset 6: Linear Minimal

**Inspired by**: Linear Docs (linear.app/docs)
**Best for**: Productivity tools, SaaS products, design-focused companies
**Tone**: Calm, sophisticated, dark-first

### Visual Direction
| Token | Light Mode | Dark Mode | Description |
|-------|-----------|-----------|-------------|
| Background | `#F4F5F8` | `#08090A` | Mercury / near-black |
| Surface | `#FFFFFF` | `#1A1B1E` | Cards |
| Text Primary | `#171717` | `#FFFFFF` | Standard |
| Text Secondary | `#6B6F76` | `#8A8F98` | Muted |
| Accent | `#5E6AD2` | `#5E6AD2` | Desaturated indigo |

### Typography
- Inter Variable — precise letter-spacing and line-height per size
- Multiple title sizes with consistent scaling
- Medium and semibold weights only — no bold

### Layout Structure
- Clean left sidebar with minimal chrome
- Content area with generous whitespace
- Card grids for topic overview pages
- No right-side TOC (cleaner feel)

### Content Patterns
- ImageCard components for visual navigation
- Minimal callout usage — clean prose preferred
- Subtle hover effects and transitions
- Skip navigation link for accessibility

### When to Apply
- Product is a SaaS tool with design-focused brand
- Aesthetic quality is a brand differentiator
- Dark mode is the DEFAULT experience
- Content is workflow/task-oriented (not API reference)

---

## Preset 7: Anthropic Warm

**Inspired by**: Anthropic Docs (docs.anthropic.com)
**Best for**: AI/ML products, research-oriented tools, thoughtful brands
**Tone**: Academic, humanistic, warm

### Visual Direction
| Token | Light Mode | Description |
|-------|-----------|-------------|
| Background | `#EEECE2` | Warm cream/parchment |
| Surface | `#FFFFFF` | White cards |
| Text Primary | `#3D3929` | Warm dark brown |
| Text Secondary | `#6B6459` | Muted brown |
| Accent | `#DA7756` | Terra cotta orange |
| CTA | `#BD5D3A` | Darker terra cotta |

### Typography
- **Distinctive**: Serif body text (Georgia, Cambria, Times New Roman)
- Sans-serif headings or a custom display serif (Copernicus-style)
- Academic, book-like reading experience
- Line-height optimized for long-form reading

### Layout Structure
- Left sidebar for navigation
- Generous prose width with ample margins
- Warm, paper-like background creates reading comfort
- Minimal UI chrome — content-focused

### Content Patterns
- Long-form conceptual explanations
- Warm-tinted inline code backgrounds
- Card-based navigation for topic discovery
- Model comparison tables
- Prompt examples in styled code blocks

### When to Apply
- Product is AI/ML-related
- Brand identity is "thoughtful" or "research-driven"
- Target audience includes non-developer researchers
- Want to stand apart from typical tech aesthetics

---

## Preset 8: Notion Friendly

**Inspired by**: Notion Help (notion.com/help)
**Best for**: Consumer SaaS, productivity apps, tools for non-developers
**Tone**: Approachable, warm, guidebook-style

### Visual Direction
| Token | Light Mode | Description |
|-------|-----------|-------------|
| Background | `#FFFFFF` | Clean white |
| Surface | `#F7F6F3` | Notion's warm off-white |
| Text Primary | `#191919` | Near-black |
| Text Secondary | `#787774` | Warm gray |
| Accent | Varies | Category-specific colors |
| Border | `#E8E7E4` | Warm gray |

### Typography
- Inter — clean, approachable sans-serif
- Generous heading sizes for scanning
- Casual-professional weight hierarchy

### Layout Structure
- Category-based sidebar with visual markers
- Large hero imagery at section tops
- Card grids for topic discovery
- Multi-column layouts for featured content

### Content Patterns
- Emoji integration in category labels and navigation
- Illustration-heavy design (screenshots, diagrams)
- "What's New" sections for feature updates
- FAQ-style collapsible sections
- Community links (forums, consultants, webinars)

### When to Apply
- Product targets non-developers or mixed audiences
- Brand identity is "friendly and approachable"
- Documentation is more "help center" than "API reference"
- Visual storytelling matters more than code blocks

---

## Quick Selection Guide

| If your project is... | Recommended preset |
|-----------------------|-------------------|
| API/developer platform | **Stripe Premium** or **GitHub System** |
| Open-source framework | **Vercel Monochrome** or **Tailwind Utility** |
| Backend/database platform | **Supabase Bold** |
| Design-focused SaaS | **Linear Minimal** |
| AI/ML product | **Anthropic Warm** |
| Consumer-facing tool | **Notion Friendly** |
| Enterprise with accessibility needs | **GitHub System** |
| Dark-mode-first product | **Linear Minimal** or **Supabase Bold** |
| Multi-product platform | **GitHub System** or **Stripe Premium** |
| Minimalist brand | **Vercel Monochrome** |

## Combining Presets

You can mix aspects from multiple presets:
- **Colors** from one preset + **layout** from another
- **Content patterns** (e.g., GitHub's callout system) can be used with any visual style
- The user can specify: "Vercel Monochrome layout with Stripe's tabbed code blocks"

When mixing, prioritize **layout and content patterns** from one preset and **visual tokens** from another. Never mix conflicting visual directions (e.g., Anthropic's warm serif + Linear's cold minimal).
