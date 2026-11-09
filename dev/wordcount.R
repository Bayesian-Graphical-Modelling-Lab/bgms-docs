# Prose word counts for the site's pages.
#
# Counts, for every .qmd outside manual/, dev/, docs/, _site/, _freeze/ and
# _pdf-src/, the words that sit outside fenced code blocks and outside the YAML
# header. A word is a whitespace-separated token with at least one letter or
# digit, so table rules, div fences and lone math delimiters do not count.
# Prints one row per page and a total per section (the top-level directory;
# pages at the root are "site").
#
# Information only, never a gate (COMMON.md, sufficiency, not length).
#
# Usage (from the repo root):
#   Rscript dev/wordcount.R              # print the table
#   Rscript dev/wordcount.R counts.csv   # also write page,section,words

args = commandArgs(trailingOnly = TRUE)

skip = "^(manual|dev|docs|_site|_freeze|_pdf-src|_pdf)/"
pages = list.files(".", pattern = "[.]qmd$", recursive = TRUE)
pages = sort(pages[!grepl(skip, pages)])

prose_words = function(path) {
  lines = readLines(path, warn = FALSE)

  # YAML header: the block between the first two `---` lines at the top.
  if(length(lines) > 0 && grepl("^---\\s*$", lines[1])) {
    close = which(grepl("^---\\s*$", lines))[2]
    if(!is.na(close)) lines = lines[-seq_len(close)]
  }

  # Fenced code blocks, ``` or ~~~, with or without a {r} header. A fence
  # closes on a line of the same character at least as long as its opener.
  keep = logical(length(lines))
  fence = NULL
  for(i in seq_along(lines)) {
    line = lines[i]
    if(is.null(fence)) {
      m = regmatches(line, regexpr("^\\s*(`{3,}|~{3,})", line))
      if(length(m) == 1L) {
        fence = trimws(m)
      } else {
        keep[i] = TRUE
      }
    } else if(grepl(sprintf("^\\s*%s+\\s*$", substr(fence, 1, 1)), line) &&
              nchar(trimws(line)) >= nchar(fence)) {
      fence = NULL
    }
  }

  tokens = unlist(strsplit(lines[keep], "\\s+"))
  sum(grepl("[[:alnum:]]", tokens))
}

section = ifelse(grepl("/", pages), sub("/.*$", "", pages), "site")
words = vapply(pages, prose_words, integer(1), USE.NAMES = FALSE)
counts = data.frame(page = pages, section = section, words = words)

cat(sprintf("%-42s %7s\n", "page", "words"))
for(s in unique(counts$section)) {
  rows = counts[counts$section == s, ]
  for(i in seq_len(nrow(rows))) {
    cat(sprintf("%-42s %7d\n", rows$page[i], rows$words[i]))
  }
  cat(sprintf("%-42s %7d\n\n", sprintf("  total %s (%d pages)", s, nrow(rows)),
              sum(rows$words)))
}
cat(sprintf("%-42s %7d\n", sprintf("total (%d pages)", nrow(counts)),
            sum(counts$words)))

if(length(args) >= 1L) {
  utils::write.csv(counts, args[1], row.names = FALSE)
}
