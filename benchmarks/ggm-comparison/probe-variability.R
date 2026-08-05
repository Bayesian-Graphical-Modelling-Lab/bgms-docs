# ==============================================================================
# Two things the main table cannot show, measured after the sweep.
#
#   BENCH_DIR=<scratch root> Rscript probe-variability.R
#
# 1. modelSelection 1.0.7 exposes no way to seed its sampler. Its C++ layer
#    carries its own generator (`setseed` in the compiled library, with no R
#    binding and no `seed` argument on modelSelectionGGM), so set.seed() does not
#    make a run reproducible: two calls under the same set.seed() return
#    different margpp. The main table reports one run per cell; this probe
#    repeats the cheapest cell so the report can state how much the recovery
#    counts move between runs.
#
# 2. Wall clock on a shared laptop. The same fit is repeated so the report can
#    state the spread rather than implying the single timing is exact.
# ==============================================================================

BENCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(BENCH))
.libPaths(c(file.path(BENCH, "lib"), .libPaths()))

REPEATS = 5L

ms_pip = function(fit, values) {
  idx = fit$indexes
  keep = idx["row", ] != idx["column", ]
  M = matrix(0, fit$p, fit$p)
  M[cbind(idx["row", keep], idx["column", keep])] = values[keep]
  M[cbind(idx["column", keep], idx["row", keep])] = values[keep]
  M[upper.tri(M)]
}

out = list()

# --- modelSelection, defaults, repeated -------------------------------------
suppressMessages(library(modelSelection))
for (p in c(50, 200)) {
  case = readRDS(file.path(BENCH, "out", sprintf("data-p%03d.rds", p)))
  present = case$present
  rows = do.call(rbind, lapply(seq_len(REPEATS), function(i) {
    set.seed(2026)
    tt = system.time(f <- modelSelectionGGM(case$y, verbose = FALSE))
    pip = ms_pip(f, f$margpp)
    data.frame(rep = i, elapsed = unname(tt[["elapsed"]]),
               sel95 = sum(pip > 0.95), tp95 = sum(pip[present] > 0.95),
               fp95 = sum(pip[!present] > 0.95),
               sel50 = sum(pip > 0.5), tp50 = sum(pip[present] > 0.5),
               fp50 = sum(pip[!present] > 0.5))
  }))
  cat(sprintf("\nmodelSelection defaults, p = %d, %d repeats under set.seed(2026)\n",
              p, REPEATS))
  print(rows, row.names = FALSE)
  out[[sprintf("modelSelection-p%d", p)]] = rows
}
detach("package:modelSelection", unload = TRUE)

# --- ssgraph, defaults, repeated (seeded, so this checks the timing only) ----
suppressMessages(library(ssgraph))
case = readRDS(file.path(BENCH, "out", "data-p050.rds"))
present = case$present
rows = do.call(rbind, lapply(seq_len(REPEATS), function(i) {
  set.seed(2026)
  tt = system.time(f <- ssgraph(case$y, method = "ggm", verbose = FALSE))
  pl = f$p_links
  pip = (pl + t(pl))[upper.tri(pl)]
  data.frame(rep = i, elapsed = unname(tt[["elapsed"]]),
             sel50 = sum(pip > 0.5), tp50 = sum(pip[present] > 0.5),
             fp50 = sum(pip[!present] > 0.5))
}))
cat(sprintf("\nssgraph defaults, p = 50, %d repeats under set.seed(2026)\n", REPEATS))
print(rows, row.names = FALSE)
out[["ssgraph-p50"]] = rows
detach("package:ssgraph", unload = TRUE)

# --- bgms, vignette settings, repeated (seeded, so this checks the timing) ---
suppressMessages(library(bgms))
rows = do.call(rbind, lapply(seq_len(REPEATS), function(i) {
  tt = system.time(f <- bgm(case$y, variable_type = "continuous",
    precision_graph_prior = "joint", update_method = "gibbs",
    chains = 4, cores = 4, seed = 2026,
    display_progress = "none", verbose = FALSE))
  pip = extract_posterior_inclusion_probabilities(f)
  pip = pip[upper.tri(pip)]
  data.frame(rep = i, elapsed = unname(tt[["elapsed"]]),
             sel50 = sum(pip > 0.5), tp50 = sum(pip[present] > 0.5),
             fp50 = sum(pip[!present] > 0.5))
}))
cat(sprintf("\nbgms vignette settings, p = 50, %d repeats at seed 2026\n", REPEATS))
print(rows, row.names = FALSE)
out[["bgms-p50"]] = rows

saveRDS(out, file.path(BENCH, "out", "variability.rds"), version = 2)
