# bgms-docs Task List (Single Source of Truth)

This file is the official status board for docs work.
If another note conflicts with this file, this file wins.

## How To Use This Board

- Keep updates short and concrete.
- Update this file when page status changes.
- Use one status value only: `Scaffolded`, `Populated`, `Contradiction-checked`, `Reviewed`, `Approved`, `Blocked`.
- Technical sign-off owner: Maarten.
- Readability sign-off owner: Emily.

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
Rules: never merge into main until the package develop ships; periodically
merge main into it; re-sweep against bgms develop HEAD at each sync.

## Fixture Configuration (brief A4, rebaked under A5, 2026-07-30)

All four fixtures are baked on the release build, bgms develop **0e116079**
(version 0.2.0.0).

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

The SBM fit and the ADHD group comparison are not manuscript analyses and run
at package defaults with the same seed. No 2-chain fixtures remain. Rebake and
re-render together; the bake costs about ten minutes (see `fixtures/bake.R`).

Both bgms-side changes that A4 left open have landed and are applied on the
site (brief A5):

- BGMS-2 (bgms #188, `0e116079`). `extract_ess()` gained
  `estimator = c("rb", "mixt")` and its `indicator` element is now the RB
  `n_eff`, matching `summary(fit)$indicator$n_eff` and `extract_rhat()`.
  Swept on reference/extractors.qmd § extract_ess, reference/index.qmd,
  guide/mcmc-diagnostics.qmd (§ sec-rb-inclusion-ess and the warmup
  subsection), and guide/mcmc-output.qmd. The same PR put `standardize`
  through lifecycle; documented on reference/bgm.qmd and
  reference/bgmCompare.qmd.
- PR #186 (`cc3410f0`). `extract_inclusion_bf()` gained `log = FALSE`, so
  the default return is the Bayes factor rather than its natural log. Swept
  on reference/extractors.qmd § extract_inclusion_bf, reference/index.qmd,
  guide/edge-selection.qmd, and guide/mcmc-output.qmd. The quoted evidence
  for `intrusion-dreams` is now the Bayes factor, about 2e119, with the log
  scale (274.76) shown alongside it; the log values themselves did not move.

The 2b decision did not change `precision_graph_prior`: the installed
release build still defaults to `"joint"`, so the effective-prior workaround
on guide/edge-selection.qmd § sec-bf-continuous stands as written.

## Current Cycle Focus

- Build trusted docs with automation-first QA.
- Run runnable R code checks on all pages with runnable code.
- Keep accountability links for high-risk claims.

## Review Sequence (Main Workflow)

This is the main A -> B workflow for Maarten and Emily.
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
- [ ] Emily completes readability sign-off.
- [ ] Any blocking issue is logged in the page board and resolved.

### D. Final release gate

- [ ] Short human smoke check (desktop/mobile visual sanity and navigation behavior).
- [ ] Zero unresolved factual issues.
- [ ] Page status moved to `Approved`.
- [ ] Automation QA requirements from step B are still green at merge time.

## Page Status Board

| Page | Risk | Status | Technical sign-off (Maarten) | Readability sign-off (Emily) | Blocking issue |
|---|---|---|---|---|---|
| **Site** | | | | | |
| news.qmd | Low | Populated | No | No | A3: the "bgms 0.2.0.0 on CRAN" entry and both entry dates (2026-07-30) are launch-gated; correct the dates if CRAN acceptance lands on another day |
| **Guide** | | | | | |
| guide/index.qmd | Low | Not started | No | No | - |
| guide/getting-started.qmd | Medium | Scaffolded | No | No | A4: numbers moved (the hidden fits ran `chains = 2` while the shown calls used the four-chain default; the hidden chunks now match the shown calls) |
| guide/graphical-models.qmd | Low | Not started | No | No | - |
| guide/bayesian-approach.qmd | Low | Not started | No | No | - |
| guide/prior-basics.qmd | Medium | Not started | No | No | Renamed from prior-guide.qmd |
| guide/ggm.qmd | Medium | Scaffolded | No | No | - |
| guide/omrf.qmd | High | Scaffolded | No | No | - |
| guide/mixed-model.qmd | Medium | Not started | No | No | - |
| guide/edge-selection.qmd | Medium | Scaffolded | No | No | A5: fixture baked on 0e116079, numbers unchanged from A4; the saturated-edge readout is now the Bayes factor (about 2e119) with the log scale (274.76) shown beside it. A4: numbers moved to the manuscript-grade fixture (inclusion probability 0.74 -> 0.66, BF10 2.8 -> 2.0, BF01 35 -> 33, log BF 317 -> 275) |
| guide/group-comparison.qmd | Medium | Scaffolded | No | No | A5: fixture baked on 0e116079, numbers unchanged. A4: numbers moved to the defaults fixture (BF10 290 -> 305, 3.5 -> 3.3, BF01 2.6 -> 2.5) |
| guide/clustering.qmd | Medium | Not started | No | No | A5: fixture baked on 0e116079, numbers unchanged. A4: numbers moved to the defaults fixture (P(B=1) 0.43 -> 0.42) |
| guide/mcmc-output.qmd | Medium | Populated | No | No | A5: fixtures baked on 0e116079, numbers unchanged; the extractor table now states both extractor scales. A4: numbers moved to the manuscript-grade fixture; the credible-interval example now pools all four chains instead of the first two |
| guide/mcmc-diagnostics.qmd | Medium | Populated | No | No | A5: fixture baked on 0e116079, fixture numbers unchanged, but the indicator ESS the page prints moved from the transition ESS to the RB one (min 1122 -> 995) because `extract_ess()` changed its default; the transition reading is now shown explicitly. A4: numbers moved to the manuscript-grade fixture; new subsection reads the warmup flag this fit now raises |
| guide/missing-data.qmd | Medium | Populated | No | No | - |
| **Reference** | | | | | |
| reference/index.qmd | Low | Scaffolded | No | No | A5: the `extract_inclusion_bf()` and `extract_ess()` rows now name the release defaults |
| reference/bgm.qmd | High | Populated | No | No | A5: fixture baked on 0e116079, numbers unchanged; `standardize` added to the deprecated-arguments callout. A4: numbers moved to the manuscript-grade fixture |
| reference/bgmCompare.qmd | High | Populated | No | No | A5: `standardize` added to the deprecated-arguments callout |
| reference/sample-ggm-prior.qmd | High | Populated | No | No | - |
| reference/priors.qmd | High | Populated | No | No | - |
| reference/methods.qmd | Medium | Populated | No | No | A5: fixtures baked on 0e116079, numbers unchanged. A4: numbers moved to the manuscript-grade fixture |
| reference/prior-sensitivity.qmd | High | Populated | No | No | A5: fixture baked on 0e116079; every statistic unchanged, only the reported refit wall-clock moved (166 s -> 129 s). A4: numbers moved to the manuscript-grade fixture (91 of 136 verdicts robust, 8 not certifiable) |
| reference/extractors.qmd | Medium | Populated | No | No | A5: fixture baked on 0e116079, numbers unchanged; the extract_inclusion_bf and extract_ess entries carry the release signatures and both scales. A4: numbers moved to the manuscript-grade fixture (inclusion probability 0.74 -> 0.66, log BF 317 -> 275) |
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

Note: the Examples section was removed from the website (undeveloped); its
seven pages are dropped from this board. Full audit findings per page:
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
- [x] Add GitHub Actions workflow in bgms-docs to render Quarto and deploy to the publishing target used by the bgms website. `publish.yml` publishes `docs/` to the `gh-pages` branch of the bgms repo; both deploy steps are guarded on `main`.
- [x] Redirect stubs for the pkgdown URL layout: `scripts/redirects.R` (project `post-render`) writes 104 stubs with canonical link tags; `redirect/` holds the /bgms-docs/ root and deep-path stubs.
- [x] Version stamp: `BGMS_DOC_VERSION=0.2.0.0` in the CI render environment; `index.qmd` keeps the same value as its in-source fallback.
- [x] Document deployment and rollback steps for maintainers (README.md § Deployment).
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

- D1 (MM, 2026-07-30): the canonical documentation URL is
  https://bayesian-graphical-modelling-lab.github.io/bgms/. The Quarto site
  supersedes the pkgdown site served there, and
  https://bayesian-graphical-modelling-lab.github.io/bgms-docs/ redirects to
  it. Implemented under brief A3; see README.md § Deployment.
