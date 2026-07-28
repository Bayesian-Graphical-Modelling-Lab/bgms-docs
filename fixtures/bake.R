# Bake the website fixtures.
#
# The executed chunks on the guide/reference pages load these .rds files
# instead of refitting (the fits take minutes). Rebake whenever the bgms
# version changes, then re-render the site so summaries, figures, and
# prose numbers stay in sync with the package.
#
# Usage (from the repo root), pointing R at the bgms build to bake with:
#   R_LIBS=dev/lib-bgms-develop Rscript fixtures/bake.R
#
# Each fit mirrors the `eval: false` chunk shown to readers on the page
# that uses the fixture.

library(bgms)
cat("Baking with bgms", as.character(utils::packageVersion("bgms")),
    "from", dirname(system.file(package = "bgms")), "\n")

out = file.path("fixtures")
stopifnot(dir.exists(out))

# guide/mcmc-diagnostics.qmd, guide/mcmc-output.qmd, guide/edge-selection.qmd
cat("fit_wenchuan ...\n")
fit = bgm(Wenchuan, chains = 2, seed = 1234)
saveRDS(fit, file.path(out, "fit_wenchuan.rds"))

# guide/clustering.qmd
cat("fit_wenchuan_sbm ...\n")
fit_sbm = bgm(Wenchuan, edge_prior = sbm_prior(), chains = 2, seed = 1234)
saveRDS(fit_sbm, file.path(out, "fit_wenchuan_sbm.rds"))

# guide/mcmc-output.qmd, guide/group-comparison.qmd
cat("fit_compare_adhd ...\n")
fit_compare = bgmCompare(
  x = ADHD[, -1],
  group_indicator = ADHD$group,
  variable_type = "ordinal",
  chains = 2,
  seed = 1234
)
saveRDS(fit_compare, file.path(out, "fit_compare_adhd.rds"))

cat("done\n")
