# The Examples series, in order. One source of truth for the two build steps
# that need the order: the companion scripts (scripts/extract-example-code.R)
# and the PDF (scripts/build-examples-pdf.R). Sourced, never run on its own.
#
# Getting started is entry 1 and an examples page like the others, so the
# companion scripts are numbered from 01 and SERIES_OFFSET is zero.
#
# Adding a page means listing its slug here, adding it to the `examples`
# sidebar in _quarto.yml, and adding an entry to examples/index.qmd. Pages
# listed here that do not exist yet are skipped by both build steps, so the
# list can run ahead of the pages.

SERIES = c(
  "getting-started",          # 01
  "estimation-to-evidence",   # 02
  "reading-the-output",       # 03
  "check-your-priors",        # 04
  "comparing-groups",         # 05
  "edge-clustering",          # 06
  "from-bootnet-qgraph"       # 07
)

SERIES_OFFSET = 0L

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
