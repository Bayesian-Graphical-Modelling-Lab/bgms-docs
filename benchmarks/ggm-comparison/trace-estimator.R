# ==============================================================================
# How much of bgms's convergence speed is the sampler and how much is the
# estimator?
#
#   BENCH_DIR=<root> Rscript trace-estimator.R <n>
#
# ssgraph reports p_links = (count of retained draws with the edge present)/nmc,
# a raw indicator average. bgms's extract_posterior_inclusion_probabilities()
# defaults to estimator = "rb", the Rao-Blackwellised average of
# J = gamma + (1 - 2 gamma) alpha. Comparing the two head to head therefore
# compares estimators as well as samplers.
#
# This refits the bgms grid and reads BOTH estimators off the SAME fit, so the
# draws are identical and the only thing that differs is the summary. The raw
# column is the like-for-like comparison against ssgraph; the rb column is what
# a bgms user actually gets.
# ==============================================================================

args = commandArgs(trailingOnly = TRUE)
n = as.integer(args[[1]])
p = 100L

BENCH = Sys.getenv("BENCH_DIR")
.libPaths(c(file.path(BENCH, "lib"), .libPaths()))
library(bgms)

suffix = if (n == 1000L) "" else sprintf("-n%04d", n)
case = readRDS(file.path(BENCH, "out", sprintf("data-p%03d%s.rds", p, suffix)))
y = case$y; present = case$present

auc_of = function(pip) {
  r = rank(pip); n1 = sum(present); n0 = sum(!present)
  (sum(r[present]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
upper = function(M) M[upper.tri(M)]

VALUES = c(8, 16, 32, 64, 125, 250, 500, 1000, 2000, 4000, 8000)
rows = list()
for (v in VALUES) {
  tt = system.time(f <- bgm(y, variable_type = "continuous",
    precision_graph_prior = "joint", update_method = "gibbs",
    chains = 1, cores = 1, warmup = v, iter = v, seed = 2026L,
    display_progress = "none", verbose = FALSE))
  rb  = upper(extract_posterior_inclusion_probabilities(f, estimator = "rb"))
  raw = upper(extract_posterior_inclusion_probabilities(f, estimator = "raw"))
  rows[[length(rows) + 1L]] = data.frame(
    n = n, value = v, elapsed = unname(tt[["elapsed"]]),
    auc_rb = auc_of(rb), auc_raw = auc_of(raw),
    sel_rb = sum(rb > 0.5), sel_raw = sum(raw > 0.5),
    distinct_raw = length(unique(raw)))
  cat(sprintf("n=%4d iter=%5d %7.2fs  AUC rb %.5f  raw %.5f  (diff %+.5f)  sel %d/%d  distinct raw values %d\n",
              n, v, tt[["elapsed"]], auc_of(rb), auc_of(raw), auc_of(raw) - auc_of(rb),
              sum(rb > 0.5), sum(raw > 0.5), length(unique(raw))))
  saveRDS(do.call(rbind, rows),
          file.path(BENCH, "out", "trace", sprintf("bgms-estimator-p100%s.rds", suffix)),
          version = 2)
}
