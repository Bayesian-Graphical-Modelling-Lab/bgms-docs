# Redirect stubs for the URL paths the previous pkgdown site served.
#
# The Quarto site replaces the pkgdown site at the canonical address
# https://bayesian-graphical-modelling-lab.github.io/bgms/. The two sites do
# not share a URL layout: pkgdown gave every help topic its own page, while
# the Quarto reference groups topics onto ten pages with per-topic anchors.
# Without stubs, every old link and every indexed pkgdown URL would 404.
#
# This script runs as the project `post-render` step and writes one stub per
# old path into the render output. Each stub carries a canonical link tag (so
# search engines fold the old URL into the new one), a meta refresh, and a
# script fallback, plus a visible link for anyone with both disabled.
#
# Paths that the two sites happen to share (index.html, reference/index.html,
# reference/bgm.html, reference/bgmCompare.html) need no stub and must not get
# one: a stub there would overwrite the real page.
#
# To add a mapping, add a `"old/path.html" = "new/path.html#anchor"` line to
# REDIRECTS. The script checks every target against the render output and
# reports any that are missing.

out_dir = Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", unset = "docs")
project_dir = Sys.getenv("QUARTO_PROJECT_DIR", unset = ".")

# The stubs describe the website's URL layout, so they belong to a render that
# produces the website. The pdf profile renders the Examples series into _pdf/
# and must not collect 104 HTML stubs on the way.
if(basename(out_dir) != "docs") {
  cat("redirects: output directory is", out_dir,
      "- not the website render, no stubs written\n")
  quit(save = "no")
}

# Canonical site URL, read from _quarto.yml so there is one source of truth.
site_url = "https://bayesian-graphical-modelling-lab.github.io/bgms"
quarto_yml = file.path(project_dir, "_quarto.yml")
if(file.exists(quarto_yml)) {
  hit = grep("^\\s*site-url:", readLines(quarto_yml, warn = FALSE), value = TRUE)
  if(length(hit) == 1L) {
    site_url = sub("^\\s*site-url:\\s*", "", hit[1])
    site_url = gsub("^[\"']|[\"']$", "", trimws(site_url))
    site_url = sub("/$", "", site_url)
  }
}

# --- Mapping: old pkgdown path -> new site path (with optional anchor) ------

REDIRECTS = c(
  # Repository meta pages pkgdown generated from the repo's markdown files.
  "authors.html"                  = "index.html",
  "LICENSE-text.html"             = "index.html",
  "CODE_OF_CONDUCT.html"          = "index.html",
  "CONTRIBUTING.html"             = "index.html",
  "CONTRIBUTORS.html"             = "index.html",
  "PULL_REQUEST_TEMPLATE.html"    = "index.html",
  "copilot-instructions.html"     = "index.html",

  # Change log.
  "news/index.html"               = "news.html",

  # Vignettes. The Quarto guide pages own this material now.
  "articles/index.html"           = "guide/index.html",
  "articles/intro.html"           = "examples/getting-started.html",
  "articles/introduction.html"    = "examples/getting-started.html",
  "articles/comparison.html"      = "examples/comparing-groups.html",
  "articles/diagnostics.html"     = "guide/mcmc-diagnostics.html",
  "articles/missing_data.html"    = "guide/missing-data.html",
  "articles/prior-sensitivity.html" = "reference/prior-sensitivity.html",
  "articles/fast-ggm.html"        = "guide/fast-ggm.html",

  # Pages the Quarto site itself has retired or moved (R1 restructure,
  # 2026-11). Same machinery: an old URL keeps resolving to its new home.
  "guide/getting-started.html"    = "examples/getting-started.html",
  "guide/group-comparison.html"   = "examples/comparing-groups.html",

  # Package-level topic.
  "reference/bgms-package.html"   = "reference/index.html",
  "reference/bgms.html"           = "reference/index.html",

  # Estimation entry points removed before 0.2.0.0.
  "reference/bgm.em.html"         = "reference/bgm.html",
  "reference/est_bgm.html"        = "reference/bgm.html",
  "reference/mple.html"           = "reference/bgm.html",
  "reference/mppe.html"           = "reference/bgm.html",

  # Prior constructors and their unpack helpers.
  "reference/cauchy_prior.html"           = "reference/priors.html#cauchy_prior",
  "reference/normal_prior.html"           = "reference/priors.html#normal_prior",
  "reference/beta_prime_prior.html"       = "reference/priors.html#beta_prime_prior",
  "reference/gamma_prior.html"            = "reference/priors.html#gamma_prior",
  "reference/exponential_prior.html"      = "reference/priors.html#exponential_prior",
  "reference/bernoulli_prior.html"        = "reference/priors.html#bernoulli_prior",
  "reference/beta_bernoulli_prior.html"   = "reference/priors.html#beta_bernoulli_prior",
  "reference/sbm_prior.html"              = "reference/priors.html#sbm_prior",
  "reference/unpack_interaction_prior.html" = "reference/priors.html#parameter-priors",
  "reference/unpack_parameter_prior.html"   = "reference/priors.html#parameter-priors",
  "reference/unpack_threshold_prior.html"   = "reference/priors.html#parameter-priors",
  "reference/unpack_scale_prior.html"       = "reference/priors.html#scale-priors",
  "reference/unpack_indicator_prior.html"   = "reference/priors.html#indicator-priors",

  # Prior samplers and the hierarchical trust gauge.
  "reference/sample_ggm_prior.html"       = "reference/sample-ggm-prior.html",
  "reference/sample_precision_prior.html" = "reference/sample-ggm-prior.html",
  "reference/sample_graph_prior.html"     = "reference/prior-samplers.html#sample_graph_prior",
  "reference/sample_sbm_prior.html"       = "reference/prior-samplers.html#sample_sbm_prior",
  "reference/summarize_zratio_gauge.html" = "reference/prior-samplers.html#summarize_zratio_gauge",
  "reference/summarize_zratio_diagnostics.html" = "reference/prior-samplers.html#summarize_zratio_gauge",

  # S3 methods on fitted objects.
  "reference/print.bgms.html"             = "reference/methods.html#print",
  "reference/print.bgmCompare.html"       = "reference/methods.html#print",
  "reference/summary.bgms.html"           = "reference/methods.html#summary",
  "reference/summary.bgmCompare.html"     = "reference/methods.html#summary",
  "reference/coef.bgms.html"              = "reference/methods.html#coef",
  "reference/coef.bgmCompare.html"        = "reference/methods.html#coef",
  "reference/predict.bgms.html"           = "reference/methods.html#predict",
  "reference/predict.bgmCompare.html"     = "reference/methods.html#predict",
  "reference/simulate.bgms.html"          = "reference/methods.html#simulate",
  "reference/simulate.bgmCompare.html"    = "reference/methods.html#simulate",
  "reference/simulate_mrf.html"           = "reference/methods.html#simulate_mrf",
  "reference/mrfSampler.html"             = "reference/methods.html#simulate_mrf",

  # Accessors. The extractor page is the documented way to pull components
  # out of a fit; `$` and `[[` keep working but have no page of their own.
  "reference/cash-.bgms.html"             = "reference/extractors.html",
  "reference/cash-.bgmCompare.html"       = "reference/extractors.html",
  "reference/[[.bgms.html"                = "reference/extractors.html",
  "reference/[[.bgmCompare.html"          = "reference/extractors.html",
  "reference/extractor_functions.html"    = "reference/extractors.html",

  # Extractors, including the per-class method pages pkgdown emitted.
  "reference/extract_arguments.html"                = "reference/extractors.html#extract_arguments",
  "reference/extract_arguments.bgms.html"           = "reference/extractors.html#extract_arguments",
  "reference/extract_arguments.bgmCompare.html"     = "reference/extractors.html#extract_arguments",
  "reference/extract_main_effects.html"             = "reference/extractors.html#extract_main_effects",
  "reference/extract_category_thresholds.html"      = "reference/extractors.html#extract_main_effects",
  "reference/extract_category_thresholds.bgms.html" = "reference/extractors.html#extract_main_effects",
  "reference/extract_category_thresholds.bgmCompare.html" = "reference/extractors.html#extract_main_effects",
  "reference/extract_pairwise_thresholds.html"      = "reference/extractors.html#extract_main_effects",
  "reference/extract_pairwise_interactions.html"    = "reference/extractors.html#extract_pairwise_interactions",
  "reference/extract_pairwise_interactions.bgms.html" = "reference/extractors.html#extract_pairwise_interactions",
  "reference/extract_pairwise_interactions.bgmCompare.html" = "reference/extractors.html#extract_pairwise_interactions",
  "reference/extract_indicators.html"               = "reference/extractors.html#extract_indicators",
  "reference/extract_indicators.bgms.html"          = "reference/extractors.html#extract_indicators",
  "reference/extract_indicators.bgmCompare.html"    = "reference/extractors.html#extract_indicators",
  "reference/extract_edge_indicators.html"          = "reference/extractors.html#extract_indicators",
  "reference/extract_posterior_inclusion_probabilities.html" = "reference/extractors.html#extract_posterior_inclusion_probabilities",
  "reference/extract_posterior_inclusion_probabilities.bgms.html" = "reference/extractors.html#extract_posterior_inclusion_probabilities",
  "reference/extract_posterior_inclusion_probabilities.bgmCompare.html" = "reference/extractors.html#extract_posterior_inclusion_probabilities",
  "reference/extract_inclusion_bf.html"             = "reference/extractors.html#extract_inclusion_bf",
  "reference/extract_prior_inclusion_probabilities.html" = "reference/extractors.html#extract_prior_inclusion_probabilities",
  "reference/extract_indicator_priors.html"         = "reference/extractors.html#extract_indicator_priors",
  "reference/extract_indicator_priors.bgms.html"    = "reference/extractors.html#extract_indicator_priors",
  "reference/extract_indicator_priors.bgmCompare.html" = "reference/extractors.html#extract_indicator_priors",
  "reference/extract_edge_priors.html"              = "reference/extractors.html#extract_indicator_priors",
  "reference/extract_group_params.html"             = "reference/extractors.html#extract_group_params",
  "reference/extract_group_params.bgmCompare.html"  = "reference/extractors.html#extract_group_params",
  "reference/extract_main_difference.bgmCompare.html" = "reference/extractors.html#extract_group_params",
  "reference/extract_pairwise_difference.bgmCompare.html" = "reference/extractors.html#extract_group_params",
  "reference/extract_sbm.html"                      = "reference/extractors.html#extract_sbm",
  "reference/extract_sbm.bgms.html"                 = "reference/extractors.html#extract_sbm",
  "reference/summarySBM.html"                       = "reference/extractors.html#extract_sbm",
  "reference/summary_SBM.html"                      = "reference/extractors.html#extract_sbm",
  "reference/extract_ess.html"                      = "reference/extractors.html#extract_ess",
  "reference/extract_ess.bgms.html"                 = "reference/extractors.html#extract_ess",
  "reference/extract_ess.bgmCompare.html"           = "reference/extractors.html#extract_ess",
  "reference/extract_rhat.html"                     = "reference/extractors.html#extract_rhat",
  "reference/extract_rhat.bgms.html"                = "reference/extractors.html#extract_rhat",
  "reference/extract_rhat.bgmCompare.html"          = "reference/extractors.html#extract_rhat",
  "reference/extract_precision.html"                = "reference/extractors.html#extract_precision",
  "reference/extract_partial_correlations.html"     = "reference/extractors.html#extract_partial_correlations",
  "reference/extract_log_odds.html"                 = "reference/extractors.html#extract_log_odds",

  # Prior sensitivity check and its methods.
  "reference/prior_sensitivity_check.html"          = "reference/prior-sensitivity.html",
  "reference/print.bgms_prior_sensitivity.html"     = "reference/prior-sensitivity.html",
  "reference/plot.bgms_prior_sensitivity.html"      = "reference/prior-sensitivity.html",

  # Datasets.
  "reference/ADHD.html"                             = "reference/datasets.html#adhd",
  "reference/Boredom.html"                          = "reference/datasets.html#boredom",
  "reference/Wenchuan.html"                         = "reference/datasets.html#wenchuan"
)

# --- Machinery --------------------------------------------------------------

# Path of `to` relative to the directory holding `from`, both site-relative.
relative_to = function(from, to) {
  from_dir = utils::head(strsplit(from, "/", fixed = TRUE)[[1]], -1L)
  to_parts = strsplit(to, "/", fixed = TRUE)[[1]]
  shared = 0L
  while(shared < length(from_dir) && shared < length(to_parts) - 1L &&
        from_dir[shared + 1L] == to_parts[shared + 1L]) {
    shared = shared + 1L
  }
  paste(c(rep("..", length(from_dir) - shared),
          to_parts[(shared + 1L):length(to_parts)]),
        collapse = "/")
}

stub = function(href, canonical) {
  sprintf('<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Redirecting</title>
<link rel="canonical" href="%s">
<meta http-equiv="refresh" content="0; url=%s">
<script>window.location.replace("%s" + window.location.search);</script>
</head>
<body>
<p>This page has moved to <a href="%s">%s</a>.</p>
</body>
</html>
', canonical, href, href, href, canonical)
}

targets = sub("#.*$", "", REDIRECTS)
missing_targets = unique(targets[!file.exists(file.path(out_dir, targets))])
collisions = intersect(names(REDIRECTS), unique(targets))

for(from in names(REDIRECTS)) {
  if(from %in% collisions) next
  to = REDIRECTS[[from]]
  path = sub("#.*$", "", to)
  fragment = if(grepl("#", to, fixed = TRUE)) sub("^[^#]*", "", to) else ""
  href = paste0(relative_to(from, path), fragment)
  dest = file.path(out_dir, from)
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  writeLines(stub(href, paste0(site_url, "/", path, fragment)), dest)
}

cat(sprintf("redirects: wrote %d stubs for the pkgdown URL layout\n",
            length(REDIRECTS) - length(collisions)))

if(length(collisions) > 0) {
  warning("redirects: mapping source collides with a real page, skipped: ",
          paste(collisions, collapse = ", "), call. = FALSE)
}
if(length(missing_targets) > 0) {
  warning("redirects: target missing from the render output: ",
          paste(missing_targets, collapse = ", "), call. = FALSE)
}
