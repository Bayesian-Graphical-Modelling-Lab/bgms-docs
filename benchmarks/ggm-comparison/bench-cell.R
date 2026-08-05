# ==============================================================================
# One cell of the three-package sparse-GGM benchmark.
#
#   Rscript bench-cell.R <cell> <p>
#
# One fit per R session, so no fit's timing is contaminated by another fit's
# allocator state, and so a cell can be re-run on its own. The result lands in
# out/cells/<cell>-p<p>.rds.
#
# Environment: BENCH_DIR points at the scratch root, which holds lib/ (the CRAN
# builds of modelSelection and ssgraph) and out/ (the data and the results).
# ==============================================================================

args = commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
cell = args[[1]]
p = as.integer(args[[2]])

BENCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(BENCH))
.libPaths(c(file.path(BENCH, "lib"), .libPaths()))

# Threading is not pinned here, because there is nothing on this machine to pin:
# R links the serial reference BLAS, modelSelection has no thread argument, and
# the CRAN source build of ssgraph carries no OpenMP runtime (verified with
# `nm -u ssgraph.so | grep omp`, which is empty), so its `cores` argument has no
# effect. bgms is the only cell that uses more than one thread, and it does so
# through its own `cores` argument. Every row records CPU time alongside wall
# clock so the claim can be checked from the results.

SEED = 2026L
case = readRDS(file.path(BENCH, "out", sprintf("data-p%03d.rds", p)))
y = case$y
present = case$present

# ------------------------------------------------------------------------------
# The cells.
#
# Each entry states the package, whether it is the package's default call or the
# call its own documentation points at for sparse structure learning, the number
# of threads the fit actually uses on this machine, the package's own decision
# rule, and a fit() that returns the p x p matrix of posterior edge inclusion
# probabilities.
# ------------------------------------------------------------------------------

upper_of = function(M) M[upper.tri(M)]

# modelSelection returns inclusion probabilities as a flat vector over the
# upper-diagonal AND diagonal entries of Omega, indexed by fit$indexes. Lift the
# off-diagonal ones back into a p x p matrix so every cell reports the same shape.
ms_to_matrix = function(fit, values) {
  idx = fit$indexes
  keep = idx["row", ] != idx["column", ]
  M = matrix(0, fit$p, fit$p)
  M[cbind(idx["row", keep], idx["column", keep])] = values[keep]
  M[cbind(idx["column", keep], idx["row", keep])] = values[keep]
  M
}

CELLS = list(

  # --- bgms -------------------------------------------------------------------
  # The vignette's fast route, argument for argument as vignettes/fast-ggm.Rmd
  # displays it: joint precision-graph prior, Gibbs updates, 4 chains on 4
  # threads, and everything else at the bgm() default (edge_prior =
  # bernoulli_prior(0.5), warmup = 2000, iter = 2000).
  "bgms-vignette" = list(
    package = "bgms", kind = "vignette settings (joint + gibbs)",
    threads = 4L, own_rule = 0.5,
    call = 'bgm(y, variable_type = "continuous", precision_graph_prior = "joint",
    update_method = "gibbs", chains = 4, cores = 4, seed = 2026)',
    fit = function(y) {
      library(bgms)
      f = bgm(y,
        variable_type = "continuous",
        precision_graph_prior = "joint", update_method = "gibbs",
        chains = 4, cores = 4, seed = SEED,
        display_progress = "none", verbose = FALSE
      )
      list(pip = extract_posterior_inclusion_probabilities(f),
           max_rhat = max(summary(f)$indicator[, "Rhat"], na.rm = TRUE))
    }
  ),

  # Supplementary, not part of the defaults-vs-documented pair: the same fast
  # route under an edge prior matched to the sparsity the competitors' defaults
  # assume, so the false-positive columns can be read as an algorithm difference
  # rather than a prior difference.
  "bgms-sparse-prior" = list(
    package = "bgms", kind = "supplementary: vignette settings, sparse edge prior",
    threads = 4L, own_rule = 0.5,
    call = 'bgm(y, variable_type = "continuous", precision_graph_prior = "joint",
    update_method = "gibbs", edge_prior = bernoulli_prior(2 / (p - 1)),
    chains = 4, cores = 4, seed = 2026)',
    fit = function(y) {
      library(bgms)
      f = bgm(y,
        variable_type = "continuous",
        precision_graph_prior = "joint", update_method = "gibbs",
        edge_prior = bernoulli_prior(2 / (ncol(y) - 1)),
        chains = 4, cores = 4, seed = SEED,
        display_progress = "none", verbose = FALSE
      )
      list(pip = extract_posterior_inclusion_probabilities(f),
           max_rhat = max(summary(f)$indicator[, "Rhat"], na.rm = TRUE))
    }
  ),

  # Supplementary: the same fit with the chains run one after another, so the
  # 4-thread rows can be read against a single-threaded number.
  "bgms-serial" = list(
    package = "bgms", kind = "supplementary: vignette settings, 1 thread",
    threads = 1L, own_rule = 0.5,
    call = 'bgm(y, variable_type = "continuous", precision_graph_prior = "joint",
    update_method = "gibbs", chains = 4, cores = 1, seed = 2026)',
    fit = function(y) {
      library(bgms)
      f = bgm(y,
        variable_type = "continuous",
        precision_graph_prior = "joint", update_method = "gibbs",
        chains = 4, cores = 1, seed = SEED,
        display_progress = "none", verbose = FALSE
      )
      list(pip = extract_posterior_inclusion_probabilities(f),
           max_rhat = max(summary(f)$indicator[, "Rhat"], na.rm = TRUE))
    }
  ),

  # --- modelSelection ---------------------------------------------------------
  # Untouched defaults: niter = 1000, burnin = 100, Gibbs, local proposals,
  # normalidprior(tau = 1) slab, modelbinomprior(1/p) model prior,
  # exponentialprior(1) on the diagonal, columns centred and scaled,
  # Omegaini = "glasso-ebic".
  "modelSelection-default" = list(
    package = "modelSelection", kind = "package defaults",
    threads = 1L, own_rule = 0.95,
    call = "modelSelectionGGM(y)",
    fit = function(y) {
      library(modelSelection)
      set.seed(SEED)
      f = modelSelectionGGM(y, verbose = FALSE)
      list(pip = ms_to_matrix(f, f$margpp),
           pip_alt = ms_to_matrix(f, Matrix::colMeans(f$postSample != 0)),
           max_rhat = NA_real_)
    }
  ),

  # Documentation-directed: the global regression proposal that ?modelSelectionGGM
  # describes for mixing, run for the 5000 posterior draws that the package's own
  # empirical-Bayes wrapper uses as its final-MCMC length (niter.mcmc = 5000).
  "modelSelection-doc" = list(
    package = "modelSelection", kind = "documentation-directed",
    threads = 1L, own_rule = 0.95,
    call = 'modelSelectionGGM(y, niter = 5000, global_proposal = "regression")',
    fit = function(y) {
      library(modelSelection)
      set.seed(SEED)
      f = modelSelectionGGM(y, niter = 5000, global_proposal = "regression",
                            verbose = FALSE)
      list(pip = ms_to_matrix(f, Matrix::colMeans(f$postSample != 0)),
           pip_alt = ms_to_matrix(f, f$margpp),
           max_rhat = NA_real_)
    }
  ),

  # Documentation-directed, second route: the package's own empirical-Bayes
  # wrapper, which estimates the common edge inclusion probability from the data
  # instead of leaving it at the 1/p default. ?modelSelectionGGM points at it
  # under priorModel ("See also modelSelectionGGM_eBayes for an empirical Bayes
  # model prior"). All its lengths are at their defaults: 20 EB iterations of
  # 1000 draws each, then a final 5000-draw MCMC.
  "modelSelection-ebayes" = list(
    package = "modelSelection", kind = "documentation-directed: empirical-Bayes edge prior",
    threads = 1L, own_rule = 0.95,
    call = "modelSelectionGGM_eBayes(y = y)",
    fit = function(y) {
      library(modelSelection)
      set.seed(SEED)
      f = modelSelectionGGM_eBayes(y = y, verbose = FALSE)
      list(pip = ms_to_matrix(f, f$margpp),
           pip_alt = ms_to_matrix(f, Matrix::colMeans(f$postSample != 0)),
           max_rhat = NA_real_)
    }
  ),

  # --- ssgraph ----------------------------------------------------------------
  # Untouched defaults: iter = 5000, burnin = 2500, var1 = 4e-4, var2 = 1,
  # lambda = 1, g.prior = 0.2, g.start = "full".
  "ssgraph-default" = list(
    package = "ssgraph", kind = "package defaults",
    threads = 1L, own_rule = 0.5,
    call = 'ssgraph(y, method = "ggm")',
    fit = function(y) {
      library(ssgraph)
      set.seed(SEED)
      f = ssgraph(y, method = "ggm", verbose = FALSE)
      pl = f$p_links
      list(pip = pl + t(pl), max_rhat = NA_real_)
    }
  ),

  # Documentation-directed: the one alternative ?ssgraph names for the edge
  # prior, "0.5 as a noninformative prior". It is also the edge prior the bgms
  # rows run under, which makes this the prior-matched pair.
  "ssgraph-doc" = list(
    package = "ssgraph", kind = "documentation-directed",
    threads = 1L, own_rule = 0.5,
    call = 'ssgraph(y, method = "ggm", g.prior = 0.5)',
    fit = function(y) {
      library(ssgraph)
      set.seed(SEED)
      f = ssgraph(y, method = "ggm", g.prior = 0.5, verbose = FALSE)
      pl = f$p_links
      list(pip = pl + t(pl), max_rhat = NA_real_)
    }
  ),

  # Supplementary: a sparse edge prior of the kind Wang (2015), the method
  # ssgraph implements, uses for structure learning. ?ssgraph does not name it.
  "ssgraph-sparse-prior" = list(
    package = "ssgraph", kind = "supplementary: sparse edge prior",
    threads = 1L, own_rule = 0.5,
    call = 'ssgraph(y, method = "ggm", g.prior = 2 / (p - 1), g.start = "empty")',
    fit = function(y) {
      library(ssgraph)
      set.seed(SEED)
      f = ssgraph(y, method = "ggm", g.prior = 2 / (ncol(y) - 1),
                  g.start = "empty", verbose = FALSE)
      pl = f$p_links
      list(pip = pl + t(pl), max_rhat = NA_real_)
    }
  )
)

stopifnot(cell %in% names(CELLS))
spec = CELLS[[cell]]

# ------------------------------------------------------------------------------
# Run it. Wall clock is the elapsed time of the fit call and nothing else: data
# are already in memory and no accuracy work happens inside the timer.
# ------------------------------------------------------------------------------
message(sprintf("[%s] p = %d  (%s, %s)", cell, p, spec$package, spec$kind))
timing = system.time(res <- spec$fit(y))

score = function(pip_vec, cut) {
  sel = pip_vec > cut
  list(
    cut = cut,
    selected = sum(sel),
    true_positive = sum(sel & present),
    false_positive = sum(sel & !present),
    false_negative = sum(!sel & present),
    precision = if (sum(sel) > 0) sum(sel & present) / sum(sel) else NA_real_,
    recall = sum(sel & present) / sum(present)
  )
}

pip = upper_of(res$pip)
out = list(
  cell = cell, package = spec$package, kind = spec$kind,
  version = as.character(utils::packageVersion(spec$package)),
  p = p, n = nrow(y), pairs = length(present), edges = sum(present),
  call = spec$call, threads = spec$threads,
  elapsed = unname(timing[["elapsed"]]),
  cpu = unname(timing[["user.self"]] + timing[["sys.self"]] +
                 timing[["user.child"]] + timing[["sys.child"]]),
  own = score(pip, spec$own_rule),
  matched = score(pip, 0.5),
  max_rhat = res$max_rhat,
  pip = pip,
  pip_alt = if (!is.null(res$pip_alt)) upper_of(res$pip_alt) else NULL
)

dir.create(file.path(BENCH, "out", "cells"), showWarnings = FALSE, recursive = TRUE)
saveRDS(out, file.path(BENCH, "out", "cells", sprintf("%s-p%03d.rds", cell, p)),
        version = 2)

cat(sprintf(
  "%-24s p=%3d  %8.2f s wall  %8.2f s cpu  | own(>%.2f): sel %4d tp %3d fp %4d | matched(>0.50): sel %4d tp %3d fp %4d\n",
  cell, p, out$elapsed, out$cpu, spec$own_rule,
  out$own$selected, out$own$true_positive, out$own$false_positive,
  out$matched$selected, out$matched$true_positive, out$matched$false_positive
))
