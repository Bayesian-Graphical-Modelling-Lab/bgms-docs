# ==============================================================================
# One replicate of the time-to-AUC-convergence comparison.
#
#   BENCH_DIR=<root> Rscript rep-cell.R <seed> <n>
#
# Ten replicates make the T numbers robust. Each replicate is a fresh dataset
# from the same generator with a new seed, so the spread reported covers both
# Monte Carlo noise and the graph-to-graph variation that a single dataset
# hides. T is always measured within a replicate, against that replicate's own
# longest run, so a varying true graph does not contaminate it.
#
# Grids are truncated where the reference AUC is already within 0.0015 of the
# full-grid answer, measured on the seed-2026 traces. T is read at tolerance
# 0.01, so a 0.0015 shift in the reference cannot move which point is selected.
#
# Every arm runs one chain on one thread. bgms records both estimators off the
# same fit: raw is the like-for-like comparison against ssgraph's p_links,
# rb is what a bgms user actually receives.
# ==============================================================================

args = commandArgs(trailingOnly = TRUE)
seed = as.integer(args[[1]]); n = as.integer(args[[2]]); p = 100L
BENCH = Sys.getenv("BENCH_DIR")
.libPaths(c(file.path(BENCH, "lib"), .libPaths()))

simulate_sparse_ggm = function(p, avg_degree = 3, weight = 0.25, seed) {
  set.seed(seed)
  K = matrix(0, p, p)
  pairs = which(upper.tri(K), arr.ind = TRUE)
  present = stats::runif(nrow(pairs)) < avg_degree / (p - 1)
  K[pairs[present, , drop = FALSE]] =
    sample(c(-1, 1), sum(present), replace = TRUE) * weight
  K = K + t(K); diag(K) = rowSums(abs(K)) + 1; K
}
library(bgms)
K = simulate_sparse_ggm(p, seed = seed)
y = simulate_mrf(num_states = n, num_variables = p, pairwise = K,
                 variable_type = "continuous", seed = seed)
present = K[upper.tri(K)] != 0

auc_of = function(pip) {
  r = rank(pip); n1 = sum(present); n0 = sum(!present)
  (sum(r[present]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
up = function(M) M[upper.tri(M)]

rows = list()
add = function(arm, v, el, auc, extra = NA_real_) {
  rows[[length(rows) + 1L]] <<- data.frame(
    seed = seed, n = n, arm = arm, value = v, elapsed = el,
    auc = auc, auc_alt = extra, stringsAsFactors = FALSE)
}

for (v in c(8, 16, 32, 64, 125, 250, 500, 1000, 2000)) {
  tt = system.time(f <- bgm(y, variable_type = "continuous",
    precision_graph_prior = "joint", update_method = "gibbs",
    chains = 1, cores = 1, warmup = v, iter = v, seed = 2026L,
    display_progress = "none", verbose = FALSE))
  add("bgms-raw", v, unname(tt[["elapsed"]]),
      auc_of(up(extract_posterior_inclusion_probabilities(f, estimator = "raw"))),
      auc_of(up(extract_posterior_inclusion_probabilities(f, estimator = "rb"))))
}
detach("package:bgms", unload = TRUE)

suppressMessages(library(ssgraph))
for (v in c(25, 50, 100, 250, 500, 1000, 2000, 5000)) {
  set.seed(2026L)
  tt = system.time(f <- ssgraph(y, method = "ggm", iter = v, g.prior = 0.5,
                                verbose = FALSE))
  pl = f$p_links
  add("ssgraph", v, unname(tt[["elapsed"]]), auc_of(up(pl + t(pl))))
}
detach("package:ssgraph", unload = TRUE)

suppressMessages(library(modelSelection))
for (v in c(50, 100, 250, 500, 1000, 4000, 16000)) {
  set.seed(2026L)
  tt = system.time(f <- modelSelectionGGM(y, niter = v, verbose = FALSE))
  idx = f$indexes; keep = idx["row", ] != idx["column", ]
  M = matrix(0, f$p, f$p)
  M[cbind(idx["row", keep], idx["column", keep])] = f$margpp[keep]
  M[cbind(idx["column", keep], idx["row", keep])] = f$margpp[keep]
  add("modelSelection", v, unname(tt[["elapsed"]]), auc_of(up(M)))
}

dir.create(file.path(BENCH, "out", "rep"), showWarnings = FALSE, recursive = TRUE)
saveRDS(do.call(rbind, rows),
        file.path(BENCH, "out", "rep", sprintf("rep-s%04d-n%04d.rds", seed, n)),
        version = 2)
cat(sprintf("done seed=%d n=%d  edges=%d\n", seed, n, sum(present)))
