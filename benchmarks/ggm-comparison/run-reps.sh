#!/bin/zsh
# 30 jobs (10 seeds x 3 sample sizes), 4 at a time. Every arm is single-threaded,
# and the measured cost of extra single-threaded processes on this 15-core
# machine is a few percent -- which cannot move T, because T is read off a grid
# whose points are 2x apart, and cannot move the ratios either, because the
# slowdown is common to all arms in a job.
set -e
: ${BENCH_DIR:?}
cd "$BENCH_DIR"
mkdir -p out/rep logs/rep
MAX=4
for seed in 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035; do
  for n in 200 500 1000; do
    out="out/rep/rep-s${seed}-n$(printf '%04d' $n).rds"
    [[ -f $out ]] && { echo "skip s=$seed n=$n"; continue; }
    while (( $(jobs -rp | wc -l) >= MAX )); do sleep 5; done
    echo "start s=$seed n=$n $(date +%H:%M:%S)"
    Rscript rep-cell.R $seed $n > "logs/rep/s${seed}-n${n}.log" 2>&1 &
  done
done
wait
echo "REPS DONE $(date +%H:%M:%S)"
