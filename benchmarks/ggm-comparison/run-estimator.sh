#!/bin/zsh
set -e
: ${BENCH_DIR:?}
cd "$BENCH_DIR"
for n in 200 500 1000; do
  echo "=== estimator decomposition n=$n $(date +%H:%M:%S) ==="
  Rscript trace-estimator.R $n 2>&1 | tee -a logs/estimator-n${n}.log
done
echo "ESTIMATOR DONE $(date +%H:%M:%S)"
