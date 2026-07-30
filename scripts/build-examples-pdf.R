# Assemble the Examples series into one source document for the PDF profile.
#
# Runs as the `pre-render` step of the pdf profile (see _quarto-pdf.yml), which
# then renders the assembled file:
#
#   quarto render --profile pdf --to pdf     (or: make examples-pdf)
#
# Why assemble rather than let Quarto collect the pages: a Quarto book insists
# its first chapter be a root-level index.qmd, which here is the site homepage,
# and the include shortcode pastes a page's YAML header into the body. So the
# series is concatenated here instead: each page's front matter becomes a
# chapter heading, and its internal .qmd links become absolute links to the
# live site, which is the only thing they can usefully mean inside a PDF.
#
# The order is scripts/examples-series.R, the same order the companion scripts
# and the section index use. Pages that do not exist yet are skipped, so the
# PDF is index-only until the first example page ships.
#
# The assembled file lives in _pdf-src/, whose leading underscore keeps Quarto
# from rendering it into the website. Both _pdf-src/ and the _pdf/ output are
# gitignored build artifacts; never edit the assembled file.

project_dir = Sys.getenv("QUARTO_PROJECT_DIR", unset = ".")
source(file.path(project_dir, "scripts", "examples-series.R"))

TITLE = "The bgms worked analyses"
out_dir = file.path(project_dir, "_pdf-src")
out_file = file.path(out_dir, "worked-analyses.qmd")

# Canonical site URL, read from _quarto.yml so there is one source of truth
# (same idiom as scripts/redirects.R).
site_url = "https://bayesian-graphical-modelling-lab.github.io/bgms"
quarto_yml = file.path(project_dir, "_quarto.yml")
if(file.exists(quarto_yml)) {
  hit = grep("^\\s*site-url:", readLines(quarto_yml, warn = FALSE), value = TRUE)
  if(length(hit) == 1L) {
    site_url = sub("/$", "", gsub("^[\"']|[\"']$", "",
                                 trimws(sub("^\\s*site-url:\\s*", "", hit[1]))))
  }
}

split_front_matter = function(lines) {
  if(length(lines) == 0 || !grepl("^---\\s*$", lines[1])) {
    return(list(yaml = character(0), body = lines))
  }
  close = which(grepl("^---\\s*$", lines))[2]
  list(yaml = lines[2:(close - 1)], body = lines[-seq_len(close)])
}

yaml_field = function(yaml, field) {
  hit = grep(sprintf("^%s:", field), yaml, value = TRUE)
  if(length(hit) == 0) return(NA_character_)
  gsub("^[\"']|[\"']$", "", trimws(sub(sprintf("^%s:", field), "", hit[1])))
}

# Lexical path normalization: the link targets need not exist yet, so this
# cannot go through normalizePath().
collapse_path = function(path) {
  out = character(0)
  for(part in strsplit(path, "/", fixed = TRUE)[[1]]) {
    if(part %in% c("", ".")) next
    if(part == ".." && length(out) > 0 && utils::tail(out, 1) != "..") {
      out = utils::head(out, -1)
    } else {
      out = c(out, part)
    }
  }
  paste(out, collapse = "/")
}

# A link to ../guide/ggm.qmd#sec-x, written on a page in examples/, means the
# live site's guide/ggm.html#sec-x once that page is inside a PDF.
absolutize_links = function(body, page_dir) {
  pattern = "\\]\\(([^)]*\\.qmd(#[^)]*)?)\\)"
  hits = gregexpr(pattern, body, perl = TRUE)
  regmatches(body, hits) = lapply(regmatches(body, hits), function(links) {
    vapply(links, function(link) {
      target = sub(pattern, "\\1", link)
      path = sub("#.*$", "", target)
      fragment = if(grepl("#", target, fixed = TRUE)) {
        sub("^[^#]*", "", target)
      } else ""
      html = sub("[.]qmd$", ".html", collapse_path(file.path(page_dir, path)))
      sprintf("](%s/%s%s)", site_url, html, fragment)
    }, character(1), USE.NAMES = FALSE)
  })
  body
}

chapter = function(page) {
  parts = split_front_matter(readLines(file.path(project_dir, page),
                                       warn = FALSE))
  title = yaml_field(parts$yaml, "title")
  if(is.na(title)) stop("no title in front matter: ", page)
  c(sprintf("# %s", title), "",
    absolutize_links(parts$body, dirname(page)), "")
}

slugs = series_pages(project_dir)
pages = c("examples/index.qmd",
          if(length(slugs) > 0) file.path("examples", paste0(slugs, ".qmd")))

front_matter = c(
  "---",
  sprintf('title: "%s"', TITLE),
  'subtitle: "Worked analyses from the bgms documentation"',
  sprintf('# Assembled by scripts/build-examples-pdf.R from: %s',
          paste(pages, collapse = ", ")),
  "---",
  ""
)

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
writeLines(c(front_matter, unlist(lapply(pages, chapter))), out_file)

cat(sprintf("examples pdf: assembled %d page%s into %s\n",
            length(pages), if(length(pages) == 1L) "" else "s", out_file))
