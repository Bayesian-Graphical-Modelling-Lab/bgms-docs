# Marks a development build as a development build.
#
# This script runs as a project `post-render` step and does nothing unless
# BGMS_DOC_CHANNEL is "dev" (see scripts/doc-build.R). For a development build
# it walks the render output and gives every page:
#
#   - a banner naming the build and linking the released documentation,
#   - <meta name="robots" content="noindex">, so search traffic collects on
#     the release docs instead of splitting between two copies of every page,
#   - <link rel="canonical"> pointing at the same page under the site root.
#
# It runs after scripts/redirects.R, so the pkgdown redirect stubs are marked
# too. They already carry a canonical tag of their own and get only the robots
# tag; the banner goes to real pages, which are the ones a reader lands on.
#
# The release build must leave the published HTML exactly as it is today, so
# none of this is conditional inside the page sources: nothing is added to a
# release render at all.

project_dir = Sys.getenv("QUARTO_PROJECT_DIR", unset = ".")
out_dir = Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", unset = "docs")

source(file.path(project_dir, "scripts", "doc-build.R"))

if(basename(out_dir) != "docs") {
  cat("dev-build: output directory is", out_dir,
      "- not the website render, nothing marked\n")
  quit(save = "no")
}

if(!doc_is_dev()) {
  cat("dev-build: release build, nothing marked\n")
  quit(save = "no")
}

site_url = doc_site_url(project_dir)

banner = paste0(
  '<div class="bgms-dev-banner" id="bgms-dev-banner" role="note">',
  '<span class="bgms-dev-banner-text">',
  'Development version of the bgms documentation. ',
  'The latest release is at ',
  sprintf('<a href="%s/">%s/</a>.', site_url, sub("^[a-z]+://", "", site_url)),
  '</span>',
  '<button type="button" class="bgms-dev-banner-dismiss" ',
  'aria-label="Dismiss this notice">&times;</button>',
  '</div>')

robots = '<meta name="robots" content="noindex">'

read_file = function(path) {
  readChar(path, file.size(path), useBytes = TRUE)
}

write_file = function(path, text) {
  con = file(path, open = "wb")
  on.exit(close(con))
  writeChar(text, con, eos = NULL, useBytes = TRUE)
}

pages = list.files(out_dir, pattern = "\\.html$", recursive = TRUE)

marked = 0L
bannered = 0L
skipped = character(0)

for(page in pages) {
  path = file.path(out_dir, page)
  html = read_file(path)

  if(!grepl("</head>", html, fixed = TRUE, useBytes = TRUE)) {
    skipped = c(skipped, page)
    next
  }

  head_additions = robots
  # The redirect stubs already point at the page that owns their material;
  # a second canonical tag would contradict the first.
  if(!grepl('rel="canonical"', html, fixed = TRUE, useBytes = TRUE)) {
    head_additions = paste0(
      head_additions,
      sprintf('<link rel="canonical" href="%s/%s">', site_url, page))
  }

  html = sub("</head>", paste0(head_additions, "</head>"), html,
             fixed = TRUE, useBytes = TRUE)
  marked = marked + 1L

  # Quarto's own pages carry a class list on <body>; the redirect stubs do not,
  # and have no chrome for a banner to sit above.
  if(grepl('<body class="', html, fixed = TRUE, useBytes = TRUE)) {
    html = sub('<body class="', '<body class="bgms-dev-build ', html,
               fixed = TRUE, useBytes = TRUE)
    html = sub('(<body class="[^"]*">)', paste0("\\1", banner), html,
               useBytes = TRUE)
    bannered = bannered + 1L
  }

  write_file(path, html)
}

# The sitemap and robots.txt name the site root's URLs, which this build is not.
# Only the root copy of either has any standing, so the development build ships
# neither.
for(stray in c("sitemap.xml", "robots.txt")) {
  path = file.path(out_dir, stray)
  if(file.exists(path)) {
    unlink(path)
  }
}

cat(sprintf(paste0("dev-build: marked %d pages noindex (%d with the ",
                   "development banner), dropped sitemap.xml and robots.txt\n"),
            marked, bannered))

if(length(skipped) > 0) {
  warning("dev-build: no </head> to mark in: ",
          paste(skipped, collapse = ", "), call. = FALSE)
}
