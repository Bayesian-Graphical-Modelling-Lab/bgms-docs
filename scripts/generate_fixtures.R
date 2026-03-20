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

cat("Done.\n")
