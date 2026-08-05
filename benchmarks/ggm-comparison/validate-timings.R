# ==============================================================================
# Flag cells whose wall clock cannot be trusted.
#
#   BENCH_DIR=<scratch root> Rscript validate-timings.R          # report only
#   BENCH_DIR=<scratch root> Rscript validate-timings.R --purge  # delete them
#
# R's elapsed time is real time, so a fit that was in flight while the machine
# slept, or that shared the machine with a burst of foreign load, records a wall
# clock that is longer than the work it did. CPU time is immune to both: it only
# advances while the process runs. So the ratio of CPU time to wall clock is the
# check.
#
# Expected ratios on this machine:
#   single-threaded cells   about 1.0 (every cell except the two bgms 4-thread ones)
#   bgms at cores = 4       about 3.3 to 3.7 (4 chains, some of it serial)
#
# A cell well below its expected ratio did not get the machine to itself for the
# whole fit and has to be re-run. With --purge its result file is deleted, and
# re-running run-bench.sh redoes exactly those cells.
# ==============================================================================

BENCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(BENCH))
purge = "--purge" %in% commandArgs(trailingOnly = TRUE)

files = sort(Sys.glob(file.path(BENCH, "out", "cells", "*.rds")))
if (length(files) == 0) {
  cat("no cells yet\n")
  quit(save = "no")
}

FLOOR = c("1" = 0.90, "4" = 2.50)

bad = character()
for (f in files) {
  z = readRDS(f)
  ratio = z$cpu / z$elapsed
  floor_ = FLOOR[[as.character(z$threads)]]
  ok = ratio >= floor_
  cat(sprintf("%-24s p=%3d  %8.2f s wall  %8.2f s cpu  ratio %.2f (floor %.2f)  %s\n",
              z$cell, z$p, z$elapsed, z$cpu, ratio, floor_,
              if (ok) "ok" else "SUSPECT"))
  if (!ok) bad = c(bad, f)
}

if (length(bad) == 0) {
  cat("\nall timings clean\n")
} else {
  cat(sprintf("\n%d suspect cell(s)\n", length(bad)))
  if (purge) {
    file.remove(bad)
    cat("deleted; re-run run-bench.sh to redo them\n")
  } else {
    cat("re-run with --purge to delete them\n")
  }
}
