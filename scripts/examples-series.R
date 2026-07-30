# The Examples series, in order. One source of truth for the two build steps
# that need the order: the companion scripts (scripts/extract-example-code.R)
# and the PDF (scripts/build-examples-pdf.R). Sourced, never run on its own.
#
# Entry 1 of the series as the reader sees it on examples/index.qmd is "Your
# first network", which is guide/getting-started.qmd and not an examples page.
# The examples pages therefore start at position 2, which is what SERIES_OFFSET
# encodes and what the companion scripts are numbered with.
#
# Adding a page means listing its slug here, adding it to the `examples`
# sidebar in _quarto.yml, and adding an entry to examples/index.qmd. Pages
# listed here that do not exist yet are skipped by both build steps, so the
# list can run ahead of the pages.

SERIES = c(
  "estimation-to-evidence",   # 02
  "reading-the-output",       # 03
  "check-your-priors",        # 04
  "comparing-groups",         # 05
  "edge-clustering",          # 06
  "from-bootnet-qgraph",      # 07
  "reporting"                 # 08
)

SERIES_OFFSET = 1L

# Slugs in series order, restricted to the pages that exist.
series_pages = function(project_dir = ".") {
  present = sub("[.]qmd$", "",
                list.files(file.path(project_dir, "examples"),
                           pattern = "[.]qmd$"))
  present = setdiff(present, "index")
  unlisted = setdiff(present, SERIES)
  if(length(unlisted) > 0) {
    warning("examples series: page missing from SERIES in ",
            "scripts/examples-series.R: ",
            paste(unlisted, collapse = ", "), call. = FALSE)
  }
  intersect(SERIES, present)
}

# Position in the series, as printed in companion script names.
series_number = function(slug) {
  sprintf("%02d", match(slug, SERIES) + SERIES_OFFSET)
}
