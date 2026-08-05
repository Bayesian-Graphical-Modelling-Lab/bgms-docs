# Measured GGM comparison: bgms vs modelSelection vs ssgraph

The benchmark behind the "How the fast route compares" section of
`guide/fast-ggm.qmd`. Run 2026-08-05 on an Apple M5 Pro (15 cores),
macOS 26.4.1, R 4.6.0 with the serial reference BLAS; bgms 0.2.0.0,
modelSelection 1.0.7, ssgraph 1.16, one fit at a time.

## What is here

| file | what it is |
|---|---|
| `results.md`, `results.csv` | the full tables at p = 50, 100, 200: wall clock, CPU, threads, edge recovery at each package's own rule and at matched 0.5, AUC |
| `SETTINGS.md` | per-package settings rationale, every recommendation quoted from the help page it came from |
| `gen-data.R` | regenerates the datasets; generator and seeds verbatim from the bgms repository's `data-raw/make-fast-ggm.R` |
| `bench-cell.R`, `run-bench.sh` | one benchmark cell / the one-fit-at-a-time driver |
| `env.R`, `probe-variability.R` | machine record; seeding and run-to-run variability probes |
| `validate-timings.R` | CPU-to-wall check that flags cells whose clock is untrustworthy |
| `collect.R` | builds `results.md` and `results.csv` from the per-cell outputs |
| `gen-data-n.R`, `rep-cell.R`, `run-reps.sh` | the time-to-converged-ranking study: 10 replicate datasets at n = 1000/500/200, p = 100, one chain on one thread per arm |
| `trace-estimator.R`, `run-estimator.sh` | Rao-Blackwellized vs raw inclusion probabilities read off identical bgms draws |

## Rebuild

The competitors are installed into a scratch library and must never
become bgms dependencies; nothing here is run by the site build.

    export BENCH_DIR=<scratch root>          # gets lib/ and out/
    Rscript -e 'install.packages(c("modelSelection", "ssgraph"),
      lib = file.path(Sys.getenv("BENCH_DIR"), "lib"))'
    Rscript gen-data.R
    ./run-bench.sh
    Rscript env.R && Rscript probe-variability.R
    Rscript validate-timings.R && Rscript collect.R

    # follow-up: time to a converged ranking
    Rscript gen-data-n.R
    ./run-reps.sh
    ./run-estimator.sh

Re-run this when a competitor releases a new version, and update the
page's tables from the fresh `results.md`. Timings are facts about a
machine: state the hardware, the thread counts, and the package
versions with any number quoted from here.
