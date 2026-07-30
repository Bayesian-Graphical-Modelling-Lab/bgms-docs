# Build targets for the bgms documentation site.
#
# Quarto is not always on the PATH; on macOS the RStudio-bundled binary lives
# at /Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto. Point
# the QUARTO variable at whichever one you want:
#
#   make site QUARTO=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto
#
# R_LIBS points at the bgms build the site documents. Every target that can
# execute package code sets it, so the numbers on the site come from one build.

QUARTO ?= quarto
R_LIBS ?= dev/lib-bgms-develop
PDF := _pdf/_pdf-src/worked-analyses.pdf

.PHONY: all site preview fixtures example-scripts examples-pdf clean-pdf

## all: the site, then the PDF. In this order: a site render rewrites docs/,
## so a PDF copied there before it does not survive.
all: site examples-pdf

## site: render the whole site to docs/ (the profile CI uses)
site:
	R_LIBS=$(R_LIBS) $(QUARTO) render --profile ci

## preview: live-reloading local preview
preview:
	R_LIBS=$(R_LIBS) $(QUARTO) preview

## fixtures: rebake the .rds fixtures the pages read (about ten minutes)
fixtures:
	R_LIBS=$(R_LIBS) Rscript fixtures/bake.R

## example-scripts: regenerate examples/R/NN-slug.R from the example pages
## (the site render does this too, as its pre-render step)
example-scripts:
	Rscript scripts/extract-example-code.R

## examples-pdf: the Examples series as one PDF, published beside the section
## index so the download link on examples/index.qmd resolves
examples-pdf:
	R_LIBS=$(R_LIBS) $(QUARTO) render --profile pdf --to pdf
	mkdir -p docs/examples
	cp $(PDF) docs/examples/bgms-worked-analyses.pdf
	@echo "docs/examples/bgms-worked-analyses.pdf"

clean-pdf:
	rm -rf _pdf _pdf-src
