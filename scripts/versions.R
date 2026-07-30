# The version index the navbar switcher reads.
#
# This script runs as a project `post-render` step and writes versions.json to
# the site root. Only the release build writes it: the file describes the whole
# documentation family, and only the build that owns the root can speak for the
# family. The development build at /bgms/dev/ reads the root copy one directory
# up (see the switcher in js.html), and archived releases will do the same.
#
# The file it writes:
#
#   {
#     "root": "/bgms/",
#     "versions": [
#       {"version": "0.2.0.0",     "kind": "release",     "path": "/bgms/"},
#       {"version": "development", "kind": "development", "path": "/bgms/dev/"}
#     ]
#   }
#
# The release version string comes from the installed bgms DESCRIPTION, never
# from prose here; see scripts/doc-build.R.
#
# Adding an archived release is one line. On release day, after the outgoing
# release has been copied to /vX.Y.Z/ on the gh-pages branch, add its version
# string to ARCHIVED below. README.md § Deployment holds the full recipe.

project_dir = Sys.getenv("QUARTO_PROJECT_DIR", unset = ".")
out_dir = Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", unset = "docs")

source(file.path(project_dir, "scripts", "doc-build.R"))

# --- Archived releases, newest first ----------------------------------------
# Each entry is a version string; its documentation lives at <root>vX.Y.Z/.
# Archiving starts with the release *after* 0.2.0.0, so this list is empty
# until then.

ARCHIVED = character(0)

# ----------------------------------------------------------------------------

# The stubs and this index describe the website's URL layout, so they belong to
# a render that produces the website. The pdf profile renders the Examples
# series into _pdf/ and must not collect a version index on the way.
if(basename(out_dir) != "docs") {
  cat("versions: output directory is", out_dir,
      "- not the website render, no version index written\n")
  quit(save = "no")
}

if(doc_is_dev()) {
  cat("versions: development build, the root build owns versions.json\n")
  quit(save = "no")
}

root = doc_site_root_path()

entries = list(
  list(version = doc_version(), kind = "release", path = root),
  list(version = "development", kind = "development",
       path = paste0(root, DOC_DEV_DIR, "/"))
)
for(version in ARCHIVED) {
  entries[[length(entries) + 1L]] =
    list(version = version, kind = "archive",
         path = paste0(root, "v", version, "/"))
}

# Small enough to write by hand, and writing it by hand keeps the render free
# of a JSON dependency the CI image does not otherwise need.
json_string = function(x) {
  paste0('"', gsub('"', '\\\\"', gsub('\\\\', '\\\\\\\\', x)), '"')
}

entry_json = function(entry) {
  sprintf('    {"version": %s, "kind": %s, "path": %s}',
          json_string(entry$version), json_string(entry$kind),
          json_string(entry$path))
}

json = paste0(
  "{\n",
  '  "_comment": ',
  json_string(paste(
    "Written by scripts/versions.R during the release render; do not edit.",
    "Every documented version of bgms, newest first.",
    "Add an archived release by adding its version string to ARCHIVED in",
    "that script."
  )), ",\n",
  '  "root": ', json_string(root), ",\n",
  '  "versions": [\n',
  paste(vapply(entries, entry_json, character(1)), collapse = ",\n"), "\n",
  "  ]\n",
  "}\n"
)

dest = file.path(out_dir, "versions.json")
writeLines(json, dest, useBytes = TRUE)

cat(sprintf("versions: wrote %s with %d entries (%s)\n", dest, length(entries),
            paste(vapply(entries, function(e) e$version, character(1)),
                  collapse = ", ")))
