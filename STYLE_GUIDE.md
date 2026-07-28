# bgms Documentation Style Guide

## Heading Hierarchy

### Title (H1)
- **Never use `# Heading` in `.qmd` files**
- The page title comes from the YAML front matter `title:` field
- This automatically renders as H1 and appears in the browser tab

```yaml
---
title: "Getting Started"
---
```

### Main Sections (H2)
- Use `## Heading` for top-level content sections
- These appear in the right-side Table of Contents (TOC)
- Keep concise: 1-3 words when possible

```markdown
## Installation
## Basic Example
## Understanding the Output
```

### Subsections (H3)
- Use `### Heading` for subsections within H2 sections
- Also appear in TOC (nested under parent H2)
- Use when a section needs logical subdivisions

```markdown
## Installation

### From CRAN

### Development Version
```

### Lower Levels (H4+)
- Use sparingly - consider restructuring if you need H4
- Do not appear in TOC
- Good for: parameter groups, minor distinctions

---

## Page Types

### Index Pages (guide/index.qmd, reference/index.qmd, manual/index.qmd)

**Goal:** Overview/navigation page with minimal TOC

**Structure:**
```yaml
---
title: "User's Guide"
subtitle: "Short description of this section"
---
```

- Use descriptive prose instead of heading-heavy structure
- Link to content pages inline or via bullet lists
- If headings are needed, add `toc: false` to front matter

### Content Pages (tutorials, explanations)

**Structure:**
```markdown
---
title: "Getting Started"
---

Brief introduction paragraph.

## Installation

Explanation...

### From CRAN

```r
install.packages("bgms")
```

### Development Version

```r
remotes::install_github(...)
```

## Basic Example

...
```

### Reference Pages (function documentation)

**Standard sections (in order):**
```markdown
---
title: "bgm"
---

Brief one-line description.

## Description

Detailed explanation of what the function does.

## Usage

```r
bgm(data, ...)
```

## Arguments

| Argument | Description |
|----------|-------------|
| `data`   | A data frame... |

## Value

Description of return value.

## Examples

```r
# Load data
data(Wenchuan)
fit <- bgm(Wenchuan)
```

## See Also

Links to related functions.

## References

Citations if applicable.
```

---

## TOC Behavior

| Scenario | TOC Visible? | Solution |
|----------|--------------|----------|
| Page has H2/H3 headings | Yes | Expected behavior |
| Index page, want no TOC | Add `toc: false` | Clean navigation page |
| Long page with many sections | Yes | Good for navigation |
| Short page (< 3 headings) | Minimal | Consider removing headings |

---

## General Rules

1. **One H2 minimum** for content pages (generates useful TOC)
2. **Consistent naming** across similar pages (all reference pages use same sections)
3. **No orphan headings** - every heading should have content below it
4. **Code comments are not headings** - `# comment` inside code blocks is fine
5. **Cross-reference with IDs** when needed: `## Overview {#overview}`

---

## Mathematical Notation

Conventions established in the guide pages. All manual and reference pages must follow these.

### Pairwise associations and interaction matrices

| Symbol | Meaning | Context |
|--------|---------|---------|
| `ω_{ij}` | Partial association (pairwise interaction) | All models — the unified user-facing symbol |
| `Ω` (bold) | Interaction matrix (matrix of `ω_{ij}`) | All models |
| `Θ` (bold) | Precision matrix (GGM-specific, `Θ = −2Ω`) | GGM pages only |
| `θ_{ij}` | Precision element (`θ_{ij} = −2ω_{ij}`) | GGM pages only |

Do **not** use `σ_{ij}` for pairwise interactions — that is the C++ variable name, not the user-facing notation.

### Thresholds and main effects

| Symbol | Meaning |
|--------|---------|
| `μ_{ic}` or `μ_i(c)` | Category threshold for variable `i`, category `c` |
| `α`, `β` (Blume-Capel) | Linear and quadratic effects in `μ(c) = α(c − b) + β(c − b)²` |

### Edge indicators and inclusion probabilities

| Symbol | Meaning |
|--------|---------|
| `γ_{ij}` | Edge inclusion indicator (0/1) |
| `π_{ij}` | Edge inclusion probability |

### Group comparison (bgmCompare)

| Symbol | Meaning |
|--------|---------|
| `ω_{ij}^{(g)}` | Group-specific partial association in group `g` |
| `ω_{ij}` | Overall (baseline) partial association |
| `δ_{ij}^{(k)}` | Contrast parameter for the `k`-th orthogonal contrast |
| `c_{gk}` | Projection-matrix coefficient |

The per-group parameter is `ω_{ij}^{(g)} = ω_{ij} + Σ_k c_{gk} δ_{ij}^{(k)}`.

Terminology: call `δ` **contrast parameters**, not "group differences." For two groups the single contrast reduces to a scaled group difference, but for `G > 2` the `G − 1` contrasts are projections onto orthogonal basis directions, not pairwise group differences.

### Hamiltonian sampler (NUTS)

| Symbol | Meaning |
|--------|---------||
| `q` | Position (parameter vector) |
| `p` | Momentum |
| `π(q)` | Target density (avoids collision with `p` for momentum) |
| `H(q, p)` | Hamiltonian: `−log π(q) + ½ pᵀ M⁻¹ p` |
| `M` | Mass matrix (diagonal) |
| `ε` | Step size |

### Adaptive Metropolis

Metropolis pages use `θ_k` for a scalar parameter element (no Hamiltonian context). This does not conflict with the GGM precision element because the Metropolis page describes a generic algorithm.

### Proposal standard deviations

| Symbol | Meaning |
|--------|---------||
| `σ_k` or `σ_{ij}` | Proposal standard deviation (Metropolis, MoMS edge moves) |

Do **not** use `τ` for proposal SDs.

### Covariance and related

| Symbol | Meaning |
|--------|---------|
| `Σ` (bold) | Covariance matrix |
| `ρ_{ij·rest}` | Partial correlation |
| `Φ` (bold) | Upper Cholesky factor of `Θ` (GGM internals) |

### Precision-diagonal prior and the `eta` frame

| Symbol | Meaning |
|--------|---------|
| `η` | Standardized rate of the Gamma-family prior on the precision diagonal: the rate in the frame where the slab has unit scale (raw rate = `η / s`, `s` the slab scale) |
| `δ` | Determinant-tilt exponent on the continuous-block precision matrix (`bgm()` argument `delta`; prior multiplied by `|K|^δ`) |

### Edge clustering (SBM)

| Symbol | Meaning |
|--------|---------|
| `B` | Number of blocks/clusters (guide pages); manual pages use `K` |
| `λ` | Rate of the shifted-Poisson prior on the number of clusters: `B − 1 ~ Poisson(λ)`, so `E[B] = 1 + λ` |

Always say **shifted Poisson** (`B − 1 ~ Poisson(λ)`), never zero-truncated Poisson — the convention changed on develop.

### Hierarchical graph prior (Z-ratio)

Manual-only symbols (zratio-hierarchical.qmd and pages linking to it):

| Symbol | Meaning |
|--------|---------|
| `Z(Γ)` | Per-graph normalizing constant of the precision prior |
| `J` | Normalizer ratio carried by an edge move: `J = Z(Γ⁻)/Z(Γ⁺)` |
| `(δ, η, α)` | Standardized cell in which the constants and correction tables are built: tilt exponent, standardized diagonal rate, and slab shape |

### Known overloads (acceptable)

- `α`, `β` — Blume-Capel effects in model pages; Beta prior shape parameters in prior/clustering pages. Context disambiguates.
- `δ` — Contrast parameters in group-comparison pages; cluster assignment probabilities in clustering.qmd; determinant-tilt exponent in GGM/mixed and Z-ratio pages. Different page contexts, no within-page collision.
- `η` — Standardized diagonal rate in prior pages; adjacent-category canonical parameter `η_c` in omrf-internals.qmd. Context disambiguates.
- `λ` — Shifted-Poisson rate in clustering/SBM pages only.
