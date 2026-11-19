# TEMPORARY: prints the speedup of the C++ scrub() over the old R scrub() on
# each CI platform, then this file is reverted. Inside R CMD check only.

# copy of the R scrub() before it moved to C++ (commit 8cc953a)
.scrub_r <- function(x) {
  x <- num_to_chr(x)
  x[is.na(x)] <- ""
  x <- gsub(
    pattern = "[\u2212\u2013\u2014]",
    replacement = "-",
    x = x,
    perl = TRUE
  )
  trimws(gsub(
    pattern = "[^A-Za-z0-9. ,'-]|[dgDG]",
    replacement = "'",
    x = x,
    perl = TRUE
  ))
}

speedup_lats <- rep(
  x = c(
    "40.4183318N",
    "-45.23323",
    "N40 25 5.994",
    "40:25:5.994N",
    "40d 25' 6\" N",
    "45N54.2356"
  ),
  length.out = 10000L
)
speedup_lons <- rep(
  x = c(
    "74.6411133W",
    "-120.5",
    "E74 38 28.008",
    "74:38:28W",
    "74d 38' 28\" W",
    "45W54.2356"
  ),
  length.out = 10000L
)

# the new and the old way to run each function
speedup_cases <- list(
  parse_lat = list(
    new = function() parse_lat(speedup_lats),
    old = function() pz_parse_lat(.scrub_r(speedup_lats))
  ),
  parse_lon = list(
    new = function() parse_lon(speedup_lons),
    old = function() pz_parse_lon(.scrub_r(speedup_lons))
  ),
  parse_parts_lat = list(
    new = function() parse_parts_lat(speedup_lats),
    old = function() pz_parse_parts_lat(.scrub_r(speedup_lats))
  )
)

for (fn in names(speedup_cases)) {
  case <- speedup_cases[[fn]]
  test_that(sprintf(fmt = "%s: speedup of the C++ scrub() (10k strings)", fn), {
    skip_on_cran()
    skip_if_not_installed(pkg = "bench")
    skip_if_not(
      condition = testthat::is_checking(),
      message = "only inside R CMD check (installed, optimised build)"
    )

    bm <- bench::mark(
      case[["old"]](),
      case[["new"]](),
      iterations = 20L,
      check = FALSE
    )
    old <- as.numeric(median(bm$time[[1L]]))
    new <- as.numeric(median(bm$time[[2L]]))
    cat(
      sprintf("PARZER_SCRUB %s speedup %.3f\n", fn, old / new),
      file = stderr()
    )
    expect_gt(object = old / new, expected = 0)
  })
}
