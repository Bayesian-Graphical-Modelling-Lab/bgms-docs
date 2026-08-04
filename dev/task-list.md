# bgms-docs Task List (Single Source of Truth)

This file is the official status board for docs work.
If another note conflicts with this file, this file wins.

## How To Use This Board

- Keep updates short and concrete.
- Update this file when page status changes.
- Use one status value only: `Scaffolded`, `Populated`, `Contradiction-checked`, `Reviewed`, `Approved`, `Blocked`.
- Technical sign-off owner: Maarten.
- Readability sign-off owner: Maarten, who took the role over on 2026-08-03.
- An AI checklist pass runs first and feeds that sign-off: it is an input, not
  a gate. See `dev/set-up.md` Phase 5 for the checklist and its limits.

## docs/develop Branch

Long-lived branch tracking bgms `develop`. First audited against 4e508ed9 on
2026-07-28 (work plan: `dev/audit-develop-2026-07-28.md`, phases A-F);
re-swept against develop HEAD c1e52c8e on 2026-07-30 under brief A1
(PRs #176-#185, including the split-Rhat fix, the Rao-Blackwellized
inclusion machinery, and the refit-based `prior_sensitivity_check()`).
Reconciled with the release build, develop HEAD 0e116079, on 2026-07-30
under brief A5 (PRs #186-#188: the `log` argument on
`extract_inclusion_bf()`, the RB alignment of `extract_ess()`, and the
lifecycle deprecation of `standardize`).
Reconciled with the CRAN release, bgms main HEAD **6126312a**, on
2026-08-04 under brief A8, after the 2026-08 pre-CRAN review cycle
(roughly 270 commits past the A5 pin). bgms 0.2.0.0 was accepted on CRAN
on 2026-08-04.
Rules: never merge into main until the package develop ships; periodically
merge main into it; re-sweep against bgms develop HEAD at each sync.

## Fixture Configuration (brief A4, rebaked under A5 and A8)

All four fixtures are baked on the CRAN release build, bgms main
**6126312a** (version 0.2.0.0), rebaked 2026-08-04 under brief A8. The
installed build is a clean export of bgms main; its package sources were
diffed against the CRAN source tarball `bgms_0.2.0.0.tar.gz` and are
identical across `R/`, `man/`, `vignettes/`, `NAMESPACE`, and `NEWS.md`,
with `src/` differing only in trailing newlines added by `R CMD build`.

The Wenchuan fit and its prior sensitivity check are baked at the tutorial
paper's manuscript-grade configuration: `bgm(Wenchuan, iter = 1e4,
warmup = 5e3, seed = 123)` and `prior_sensitivity_check(fit, seed = 123)`,
read from the tutorial repo's `R/01-worked-example.R` and
`R/16-run-sensitivity-check.R`. Same seed, settings, and data as the paper,
so the site and the paper quote one set of numbers by construction, not by
coordination. Verified identical against the tutorial's `tables/` outputs
from its 2026-07-30 run: evidence verdicts 35 presence / 39 undecided /
62 absence, per-edge inclusion probabilities agreeing to 5e-16 and log
Bayes factors to 4e-13.

The A4 pin was the earlier build c1e52c8e. The A5 rebake on 0e116079 is
bit-identical to it on every statistic: raw draws, RB inclusion draws and
odds accumulators, all summary tables, every extractor return on both
scales, and the whole prior-sensitivity result apart from its wall-clock
columns (`$grid$seconds`, `$runtime_seconds`). PRs #186-#188 touch the
extractors and argument validation, not the samplers, and the fixtures
confirm it.

The A8 rebake on 6126312a holds that line where it counts and moves where
the package moved. **`fit_wenchuan` is bit-identical to the A5 bake** on
every statistic checked: raw draws, all four summary tables, all three
`coef()` tables, fourteen extractors, both Bayes-factor scales, and
`verdicts()`. The ordinal samplers are untouched by the 2026-08 cycle and
the fixture proves it. Three traced deviations elsewhere, none of them a
sampler change:

- `fit_wenchuan_sbm`: every S7 property identical except
  `posterior_summary_pairwise_allocations`. The allocation draws
  themselves are bit-identical; the transition counts moved by at most 1
  per cell because the counter stopped counting a transition at every
  chain boundary (bgms F-095, `0bd1cd50`). Row sums go from 7999 to the
  correct `4 * (2000 - 1) = 7996`. `mean`, `sd`, and `Rhat` are unchanged.
- `ps_wenchuan`: verdicts, mover classifications, `chosen_scale_pip`,
  `$curve`, and every anchor verdict are identical, and the refits are
  provably the same draws (`$grid$rhat_continuous` bit-identical on all
  six rows). What moved is the unit and the diagnostics. The curve is
  reported in natural log rather than log10 (`log10_bf` -> `log_bf`,
  `chosen_scale_log10_bf` -> `chosen_scale_log_bf`, `tolerance` 0.5 ->
  `0.5 * log(10)`; bgms F-051, `4cc8ce41`) and the new values equal the
  old ones times `log(10)` to 7e-15. The grid's `indicator_pair_ess`
  column is replaced by `inclusion_ess_min` (RB rather than transition
  ESS), `rb_median_rhat` shifts in the fourth decimal, and
  `ess_continuous` moves on one anchor row, all from the RB indicator
  masking change (bgms `b42df13f`). New fields `$unit` and `$vary`.
- `fit_compare_adhd`: **expected to move** (bgms F-119, `436a7a89`). The
  fixture bakes at package defaults, and those defaults changed from
  Cauchy to Normal for both the baseline interaction prior and the
  difference family. Quoted numbers on guide/group-comparison.qmd shifted
  accordingly; see that page's row.

The SBM fit and the ADHD group comparison are not manuscript analyses and run
at package defaults with the same seed. No 2-chain fixtures remain. Rebake and
re-render together; the bake costs about ten minutes (see `fixtures/bake.R`).
Baked `.rds` files resurface as `-rw-------` when Dropbox is syncing;
`chmod 644 fixtures/*.rds` after a bake.

Both bgms-side changes that A4 left open have landed and are applied on the
site (brief A5):

- BGMS-2 (bgms #188, `0e116079`). `extract_ess()` gained
  `estimator = c("rb", "mixt")` and its `indicator` element is now the RB
  `n_eff`, matching `summary(fit)$indicator$n_eff` and `extract_rhat()`.
  Swept on reference/extractors.qmd § extract_ess, reference/index.qmd,
  guide/mcmc-diagnostics.qmd (§ sec-rb-inclusion-ess and the warmup
  subsection), and guide/mcmc-output.qmd. The same PR put `standardize`
  through lifecycle; documented on reference/bgm.qmd and
  reference/bgmCompare.qmd. **Superseded in part by A8**: the release
  drops `n_eff_mixt` from `summary(fit)$indicator` and deprecates
  `extract_ess(estimator = "mixt")` (bgms `b42df13f`), on the ground that
  the two-state model behind it is rejected on a substantial share of edge
  chains. The exploration signal is now the directional transition counts.
  Swept across guide/mcmc-diagnostics.qmd, guide/mcmc-output.qmd,
  reference/extractors.qmd, reference/methods.qmd, reference/index.qmd, and
  examples/reading-the-output.qmd; manual/diagnostics.qmd still describes
  the retired statistic and is left to the post-launch manual pass.
- PR #186 (`cc3410f0`). `extract_inclusion_bf()` gained `log = FALSE`, so
  the default return is the Bayes factor rather than its natural log. Swept
  on reference/extractors.qmd § extract_inclusion_bf, reference/index.qmd,
  guide/edge-selection.qmd, and guide/mcmc-output.qmd. The quoted evidence
  for `intrusion-dreams` is now the Bayes factor, about 2e119, with the log
  scale (274.76) shown alongside it; the log values themselves did not move.

`precision_graph_prior` now defaults to `"hierarchical"` on the CRAN
release build (bgms F-010, merged `d3d8dbcf`); the signature is
`c("hierarchical", "joint")`. Verified against the installed build under
A8: a default continuous fit runs the hierarchical path, its prior
inclusion probabilities are exactly the nominal 0.5 under
`bernoulli_prior(0.5)`, and the trust gauge runs in-chain and fills
`fit$zratio_diag`, with `options(bgms.zratio_gauge_sweeps = 0L)` as the
off switch. Naming the argument where it is vacuous (ordinal data, or
`edge_selection = FALSE`) is accepted and reported rather than an error.
The effective-prior workaround on guide/edge-selection.qmd
§ sec-bf-continuous is therefore reframed as the `"joint"` opt-in path,
and the posterior-odds shortcut now holds for continuous edges by default.

## Network Figure Convention (brief A6, 2026-07-30)

D2 (MM, 2026-07-30): the canonical network display on this site is the
**edge evidence plot**, the network split into evidence of presence,
evidence of absence, and undecided, on one shared layout, with categories
from `extract_inclusion_bf()` at a Bayes factor of 10 either way. It
mirrors the tutorial paper's own figure practice (R/18); it is not a site
invention. A traditional weighted or median-probability network may appear
only as an explicit estimation-workflow foil, never as a page's final
display, and never on Getting Started. The prior-to-posterior
(spike-and-slab) plot of R/21 joins the palette for pages that discuss a
single edge's weight. Codified in `STYLE_GUIDE.md` § Network Figures;
reference implementation `plot_edge_evidence()` in
`guide/getting-started.qmd`.

Rendering note: `_freeze` invalidates on code changes only, so a
prose-only edit to a page with code chunks is served stale by a project
render. Re-render each edited page individually first
(`quarto render <page>.qmd --profile ci`, which always executes), then run
the project render.

## Examples Section Scaffold (brief B0, 2026-07-30)

D2 (MM, 2026-07-30): navbar label **Examples**, index title **Worked
analyses**. The section is wired and empty: navbar item between Get Started and
Guide, an `examples` sidebar listing only pages that exist, and
`examples/index.qmd` carrying the eight-entry series contract with the
unpublished entries as plain text.

Three conventions ship with it, all of them generated rather than
hand-maintained, and all of them documented in `STYLE_GUIDE.md` § Example
Pages:

- **Page template**: `dev/templates/example-page.qmd`, one comment per slot.
  Payoff figure first, and for a whole-network result that figure is the edge
  evidence plot (D2, § Network Figures), never a generic network plot.
- **Companion scripts**: `scripts/extract-example-code.R` tangles each page to
  `examples/R/NN-slug.R` as the project pre-render step. Chunks marked
  `purl: false` stay out; `eval: false` mirrors go in as runnable code, so the
  `library()` calls must live in a chunk the reader can see.
- **PDF**: `make examples-pdf` (profile `_quarto-pdf.yml`) assembles the index
  and the published pages, in series order, into one PDF. It renders to `_pdf/`
  and cannot disturb the site render; `scripts/redirects.R` now stands down for
  any render whose output directory is not `docs/`.

Series order has one home, `scripts/examples-series.R`; adding a page means
listing it there, in the `examples` sidebar, and in the index prose.

## Versioned Deployment (brief A7, 2026-07-30)

D4 (MM, 2026-07-30): the documentation is versioned, Documenter style. The
site ROOT serves the current release directly, with no /stable/ indirection;
/dev/ serves the development documentation and is deployed on every push to
docs/develop; a frozen /vX.Y.Z/ archive is added per CRAN release, starting
with the release AFTER 0.2.0.0, so this brief builds no v-directories. The
minimum shipped now is root + /dev/ + a two-entry version switcher.

The load-bearing rule is the **root-exclusion invariant**: a root deploy
replaces the root and never touches dev/ or any vX.Y.Z/; a dev deploy
replaces dev/ and touches nothing outside it.
`peaceiris/actions-gh-pages` cannot express it (it cleans its destination
with `git rm -r --ignore-unmatch *`, and with no `destination_dir` that is
the whole branch; `exclude_assets` filters the source, not the destination),
so both deploys to the bgms repository go through
`scripts/deploy-gh-pages.sh`. `scripts/simulate-deploy.sh` proves both
directions against a throwaway repository and needs no network; run it after
any change to the deploy script.

One flag, `BGMS_DOC_CHANNEL` (`release` or `dev`), decides everything that
differs between the two builds, through `scripts/doc-build.R`: the version
the citation picker prints (read from the installed bgms DESCRIPTION, so the
version string is never written down in a page), the version index
`versions.json` (written by `scripts/versions.R`, and only by the release
build, which is the one that can speak for the family), and the
development-build marking (`scripts/dev-build.R`: banner, `noindex`,
canonical links to the root equivalents, no sitemap or robots.txt). The
navbar switcher lives in `js.html` and degrades to no dropdown when
versions.json is unreachable, as in a local preview.

`index.qmd` is now `freeze: false`, because the citation version has to come
from the build rather than from a stored result.

Release-day sequence, how to add an archive entry, and the invariant:
README.md § Deployment.

Side effect, intended: merging this to docs/develop puts the development
documentation at .../bgms/dev/ in public, while the pkgdown site keeps
serving the root until the acceptance-day deploy. The switcher only appears
once main has deployed the root versions.json.

## A2 Sign-off (2026-08-04, delegated)

MM delegated both sign-off columns to an AI pass (Fable) on 2026-08-04 and
reviews the LIVE SITE after launch instead. The pass read all nine
newcomer-path pages in full against the Phase 5 checklist, verified
signatures and defaults against the installed CRAN 0.2.0.0 build
(formals of bgm, prior_sensitivity_check, extract_ess, verdicts), ran the
terminology-law greps (zero hits for "network model" and "regulariz" on the
nine pages), re-rendered every edited page individually plus the project
(clean), and re-ran the link check (154 pages, zero broken). Findings and
fixes are recorded per row in the Page Status Board; the two substantive
catches were a direction error on guide/edge-selection.qmd (posterior odds
understate, not overstate, under bernoulli_prior(0.1)) and the
reference-coverage gap for verdicts(), calibration_check(),
plot_edge_posterior(), extract_centrality(), and the plot() methods
(reference/index.qmd made honest; site pages are post-launch debt). That
debt is now paid: A9 (2026-08-04) shipped the site pages and restored the
"complete documentation" headline. The naive-reader gap recorded under
Phase 5 remains open and is unaffected by this pass.

## Live-Site Review Fixes (2026-08-04, MM review comments)

Three fixes from MM's review of the live flagship. (1) The leaked
"package 'qgraph' was built under R version 4.6.1" warning at the top of
examples/estimation-to-evidence.qmd and inside guide/getting-started.qmd's
visible library(qgraph) chunk is suppressed (warning: false on both
chunks). (2) Both pages now say, next to the qgraph helper, that plot(fit)
draws a rudimentary version of the edge evidence display in one call and
that the easybgm package (CRAN link; no references.bib entry, so no
citation) offers more elaborate plotting and summary functions on top of
bgms. (3) The flagship's What-to-report callout gained a
plot_edge_posterior() line for the single-edge figure. Package-side, MM
routed the summary print's NA-suppression note to a bgms agent; when that
lands in a build, reading-the-output's indicator-block prose and the
frozen printouts need a text check at the next render.

## C3 Troubleshooting Entry (2026-08-04)

Symptom-first front door for guide/mcmc-diagnostics.qmd. New
`sec-symptom-index` table sits after the intro and routes fifteen
symptoms to a section and a one-line action; three new sections back it
(`sec-sampler-warnings`, `sec-reproducibility`, `sec-still-stuck`), and
nine existing headings gained explicit `{#sec-...}` anchors so the FAQ
and the Examples pages can deep-link the same targets. No existing prose
was rewritten.

The warning enumeration is exhaustive for the release build. Source of
truth: the CRAN 0.2.0.0 tarball,
`grep -rn "warning(" R/` (19 call sites in 11 files), cross-checked
against the installed build by deparsing every function in the namespace
(11 functions contain a `warning()` call, the same set).
`warning_once()` is defined but has zero callers, so it emits nothing.
Out of scope and stated as such on the page: `simulate_mrf()` and
`predict()`'s recoding warning, which are not fit or check warnings.

Two anchor-only edits outside the page: `sec-pinned-indicators` on
guide/mcmc-output.qmd (an inline span on the `NA` precision-columns
sentence, since the explanation sits mid-section) and `sec-how-to-act` on
examples/check-your-priors.qmd. Both link targets verified against the
rendered HTML.

Open: the "results differ between runs" row points at the new on-page
section only. When C2 ships, add the FAQ answer as a second target
(the brief asks for both).

## A9 Reference Coverage (2026-08-04)

Closes flagged-issues bgms-docs item 20. Every 0.2.0.0 export now has a
site entry: `getNamespaceExports("bgms")` (39 names) set-minus the names
appearing in reference/*.qmd is empty. New page reference/checks.qmd holds
verdicts() and calibration_check(); the plot() methods and
plot_edge_posterior() went to reference/methods.qmd; extract_centrality()
to reference/extractors.qmd. mrfSampler() was established as deprecated
from the build (lifecycle warning naming 0.1.6.3) and NEWS, and is
recorded as a deprecated former name of simulate_mrf() rather than given
an entry. Every signature was checked against formals() on the installed
build and every claim against a live call on the baked fixtures; no new
fixtures were needed. Project render clean (52/52), link check clean (156
pages, zero broken).

## A2 Readability Pass (2026-08-03)

AI checklist pass over the nine newcomer-path pages, feeding MM's readability
sign-off. All internal links and anchors on those pages resolve (~130 checked,
zero broken); the A4/A5 number set is consistent across them.

MM adjudicated six judgment items; applied:

- `bgm()` returns an **S7 object**, not a list (`class(fit)` is `"bgms"`,
  `"S7_object"`). Corrected on guide/mcmc-output.qmd, which contradicted
  reference/bgm.qmd and reference/index.qmd.
- "graphical models", never "network models" — one instance on
  reference/prior-sensitivity.qmd.
- The inclusion Bayes factor is finite *almost everywhere* but can hit a
  numerical bound. The blanket "finite even for saturated edges" softened on
  reference/index.qmd and guide/mcmc-output.qmd (closes flagged issue 17);
  guide/edge-selection.qmd already read correctly and was left alone.
- guide/mcmc-diagnostics.qmd's energy-slope closing sentence: KEEP as written
  (MM).
- guide/edge-selection.qmd's "two alternatives" list: the third item was not an
  alternative; it is now a paragraph opening "As an alternative to these two".
- Leading Edge Selection with spike-and-slab: fine on that page (MM).

Mechanical fixes applied in the same pass: page name standardized to **Model
Output** in link text (was split 7/6 with "MCMC Output"); en-GB spellings
(`favour`, `favours`, `neighbouring`) moved to the site's en-US; the homepage
Quick Start's lone `<-` moved to `=`; bgms 0.2.0 -> 0.2.0.0 on reference/bgm.qmd;
summary column order corrected there; a literal parameter name that rendered as
an en dash; a heading that collided with the example page it links to; and a
trace-plot loop that shadowed `c()`.

Structural: the Examples section was unreachable from the homepage,
guide/index.qmd, and Getting Started's Next steps, though it is in the navbar —
entry points added to all three (the homepage hero gained a third button in its
existing three-column grid, and the feature grid a fourth card, which needed
`.feature` to go from 33% to 50% width in index.css so four cards lay out two by
two). reference/prior-samplers.qmd was missing from the board; row added above.

Not covered, and not to be recorded as passed: the naive-reader pass. See
`dev/set-up.md` Phase 5.

## Current Cycle Focus

- Build trusted docs with automation-first QA.
- Run runnable R code checks on all pages with runnable code.
- Keep accountability links for high-risk claims.

## Review Sequence (Main Workflow)

This is the main A -> B workflow for Maarten and the AI sessions.
Anything below in "Secondary Backlog" is not part of this immediate review sequence.

### A. Draft and source-linking

- [ ] Draft or update page content.
- [ ] Add provenance/accountability links for high-risk claims (hard gate).
- [ ] Ensure no unresolved factual placeholders remain except explicit blockers.

### B. Automated QA gate

- [ ] Full render passes.
- [ ] Link checks pass.
- [ ] Search index sanity check passes.
- [ ] No unresolved `TODO:` markers.
- [ ] No malformed `SOURCE:` markers (if inline provenance is used).
- [ ] Runnable code executes on all pages that contain runnable code.

### C. Human review gate

- [ ] Maarten completes technical sign-off.
- [ ] AI readability checklist pass run and its findings recorded.
- [ ] Maarten completes readability sign-off.
- [ ] Any blocking issue is logged in the page board and resolved.

### D. Final release gate

- [ ] Short human smoke check (desktop/mobile visual sanity and navigation behavior).
- [ ] Zero unresolved factual issues.
- [ ] Page status moved to `Approved`.
- [ ] Automation QA requirements from step B are still green at merge time.

## Page Status Board

| Page | Risk | Status | Technical sign-off (Maarten) | Readability sign-off (Maarten) | Blocking issue |
|---|---|---|---|---|---|
| **Site** | | | | | |
| faq.qmd | Medium | Populated | No | No | C2 (2026-08-04, Fable): fourteen questions under four headings (Getting started 3, Reading the results 6, Priors 2, Practicalities 3), every answer 2-5 sentences routing to its canonical page, no explanation owned by the FAQ. MM review 2026-08-04: centrality-as-intervention-targets question removed (not a relevant question for these methods). Provenance per question logged in the PR (GitHub issues #6/#10/#22, the tutorial repo's misreadings notes, guide hedges, the C3 symptom rows, B3/B6 material); no unevidenced questions. Placement: footer center link (nav-item syntax; a markdown footer link does not get per-page path resolution and broke 52 links before the fix), search-indexed; navbar left untouched per the brief. Runs-differ answer gives the honest MCMC/seed/mcse account and routes to C3's reproducibility section |
| index.qmd | Low | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | A2 sign-off pass: reviewed, no changes; citation picker reads the version off the installed build, Quick Start's install.packages("bgms") is live now that 0.2.0.0 is on CRAN |
| index.qmd | High | Populated (C1 addition pass) | No | No | C1 (2026-08-04, Fable): payoff figure under Quick Start (static PNG images/edge-evidence-wenchuan.png, generated from fit_wenchuan.rds with the flagship helper; static because index.qmd is freeze:false and CI has no fixtures, so an executed chunk would fail the deploy; numbers 35/62/39 match B1 and the A-series re-sweeps re-verify), one-sentence evidence line linking the flagship; audience fork above the feature cards (worked analyses vs from-bootnet-qgraph), styled with Bootstrap utilities only, index.css untouched; trust block after the citation picker (tutorial in preparation per D3, Marsman 2022 / Sekulovski 2024 / Huth 2026 by DOI, dated 0.2.0.0 news line); T4 no-op, the Examples card already existed. Visual gate: before/after screenshots light+dark x desktop+390px (headless Chrome against a local server; dark via the localStorage sentinel), hero intact, no layout breakage; sticker's right-edge overflow at 390px is pre-existing. Added text ~115 words. MM readability sign-off MANDATORY before merge per the brief |
| news.qmd | Low | Populated | No | No | A8 (2026-08-04, bgms main 6126312a): both entry dates corrected to 2026-08-04, the CRAN Published date; the 0.2.0.0 entry gained a changed-defaults paragraph (association scale, Normal slab in both entry points, hierarchical precision-graph prior, iter/warmup 2000, target_accept 0.80). A6: the 0.2.0.0 entry was reweighted to NEWS.md's own emphasis (model-class expansion, predict/simulate, NUTS backend, RB inclusion, prior constructors, sensitivity check last); MM reviews the wording. A3: the "bgms 0.2.0.0 on CRAN" entry and both entry dates (2026-07-30) are launch-gated; correct the dates if CRAN acceptance lands on another day |
| **Guide** | | | | | |
| guide/index.qmd | Low | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | A2 sign-off pass: the Edge Selection line reworded to lead with evidence rather than the spike-and-slab mechanism, per MM's terminology rulings |
| guide/getting-started.qmd | Medium | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | A2 sign-off pass (2026-08-04): full read, no further changes; figures and both fits' numbers verified against the fresh render (undecided pips 0.55/0.502 as stated). A8 (2026-08-04, bgms main 6126312a): the live GGM fit runs the new hierarchical default, so its numbers moved: the two undecided pairs go from pip 0.64/0.40 and BF 2.7/1.1 to 0.502/0.552 and BF 1.0/1.2, and the prior inclusion probability is now exactly 0.5. The verdict split is unchanged (3 presence / 5 absence / 2 undecided, same pairs). The closing caution is rewritten: the Bayes factor now IS the posterior odds by default, and the median-probability foil is rewritten because both undecided pairs now sit above 0.5. A6: both median-probability plots replaced by the three-panel edge evidence plot (D2); ordinal splits 8 presence / 1 absence / 1 undecided, GGM 3 / 5 / 2. The shown chunks now execute rather than mirroring a hidden twin, so the `qgraph` soft guard is gone (qgraph is a CI dependency). Install snippet pinned to `@develop`. MM re-reviews the figures. A4: numbers moved (the hidden fits ran `chains = 2` while the shown calls used the four-chain default; the hidden chunks now match the shown calls) |
| guide/graphical-models.qmd | Low | Not started | No | No | - |
| guide/bayesian-approach.qmd | Low | Not started | No | No | - |
| guide/prior-basics.qmd | Medium | Not started | No | No | A8 (2026-08-04, bgms main 6126312a): hierarchical/joint framing inverted in sec-edge-priors-continuous; the Cauchy slab no longer described as the bgmCompare baseline default. Renamed from prior-guide.qmd |
| guide/ggm.qmd | Medium | Scaffolded | No | No | A8 (2026-08-04, bgms main 6126312a): the precision_graph_prior bullets reordered with `"hierarchical"` as the default, the gauge described as in-chain, and the vacuous-argument acceptance stated |
| guide/omrf.qmd | High | Scaffolded | No | No | - |
| guide/mixed-model.qmd | Medium | Not started | No | No | A8 (2026-08-04, bgms main 6126312a): continuous-block paragraph reframed on the hierarchical default |
| guide/edge-selection.qmd | Medium | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | A2 sign-off pass (2026-08-04): CORRECTED a direction error introduced by the writing pass: under bernoulli_prior(0.1) the posterior odds UNDERSTATE the evidence for inclusion (they were said to overstate it). A8 (2026-08-04, bgms main 6126312a): sec-bf-continuous rewritten: the posterior-odds shortcut holds for continuous edges under the new default, and the effective-prior workaround is reframed as the `"joint"` opt-in. A6: the median-probability section now says it is a summary, not a display, and points at the edge evidence plot (D2). A5: fixture baked on 0e116079, numbers unchanged from A4; the saturated-edge readout is now the Bayes factor (about 2e119) with the log scale (274.76) shown beside it. A4: numbers moved to the manuscript-grade fixture (inclusion probability 0.74 -> 0.66, BF10 2.8 -> 2.0, BF01 35 -> 33, log BF 317 -> 275) |
| guide/group-comparison.qmd | Medium | Scaffolded | No | No | A8 (2026-08-04, bgms main 6126312a): compare-slab defaults swept Cauchy -> Normal (F-119), and the ADHD fixture rebaked at the new defaults moved every quoted number: motor-seat BF10 305 -> 886 (pip 0.997 -> 0.999), avoid-closeatt 3.3 -> 6.2, forget-talks BF01 2.5 -> 3.4 (pip 0.28 -> 0.23). A5: fixture baked on 0e116079, numbers unchanged. A4: numbers moved to the defaults fixture (BF10 290 -> 305, 3.5 -> 3.3, BF01 2.6 -> 2.5) |
| guide/clustering.qmd | Medium | Not started | No | No | A5: fixture baked on 0e116079, numbers unchanged. A4: numbers moved to the defaults fixture (P(B=1) 0.43 -> 0.42) |
| guide/mcmc-output.qmd | Medium | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | C3 (2026-08-04): anchor only, `sec-pinned-indicators` on the `NA` precision-columns sentence, so the diagnostics symptom index can deep-link it. A2 sign-off pass (2026-08-04): full read, no further changes. A8 (2026-08-04, bgms main 6126312a): `n_eff_mixt` removed as a reported summary column and from the extractor table; the NA rule corrected; the zratio_diag gloss now says the gauge runs by default. A5: fixtures baked on 0e116079, numbers unchanged; the extractor table now states both extractor scales. A4: numbers moved to the manuscript-grade fixture; the credible-interval example now pools all four chains instead of the first two |
| guide/mcmc-diagnostics.qmd | Medium | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | C3 (2026-08-04): symptom index added after the intro (15 rows, each with a one-line action), plus three new sections (sampler warnings enumerated from the release build, run-to-run reproducibility, still stuck) and explicit anchors on nine existing headings. Additions and anchors only; no existing prose rewritten. Micro-prose (rows and actions) awaits the Fable pass and MM review. A2 sign-off pass (2026-08-04): two stale NA claims corrected in the MCSE and R-hat sections (both still said NA appears for edges that never flipped; the rule is pinned draws, a smaller set), plus one clarity fix in the flag walkthrough. A8 (2026-08-04, bgms main 6126312a): sec-mixture-ess rewritten around the composite ESS, with the transition-based mixture ESS recorded as retired in 0.2.0.0; sec-rb-inclusion-ess reworked onto the transition counts and the two NA routes; sec-trust-gauge rewritten for the run-by-default gauge with its off switch, thresholds (1% flip rate, 0.02 harm), and advice ladder; the live `estimator = "mixt"` chunk replaced. A6: the `n_eff_mixt` gloss was wrong ("frequent switching means precisely estimated") and is corrected against `src/mcmc_diagnostics.cpp:375-387`: the statistic compares switch rates with an independent chain at the same inclusion probability, so absolute flip frequency is not a quality measure (a2-review-findings 1). A5: fixture baked on 0e116079, fixture numbers unchanged, but the indicator ESS the page prints moved from the transition ESS to the RB one (min 1122 -> 995) because `extract_ess()` changed its default; the transition reading is now shown explicitly. A4: numbers moved to the manuscript-grade fixture; new subsection reads the warmup flag this fit now raises |
| guide/missing-data.qmd | Medium | Populated | No | No | - |
| **Examples** | | | | | |
| examples/index.qmd | Low | Scaffolded | No | No | B0: section wired and the series contract written; the seven entries below stay unlinked plain text in the index prose until their pages ship. The PDF download link stays commented until the first one does; uncommenting it also means adding the `make examples-pdf` step to publish.yml, after the render and before the deploy, since a site render rewrites `docs/` |
| examples/estimation-to-evidence.qmd | High | Not started | No | No | B1; D3 gate (ship at launch vs hold for the tutorial preprint) |
| examples/estimation-to-evidence.qmd | High | Populated | No | No | A9 (2026-08-04): the `?verdicts` pointer upgraded to a link to reference/checks.qmd#verdicts, now that the page exists; no other change, and the page's numbers are unmoved. B1 (2026-08-04, Fable): the flagship worked analysis, template shape (payoff figure first). Full Wenchuan fit from fit_wenchuan.rds; verdicts 35/39/62 at BF 10 (40/12/84 at 3, 29/83/24 at 30, verified against the fixture); intrusion-concen payoff (BF 158.6, weight -0.14 [-0.20, -0.07]) against the live in-page EBICglasso zero (75 of 136 edges selected). Uses verdicts() (no site reference page yet, points at ?verdicts; flagged-issues item 20). Helper is the Getting Started plot_edge_evidence with vsize exposed (9 for 17 nodes); layout deterministic via seed, no layout fixture needed. Papers line carries "manuscript in preparation" per the D3 fallback. Ownership trim: guide/edge-selection.qmd#a-worked-example reduced to a three-edge snippet linking here (run-length rationale moved here); inbound links on reading-the-output and reference/bgm repointed. STYLE_GUIDE Network Figures classification clause updated for the hierarchical default. MM sign-off pending |
| examples/reading-the-output.qmd | Medium | Populated | No | No | A8 (2026-08-04, bgms main 6126312a): the indicator-block walkthrough corrected: `n_eff_mixt` is gone from the table, the blanks are nine edges rather than sixteen (the sixteen zero-transition edges are a different, larger set), and `distant-numb` is named as the second NA route. B2: summary() of the Wenchuan fit walked block by block, all column claims verified against R/mcmc_summary.R and src/mcmc_diagnostics.cpp on the release build. Template deviation, with reason: the payoff slot holds the full printed summary() instead of a figure (the printout is the artifact this page teaches), and the fit mirror precedes it so the companion script runs in order. The brief's "partial correlations" row in Where-is-X is split per model type: extract_partial_correlations() returns NULL on this all-ordinal fit, so the ordinal row points at extract_log_odds(). Closing bgmCompare pointer goes to guide/group-comparison.qmd until the B4 example ships. guide/mcmc-output.qmd gained the top-of-page pointer here |
| examples/check-your-priors.qmd | High | Not started | No | No | B3; reads ps_wenchuan.rds |
| examples/check-your-priors.qmd | High | Populated | No | No | C3 (2026-08-04): anchor only, `sec-how-to-act` on the How to act heading, so the diagnostics symptom index can deep-link the scale-dependent-verdict remedy. B3 (2026-08-04, Fable): prior_sensitivity_check() on the Wenchuan fit, read from ps_wenchuan.rds, template shape (payoff curve first). Headline 91 of 136 verdicts hold across 0.4x-2.5x; categories 91 robust / 6 within noise / 31 beyond noise / 8 not certifiable; flash-concen the only presence mover, to undecided; preferred scale 0.18 [0.148, 0.218] against the chosen 1; every number verified against the fixture's printed report. Curve prose states the max_labels = 10 rule: plot(ps) colors and names only the ten largest evidence swings, so the report's movers table is the complete list (the roxygen's promised corner note for the rest is not drawn; flagged upstream as a bgms polish item). Companion script 04-check-your-priors.R reruns fit, check, report, and curve. Wiring: examples sidebar and index entry activated, estimation-to-evidence footer link switched from the in-preparation note, guide/prior-basics.qmd robustness paragraph links here. MM sign-off pending |
| examples/comparing-groups.qmd | Medium | Not started | No | No | B4 |
| examples/comparing-groups.qmd | Medium | Populated | No | No | B4 (2026-08-04, Fable): the worked bgmCompare page on the ADHD fixture (defaults + seed, matching fixtures/bake.R exactly). Payoff = plot(fit) difference display, live: 5 supported / 0 ruled out / 148 undecided of 153 pairwise differences at BF 10; 2 fragile; 18 main-diff rows unsampled (main_difference_selection = FALSE) with the print's marking explained; flag_validated = FALSE for differences stated per the checks contract. Difference walked: motor-seat BF 886, group weights -0.51 (no diagnosis) vs +0.91 (diagnosed), the sign flip named as the finding. Equivalence handled honestly: none at BF 10 (strongest forget-org BF01 3.6, undecided), 8 at threshold 3 shown live, scope stated as invariance of the modeled parameter. Guide trim per ownership rule: group-comparison.qmd's worked example (fixture chunks + three-row snippet) replaced by a pointer paragraph; NOTE FOR MM per the brief. Companion script 05 = fit, plot, verdicts, difference walk, threshold-3 table. MM sign-off pending |
| examples/edge-clustering.qmd | Medium | Not started | No | No | B5 |
| examples/edge-clustering.qmd | Medium | Populated | No | No | B5 REWORKED on the Martarelli data (2026-08-05, Fable; MM directive replacing the Wenchuan version): 18 items (8 SBPS boredom + 10 CEI-II curiosity) from the French SBPS validation, N = 490, data shipped at data/martarelli.rds and published with the site (companion script downloads it from the site URL). Fit = bgm(items, edge_prior = sbm_prior(), iter = 2e4, warmup = 1e4, seed = 123); the run length is deliberate and taught on-page: defaults (2e3/2e3) print a warmup warning with split-Rhat 1.35 / ESS 44, and the clustering BF is unstable until convergence (about 6 at iter 1e4 vs about 200 at 2e4); final diagnostics worst split-Rhat 1.013, min ESS about 350, wobble confined to cross-block edges. Story: clustering BF 202, two-vs-one 212, two-vs-three 1.04 (undecided; second-order honesty beat), modal partition recovers the two instruments exactly, co-clustering 0.82-0.96 within / at most 0.09 between; verdicts 37/24/92. Citation fix riding along: datasets.qmd Boredom section cited a fabricated Martarelli/Wolff/Wolff entry (dead DOI); replaced with the Crossref-verified EJPA paper (MartarelliEtAl_2023_sbps), bad bib entry deleted; package-side name nit filed as flagged-issues item 24. Wenchuan-null cross-claim DROPPED: the old fit_wenchuan_sbm fixture at defaults is itself under-converged (Rhat 1.15, ESS 123). Companion script 06 = download, fit, extract, BFs, allocations, ranges, heatmap, verdicts. MM sign-off pending |
| examples/from-bootnet-qgraph.qmd | High | Not started | No | No | B6; terminology sync with the tutorial manuscript (NS) |
| examples/from-bootnet-qgraph.qmd | High | Populated | No | No | B6 (2026-08-04, Fable): the switcher on-ramp. Eleven-row mapping table synced with the manuscript's translation table (sec:translation): its eight rows carried over cell for cell in website register; three rows added beyond it, flagged for the manuscript to adopt or decline: how-do-I-draw-it (plot(network) -> plot(fit)), do-the-groups-differ (NCT -> bgmCompare; the manuscript deliberately keeps groups out of its table and points at its discussion instead, so this row is a deliberate page-level deviation), and what-does-a-blank-mean (links the flagship). Left column verified against installed bootnet 1.9.1 / qgraph 1.10.1 / NetworkComparisonTest 2.2.3 (differenceTest measure = "edge" confirmed in its Rd); every right-column call executed against fit_wenchuan.rds in a hidden verify-map chunk that stopifnot-fails the render on a broken claim. Epskamp-Borsboom-Fried 2018 added to references.bib after Crossref verification (the one citation the silent-zero quote at p. 200 needs). Companion script 07 is the right column top to bottom. Give-up paragraph names runtime, prior-owned shrinkage, CS-coefficient, bridge/expected-influence, non-EBICglasso defaults. MM close review expected per the brief |
| **Reference** | | | | | |
| reference/index.qmd | Low | Populated | No | No | A9 (2026-08-04): the gap note DELETED and the "Complete documentation for all exported functions" headline restored, verified first against getNamespaceExports("bgms") set-minus the names documented in reference/*.qmd (empty; the three deprecated extractor aliases are covered by the Deprecated section, mrfSampler by the simulate_mrf row). New rows: verdicts() and calibration_check() under Diagnostics, plot() and plot_edge_posterior() under Methods, extract_centrality() under Extractors. MM sign-off pending; this supersedes the A2 approval below. A2 sign-off pass (2026-08-04): COVERAGE GAP found and made honest: verdicts(), calibration_check(), plot_edge_posterior(), extract_centrality(), and the plot() methods are exported with complete R help but have no site pages; the 'Complete documentation for all exported functions' headline softened and a pointer to ?verdicts added. Site pages for these are post-launch debt (routed to plans flagged-issues). A8 (2026-08-04, bgms main 6126312a): the prior table no longer names Cauchy as the bgmCompare default; the extract_ess row drops `estimator = "mixt"`. A5: the `extract_inclusion_bf()` and `extract_ess()` rows now name the release defaults |
| reference/bgm.qmd | High | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | A2 sign-off pass (2026-08-04): full read; signature and every documented default verified against formals(bgm) on the installed CRAN build, exact match. A8 (2026-08-04, bgms main 6126312a): signature and precision_graph_prior row rewritten for the hierarchical default; the correction-table callout split into the hierarchical surface build and the joint correction table; the zratio_diag return field rewritten. A5: fixture baked on 0e116079, numbers unchanged; `standardize` added to the deprecated-arguments callout. A4: numbers moved to the manuscript-grade fixture |
| reference/bgmCompare.qmd | High | Populated | No | No | A8 (2026-08-04, bgms main 6126312a): signature and both prior rows swept to the Normal defaults (F-119). A5: `standardize` added to the deprecated-arguments callout |
| reference/sample-ggm-prior.qmd | High | Populated | No | No | - |
| reference/checks.qmd | High | Populated | No | No | A9 (2026-08-04): new page. verdicts() and calibration_check(), both verified against formals() and live calls on fit_wenchuan.rds. verdicts() runs live (35 presence / 39 undecided / 62 absence at BF 10, 7 fragile, 136 indicators; 29/83/24 at BF 30). calibration_check() also runs live: it reads the existing draws and never refits, measured at 1.4 s for the 17-variable Wenchuan fit at the default nrep = 200, so no eval:false mirror was needed; the chunk passes seed = 123 because the consistency band is resampled and an unseeded rerun would move share_outside_band. Fragility defined exactly as the print method defines it (a verdict boundary within two standard errors of the evidence), with the 37,010-fit / 66-error operating point and the bgmCompare flag_validated = FALSE caveat carried over from the Rd. MM sign-off pending |
| reference/prior-samplers.qmd | High | Populated | No | No | A8 (2026-08-04, bgms main 6126312a): the summarize_zratio_gauge section no longer says the gauge is off by default; `harm_threshold` corrected 0.01 -> 0.02 (F-103) in both the signature and the argument table; `block_lo`/`block_hi` added to the per_chain columns. A2 readability pass 2026-08-03: page is in the sidebar and linked five times from reference/index.qmd and reference/bgm.qmd, but was missing from this board (same class as the null-space and zratio-hierarchical findings under A1). Never gated; not on the A2 newcomer path, so it does not block launch |
| reference/priors.qmd | High | Populated | No | No | A8 (2026-08-04, bgms main 6126312a): cauchy_prior() no longer described as the bgmCompare baseline default |
| reference/methods.qmd | Medium | Populated | No | No | A9 (2026-08-04): new `plot` section for plot.bgms and plot.bgmCompare beside print/summary/coef, with the edge evidence plot stated as its contract (STYLE_GUIDE Network Figures) and the Getting Started plot_edge_evidence() helper cross-linked; live figures for plot(fit) at 13x5 and plot(fit, type = "centrality"). plot_edge_posterior() placed here rather than on checks.qmd, as the package's other fit-drawing entry point; on a page of two check objects it would have been the only entry that is not a check. mrfSampler() recorded under simulate_mrf as a deprecated former name (renamed 0.1.6.3; still works, warns once per session). Signatures verified against formals(). MM sign-off pending. A8 (2026-08-04, bgms main 6126312a): the indicator-table column list drops `n_eff_mixt` and states the two NA routes. A5: fixtures baked on 0e116079, numbers unchanged. A4: numbers moved to the manuscript-grade fixture |
| reference/prior-sensitivity.qmd | High | Approved | Yes (A2 pass delegated to AI, 2026-08-04) | Yes (A2 pass delegated to AI, 2026-08-04) | A2 sign-off pass (2026-08-04): formals verified against the installed build (exact match, including tolerance = 0.5 * log(10)); 'prices the curve' reworded. A8 (2026-08-04, bgms main 6126312a): the Bartos framing aligned to the MM-approved F-005 roxygen (the reweighting identity is Bartos's, applied locally; the anchored construction is the package's); the whole page moved from log10 to natural log units (F-051), the renamed columns fixed in the Value table and in the live chunk, the new `vary` argument documented, `tolerance` default corrected to `0.5 * log(10)`, and the display cap stated as ln(1e6). A6: the page no longer claims the method is that of @BartosEtAl_2026_sensitivity; the citation stays as the single-fit approach the design departs from, per `R/prior_sensitivity.R:11-14`. A5: fixture baked on 0e116079; every statistic unchanged, only the reported refit wall-clock moved (166 s -> 129 s). A4: numbers moved to the manuscript-grade fixture (91 of 136 verdicts robust, 8 not certifiable) |
| reference/extractors.qmd | Medium | Populated | No | No | A9 (2026-08-04): extract_centrality() added with its summary() and plot() methods, live on fit_wenchuan.rds (dreams most central, p_most_central 0.71). Placed after extract_pairwise_interactions, the draws it is computed from, NOT in alphabetical position as A9 T3 asked: this page is ordered thematically, not alphabetically, so the brief's slot did not exist. `measure` documented as accepting only "strength" (anything else is a match.arg error, verified). The centrality caveat is the Rd's own (model-averaged draws, difference read as numbers not a picture, the point mass at zero behind p_positive); no guide cross-link was added because no guide page discusses centrality. MM sign-off pending. A8 (2026-08-04, bgms main 6126312a): extract_prior_inclusion_probabilities rewritten for the hierarchical default (no table, no chain); the F-020 slab-weight-disagreement caveat added to extract_rhat with its manual workaround; extract_ess rewritten for the deprecation of `estimator = "mixt"` and its live chunk replaced. A5: fixture baked on 0e116079, numbers unchanged; the extract_inclusion_bf and extract_ess entries carry the release signatures and both scales. A4: numbers moved to the manuscript-grade fixture (inclusion probability 0.74 -> 0.66, log BF 317 -> 275) |
| reference/datasets.qmd | Low | Populated | No | No | - |
| **Manual** | | | | | |
| manual/index.qmd | Low | Scaffolded | No | No | - |
| manual/architecture.qmd | Medium | Populated | No | No | - |
| manual/r-scaffolding.qmd | Medium | Not started | No | No | A1: no walkthrough for the #183 R files (`prior_sensitivity.R`, `refit_engine.R`, `anchor_curve.R`) |
| manual/model-classes.qmd | High | Contradiction-checked | No | No | A1: `base_model.h` gained warm-start (`set_warm_step_size`, `get_final_inv_mass`, ...) and RB-inclusion accessors in #182/#183; `set_gauge_active` signature changed and `on_warmup_end` was dropped |
| manual/samplers.qmd | High | Populated | No | No | Stale vs refactored dispatch (audit 2026-07-28 §1.2); also A1: warm-start hooks added to `sampler_base.h` (#183) |
| manual/nuts.qmd | High | Populated | No | No | - |
| manual/null-space.qmd | High | Populated | No | No | A1: page is in the sidebar but was missing from this board |
| manual/rattle.qmd | High | Populated | No | No | - |
| manual/metropolis.qmd | High | Populated | No | No | - |
| manual/warmup.qmd | High | Populated | No | No | - |
| manual/diagnostics.qmd | High | Populated | No | No | A1: stale claim that `n_eff_mixt` is "flagged in the output" below 5 transitions; that suppression was removed in bgms #182 |
| manual/pseudolikelihood.qmd | Medium | Populated | No | No | - |
| manual/parameter-priors.qmd | High | Populated | No | No | A1: needs a pointer to `prior_sensitivity_check()`. Commit 794569b removed the old one, which said the per-iteration scale draws "feed" the check; #183 made the check refit-based, so the old sentence must not be restored verbatim |
| manual/zratio-hierarchical.qmd | High | Populated | No | No | A1: page is in the sidebar but was missing from this board. Stale source path (`src/models/zratio_gauge.h` moved under `src/models/ggm/` in #180); the one-time surface build now announces itself and its elapsed time (#173) |
| manual/parallel-chains.qmd | Medium | Populated | No | No | - |
| manual/ggm-internals.qmd | High | Contradiction-checked | No | No | - |
| manual/omrf-internals.qmd | High | Contradiction-checked | No | No | - |
| manual/variable-helpers.qmd | High | Contradiction-checked | No | No | - |
| manual/mixed-internals.qmd | High | Contradiction-checked | No | No | - |
| manual/edge-priors.qmd | High | Contradiction-checked | No | No | - |
| manual/sbm-prior.qmd | High | Contradiction-checked | No | No | - |
| manual/bgmcompare-internals.qmd | High | Contradiction-checked | No | No | - |
| manual/numerical.qmd | High | Populated | No | No | - |

Note: the Examples section rows above are the rebuilt section (brief B0), not
the seven undeveloped pages removed in c1cb840; those are gone for good and
share nothing with these. Full audit findings per page:
`dev/audit-2026-07-28.md`.

## Secondary Backlog (Not Part of A -> B Review Sequence)

These tasks are important but are not part of the core review flow above.

### P1 - Documentation delivery workflow

- [ ] Finalize and follow the process in `dev/set-up.md`.
- [ ] Keep this file updated at every status change.
- [ ] Define accountability link examples for high-risk claims.
- [ ] Add a small script/CI job for the required automation QA checklist.

### P2 - Infrastructure

Closed under brief A3 (branch `docs/a3-launch-mechanics`). Decision D1 (MM,
2026-07-30): the canonical URL is
https://bayesian-graphical-modelling-lab.github.io/bgms/, the Quarto site
supersedes the pkgdown site currently served there, and /bgms-docs/ redirects
to it.

- [x] Host the documentation from bgms-docs while keeping the public URL at https://bayesian-graphical-modelling-lab.github.io/bgms/.
- [x] Add GitHub Actions workflow in bgms-docs to render Quarto and deploy to the publishing target used by the bgms website. `publish.yml` publishes `docs/` to the `gh-pages` branch of the bgms repo; every deploy step is guarded on a branch.
- [x] Redirect stubs for the pkgdown URL layout: `scripts/redirects.R` (project `post-render`) writes 104 stubs with canonical link tags; `redirect/` holds the /bgms-docs/ root and deep-path stubs.
- [x] Version stamp: read from the installed bgms DESCRIPTION at render time (A7, `scripts/doc-build.R`), so the release build and the dev build each print their own. `BGMS_DOC_VERSION` remains as an override and is no longer set in CI; the hardcoded 0.2.0.0 fallback in `index.qmd` is gone.
- [x] Versioned deployment (A7): root = release, `/dev/` = development docs on every push to docs/develop, `/vX.Y.Z/` archives from the release after 0.2.0.0. `scripts/deploy-gh-pages.sh` holds the root-exclusion invariant, `scripts/simulate-deploy.sh` proves it, `scripts/versions.R` writes the version index and `js.html` renders the switcher.
- [x] Document deployment and rollback steps for maintainers (README.md § Deployment), including the release-day archive recipe and how to add a versions.json entry.
- [ ] BLOCKED on MM: configure deployment credentials with least-privilege access. Needs an SSH deploy key pair, the public half as a write-enabled deploy key on the bgms repo, the private half as the `BGMS_SITE_DEPLOY_KEY` secret here, and Pages on the bgms repo set to the `gh-pages` branch. Exact steps: README.md § Deployment → One-time setup.
- [ ] BLOCKED on MM or the bgms companion agent, before the first deploy: retire pkgdown in the bgms repo (delete `.github/workflows/pkgdown.yaml` and `_pkgdown.yml`), or its next push rebuilds pkgdown over the new site. Also point the DESCRIPTION `URL` field and the README badge at the canonical site.
- [ ] Open: no custom 404 page on the canonical site. Unmapped paths fall through to the GitHub Pages default. A `404.qmd` offering navigation would close the last of the BGGM failure mode.

### P3 - Notation consistency fixes

See STYLE_GUIDE.md \u00a7 Mathematical Notation for the authoritative conventions.
All notation fixes have been applied.

### P2 - Documentation maintenance

- [ ] Define a process to monitor upstream bgms repository changes for documentation impact.
- [ ] Add criteria for when code/API changes require documentation updates.
- [ ] Add attribution/licensing note after confirming terms for reused Quarto website structure/content.
- [ ] Investigate similar projects for attribution, content licensing, and trademark notices.
- [ ] Optional future check: if Positron website assets/templates are introduced later, reassess attribution and license compatibility.
- [ ] Deferred: draft `docs/attribution.md` template and `README.md` provenance boilerplate after licensing position is confirmed.

### P3 - Upstream change automation (bgms -> bgms-docs)

Event-driven alerts:

- [ ] In bgms repo: add workflow that detects docs-impacting file changes and sends `repository_dispatch` to bgms-docs.
- [ ] In bgms repo: define docs-impacting path filters (`R/**`, `src/**`, `man/**`, `NAMESPACE`, `DESCRIPTION`, `NEWS*`, selected `vignettes/**`).
- [ ] In bgms-docs repo: add workflow triggered by `repository_dispatch` to create or update a docs-sync issue immediately.
- [ ] In bgms-docs repo: issue body should include commit SHA, PR number/title, changed files summary, compare URL, and trigger timestamp.

Scheduled checks:

- [ ] Add weekly scheduled workflow in bgms-docs to compare latest processed bgms SHA with upstream default branch SHA.
- [ ] Add monthly scheduled workflow option (configurable) for lower-noise periods.
- [ ] Ensure scheduled run opens/updates issue only when there is meaningful delta.

Triage workflow:

- [ ] Auto-apply labels on created/updated issue: `docs-sync`, `needs-triage`.
- [ ] Add triage decision checklist to issue template: `no-doc-change`, `minor-doc-update`, `major-doc-update`.
- [ ] Auto-convert triage decision to follow-up issue labels (`minor`, `major`, `blocked`) when triage is completed.
- [ ] Keep one rolling tracking issue per release cycle to avoid issue spam.

Reliability and security:

- [ ] Configure cross-repo auth using least-privilege token (`BGMS_DOCS_DISPATCH_TOKEN`) stored as repository secret.
- [ ] Add idempotency guard so the same commit/PR event is not appended twice.
- [ ] Add failure notification path (workflow summary + optional issue comment) when dispatch or API update fails.

Optional enhancements:

- [ ] In bgms PR template: add checkbox "This change may require docs updates" and map to `docs-impact` label.
- [ ] If `docs-impact` label is set, force dispatch regardless of path-filter outcome.
- [ ] Add contributor docs in `README.md` describing how automated docs-sync signals are generated and triaged.

### P3 - Design de-risking (Quarto-derived skeleton)

Layout-impact guardrails:

- [ ] Capture visual baseline for home, one guide page, one reference page, one manual page, in both light and dark mode.
- [ ] Define acceptance criteria per page type (navbar, sidebar, TOC, heading scale, code readability, mobile nav).
- [ ] Use change sequencing: replace styles/scripts first, then remove legacy files after replacement behavior is verified.
- [ ] For each de-risking PR, include before/after screenshots and a short note on intentional layout changes.
- [ ] Keep a rollback path: avoid deleting original files until replacement CSS/JS has passed review.

Keep:

- [ ] Keep Quarto-generated runtime assets in `docs/site_libs/` as standard framework output; do not hand-edit generated files.
- [ ] Keep overall information architecture pattern (navbar + sidebar + TOC) as implementation pattern, not copied branding.
- [ ] Keep package-specific content structure in `guide/`, `reference/`, and `manual/`.

Change:

- [ ] Refactor `index.css` hero/banner layout to diverge clearly from inherited skeleton.
- [ ] Rewrite `theme.scss` token choices to a bgms-specific design system.
- [ ] Rewrite `theme-dark.scss` custom rules and remove Quarto/Posit-specific language.
- [ ] Review and simplify `js.html` behavior; keep only behavior needed for bgms docs UX.
- [ ] Update `styles.css` to remove "Quarto-inspired" framing and define explicit bgms branding tokens.

Remove or archive:

- [ ] Remove `_quarto.yml.quarto-web-original` when internal reference is no longer needed.
- [ ] Remove or replace `filters/tools-tabset.lua` if tools-tabset UI is unused; otherwise rewrite labels/icons/text.
- [ ] Remove leftover Quarto/Posit naming in comments, alt text, class names, and metadata when not functionally required.

Governance and traceability:

- [ ] Add `docs/attribution.md` with explicit acknowledgments and links once licensing/permission is clarified.
- [ ] Add provenance note in `README.md` describing what was adapted vs rewritten.
- [ ] Record source map in `docs/attribution.md`: adapted elements vs original bgms work.
- [ ] Add release checklist item: design de-risking pass completed before first public deployment.

### P3 - Automated reference checking

- [ ] Integrate `hallucinator-cli` (Rust) into a pre-render or pre-commit check for `.bib` files.
  - Install: `curl --proto '=https' --tlsv1.2 -LsSf https://github.com/gianlucasb/hallucinator/releases/latest/download/hallucinator-cli-installer.sh | sh`
  - Checks CrossRef, arXiv, DBLP, Semantic Scholar, ACL, Europe PMC, PubMed, OpenAlex in parallel.
  - Flags: verified, author-mismatch, not-found (potential hallucination), retracted papers.
  - Supports `.bib` files directly: `hallucinator-cli check references.bib`
  - Known limitations: weak on books, old math papers, niche venues; DBLP rate-limits (consider offline DB).
- [ ] Evaluate as part of a future quarto-based paper-writing suite for automated reference validation.
- [ ] Consider complementing with `rcrossref` (R/CRAN) DOI-based metadata verification for entries that have DOIs.

## Open Decisions

- None currently.

## Settled Decisions

- D4 (MM, 2026-07-30): the documentation is versioned. The site root serves
  the current release directly, /dev/ serves the development documentation
  and deploys on every push to docs/develop, and a frozen /vX.Y.Z/ archive
  joins them per CRAN release from the release after 0.2.0.0. Implemented
  under brief A7; see the Versioned Deployment section above and README.md
  § Deployment.
- D2 (MM, 2026-07-30): the edge evidence plot is the site's canonical
  network display; the median-probability network is never a final
  display. Implemented under brief A6; see the Network Figure Convention
  section above and STYLE_GUIDE.md § Network Figures.
- D1 (MM, 2026-07-30): the canonical documentation URL is
  https://bayesian-graphical-modelling-lab.github.io/bgms/. The Quarto site
  supersedes the pkgdown site served there, and
  https://bayesian-graphical-modelling-lab.github.io/bgms-docs/ redirects to
  it. Implemented under brief A3; see README.md § Deployment.
