#!/bin/zsh
# ==============================================================================
# Driver for the three-package sparse-GGM benchmark.
#
#   BENCH_DIR=<scratch root> ./run-bench.sh
#
# One fit at a time, one R session per fit, in a fixed order: the whole point of
# the exercise is wall clock, so nothing else of ours may be running while it
# goes. Cells whose result file already exists are skipped, so an interrupted
# sweep resumes by re-running the same command.
#
# Two passes. The first is the benchmark proper: every package at its defaults
# and at the settings its own documentation points at. The second adds the
# supplementary cells that make the first pass readable, and can be dropped
# without losing the deliverable.
# ==============================================================================

set -e
: ${BENCH_DIR:?set BENCH_DIR to the scratch root}
cd "$BENCH_DIR"
mkdir -p out/cells logs

PRIMARY=(
  bgms-vignette
  modelSelection-default
  modelSelection-ebayes
  modelSelection-doc
  ssgraph-default
  ssgraph-doc
)

SUPPLEMENTARY=(
  bgms-sparse-prior
  ssgraph-sparse-prior
  bgms-serial
)

run_pass () {
  local label=$1; shift
  for p in 50 100 200; do
    for cell in "$@"; do
      out="out/cells/${cell}-p$(printf '%03d' $p).rds"
      if [[ -f $out ]]; then
        echo "skip  $cell p=$p (already done)"
        continue
      fi
      echo "=== [$label] $cell p=$p  $(date +%H:%M:%S) ==="
      Rscript bench-cell.R "$cell" "$p" 2>&1 | tee -a "logs/${cell}-p${p}.log"
    done
  done
}

run_pass primary "${PRIMARY[@]}"
run_pass supplementary "${SUPPLEMENTARY[@]}"

echo "all cells done $(date +%H:%M:%S)"
