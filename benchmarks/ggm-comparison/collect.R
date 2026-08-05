# ==============================================================================
# Turn the per-cell result files into the results table.
#
#   BENCH_DIR=<scratch root> Rscript collect.R
#
# Writes out/results.csv (one row per cell) and out/results.md (the table as it
# appears in the completion report).
# ==============================================================================

BENCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(BENCH))

files = sort(Sys.glob(file.path(BENCH, "out", "cells", "*.rds")))
stopifnot(length(files) > 0)
cells = lapply(files, readRDS)

ORDER = c("bgms-vignette", "bgms-sparse-prior", "bgms-serial",
          "modelSelection-default", "modelSelection-ebayes", "modelSelection-doc",
          "ssgraph-default", "ssgraph-doc", "ssgraph-sparse-prior")

fmt_time = function(s) {
  ifelse(s < 100, sprintf("%.1f s", s),
         ifelse(s < 6000, sprintf("%.0f s", s), sprintf("%.1f min", s / 60)))
}

# Two decision-rule-free summaries, so the table is not read entirely through
# operating points that the three packages' different edge priors set at
# different places.
#
#   auc  Mann-Whitney statistic of the inclusion probabilities: the probability
#        that a true edge is ranked above an absent one, with ties counted half.
#        Independent of any cut.
#   tp_at_E  true edges among the E highest-ranked pairs, E being the number of
#        edges the graph actually has. Ties at the boundary are broken in the
#        pairs' own index order, which is arbitrary but fixed.
auc_of = function(pip, present) {
  r = rank(pip)
  n1 = sum(present); n0 = sum(!present)
  (sum(r[present]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
tp_at_E = function(pip, present) {
  E = sum(present)
  sum(present[order(pip, decreasing = TRUE)[seq_len(E)]])
}
present_cache = new.env(parent = emptyenv())
present_of = function(p) {
  key = as.character(p)
  if (is.null(present_cache[[key]])) {
    present_cache[[key]] =
      readRDS(file.path(BENCH, "out", sprintf("data-p%03d.rds", p)))$present
  }
  present_cache[[key]]
}

tab = do.call(rbind, lapply(cells, function(z) data.frame(
  cell = z$cell, package = z$package, version = z$version, kind = z$kind,
  p = z$p, n = z$n, pairs = z$pairs, edges = z$edges, threads = z$threads,
  elapsed_s = round(z$elapsed, 2), cpu_s = round(z$cpu, 2),
  own_cut = z$own$cut,
  own_selected = z$own$selected, own_tp = z$own$true_positive,
  own_fp = z$own$false_positive, own_fn = z$own$false_negative,
  own_precision = round(z$own$precision, 3), own_recall = round(z$own$recall, 3),
  m_selected = z$matched$selected, m_tp = z$matched$true_positive,
  m_fp = z$matched$false_positive, m_fn = z$matched$false_negative,
  m_precision = round(z$matched$precision, 3),
  m_recall = round(z$matched$recall, 3),
  auc = round(auc_of(z$pip, present_of(z$p)), 4),
  tp_at_E = tp_at_E(z$pip, present_of(z$p)),
  max_rhat = round(z$max_rhat, 4),
  stringsAsFactors = FALSE
)))

tab = tab[order(match(tab$cell, ORDER), tab$p), ]
write.csv(tab, file.path(BENCH, "out", "results.csv"), row.names = FALSE)

# ------------------------------------------------------------------------------
# The report table: one block per p, one row per cell.
# ------------------------------------------------------------------------------
lines = c()
add = function(...) lines <<- c(lines, sprintf(...))

for (pp in sort(unique(tab$p))) {
  sub = tab[tab$p == pp, ]
  add("### p = %d, n = %d: %d pairs, %d true edges\n", pp, sub$n[1],
      sub$pairs[1], sub$edges[1])

  add("**Wall clock**\n")
  add("| package | settings | threads | wall clock | CPU time | max Rhat |")
  add("|---|---|---:|---:|---:|---:|")
  for (i in seq_len(nrow(sub))) {
    r = sub[i, ]
    add("| %s %s | %s | %d | %s | %s | %s |",
        r$package, r$version, r$kind, r$threads,
        fmt_time(r$elapsed_s), fmt_time(r$cpu_s),
        if (is.na(r$max_rhat)) "n/a" else sprintf("%.3f", r$max_rhat))
  }
  add("")

  add("**Edge recovery**\n")
  add("| package | settings | own rule | sel | TP | FP | FN | prec | rec | matched rule > 0.5 | sel | TP | FP | FN | prec | rec | AUC | TP in top %d |", sub$edges[1])
  add("|---|---|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|")
  for (i in seq_len(nrow(sub))) {
    r = sub[i, ]
    add("| %s | %s | > %.2f | %d | %d | %d | %d | %.3f | %.3f | > 0.50 | %d | %d | %d | %d | %.3f | %.3f | %.4f | %d |",
        r$package, r$kind, r$own_cut,
        r$own_selected, r$own_tp, r$own_fp, r$own_fn, r$own_precision, r$own_recall,
        r$m_selected, r$m_tp, r$m_fp, r$m_fn, r$m_precision, r$m_recall,
        r$auc, r$tp_at_E)
  }
  add("")
}

writeLines(lines, file.path(BENCH, "out", "results.md"))
cat(paste(lines, collapse = "\n"), "\n")

# ------------------------------------------------------------------------------
# Agreement between the two spike-and-slab routes that run under the same edge
# prior, at the matched cut. Reported as a note under the table.
# ------------------------------------------------------------------------------
pip_of = function(cell, pp) {
  f = file.path(BENCH, "out", "cells", sprintf("%s-p%03d.rds", cell, pp))
  if (file.exists(f)) readRDS(f)$pip else NULL
}
cat("\n--- pairwise agreement at the > 0.5 cut ---\n")
for (pp in sort(unique(tab$p))) {
  a = pip_of("bgms-vignette", pp)
  for (other in c("ssgraph-doc", "ssgraph-default", "ssgraph-sparse-prior",
                  "modelSelection-default", "modelSelection-ebayes",
                  "modelSelection-doc", "bgms-sparse-prior")) {
    b = pip_of(other, pp)
    if (is.null(a) || is.null(b)) next
    cat(sprintf("p=%3d  bgms-vignette vs %-22s : %d / %d pairs agree (%.2f%%)\n",
                pp, other, sum((a > 0.5) == (b > 0.5)), length(a),
                100 * mean((a > 0.5) == (b > 0.5))))
  }
}
