# ==============================================================================
# The machine and software record. Every timing in the results table is a fact
# about this machine and these builds and is worthless without it.
#
#   BENCH_DIR=<scratch root> Rscript env.R
# ==============================================================================

BENCH = Sys.getenv("BENCH_DIR")
stopifnot(nzchar(BENCH))
.libPaths(c(file.path(BENCH, "lib"), .libPaths()))

si = sessionInfo()
rec = list(
  cpu = system("sysctl -n machdep.cpu.brand_string", intern = TRUE),
  cores_total = parallel::detectCores(),
  cores_performance = as.integer(system("sysctl -n hw.perflevel0.logicalcpu",
                                        intern = TRUE)),
  cores_efficiency = as.integer(system("sysctl -n hw.perflevel1.logicalcpu",
                                       intern = TRUE)),
  os = paste(Sys.info()[["sysname"]], Sys.info()[["release"]]),
  macos = system("sw_vers -productVersion", intern = TRUE),
  r_version = R.version.string,
  platform = R.version$platform,
  blas = si$BLAS,
  lapack = si$LAPACK,
  bgms = as.character(utils::packageVersion("bgms")),
  bgms_lib = find.package("bgms"),
  bgms_built = read.dcf(file.path(find.package("bgms"), "DESCRIPTION"),
                        fields = "Built")[1, 1],
  modelSelection = as.character(utils::packageVersion("modelSelection")),
  modelSelection_lib = find.package("modelSelection"),
  ssgraph = as.character(utils::packageVersion("ssgraph")),
  ssgraph_lib = find.package("ssgraph"),
  BDgraph = as.character(utils::packageVersion("BDgraph")),
  date = as.character(Sys.Date())
)
saveRDS(rec, file.path(BENCH, "out", "environment.rds"), version = 2)
str(rec)
