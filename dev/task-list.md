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
Rules: never merge into main until the package develop ships; periodically
merge main into it; re-sweep against bgms develop HEAD at each sync.

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
| **Guide** | | | | | |
| guide/index.qmd | Low | Not started | No | No | - |
| guide/getting-started.qmd | Medium | Scaffolded | No | No | - |
| guide/graphical-models.qmd | Low | Not started | No | No | - |
| guide/bayesian-approach.qmd | Low | Not started | No | No | - |
| guide/prior-basics.qmd | Medium | Not started | No | No | Renamed from prior-guide.qmd |
| guide/ggm.qmd | Medium | Scaffolded | No | No | - |
| guide/omrf.qmd | High | Scaffolded | No | No | - |
| guide/mixed-model.qmd | Medium | Not started | No | No | - |
| guide/edge-selection.qmd | Medium | Scaffolded | No | No | - |
| guide/group-comparison.qmd | Medium | Scaffolded | No | No | - |
| guide/clustering.qmd | Medium | Not started | No | No | - |
| guide/mcmc-output.qmd | Medium | Populated | No | No | - |
| guide/mcmc-diagnostics.qmd | Medium | Populated | No | No | - |
| guide/missing-data.qmd | Medium | Populated | No | No | - |
| **Reference** | | | | | |
| reference/index.qmd | Low | Scaffolded | No | No | - |
| reference/bgm.qmd | High | Populated | No | No | - |
| reference/bgmCompare.qmd | High | Populated | No | No | - |
| reference/sample-ggm-prior.qmd | High | Populated | No | No | - |
| reference/priors.qmd | High | Populated | No | No | - |
| reference/methods.qmd | Medium | Populated | No | No | - |
| reference/prior-sensitivity.qmd | High | Populated | No | No | - |
| reference/extractors.qmd | Medium | Populated | No | No | - |
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

- [ ] Host the documentation from bgms-docs while keeping the public URL at https://bayesian-graphical-modelling-lab.github.io/bgms/.
- [ ] Add GitHub Actions workflow in bgms-docs to render Quarto and deploy to the publishing target used by the bgms website.
- [ ] Configure deployment credentials (fine-grained PAT or GitHub App) with least-privilege access.
- [ ] Document deployment and rollback steps for maintainers.

### P3 - Notation consistency fixes\n\nSee STYLE_GUIDE.md \u00a7 Mathematical Notation for the authoritative conventions.\nAll notation fixes have been applied.

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
