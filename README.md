# bgms Documentation

**Live site:** <https://bayesian-graphical-modelling-lab.github.io/bgms/>

Documentation site for the [bgms](https://github.com/Bayesian-Graphical-Modelling-Lab/bgms) R package.

## Structure

- `guide/` — User's Guide (tutorials, statistical concepts)
- `reference/` — Function reference (API documentation)
- `manual/` — Reference Manual (C++ backend, algorithms)

## Building Locally

Requires [Quarto](https://quarto.org/docs/get-started/).

```bash
# Preview with live reload
quarto preview

# Build static site
quarto render
```

Output goes to `docs/`.

Pages that report model output read baked `.rds` fixtures instead of refitting.
The fixtures are not in the repository; bake them once, pointing R at the bgms
build you want the numbers to come from:

```bash
R_LIBS=dev/lib-bgms-develop Rscript fixtures/bake.R
```

`fixtures/bake.R` is the only fixture script. Rebake whenever the bgms version
changes, then re-render so the summaries, figures, and prose numbers stay in
sync with the package.

The Wenchuan fit and its prior sensitivity check run at the tutorial paper's
configuration, so the site and the paper quote one set of numbers rather than
two compatible ones. That costs about ten minutes of baking and roughly 160 MB
of `.rds` on disk (gitignored). Everything else in the script runs at package
defaults. See the header of `fixtures/bake.R` for the reasoning and the
measured per-fixture timings.

## Contributing

1. Edit `.qmd` files in the appropriate directory
2. Preview locally with `quarto preview`
3. Commit and push — GitHub Actions will deploy automatically

## Deployment

The canonical site is <https://bayesian-graphical-modelling-lab.github.io/bgms/>,
which is GitHub Pages for the **bgms package repository**. This repository owns
the content; the package repository owns the URL. On a push to `main`,
[`.github/workflows/publish.yml`](.github/workflows/publish.yml) renders the
site here and publishes it to the `gh-pages` branch of
`Bayesian-Graphical-Modelling-Lab/bgms`. Both deploy steps are guarded on
`main`, so a manual run from any other branch renders and stops.

This repository's own Pages site,
<https://bayesian-graphical-modelling-lab.github.io/bgms-docs/>, serves only
the redirect in [`redirect/`](redirect/): `index.html` sends the root to the
canonical address, and `404.html` carries any deep path across to the matching
canonical path.

`scripts/redirects.R` runs as the project `post-render` step and writes a stub
for every URL the earlier pkgdown site served, so old links and indexed URLs
land on the page that now owns the material instead of a 404. Add mappings to
the table at the top of that script; it checks every target against the render
output and warns about any that are missing.

### One-time setup

The cross-repository deploy needs an SSH deploy key. This is the only part that
cannot be done from this repository:

1. Generate a key pair, for example
   `ssh-keygen -t ed25519 -N "" -C "bgms-docs site deploy" -f bgms-site-deploy`
2. In the **bgms** repository: Settings → Deploy keys → Add deploy key. Paste
   `bgms-site-deploy.pub`, title it "bgms-docs site deploy", and check
   **Allow write access**.
3. In **this** repository: Settings → Secrets and variables → Actions → New
   repository secret, named `BGMS_SITE_DEPLOY_KEY`, holding the contents of the
   private key `bgms-site-deploy`.
4. In the **bgms** repository: Settings → Pages → Source "Deploy from a
   branch", branch `gh-pages`, folder `/ (root)`.
5. In the **bgms** repository, retire pkgdown before the first deploy, or the
   next push there rebuilds pkgdown over this site: delete
   `.github/workflows/pkgdown.yaml` and `_pkgdown.yml`.
6. Delete the local key pair once both halves are stored.

### Rollback

The deploy replaces the published file set but keeps the `gh-pages` history, so
a bad deploy can be undone two ways:

- Re-run the workflow from the last good commit
  (Actions → Build and Deploy Documentation → Run workflow), or
- revert the offending commit on `main` and let the push deploy.

To inspect what is live, check out `gh-pages` in a clone of the bgms
repository.

## License

Documentation content is licensed under [CC BY 4.0](LICENSE).

Site theme files (`theme.scss`, `theme-dark.scss`, `index.css`, `js.html`, `filters/`) were adapted from the [quarto-dev/quarto-web](https://github.com/quarto-dev/quarto-web) project (MIT License, Copyright &copy; 2022 Posit Software, PBC).
