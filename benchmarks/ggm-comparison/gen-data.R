# ==============================================================================
# Data for the three-package GGM benchmark.
#
# The generator and the seeds are copied verbatim from the bgms repository's
# data-raw/make-fast-ggm.R, so every package in the benchmark is fitted to the
# same matrices the fast-GGM vignette was timed on.
# ==============================================================================

library(bgms)

SCRATCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(SCRATCH))

# --- verbatim from data-raw/make-fast-ggm.R -----------------------------------
simulate_sparse_ggm = function(p, avg_degree = 3, weight = 0.25, seed) {
  set.seed(seed)
  K = matrix(0, p, p)
  pairs = which(upper.tri(K), arr.ind = TRUE)
  present = stats::runif(nrow(pairs)) < avg_degree / (p - 1)
  K[pairs[present, , drop = FALSE]] =
    sample(c(-1, 1), sum(present), replace = TRUE) * weight
  K = K + t(K)
  diag(K) = rowSums(abs(K)) + 1
  K
}

simulate_case = function(p, n, seed) {
  K = simulate_sparse_ggm(p, seed = seed)
  list(
    K = K,
    y = simulate_mrf(
      num_states = n, num_variables = p, pairwise = K,
      variable_type = "continuous", seed = seed
    ),
    present = K[upper.tri(K)] != 0
  )
}
# --- end verbatim ------------------------------------------------------------

for (p in c(50, 100, 200)) {
  case = simulate_case(p = p, n = 1000, seed = 2026)
  out = file.path(SCRATCH, "out", sprintf("data-p%03d.rds", p))
  saveRDS(case, out, version = 2)
  cat(sprintf(
    "p = %3d  n = %d  pairs = %6d  edges = %4d  mean|y| = %.4f  var(y1) = %.4f\n",
    p, nrow(case$y), length(case$present), sum(case$present),
    mean(abs(case$y)), stats::var(case$y[, 1])
  ))
}

cat("\nbgms version:", as.character(utils::packageVersion("bgms")), "\n")
