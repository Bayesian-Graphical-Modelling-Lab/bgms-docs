# What kind of documentation build is this?
#
# The site is deployed twice from one source tree:
#
#   release   .../bgms/      built from main, the documented CRAN release
#   dev       .../bgms/dev/  built from docs/develop, on every push
#
# One environment variable, BGMS_DOC_CHANNEL, decides everything that differs
# between the two: the version the citation picker prints, the version index
# the navbar switcher reads, and the development-build marking. Nothing else
# in the repository decides on its own; index.qmd, scripts/versions.R and
# scripts/dev-build.R all ask here.
#
# The version string is read from the installed bgms build, so it is never
# written down twice. The release deploy installs bgms from the package's main
# branch and the dev deploy from develop, and each render stamps the build it
# documents. BGMS_DOC_VERSION overrides that, for the rare render that has to
# claim a version other than the installed one.

# The channel: "release" or "dev". Unset means release, so a local render and
# a manual run behave like the published site.
doc_channel = function() {
  channel = tolower(trimws(Sys.getenv("BGMS_DOC_CHANNEL", unset = "release")))
  if(!channel %in% c("release", "dev")) {
    stop("BGMS_DOC_CHANNEL is \"", channel, "\"; it must be \"release\" or ",
         "\"dev\".", call. = FALSE)
  }
  channel
}

doc_is_dev = function() {
  doc_channel() == "dev"
}

# The version this render documents, read from the bgms build R will load.
doc_version = function() {
  pinned = trimws(Sys.getenv("BGMS_DOC_VERSION", unset = ""))
  if(nzchar(pinned)) {
    return(pinned)
  }
  version = tryCatch(as.character(utils::packageVersion("bgms")),
                     error = function(e) "")
  if(!nzchar(version)) {
    stop("no installed bgms to read a version from. Point R_LIBS at the build ",
         "this render documents (see the Makefile), or set BGMS_DOC_VERSION.",
         call. = FALSE)
  }
  version
}

# The subdirectory of the site root that the development build is published
# to. Archived releases will sit beside it as vX.Y.Z/; scripts/versions.R
# writes those entries and scripts/deploy-gh-pages.sh protects both.
DOC_DEV_DIR = "dev"

# The canonical site address, read from _quarto.yml so it is written once.
doc_site_url = function(project_dir = Sys.getenv("QUARTO_PROJECT_DIR",
                                                 unset = ".")) {
  quarto_yml = file.path(project_dir, "_quarto.yml")
  if(!file.exists(quarto_yml)) {
    stop("cannot read the site URL: no _quarto.yml at ", quarto_yml,
         call. = FALSE)
  }
  hit = grep("^\\s*site-url:", readLines(quarto_yml, warn = FALSE),
             value = TRUE)
  if(length(hit) != 1L) {
    stop("cannot read the site URL: _quarto.yml has ", length(hit),
         " site-url lines, expected exactly one.", call. = FALSE)
  }
  url = sub("^\\s*site-url:\\s*", "", hit[1])
  url = gsub("^[\"']|[\"']$", "", trimws(url))
  sub("/$", "", url)
}

# The site root as a server path with a trailing slash, "/bgms/". The version
# switcher works in these terms, because every version of the documentation
# lives under it.
doc_site_root_path = function(site_url = doc_site_url()) {
  path = sub("^[a-z]+://[^/]*", "", site_url)
  if(!nzchar(path)) {
    path = "/"
  }
  if(!grepl("/$", path)) {
    path = paste0(path, "/")
  }
  path
}
