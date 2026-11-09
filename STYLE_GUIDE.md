# bgms Documentation Style Guide

## Heading Hierarchy

### Title (H1)
- **Never use `# Heading` in `.qmd` files**
- The page title comes from the YAML front matter `title:` field
- This automatically renders as H1 and appears in the browser tab

```yaml
---
title: "Getting started"
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
title: "Guide"
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
title: "Getting started"
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
remotes::install_github("Bayesian-Graphical-Modelling-Lab/bgms@develop")
```

Always pin `@develop` in install snippets. The bare call installs the
default branch, which is the released CRAN lineage, not the development
version.

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

## Example Pages

Pages in `examples/` are the worked-analysis layer of the site. Each one runs a
single analysis end to end and stops there. Template:
`dev/templates/example-page.qmd`, which carries a comment per slot and is not
part of the render. Copy it rather than a shipped page.

### What the layer owns

Examples pages own code and workflow. Guide pages own the reasoning, Reference
pages own the API contract. Where an example page needs a reason, it gives one
orienting sentence and links to the Guide; where it needs an argument or a
return value, it links to the Reference. One page owns each analysis: if a
Guide page carries a full worked run of an analysis that now has an example
page, trim it to a snippet and link across.

### Page shape

In this order, every time:

1. **Title**, from the YAML `title` field, naming the analysis a reader came to
   run ("Comparing groups"), not a topic ("Group comparison in bgms").
2. **The payoff figure**, before any prose beyond the title. For a
   whole-network result that is the edge evidence plot (see Network Figures
   below); for a single edge weight it is the prior-to-posterior plot. One
   sentence per panel underneath, saying what the panel licenses the reader to
   say.
3. **The question**, one paragraph: what the analysis answers, and what it
   costs to get it wrong.
4. **The fit**: the `eval: false` mirror of the call, matching `fixtures/bake.R`
   argument for argument, with the hidden fixture load doing the real work.
5. **Walk-through sections**, one per step, in the order a reader performs
   them. Show the output in full, then read it. Never paraphrase output you
   have not shown.
6. **What to report**, a closing callout with the sentences a reader can write,
   including the neighbouring claim the analysis does not license.
7. **Cross-link footer**: the Guide page for the reasoning, the Reference page
   for the contract, the papers for the citable record.

One concept per page. A section that starts working through a second analysis
belongs on its own page.

### Companion scripts

Every example page ships a runnable script at `examples/R/NN-slug.R`, where
`NN` is the page's position in the series as listed on `examples/index.qmd`.
The scripts are generated by `scripts/extract-example-code.R`, which
`knitr::purl()`s the pages; the site render regenerates them as its pre-render
step. Never hand-edit one, and never commit one: they are gitignored build
artifacts, rebuilt from the page they belong to.

Two chunk rules follow from that:

- Chunks a reader cannot see carry `purl: false`. That is the fixture loader,
  hidden refits, and anything else that exists only to make the page render.
- Everything the script needs, including the `library()` calls, appears in a
  chunk a reader can see. The `eval: false` mirrors are part of the script: the
  extractor strips `eval: false` before tangling, because those mirrors are
  exactly the calls the page is telling a reader to make.

### Series order

The order lives in `scripts/examples-series.R` and is used by both the
companion scripts and the PDF. Adding a page means listing its slug there,
adding it to the `examples` sidebar in `_quarto.yml`, and adding an entry to
`examples/index.qmd`. The sidebar lists only pages that exist; unpublished
entries stay in the index prose as plain text, never as a dead link or a
"coming soon" stub.

### PDF of the series

`make examples-pdf` renders the index and every published example page, in
series order, into one PDF titled "The bgms examples" and copies it to
`docs/examples/bgms-examples.pdf`, which is where the download link on
`examples/index.qmd` points. The build is the `pdf` Quarto profile
(`_quarto-pdf.yml`); it writes to `_pdf/` and never touches the site render.

Order matters, because a site render rewrites `docs/`: build the PDF after the
site, which is what `make all` does. Uncommenting the download link therefore
also means adding the PDF build to `.github/workflows/publish.yml`, after the
render step and before the deploy.

---

## Network Figures

Convention settled 2026-07-30 (MM). It mirrors the figure practice of the
tutorial paper; it is not a site invention. Every network figure on the
site follows it.

### The rule

**The canonical result display is the edge evidence plot: the network
split by evidence.** A network drawn as one picture has to make every
pair either an edge or a blank, and a blank cannot distinguish a pair the
data ruled out from a pair the data could not decide. Reporting the bare
median-probability network and reading its blanks as absence is exactly
the conflation the tutorial paper corrects.

A traditional weighted or median-probability network may appear **only**
as an explicit estimation-workflow foil, labelled as such in the
surrounding prose, and never as a page's final display. It must not
appear on Getting started at all.

### Panel structure

Three panels, drawn left to right in this order, on **one shared
layout** so the panels match node for node:

| Panel | Contents | Edge styling |
|-------|----------|--------------|
| evidence of presence | pairs with inclusion Bayes factor at or above the threshold | weighted by the posterior mean partial association; solid; `theme = "TeamFortress"`, `edge.width = 1.1` |
| evidence of absence | pairs with inclusion Bayes factor at or below the reciprocal threshold | uniform width; dashed; `edge.color = "#A66A1E"`, `lty = 2`, `edge.width = 1.1` |
| undecided | everything else | uniform width; dotted; `edge.color = "#8A8578"`, `lty = 3`, `edge.width = 1.4` |

Only the presence panel is weighted. For the other two the classification,
not a weight, is the result, so their edges carry no width information.

The shared layout is non-negotiable. Compute it once from **all** pairs,
so that no single panel sets the geometry, and pass the same coordinates
to all three:

```r
set.seed(1234)
shared = qgraph(abs(coef(fit)$pairwise), layout = "spring",
                repulsion = 0.9, DoNotPlot = TRUE)$layout
```

Each panel is titled with its category name and its edge count, for
example `evidence of absence: 5`. Do not omit the counts; an empty panel
is a result and must be visible as one.

### Categories

Categories come from [`extract_inclusion_bf()`](reference/extractors.qmd),
at an inclusion Bayes factor of **10** in either direction: at or above 10
is presence, at or below 1/10 is absence, everything between is undecided.
This matches the `evidence_threshold` default of
`prior_sensitivity_check()` and the verdict names the package itself uses
(`"presence"`, `"absence"`, `"undecided"`).

Never classify from the posterior inclusion probability alone. Under an
edge prior away from one half, and for continuous edges fitted with
`precision_graph_prior = "joint"`, the posterior odds are not the Bayes
factor; `extract_inclusion_bf()` divides the right prior odds out in
every case.

### Caption duties

The prose around the figure must state, in the site's own register, what
each panel licenses the reader to say:

- Presence: the data favour a direct association that survives
  conditioning on the rest of the network.
- Absence: a **positive statement of conditional independence**. Say so,
  and say that it is the statement an estimation workflow cannot make.
- Undecided: the pairs these data have too little to say about. Never
  fold these in with absence.

Where a page has just shown, or could plausibly show, a thresholded
network, say explicitly that a blank there is not evidence of absence.

### Reference implementation

`guide/getting-started.qmd` defines `plot_edge_evidence()` and applies it
to both an ordinal and a continuous fit. Copy it rather than re-deriving
the styling.

### Single-edge display

For a page that discusses one edge's weight rather than the whole
network, the companion figure is the **prior-to-posterior (spike-and-slab)
plot**: the two-part distribution of that edge weight, with the spike
drawn as a lollipop whose height is the probability of exactly zero and
the slab as a filled curve on the same probability-per-bin scale, so the
two are commensurable. Not required on Getting started; it enters the
palette when a page first needs parameter-level display.

### Rendering

Site figures are R-generated PNGs with an opaque white background, so
they read the same in light and dark mode. Keep ink dark and rely on
line style, not on hue alone, to separate the categories. Render the
three-panel figure at `fig-width: 9.5`, `fig-height: 3.7`.

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
