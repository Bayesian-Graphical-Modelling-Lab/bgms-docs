# generate_fixtures.R
# Run this script to (re)generate the analysis fixtures used across the
# documentation site. Fits are stored in fixtures/ as .rds files and
# loaded by individual .qmd pages via readRDS().
#
# Usage:
#   Rscript scripts/generate_fixtures.R
#
# Regenerate when:
#   - bgms changes in a way that alters the fit object structure
#   - A new fixture is needed for a new page

library(bgms)

fixtures_dir = "fixtures"
if(!dir.exists(fixtures_dir)) dir.create(fixtures_dir)

# --- Wenchuan (ordinal, 17 items, 2 chains) --------------------------------

cat("Fitting Wenchuan (17 items, 2 chains)...\n")
fit_wenchuan = bgm(Wenchuan, chains = 2, seed = 1234)
saveRDS(fit_wenchuan, file.path(fixtures_dir, "fit_wenchuan.rds"))
cat("  Saved fixtures/fit_wenchuan.rds\n")

# --- ADHD bgmCompare (binary, 18 items, 2 groups, 2 chains) ----------------

cat("Fitting ADHD bgmCompare (18 items, 2 groups, 2 chains)...\n")
fit_compare_adhd = bgmCompare(
  x = ADHD[, -1],
  group_indicator = ADHD$group,
  variable_type = "ordinal",
  chains = 2,
  seed = 1234
)
saveRDS(fit_compare_adhd, file.path(fixtures_dir, "fit_compare_adhd.rds"))
cat("  Saved fixtures/fit_compare_adhd.rds\n")

cat("Done.\n")

# --- Wenchuan SBM (edge clustering, 17 items, 2 chains) --------------------

cat("Fitting Wenchuan with SBM edge prior (2 chains)...\n")
fit_wenchuan_sbm = bgm(Wenchuan, edge_prior = sbm_prior(), chains = 2, seed = 1234)
saveRDS(fit_wenchuan_sbm, file.path(fixtures_dir, "fit_wenchuan_sbm.rds"))
cat("  Saved fixtures/fit_wenchuan_sbm.rds\n")
