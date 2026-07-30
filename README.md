# bgms Documentation

**Live site:** <https://bayesian-graphical-modelling-lab.github.io/bgms/>

Documentation site for the [bgms](https://github.com/Bayesian-Graphical-Modelling-Lab/bgms) R package.

## Structure

- `guide/` — User's Guide (tutorials, statistical concepts)
- `examples/` — Worked analyses (one analysis per page, code and workflow)
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

The `Makefile` wraps the builds that need more than a bare `quarto render`, and
takes `QUARTO=` if Quarto is not on your `PATH` (the RStudio-bundled binary
lives under `/Applications/RStudio.app/Contents/Resources/app/quarto/bin`):

```bash
make site             # render the whole site with the ci profile
make fixtures         # rebake the .rds fixtures (about ten minutes)
make example-scripts  # regenerate the Examples companion scripts
make examples-pdf     # the Examples series as one PDF
```

### Building from RStudio

The project file sets `BuildType: Makefile`, so RStudio's Build pane runs
`make` rather than a bare `quarto render`. That matters: `make` sets `R_LIBS`
to the documented bgms build and renders with the ci profile, and a bare
render does neither. The default target is `all`, which builds the site and
then the Examples PDF.

The Makefile only governs builds. Running chunks interactively in the RStudio
console still needs `R_LIBS` set in the session; put it in a `.Renviron` in
the repo root:

```
R_LIBS=dev/lib-bgms-develop
```

### The Examples section

`examples/` holds the worked analyses. Two of its build steps are generated,
never hand-maintained:

- **Companion scripts.** Each page's code is tangled to `examples/R/NN-slug.R`
  by `scripts/extract-example-code.R`, which runs as the project `pre-render`
  step, so the script published beside a page always matches it. The scripts
  are gitignored build artifacts.
- **The PDF.** `make examples-pdf` renders the index and every published
  example page, in series order, into one PDF and copies it to
  `docs/examples/bgms-worked-analyses.pdf`. It uses the `pdf` Quarto profile
  (`_quarto-pdf.yml`), writes to `_pdf/`, and leaves the site render alone. Run
  it after the site render, which rewrites `docs/`; `make all` does both in
  that order.

The series order lives in `scripts/examples-series.R`. See STYLE_GUIDE.md
§ Example Pages for the page shape and the chunk conventions the two steps
rely on.

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
the content; the package repository owns the URL.
[`.github/workflows/publish.yml`](.github/workflows/publish.yml) renders the
site here and publishes it to the `gh-pages` branch of
`Bayesian-Graphical-Modelling-Lab/bgms`.

The documentation is versioned, so that branch holds more than one site:

| Path | What it is | Deployed by |
|---|---|---|
| `/` | the current release | every push to `main` |
| `/dev/` | the development documentation | every push to `docs/develop` |
| `/vX.Y.Z/` | a frozen archive of a past release | by hand on release day, starting with the release after 0.2.0.0 |

Every deploy step is guarded on a branch, so a manual run from any other branch
renders and stops. A push to `docs/develop` publishes to `/dev/` straight away:
that documentation is public, and every page of it says so.

### The root-exclusion invariant

**A root deploy must never touch `dev/` or any `vX.Y.Z/`.** It replaces the
root, deleting whatever the render no longer produces, and leaves the other
sites alone. A dev deploy is the mirror image: it replaces `dev/` and reads or
writes nothing outside it.

`peaceiris/actions-gh-pages` cannot express that. It cleans its destination with
`git rm -r --ignore-unmatch *` before copying, and with no `destination_dir` the
destination is the whole branch, which would take `dev/` and every archive with
it; `exclude_assets` filters the source, not the destination. So both deploys to
the bgms repository go through
[`scripts/deploy-gh-pages.sh`](scripts/deploy-gh-pages.sh), which clears the
root by name and keeps `.git`, `dev/`, and any `vX.Y.Z/` directory. Its header
carries the reasoning.

[`scripts/simulate-deploy.sh`](scripts/simulate-deploy.sh) proves both
directions against a throwaway repository holding a released site, a `dev/`
build, and a `v0.1.0/` archive. It needs no network and no credentials. Run it
after any change to the deploy script:

```bash
scripts/simulate-deploy.sh
```

### What a build knows about itself

One environment variable, `BGMS_DOC_CHANNEL`, tells a render which of the two
sites it is: `release` (the default) or `dev`. Everything that differs hangs off
it, through [`scripts/doc-build.R`](scripts/doc-build.R):

- The version the citation picker prints is read from the installed bgms
  DESCRIPTION, never written down in a page. The release job installs bgms from
  the package's `main` branch and the dev job from `develop`, so each build
  stamps what it documents. `BGMS_DOC_VERSION` overrides it if a render ever has
  to claim another version.
- `versions.json`, the version index at the site root, is written by
  [`scripts/versions.R`](scripts/versions.R) and only by the release build: it
  describes the whole family, and only the build that owns the root can speak
  for the family. The dev build reads the root copy one directory up.
- The navbar version switcher is built from that file by the script in
  `js.html`. If the file is missing, as in a local preview, there is no
  dropdown and nothing else changes.
- A dev build is marked as one by
  [`scripts/dev-build.R`](scripts/dev-build.R): a dismissable banner on every
  page, `<meta name="robots" content="noindex">`, and a canonical link to the
  same page under the site root, so search traffic collects on the release
  docs. It also drops `sitemap.xml` and `robots.txt`, which describe the root's
  URLs and not its own. A release render gets none of this.

To see a development build locally:

```bash
BGMS_DOC_CHANNEL=dev make site
```

### Release day

The order matters, because the root deploy overwrites the outgoing release.

1. **Archive the outgoing release first** (from the release after 0.2.0.0
   onwards; there is nothing to archive at 0.2.0.0). In a clone of the bgms
   repository, on `gh-pages`, copy the root into its version directory and push:

   ```bash
   mkdir vX.Y.Z
   rsync -a --exclude '/.git/' --exclude '/dev/' --exclude '/v[0-9]*/' ./ vX.Y.Z/
   git add vX.Y.Z && git commit -m "Archive the X.Y.Z documentation" && git push
   ```

   The copy keeps the `versions.json` it was built with. That is harmless: the
   switcher notices the file belongs to the root and reloads the live one.
2. Add the archived version to `ARCHIVED` in
   [`scripts/versions.R`](scripts/versions.R), one line, newest first.
3. Merge `docs/develop` into `main` and push. The push renders and deploys the
   root, which now also publishes the new `versions.json`.
4. Verify: the root serves the new release, `/dev/` is still there and still
   intact, the switcher lists every entry, and the archived version still
   answers at `/vX.Y.Z/`.

### The redirect site

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
