# bgms-docs Build Plan

## How this plan works

This plan is written as a step-by-step playbook.
Read it top to bottom. Each phase tells you what to do, who does it, and when it is done.
All page statuses are tracked in one file: `dev/task-list.md`.

### Roles

- **Maarten** — technical sign-off (facts, code, algorithms).
- **Emily** — readability sign-off (clarity, audience fit).
- **LLMs** — drafting and transformation only. Never treated as source of truth.

### How git branches work

- All work happens on one cycle branch (e.g. `docs/cycle-01`).
- Files stay in their normal folders (`guide/`, `reference/`, `manual/`).
- As a page matures, you make new commits on the same branch.
- When pages are approved, merge the cycle branch into `main`.
- Statuses (Scaffolded, Populated, etc.) are labels in `dev/task-list.md`, not separate branches.

### When sources disagree, trust this order

1. bgms code behavior (actual implementation)
2. roxygen/man generated docs
3. design docs / algorithm notes
4. existing website text
5. LLM-generated text

Never let LLM text override implementation facts.

---

## Phase 0 — Preparation (one-time)

**Goal:** Lock in the page list and set up the workspace.

Do this:

- [ ] Confirm the page list. Use the `_quarto.yml` sidebar as the starting point.
- [ ] Set audience per section:
  - Guide → users and applied analysts.
  - Reference → exact API behavior.
  - Manual → technical internals and algorithms.
- [ ] Assign risk levels to each page in `dev/task-list.md`:
  - High: algorithm internals, defaults/priors, convergence, NUTS/warmup, core API (`bgm`, `bgmCompare`).
  - Medium: method interpretation, workflow guidance.
  - Low: intro/context pages.
- [ ] Create the cycle branch: `git checkout -b docs/cycle-01`.

**Done when:** Page list, audiences, and risk levels are recorded in `dev/task-list.md`.

---

## Site Structure

Four top-level sections, each with a distinct audience and purpose.

### Guide (users and applied analysts)

Teaches concepts and walks through analyses. A reader who finishes the
Guide can fit models, interpret output, and set priors with confidence.

| Page | Purpose |
|---|---|
| guide/index.qmd | Section landing page. |
| guide/getting-started.qmd | Install, load, first `bgm()` call, read the output. |
| **Background** | |
| guide/graphical-models.qmd | What is a graphical model? Nodes, edges, conditional independence. |
| guide/bayesian-approach.qmd | Why Bayesian? Posterior, prior, credible intervals, Bayes factors. |
| guide/prior-basics.qmd | Shared primer: what priors are, how bgms uses them, why they matter. Renamed from prior-guide.qmd. |
| **Models** | |
| guide/ggm.qmd | Gaussian graphical model: continuous data, partial correlations, precision matrix. |
| guide/omrf.qmd | Ordinal MRF: ordinal/binary data, category thresholds, Blume-Capel parameterization. |
| guide/mixed-model.qmd | Mixed MRF: datasets with both continuous and discrete variables. |
| **Analyses** | |
| guide/edge-selection.qmd | Bayesian edge selection: inclusion Bayes factors, posterior inclusion probabilities. Includes analysis-specific prior guidance. |
| guide/group-comparison.qmd | Comparing networks across groups with `bgmCompare()`. Includes analysis-specific prior guidance. |
| guide/clustering.qmd | Stochastic block model for edge clustering. Includes analysis-specific prior guidance. |
| **MCMC output** | |
| guide/mcmc-output.qmd | What the sampler returns: posterior samples, summary statistics, raw output structure. |
| guide/mcmc-diagnostics.qmd | Convergence checks: ESS, R-hat, trace plots, divergences, E-BFMI. |

**Pedagogical flow:** Background → Models → Analyses → MCMC output.
Each analysis page includes a short prior section specific to that analysis,
so readers learn about priors in context rather than in the abstract.

### Reference (exact API behavior)

One page per exported function or function family.
Content is extracted from roxygen documentation with minimal paraphrasing.

| Page | Purpose |
|---|---|
| reference/index.qmd | Section landing page with function index. |
| reference/bgm.qmd | `bgm()`: all arguments, defaults, return structure. |
| reference/bgmCompare.qmd | `bgmCompare()`: all arguments, defaults, return structure. |
| reference/methods.qmd | S3 methods: `print`, `plot`, `summary`, `simulate`, `predict`. |
| reference/extractors.qmd | Extractor functions: `extract_arguments`, `extract_indicators`, `extract_posterior_inclusion_probabilities`, `extract_sbm`. |
| reference/datasets.qmd | Bundled datasets. |

### Manual (technical internals and algorithms)

For developers and methodologists who need to understand how bgms works
under the hood. Each page explains a subsystem with reference to the
actual code.

| Page | Purpose |
|---|---|
| manual/index.qmd | Section landing page and subsystem map. |
| **Architecture** | |
| manual/architecture.qmd | Top-level design: R front-end → C++ engine. The three-stage pipeline (`bgm_spec` → `run_sampler` → `build_output`). Package directory layout. |
| manual/r-scaffolding.qmd | The R layer in detail: validation pipeline (`validate_data`, `validate_variable_types`, `validate_sampler`), spec construction (`bgm_spec`, `new_bgm_spec`, `validate_bgm_spec`), sampler dispatch (`run_sampler` → model-specific C++ entry points), output assembly (`build_output` → posterior summaries, raw samples, diagnostics). Data flow diagram from user call to returned fit object. |
| manual/model-classes.qmd | C++ class hierarchy: `BaseModel` → `GGMModel`, `OMRFModel`, `MixedMRFModel`. Virtual interface (capability queries, parameter access, edge selection, adaptation, missing data). How models register their storage layout. |
| **MCMC engine** | |
| manual/samplers.qmd | Sampler hierarchy: `SamplerBase` → `MetropolisSampler`, `GradientSamplerBase` → `HMCSampler`, `NUTSSampler`, `HybridNUTSSampler`. Step-size adaptation, mass matrix tuning. Factory dispatch by `sampler_type` string. |
| manual/nuts.qmd | NUTS algorithm: recursive tree-building, U-turn criterion, multinomial sampling, divergence detection. How tree depth and energy diagnostics are recorded. |
| manual/warmup.qmd | Three-stage adaptive warmup schedule: stage 1 (step-size), stage 2 (mass matrix), stage 3a (final step-size). Edge-selection phases 3b (proposal-SD tuning) and 3c (graph initialization). How `WarmupSchedule` coordinates sampler and model. |
| manual/parallel-chains.qmd | Parallel chain execution: `model.clone()` / `edge_prior.clone()` per chain, TBB thread control via `tbb::global_control`, `RcppParallel::parallelFor` dispatch through `MCMCChainRunner`. Sequential fallback for single-thread mode. Per-chain RNG seeding (`config.seed + chain_id`). Progress tracking and user-interrupt handling across threads. |
| **Models** | |
| manual/ggm-internals.qmd | GGM implementation: precision matrix parameterization, Cholesky updates (`cholupdate`), continuous-data likelihood and gradient, edge-specific Metropolis proposals. |
| manual/omrf-internals.qmd | OMRF implementation: ordinal threshold parameterization, Blume-Capel model with linear + quadratic effects, pseudo-likelihood, full-conditional Gibbs steps for edge indicators. |
| manual/variable-helpers.qmd | Numerically stable computation for MRF variables. The FAST/SAFE dual-path strategy: precomputed exponentials and power-chain accumulation when exponents are bounded (FAST path), direct log-sum-exp evaluation as fallback (SAFE path). Covers `compute_denom_ordinal`, `compute_denom_blume_capel`, `compute_probs_ordinal`, `compute_probs_blume_capel`, joint `LogZAndProbs` computation. The `EXP_BOUND = 709` threshold and contiguous-block scanning for branch-free vectorization. |
| manual/mixed-internals.qmd | Mixed MRF implementation: block structure (discrete-discrete, continuous-continuous, cross-type), how the sampler handles mixed parameter vectors. |
| **Priors and edge selection** | |
| manual/edge-priors.qmd | Edge prior framework: `BaseEdgePrior` interface, Beta-Bernoulli default, unit-information prior. How inclusion probabilities and Bayes factors are computed. |
| manual/sbm-prior.qmd | Stochastic block model prior: MFM-SBM formulation, Gibbs block-allocation updates, how cluster structure regularizes edge inclusion. The `StochasticBlockEdgePrior` class. |
| **Group comparison** | |
| manual/bgmcompare-internals.qmd | `bgmCompare` engine: separate sampler, multi-group log-posterior and gradient, output handling. How it differs from single-group `bgm`. |
| **Numerical methods** | |
| manual/numerical.qmd | Numerical stability toolkit: custom `exp`/`log` macros (`explog_macros.h`), Cholesky rank-1 updates, the FAST/SAFE pattern. Cross-references variable-helpers.qmd for the full dual-path story. |

### Examples (worked analyses)

Complete, self-contained analyses from data to interpretation.
Each example uses a bundled or simulated dataset and runs end-to-end.

| Page | Purpose |
|---|---|
| examples/index.qmd | Section landing page. |
| examples/binary-network.qmd | Binary data → OMRF → edge selection → interpretation. |
| examples/ordinal-network.qmd | Ordinal data → OMRF → edge selection → interpretation. |
| examples/continuous-network.qmd | Continuous data → GGM → edge selection → interpretation. |
| examples/mixed-network.qmd | Mixed data → Mixed MRF → edge selection → interpretation. |
| examples/group-comparison.qmd | Two-group data → `bgmCompare()` → network differences. |
| examples/clustering.qmd | Edge clustering via SBM prior → block structure. |

### Page counts

| Section | Pages |
|---|---|
| Guide | 13 |
| Reference | 6 |
| Manual | 16 |
| Examples | 7 |
| **Total** | **42** |

---

## Phase 1 — Scaffold all pages

**Goal:** Every `.qmd` file exists with headings and placeholders. No real content yet.

Do this:

- [ ] For each page, use an LLM to generate structure only:
  - Title.
  - 3–6 section headings.
  - `TODO: source` placeholders for uncertain parts.
- [ ] Do not let the LLM invent facts. Headings and placeholders only.
- [ ] Render the site. Fix broken links, missing nav entries, and heading hierarchy issues.
- [ ] Commit: `docs(scaffold): add section templates and placeholders`.
- [ ] Update status to `Scaffolded` in `dev/task-list.md`.

**Done when:**

- [ ] All target `.qmd` files exist.
- [ ] No broken links.
- [ ] Heading depth ≤ 3.
- [ ] Navigation entries are present.

**Recommended order:** Build all skeletons before populating any page.

---

## Phase 2 — Populate pages with real content

**Goal:** Fill pages with facts from sources. Mark where each fact came from.

Do this for reference pages:

- [ ] Pull function signatures, arguments, return values, and examples from roxygen/man.
- [ ] Use deterministic extraction tooling where possible (`.Rd` parsing, `tools::Rd2txt()`).
- [ ] Insert with minimal paraphrasing first.

Do this for guide and manual pages:

- [ ] Pull from algorithm design notes and implementation comments.
- [ ] Convert into plain-language explanations.

For all pages:

- [ ] Add provenance markers to important claims so you can trace where text came from:
  - `SOURCE: R/<file>.R#<function>`
  - `SOURCE: man/<topic>.Rd`
  - `SOURCE: design/<note>.md#<section>`
- [ ] For high-risk claims (defaults, priors, convergence, sampling, core API), add accountability links that point a reader or developer straight to the source. This is a hard release gate for high-risk claims. Best effort for low-risk narrative text.
- [ ] Commit: `docs(gen): populate <section> from <source>`.
- [ ] Update status to `Populated` in `dev/task-list.md`.

**Done when:** Each major claim has a provenance marker.

**Recommended order:**

1. Reference pages first (closest to direct extraction).
2. Guide pages next (user task flow).
3. Manual/algorithm pages last (highest review depth).

---

## Phase 3 — LLM refinement

**Goal:** Improve clarity without changing facts.

Do this:

- [ ] Ask LLMs to rewrite for readability only.
- [ ] Enforce these constraints:
  - Preserve function names and parameter semantics.
  - Do not alter numeric defaults unless explicitly sourced.
  - Do not add undocumented features.
- [ ] Request diff-style changes so you can review what changed.
- [ ] Always provide source text snippets in prompts.
- [ ] Ask the LLM to flag uncertainty.

**Done when:** Prose is cleaner but facts have not changed.

---

## Phase 4 — Contradiction check

**Goal:** Catch factual errors before human review begins.

Do this:

- [ ] Run an LLM pass that compares page text against quoted source excerpts.
- [ ] Require mismatch-only output with severity: `high`, `medium`, `low`.
- [ ] Fix all `high` mismatches immediately.
- [ ] Log the mismatch list in page-level review notes.
- [ ] Update status to `Contradiction-checked` in `dev/task-list.md`.

**Done when:** All high-severity mismatches are resolved.

---

## Phase 5 — Human review

**Goal:** Maarten validates facts. Emily validates readability. Both sign off.

### Maarten (technical sign-off)

- [ ] Review high-risk pages first:
  - model classes
  - MCMC/NUTS/warmup
  - core function reference (`bgm`, `bgmCompare`)
- [ ] Verify claims against the source-of-truth hierarchy.
- [ ] Check that accountability links for high-risk claims actually point to the right source.
- [ ] For algorithm pages, verify equations/steps against code or design notes.
- [ ] Log review decisions (what changed and why).

### Emily (readability sign-off)

- [ ] Review each page for clarity and audience fit.
- [ ] Flag jargon, unclear steps, or confusing structure.
- [ ] Log review decisions.

### Both

- [ ] Resolve any blocking issues and record them in `dev/task-list.md`.
- [ ] Commit fixes: `docs(review): <description of fix>`.
- [ ] Update status to `Reviewed` in `dev/task-list.md`.

**Done when:** Each high-risk page has both sign-offs recorded in the task board.

### Review cadence

- Work in short cycles: 2–3 days, 3–6 pages per cycle.
- At the end of each cycle, produce:
  - A rendered preview.
  - An open issues list.
  - An accepted pages list.

---

## Phase 6 — Consistency and style pass

**Goal:** Make the whole site feel like one voice.

Do this:

- [ ] Standardize terminology across sections.
- [ ] Normalize heading patterns and cross-links.
- [ ] Enforce `STYLE_GUIDE.md` conventions.
- [ ] Ensure examples match current API signatures.

**Done when:** No style inconsistencies across sections.

---

## Phase 7 — QA and publish

**Goal:** Final automated and human checks, then deploy.

### Automated QA (runs every cycle and pre-release)

- [ ] Full render succeeds.
- [ ] No broken links.
- [ ] Search index sanity check passes.
- [ ] No unresolved `TODO:` markers.
- [ ] No malformed `SOURCE:` markers.
- [ ] All runnable R code executes without error on every page.

### Human smoke check

- [ ] Desktop and mobile visual sanity.
- [ ] Navigation and table-of-contents behavior.
- [ ] Zero unresolved factual issues.

### Release

- [ ] Final sign-off by both Maarten and Emily.
- [ ] Update status to `Approved` in `dev/task-list.md`.
- [ ] Merge cycle branch into `main` and deploy.

**Done when:** Site is live and all pages show `Approved`.

---

## Page acceptance checklist

A page can only be marked `Approved` if all of these are true:

- [ ] Structure matches section template.
- [ ] Facts verified against source hierarchy.
- [ ] No unresolved TODOs.
- [ ] Cross-links resolve.
- [ ] Terminology consistent with related pages.
- [ ] Reviewer notes resolved.
- [ ] Automated QA checks pass.
- [ ] Rendered page looks correct on desktop and mobile.
- [ ] Code examples execute without error.
- [ ] Basic accessibility: alt text, color contrast, keyboard navigation for interactive elements.
- [ ] Accountability links present for all high-risk claims.

---

## Ongoing: keeping docs in sync with bgms

After the first release, keep docs aligned with the package:

1. Re-run deterministic extraction when bgms version or API signatures change.
2. Maintain a "changed functions → affected pages" mapping.
3. Re-open approved pages impacted by package changes before the next release.

---

## Optional: metrics to track

If you want visibility into progress, track per cycle:

- Pages scaffolded / populated / reviewed / approved.
- Open factual issues.
- Average time from scaffolded → approved.
- Factual issues older than one cycle.

Keep it lightweight. This is for direction, not reporting.
