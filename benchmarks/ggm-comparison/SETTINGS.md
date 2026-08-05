# Per-package settings rationale

Every claim below is quoted from the installed build's own help pages, README,
NEWS or vignette. Nothing is inferred from the literature except where the note
says so explicitly.

Verification commands used (scratch library on the front of `.libPaths()`):

    Rscript -e 'args(ssgraph::ssgraph)'
    Rscript -e 'args(modelSelection::modelSelectionGGM)'
    R -e 'tools::Rd2txt(utils:::.getHelpFile(help("ssgraph", package = "ssgraph")))'
    R -e 'tools::Rd2txt(utils:::.getHelpFile(help("modelSelectionGGM", package = "modelSelection")))'
    R -e 'tools::Rd2txt(utils:::.getHelpFile(help("icov", package = "modelSelection")))'

## bgms 0.2.0.0

Only one configuration, as instructed: the fast route exactly as
`vignettes/fast-ggm.Rmd` displays it.

    bgm(y, variable_type = "continuous", precision_graph_prior = "joint",
        update_method = "gibbs", chains = 4, cores = 4, seed = 2026)

Everything else is the `bgm()` default: `edge_prior = bernoulli_prior(0.5)`,
`warmup = 2000`, `iter = 2000`, so 4 chains of 2000 retained draws each. This is
the only cell with thread parallelism: 4 chains on 4 threads.

Two supplementary bgms cells are reported separately and are not part of the
defaults-versus-documented pair:

- `bgms-sparse-prior`, the same call with `edge_prior = bernoulli_prior(2/(p-1))`.
  Both competitors default to a sparsity-favouring edge prior, so without this
  row the false-positive columns would compare edge priors rather than samplers.
- `bgms-serial`, the same call with `cores = 1`, so the 4-thread rows can be read
  against a single-threaded bgms number.

Decision rule: posterior inclusion probability above 0.5, which is what
`data-raw/make-fast-ggm.R` uses and what the vignette reports. It is also the
matched rule.

## modelSelection 1.0.7

### Defaults

    modelSelectionGGM(y)

which is `niter = 1000`, `burnin = 100`, `sampler = "Gibbs"`,
`global_proposal = "none"`, `priorCoef = normalidprior(tau = 1)`,
`priorModel = modelbinomprior(1/ncol(y))`,
`priorDiag = exponentialprior(lambda = 1)`, `center = TRUE`, `scale = TRUE`,
`updates_per_iter = ceiling(sqrt(ncol(y)))`, `updates_per_column = 10`,
`Omegaini = "glasso-ebic"`.

The default model prior is already the sparse one: `modelbinomprior(1/ncol(y))`
puts a 1/p prior on each of the p(p-1)/2 edges, which is 0.02 at p = 50 and
0.005 at p = 200. Nothing in the settings needs changing to make this package
favour sparsity.

### Documentation-directed

`?modelSelectionGGM` contains no tuning section, so both directed cells come
from sentences on that page.

1. `modelSelectionGGM(y, niter = 5000, global_proposal = "regression")`.
   Details: "If `global_proposal == 'regression'`, a global proposal is used. A
   new model (set of non-zero entries in Omega[,k]) is proposed based on the
   posterior distribution of a linear regression of y[,k] on the other
   covariates", and `?truncratio` gives the motive: "to improve poor mixing when
   the current state has low proposal probability". `niter = 5000` is the length
   the package itself runs its final MCMC at (`niter.mcmc = 5000` in
   `modelSelectionGGM_eBayes`).
2. `modelSelectionGGM_eBayes(y = y)`. The `priorModel` argument doc says "See
   also `modelSelectionGGM_eBayes` for an empirical Bayes model prior", so this
   is the documented route to a data-driven edge prior instead of a fixed 1/p.
   All lengths at their defaults: `niter.eBayes = 20` empirical-Bayes iterations
   of `niter.mstep = 1000` draws, then a final `niter.mcmc = 5000` draws.

`Omegaini` stays at its default in every cell. The Examples say "y has few
columns, initialize the MCMC at the sample precision matrix. Else, leave the
argument `Omegaini` in `modelSelectionGGM` empty", and p = 50 to 200 is not few.

### Decision rule

`?icov`: "Entries with posterior probability of being non-zero below threshold
are set to 0. ... When the goal is to identify zeroes, a sensible default is
`threshold = 0.95`." So modelSelection's own rule is inclusion probability above
0.95, not 0.5. Both are reported.

Inclusion probabilities come from `margpp`, which `?modelSelectionGGM` describes
as "Rao-Blackwellized estimates of posterior marginal inclusion probabilities.
Only valid when using the Gibbs algorithm". For the two cells whose sampler is
Gibbs with local proposals, `margpp` is the reported number. For the
`global_proposal = "regression"` cell the reported number is instead the
proportion of posterior draws in which the entry is non-zero, which is valid
under any sampler; `margpp` is kept alongside it in the result files, and the
two agree to three decimals wherever both are computed.

`margpp` and `indexes` cover the diagonal of Omega as well as the off-diagonal,
so the runner keeps only entries with `row != column`.

## ssgraph 1.16

### Defaults

    ssgraph(y, method = "ggm")

which is `iter = 5000`, `burnin = 2500`, `var1 = 4e-04`, `var2 = 1`,
`lambda = 1`, `g.prior = 0.2`, `g.start = "full"`. The package vignette and the
`?ssgraph-package` examples both run the defaults at `iter = 5000`, so the
default call is also the documented call.

### Documentation-directed

ssgraph ships no tuning advice for sparse structure learning. Its defaults are
its advice: NEWS for version 1.15 records "In function `ssgraph()`, option
`g.prior` is changed from `0.5` to `0.2`", a deliberate move of the default edge
prior toward sparsity. The one alternative any ssgraph help page names is in
`?ssgraph` under `g.prior`: "a single value between 0 and 1 (e.g. 0.5 as a
noninformative prior)". So the directed cell is

    ssgraph(y, method = "ggm", g.prior = 0.5)

which happens to be the edge prior the bgms rows run under, making this the
prior-matched pair in the table.

A third, supplementary ssgraph cell uses
`g.prior = 2/(p-1), g.start = "empty"`: a sparse edge prior of the kind Wang
(2015) uses for structure learning, Wang (2015) being the method `?ssgraph`
cites. No ssgraph help page names this value, so it is labelled supplementary,
not documented.

`g.start` is worth a note. The formals say `g.start = "full"`; the argument
documentation on the same page says 'It could be an (p x p) matrix, `"empty"`
(default), or `"full"`'. The build's behaviour is "full", so the default cells
run "full".

### Decision rule

`ssgraph:::summary.ssgraph` computes `BDgraph::select(p_links, cut = 0.5)` and
labels the plot "Graph with edge posterior probability > 0.5", so ssgraph's own
rule is 0.5, the same as the matched rule.

### Threads

`?ssgraph` says the package is "implemented in C++ in parallel using OpenMP" and
offers a `cores` argument. The CRAN source build on this machine carries no
OpenMP runtime: `nm -u ssgraph.so | grep -i omp` returns nothing and
`otool -L ssgraph.so` lists no OpenMP library, because Apple clang builds
without `-fopenmp` unless configured for it. So `cores` has no effect here and
every ssgraph row is single-threaded. The CPU-time column in the results
confirms this: CPU time tracks wall clock one to one.

## Preprocessing, which each package does its own way

- bgms centres the columns of the input internally.
- modelSelection centres and scales to unit variance by default
  (`center = TRUE`, `scale = TRUE`), so it works on the correlation scale.
- ssgraph forms the uncentred scatter matrix `S = t(data) %*% data`
  (`BDgraph::get_S_n_p`) and works on the covariance scale.

The same matrix is handed to all three; each one's own preprocessing then
applies. The simulated data are mean zero by construction, so the uncentred and
centred scatter matrices differ negligibly, but the covariance-versus-
correlation scale difference is real and is part of why the slab priors are not
comparable term for term.
