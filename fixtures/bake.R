# Bake the website fixtures.
#
# The executed chunks on the guide/reference pages load these .rds files
# instead of refitting. Rebake whenever the bgms version changes, then
# re-render the site so summaries, figures, and prose numbers stay in sync
# with the package.
#
# Usage (from the repo root), pointing R at the bgms build to bake with:
#   R_LIBS=dev/lib-bgms-develop Rscript fixtures/bake.R
#
# Each fit mirrors the `eval: false` chunk shown to readers on the page
# that uses the fixture.
#
# Two configurations, on purpose:
#
#   * The Wenchuan fit and its prior sensitivity check use the
#     manuscript-grade configuration of the tutorial paper: iter = 1e4,
#     warmup = 5e3, seed = 123, everything else at package defaults
#     (four chains, ordinal, edge selection on, Bernoulli(0.5) edge prior,
#     Normal(scale = 1) slab). The paper's scripts pre-filter the data with
#     complete.cases(); bgm()'s default na_action = "listwise" drops the
#     same 18 rows, so passing Wenchuan directly gives bit-identical draws.
#     Because the seed, settings, and data all match, the numbers on this
#     site and the numbers in the paper are the same numbers, not merely
#     compatible ones. The current bake is on the CRAN release, bgms main
#     6126312a, whose draws are bit-identical to the 0e116079 and c1e52c8e
#     runs before it, and to the run the tutorial used: nothing in the
#     2026-08 pre-CRAN cycle touches the ordinal samplers.
#
#   * The SBM fit and the ADHD group comparison are not manuscript analyses,
#     so they run at package defaults with the same seed. What the site shows
#     for them is what the defaults give you. Because they track the defaults,
#     a release that changes one moves their numbers: the 0.2.0.0 compare
#     slabs went Cauchy -> Normal, so the ADHD numbers moved on the 2026-08-04
#     rebake. That is the fixture doing its job, not a regression.
#
# Bake cost, measured on a 15-core M-series laptop: fit_wenchuan 4.5 min,
# ps_wenchuan 2.8 min (warm-started NUTS refits, so the check costs less than
# the fit), fit_wenchuan_sbm and fit_compare_adhd about a minute each. Roughly
# ten minutes end to end, against about two before the manuscript-grade switch.
# This is a per-release cost, not a per-render one: the site renders from the
# .rds files and never refits. fit_wenchuan is about 130 MB at this length
# (fixtures/*.rds is gitignored, so nothing large enters the repo).

library(bgms)
cat("Baking with bgms", as.character(utils::packageVersion("bgms")),
    "from", dirname(system.file(package = "bgms")), "\n")

out = file.path("fixtures")
stopifnot(dir.exists(out))

timed = function(label, expr) {
  cat(label, "...\n")
  t0 = Sys.time()
  value = force(expr)
  cat(label, "done in", round(as.numeric(Sys.time() - t0, units = "mins"), 1),
      "min\n")
  value
}

# guide/mcmc-diagnostics.qmd, guide/mcmc-output.qmd, guide/edge-selection.qmd,
# reference/bgm.qmd, reference/methods.qmd, reference/extractors.qmd,
# reference/checks.qmd
# Manuscript-grade: matches R/01-worked-example.R in the tutorial repo.
fit = timed("fit_wenchuan", bgm(Wenchuan, iter = 1e4, warmup = 5e3, seed = 123))
saveRDS(fit, file.path(out, "fit_wenchuan.rds"))

# reference/prior-sensitivity.qmd
# Manuscript-grade: matches R/16-run-sensitivity-check.R in the tutorial repo.
ps = timed("ps_wenchuan", prior_sensitivity_check(fit, seed = 123))
saveRDS(ps, file.path(out, "ps_wenchuan.rds"))

# examples/edge-clustering.qmd
# Not a manuscript analysis. The data are the Martarelli et al. (2023)
# French SBPS validation sample (18 ordinal items: 8 boredom, 10
# curiosity/exploration), shipped in this repo at data/martarelli.rds and
# published with the site so the companion script can download it. Source:
# the lab's BGM_Workshops repo (PsyNets_Summer_2026, Morning Session /
# Group Assignment / data.rds). Columns 1:2 are Age and Gender; the
# network runs on the 18 items.
#
# Run length is deliberate, not the default. At the defaults (2e3/2e3)
# this fit prints a warmup warning and the checks confirm it (largest
# split-Rhat 1.35, smallest ESS 44), and the clustering answer is not yet
# stable (clustering BF about 6 at iter = 1e4 vs about 200 here). At
# 2e4/1e4 the worst split-Rhat is 1.013 (six parameters, all on edges
# straddling the two blocks) with smallest ESS about 350. The page walks
# this escalation. Bake cost: about 11 minutes uncontended.
martarelli = readRDS("data/martarelli.rds")
fit_sbm = timed("fit_martarelli_sbm",
                bgm(as.data.frame(martarelli[, 3:20]),
                    edge_prior = sbm_prior(),
                    iter = 2e4, warmup = 1e4, seed = 123))
saveRDS(fit_sbm, file.path(out, "fit_martarelli_sbm.rds"))

# guide/mcmc-output.qmd, guide/group-comparison.qmd, reference/methods.qmd
# Package defaults plus the seed; not a manuscript analysis.
fit_compare = timed("fit_compare_adhd", bgmCompare(
  x = ADHD[, -1],
  group_indicator = ADHD$group,
  variable_type = "ordinal",
  seed = 123
))
saveRDS(fit_compare, file.path(out, "fit_compare_adhd.rds"))

cat("done\n")
