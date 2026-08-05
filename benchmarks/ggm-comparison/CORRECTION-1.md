# BGMS-5 CORRECTION 1: modelSelection's work per iteration was undercounted 20x

To: leading agent / Fable pass. From: BGMS-5 measurement run. Date: 2026-08-05.
Trigger: MM supplied the modelSelection source (github.com/davidrusi/modelSelection),
which contradicts the accounting in REPORT.md section 5 and in both drafted texts.

## ACTION REQUIRED

Do not publish the "modelSelection is not a faster kernel" claim, or any
edge-update count for modelSelection, from the previous report or from
BGMS-5-results-drafts.md. Both are wrong. Corrected numbers below.

## What was wrong

I counted modelSelection's work as its PROPOSALS: `updates_per_column = 10` per
visited column, so 1000 iterations x ceiling(sqrt(200)) columns x 10 = 150,000
edge updates at p = 200. That is a 19.9x undercount.

`GGM_Gibbs_singlecol` in src/ggm.cpp evaluates the full conditional for EVERY
off-diagonal entry of a visited column, not only the proposed ones:

    for (j= 0; j < p; j++) {
      if (j == (int) colid) continue;
      ...
      ppnew = 1 / (1 + exp(mcurrent - mnew));
      if (margpp != nullptr) {
        if (model->at(j,0) == 0) margpp->at(j) += ppnew;
        else margpp->at(j) += 1 - ppnew;
      }
    }

So a column visit costs p-1 conditional evaluations, not 10. Verified
independently before the source arrived: with `updates_per_column = 1` all 4950
pairs at p = 100 still receive interior, distinct margpp values, which only one
proposal per visit cannot produce.

## Corrected accounting

modelSelection at its defaults: niter x ceiling(sqrt(p)) columns x (p-1) entries.
bgms at the vignette settings: 4 chains x 4000 sweeps x p(p-1)/2 pairs.

| p | modelSelection evals | per iteration | as % of a full sweep | bgms evals | work ratio bgms/mS |
|---:|---:|---:|---:|---:|---:|
| 50 | 392,000 | 392 | 32% | 19.6 M | 50x |
| 100 | 990,000 | 990 | 20% | 79.2 M | 80x |
| 200 | 2,985,000 | 2,985 | 15% | 318.4 M | 107x |

Throughput, pair-evaluations per CPU second:

| p | modelSelection | bgms | modelSelection advantage |
|---:|---:|---:|---:|
| 50 | 337,931 | 1,382,228 | 0.24x (bgms faster) |
| 100 | 550,000 | 619,815 | 0.89x (about level) |
| 200 | 719,277 | 207,841 | **3.46x (modelSelection faster)** |

## Claims to retract

1. "modelSelection is not a faster kernel; it is 5.5x slower per edge update."
   WRONG. At p = 200 it is 3.46x FASTER per pair-evaluation. The crossover is
   near p = 100; bgms is faster at p = 50.
2. "Its default run attempts 150,000 edge updates against bgms's 318 million,"
   and "about 0.75% of a sweep." WRONG. 2,985,000 evaluations, 15% of a sweep.
3. "~2000x less sampling." WRONG. 107x at p = 200.

Draft 2 (vignette paragraph) contains: "each iteration updates about sqrt(p)
columns rather than all p" -- that part is CORRECT and can stay. What must go is
any implication that the short default is cheap because it skips work within a
column. It does not; it skips columns, not entries.

## Claims that survive unchanged

- modelSelection's ranking is converged at its defaults: 256x more sampling
  moves AUC by 0.00001 and changes no selected edge. Its clock advantage is real.
- Its posterior is far more concentrated (93.2% of pairs below 0.001 at p = 200)
  and that is the 1/p prior, not the sampler: bgms under a matched sparse prior
  gives 138 ambiguous pairs against modelSelection's 134.
- Lower recall at a matched threshold: 152 true edges against bgms's 168 with a
  comparable sparse prior.
- It cannot be seeded; counts vary about 2% across identical calls.
- All wall-clock timings, edge-recovery counts, AUC values and the entire
  time-to-AUC-convergence study are unaffected. Nothing measured changed; only
  the work-accounting that interpreted it.

## Also affected: bgms's estimator is the same device

The same source passage settles a second point. modelSelection's margpp
accumulates the one-step-ahead probability that the edge is present: ppnew when
currently absent, 1 - ppnew when present. That is structurally identical to
bgms's rb estimator, J = gamma + (1 - 2 gamma) alpha. Both Rao-Blackwellise the
same quantity; they differ in how the flip probability is computed, not in the
device. Any text contrasting the two packages' inclusion-probability estimators
as different in kind would be wrong.

Divisor is a per-entry evaluation count, so entries never visited return NA
rather than 0. Confirmed empirically: at niter = 11, p = 100, 10.0% of pairs are
NA; by niter = 30, 0.1%. Under `sampler = "birthdeath"` margpp instead carries
888 exact zeros at p = 100, which is why ?modelSelectionGGM restricts margpp to
the Gibbs algorithm.

## Provenance

Source: github.com/davidrusi/modelSelection, src/ggm.cpp, GGM_Gibbs_singlecol.
Empirical corroboration: `updates_per_column` 1 vs 10 at p = 100 niter = 60, and
the NA-fraction sweep at niter = 11/15/20/30. Both reproducible from the probes
recorded in this correction; neither needed the source to reach the same
conclusion.

## Addendum: WHY modelSelection's kernel is faster, and the limit on that claim

MM asked how a spike-and-slab method can have the faster kernel. The premise
needs inverting first: ssgraph is the continuous spike-and-slab, modelSelection
is a point-mass spike. This is the mechanism behind the corrected throughput
numbers and it bounds how far they generalise.

- `?ssgraph`: `var1` is "the variance of the prior of precision matrix for the
  places that there is no link", `var2` for where there is a link. Two Gaussians,
  defaults 4e-4 and 1. Wang (2015) SSSL. No point mass.
- `?modelSelectionGGM`: "Off-diagonal Omega[j,k] are equal to zero with
  probability given by modelPrior and otherwise arises from the distribution
  indicated in priorCoef (slab)." A Dirac spike. Confirmed operationally by the
  source: `ppnew = 1/(1 + exp(mcurrent - mnew))` is a logistic of a log MARGINAL
  likelihood difference, which only arises when the coefficient has been
  integrated out under a point mass.
- bgms also has a point-mass spike, via edge indicators.

Measured cost per pair-evaluation, microseconds of CPU:

| p | modelSelection | bgms | ssgraph |
|---:|---:|---:|---:|
| 50 | 2.96 | 0.72 | 2.20 |
| 100 | 1.82 | 1.61 | 7.80 |
| 200 | 1.39 | 4.81 | 31.85 |

Scaling: modelSelection p^-0.54, bgms p^1.37, ssgraph p^1.93.

Under a continuous spike every one of the p-1 off-diagonals of a column is
always non-zero, because a spike draw is still a draw. So each ssgraph column
visit samples a dense (p-1)-variate conditional normal: O(p^3) per column,
O(p^4) per sweep, O(p^2) per pair. The measured p^1.93 is that.

Under a point mass the algebra is confined to the included submatrix, which on
this data is 2.9 entries per column at EVERY p (average degree 3 by
construction). modelSelection's per-entry work therefore barely depends on p,
and the fixed per-column cost amortises over more entry evaluations as p grows,
so its per-pair cost falls: p^-0.54.

bgms is intermediate: point-mass spike, but its within-model step draws the whole
column of K from its conjugate conditional through rank-2 Cholesky/SMW updates,
O(p^2) per column and O(p) per pair. Measured p^1.37.

### Two limits any published sentence must respect

1. There is a crossover. At p = 50 bgms is 4x cheaper per pair-evaluation
   (0.72 vs 2.96 us) and modelSelection only wins from about p = 100. "Faster
   kernel" is false at p = 50 and true at p = 200.
2. The advantage is sparsity-dependent, not dimension-dependent. It comes from
   2.9 included entries per column. On a denser graph the included submatrix
   grows and the advantage shrinks; this benchmark has only one graph density
   (average degree 3) and cannot say where it disappears. Vogels et al. varied
   density (1% and 10% at p = 100) precisely because it matters.

This is the same mechanism as the report's "bgms's runtime adapts to sparsity,
ssgraph's does not" finding (CPU 1532 s to 442 s under a sparse prior against
ssgraph's flat 3169 to 3264 s). Point-mass methods get paid for sparsity;
continuous ones do not. It is one finding, not two.
