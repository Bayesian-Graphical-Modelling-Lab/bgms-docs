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
# Name one or more steps to bake only those and leave the other fixtures
# untouched, e.g.
#   R_LIBS=dev/lib-bgms-develop Rscript fixtures/bake.R fit_marks
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
# the fit), fit_wenchuan_sbm and fit_compare_adhd about a minute each, fit_marks
# well under a minute. Roughly ten minutes end to end, against about two before the manuscript-grade switch.
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

# Steps to bake: all of them when no step is named on the command line.
only = commandArgs(trailingOnly = TRUE)
bake = function(step) length(only) == 0L || step %in% only

# guide/mcmc-diagnostics.qmd, guide/mcmc-output.qmd, guide/edge-selection.qmd,
# reference/bgm.qmd, reference/methods.qmd, reference/extractors.qmd,
# reference/checks.qmd
# Manuscript-grade: matches R/01-worked-example.R in the tutorial repo.
if(bake("fit_wenchuan")) {
  fit = timed("fit_wenchuan",
              bgm(Wenchuan, iter = 1e4, warmup = 5e3, seed = 123))
  saveRDS(fit, file.path(out, "fit_wenchuan.rds"))
}

# reference/prior-sensitivity.qmd
# Manuscript-grade: matches R/16-run-sensitivity-check.R in the tutorial repo.
if(bake("ps_wenchuan")) {
  if(!exists("fit")) fit = readRDS(file.path(out, "fit_wenchuan.rds"))
  ps = timed("ps_wenchuan", prior_sensitivity_check(fit, seed = 123))
  saveRDS(ps, file.path(out, "ps_wenchuan.rds"))
}

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
if(bake("fit_martarelli_sbm")) {
  martarelli = readRDS("data/martarelli.rds")
  fit_sbm = timed("fit_martarelli_sbm",
                  bgm(as.data.frame(martarelli[, 3:20]),
                      edge_prior = sbm_prior(),
                      iter = 2e4, warmup = 1e4, seed = 123))
  saveRDS(fit_sbm, file.path(out, "fit_martarelli_sbm.rds"))
}

# guide/mcmc-output.qmd, examples/comparing-groups.qmd, reference/methods.qmd
# Package defaults plus the seed; not a manuscript analysis.
if(bake("fit_compare_adhd")) {
  fit_compare = timed("fit_compare_adhd", bgmCompare(
    x = ADHD[, -1],
    group_indicator = ADHD$group,
    variable_type = "ordinal",
    seed = 123
  ))
  saveRDS(fit_compare, file.path(out, "fit_compare_adhd.rds"))
}

# guide/ggm.qmd (Example: five examination marks)
# Not a manuscript analysis. The examination marks of 88 students on five
# subjects (Mardia, Kent and Bibby, 1979), moved off the Getting started page
# in the R1 restructure. The data are built from the literal that page used,
# saved to data/marks.rds and published with the site so the page's mirror
# chunk can download them; then a default continuous fit plus the seed. The
# z-ratio surface build is capped at four cores through its option, so the
# call stays the one the page shows.
if(bake("fit_marks")) {
  marks = data.frame(
    mechanics  = c(77,63,75,55,63,53,51,59,62,64,52,55,50,65,31,60,44,42,62,31,
                   44,49,12,49,54,54,44,18,46,32,30,46,40,31,36,56,46,45,42,40,
                   23,48,41,46,46,40,49,22,35,48,31,17,49,59,37,40,35,38,43,39,
                   62,48,34,18,35,59,41,31,17,34,46,10,46,30,13,49,18,8,23,30,
                   3,7,15,15,5,12,5,0),
    vectors    = c(82,78,73,72,63,61,67,70,60,72,64,67,50,63,55,64,69,69,46,49,
                   61,41,58,53,49,53,56,44,52,45,69,49,27,42,59,40,56,42,60,63,
                   55,48,63,52,61,57,49,58,60,56,57,53,57,50,56,43,35,44,43,46,
                   44,38,42,51,36,53,41,52,51,30,40,46,37,34,51,50,32,42,38,24,
                   9,51,40,38,30,30,26,40),
    algebra    = c(67,80,71,63,65,72,65,68,58,60,60,59,64,58,60,56,53,61,61,62,
                   52,61,61,49,56,46,55,50,65,49,50,53,54,48,51,56,57,55,54,53,
                   59,49,49,53,46,51,45,53,47,49,50,57,47,47,49,48,41,54,38,46,
                   36,41,50,40,46,37,43,37,52,50,47,36,45,43,50,38,31,48,36,43,
                   51,43,43,39,44,32,15,21),
    analysis   = c(67,70,66,70,70,64,65,62,62,62,63,62,55,56,57,54,53,55,57,63,
                   62,49,63,62,47,59,61,57,50,57,52,59,61,54,45,54,49,56,49,54,
                   53,51,46,41,38,52,48,56,54,42,54,43,39,15,28,21,51,47,34,32,
                   22,44,47,56,48,22,30,27,35,47,29,47,15,46,25,23,45,26,48,33,
                   47,17,23,28,36,35,20,9),
    statistics = c(81,81,81,68,63,73,68,56,70,45,54,44,63,37,73,40,53,45,45,62,
                   46,64,67,47,53,44,36,81,35,64,45,37,61,68,51,35,32,40,33,25,
                   44,37,34,40,41,31,39,41,33,32,34,51,26,46,45,61,50,24,49,43,
                   42,33,29,30,29,19,33,40,31,36,17,39,30,18,31,9,40,40,15,25,
                   40,22,18,17,18,21,20,14)
  )
  saveRDS(marks, file.path("data", "marks.rds"))
  options(bgms.zratio_surface_cores = 4L)
  fit_marks = timed("fit_marks",
                    bgm(marks, variable_type = "continuous", seed = 1234))
  saveRDS(fit_marks, file.path(out, "fit_marks.rds"))
}

cat("done\n")
