# ==============================================================================
# Extra sample sizes for the convergence study.
#
#   BENCH_DIR=<scratch root> Rscript gen-data-n.R
#
# Same generator and same seed as data-raw/make-fast-ggm.R, so the only thing
# that changes between these datasets and the benchmark's is n. The graph is a
# function of the seed alone, so all three sample sizes share one true graph and
# the recovery numbers are directly comparable across them.
#
# Why these sizes. For an edge given the other p - 2 variables the partial
# correlation is 0.25/1.75 = 0.143 by construction, and its standard error goes
# as 1/sqrt(n - p - 1). At p = 100 that gives a per-edge z of 4.28 at n = 1000,
# 2.86 at n = 500 and 1.42 at n = 200, so an AUC of roughly Phi(z/sqrt(2)):
# 0.998, 0.978 and 0.842. n = 1000 is the ceiling that made T tie; the other two
# bracket the region where AUC has left the ceiling but signal remains.
#
# p stays at 100. At p = 200 with n = 200 the scatter matrix is singular and
# ssgraph initialises with solve(S), so that arm would fail rather than run.
# ==============================================================================

library(bgms)

BENCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(BENCH))

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

P = 100L
for (n in c(200L, 500L)) {
  case = simulate_case(p = P, n = n, seed = 2026)
  out = file.path(BENCH, "out", sprintf("data-p%03d-n%04d.rds", P, n))
  saveRDS(case, out, version = 2)
  pc = 0.25 / 1.75
  z = pc * sqrt(n - P - 1)
  cat(sprintf(
    "p = %3d  n = %4d  edges = %3d  partial r = %.3f  z = %.2f  predicted AUC = %.3f\n",
    P, n, sum(case$present), pc, z, stats::pnorm(z / sqrt(2))
  ))
}

# The graph must be identical across sample sizes; this is the check.
g = lapply(c(200L, 500L), function(n)
  readRDS(file.path(BENCH, "out", sprintf("data-p%03d-n%04d.rds", P, n)))$present)
g1000 = readRDS(file.path(BENCH, "out", sprintf("data-p%03d.rds", P)))$present
stopifnot(identical(g[[1]], g1000), identical(g[[2]], g1000))
cat("true graph identical across n = 200, 500, 1000\n")
