# Performance regression guards
#
# These tests use the `bench` package (listed in Suggests) and are skipped
# on CRAN. They verify four properties:
#
#   1. Absolute floor  - a given input size must complete within a generous
#                        wall-clock budget (catches catastrophic regressions).
#   2. Linear scaling  - per-item time must not grow more than 3× when input
#                        size increases 10× (catches O(n²) regressions).
#   3. Bounded memory  - R heap bytes allocated per item must stay below a
#                        ceiling (catches extra R copies; blind to C++
#                        allocations and leaks).
#   4. Relative speed  - time of parzer divided by the time of a base R
#                        baseline, measured in the same run, must stay below
#                        a ceiling (catches moderate slowdowns, e.g.
#                        std::regex coming back). Installed builds only.
#
# Thresholds of 1-3 are intentionally loose: the 2 s floor is about 10 000
# times the measured time for 96 strings (about 0.1 ms with -O2), so slow CI
# runners and -O0 debug builds never trigger false positives. They only catch
# catastrophic regressions; compare timings with benchmarks/compare_with_ref.R.
# Test 4 does not depend on machine speed, so its limit is much tighter.

# ---------------------------------------------------------------------------
# Shared fixtures
# ---------------------------------------------------------------------------

bench_lats <- c(
  "40.4183318N",
  "-45.23323",
  "N40 25 5.994",
  "40:25:5.994N",
  "40d 25' 6\" N",
  "45N54.2356"
)
bench_lons <- c(
  "74.6411133W",
  "-120.5",
  "E74 38 28.008",
  "74:38:28W",
  "74d 38' 28\" W",
  "45W54.2356"
)

# n=96 (6 patterns × 16) and n=960 (6 patterns × 160) for 10× ratio
lats_96 <- rep(bench_lats, 16L)
lats_960 <- rep(bench_lats, 160L)
lons_96 <- rep(bench_lons, 16L)
lons_960 <- rep(bench_lons, 160L)

# ---------------------------------------------------------------------------
# 1. Absolute throughput floor
# ---------------------------------------------------------------------------

test_that("parse_lat absolute floor: 96 strings in < 2 s", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_lat(lats_96), iterations = 10L, check = FALSE)
  expect_lt(
    as.numeric(median(bm$time[[1L]])),
    2.0,
    label = "parse_lat(96) median wall time (s)"
  )
})

test_that("parse_lon absolute floor: 96 strings in < 2 s", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_lon(lons_96), iterations = 10L, check = FALSE)
  expect_lt(
    as.numeric(median(bm$time[[1L]])),
    2.0,
    label = "parse_lon(96) median wall time (s)"
  )
})

test_that("parse_parts_lat absolute floor: 96 strings in < 2 s", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_parts_lat(lats_96), iterations = 10L, check = FALSE)
  expect_lt(
    as.numeric(median(bm$time[[1L]])),
    2.0,
    label = "parse_parts_lat(96) median wall time (s)"
  )
})

test_that("parse_llstr absolute floor: 96 strings in < 2 s", {
  skip_on_cran()
  skip_if_not_installed("bench")

  llstrs_96 <- paste(lats_96, lons_96, sep = ", ")
  bm <- bench::mark(
    suppressWarnings(parse_llstr(llstrs_96)),
    iterations = 10L,
    check = FALSE
  )
  expect_lt(
    as.numeric(median(bm$time[[1L]])),
    2.0,
    label = "parse_llstr(96) median wall time (s)"
  )
})

# ---------------------------------------------------------------------------
# 2. Near-linear O(n) scaling  (n=96 → n=960, i.e. 10× more items)
#
# per_item_ratio = (t_large/960) / (t_small/96) = (t_large/t_small) / 10
#   linear O(n)  → ratio ≈ 1
#   quadratic    → ratio ≈ 10  → FAIL
# Threshold 3 allows generous constant-factor variance while catching
# any super-linear regression.
# ---------------------------------------------------------------------------

.scaling_ratio <- function(bm) {
  t_small <- as.numeric(median(bm$time[[1L]]))
  t_large <- as.numeric(median(bm$time[[2L]]))
  (t_large / 960) / (t_small / 96)
}

test_that("parse_lat scales near-linearly (n=96 to n=960)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(
    n96 = parse_lat(lats_96),
    n960 = parse_lat(lats_960),
    iterations = 10L,
    check = FALSE
  )
  ratio <- .scaling_ratio(bm)
  expect_lt(
    ratio,
    3,
    label = sprintf(
      "parse_lat per-item scaling ratio = %.2f (must be < 3)",
      ratio
    )
  )
})

test_that("parse_lon scales near-linearly (n=96 to n=960)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(
    n96 = parse_lon(lons_96),
    n960 = parse_lon(lons_960),
    iterations = 10L,
    check = FALSE
  )
  ratio <- .scaling_ratio(bm)
  expect_lt(
    ratio,
    3,
    label = sprintf(
      "parse_lon per-item scaling ratio = %.2f (must be < 3)",
      ratio
    )
  )
})

test_that("parse_parts_lat scales near-linearly (n=96 to n=960)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(
    n96 = parse_parts_lat(lats_96),
    n960 = parse_parts_lat(lats_960),
    iterations = 10L,
    check = FALSE
  )
  ratio <- .scaling_ratio(bm)
  expect_lt(
    ratio,
    3,
    label = sprintf(
      "parse_parts_lat per-item scaling ratio = %.2f (must be < 3)",
      ratio
    )
  )
})

# ---------------------------------------------------------------------------
# 3. Bounded memory allocation per item
#
# bench::mark() mem_alloc reports total R heap bytes allocated in one
# expression evaluation (via Rprofmem). Threshold of 10 kB/item is ~10-100×
# typical; it catches any regression that introduces per-item R heap growth
# (e.g. temporary lists or unnecessary copies).
#
# It does not see C++ allocations (std::string, std::regex, std::vector) and
# cannot detect leaks. The C++ code currently uses only RAII containers, so
# leaks are unlikely; run the tests under ASan or valgrind to check for them.
# ---------------------------------------------------------------------------

test_that("parse_lat allocates < 10 kB per item (960 items)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_lat(lats_960), iterations = 5L, check = FALSE)
  bytes_per_item <- as.numeric(bm$mem_alloc[[1L]]) / 960
  expect_lt(
    bytes_per_item,
    10000,
    label = sprintf(
      "parse_lat bytes/item = %.1f (must be < 10 000)",
      bytes_per_item
    )
  )
})

test_that("parse_lon allocates < 10 kB per item (960 items)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_lon(lons_960), iterations = 5L, check = FALSE)
  bytes_per_item <- as.numeric(bm$mem_alloc[[1L]]) / 960
  expect_lt(
    bytes_per_item,
    10000,
    label = sprintf(
      "parse_lon bytes/item = %.1f (must be < 10 000)",
      bytes_per_item
    )
  )
})

test_that("parse_parts_lat allocates < 10 kB per item (960 items)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_parts_lat(lats_960), iterations = 5L, check = FALSE)
  bytes_per_item <- as.numeric(bm$mem_alloc[[1L]]) / 960
  expect_lt(
    bytes_per_item,
    10000,
    label = sprintf(
      "parse_parts_lat bytes/item = %.1f (must be < 10 000)",
      bytes_per_item
    )
  )
})

# ---------------------------------------------------------------------------
# 4. Relative speed against a base R baseline
#
# The tests above only catch large slowdowns. These ones divide the median
# time of parzer on 10 000 strings by the median time of
# gsub("[^0-9A-Za-z.]", "'", x) on the same strings, measured in the same run.
# The ratio depends much less on the machine than a time does, but it still
# varies between platforms.
#
# Ratios measured on 2026-11-19 (CI on draft PR #63, R CMD check, -O2):
#                          parse_lat  parse_lon  parse_llstr
#   local macOS arm64         1.53       1.58       2.37
#   CI macOS                  1.59       2.06       3.03
#   CI Ubuntu (3 R versions)  2.7-3.0    2.8-3.1    4.2-4.6
#   CI Windows                3.86       3.85       5.03
#   std::regex (aacd37b, local macOS)
#                             20         25-26      33-34
# Each limit is 1.5 times the worst platform (Windows), rounded: it catches a
# slowdown of about 1.6x on Windows and 3.4x or more on macOS, and the return
# of std::regex everywhere.
#
# A package loaded with devtools::test() (pkgload::load_all()) is compiled at
# -O0 and runs about 7x slower, so these tests only run inside R CMD check
# (testthat::is_checking()), on the installed package.
# ---------------------------------------------------------------------------

bench_ratio_max <- c(parse_lat = 6, parse_lon = 6, parse_llstr = 8)

.relative_time <- function(f, baseline) {
  bm <- bench::mark(f(), baseline(), iterations = 20L, check = FALSE)
  as.numeric(median(bm$time[[1L]])) / as.numeric(median(bm$time[[2L]]))
}

.base_r_baseline <- function(x) {
  function() gsub("[^0-9A-Za-z.]", "'", x)
}

lats_10k <- rep(bench_lats, length.out = 10000L)
lons_10k <- rep(bench_lons, length.out = 10000L)
llstrs_10k <- paste(lats_10k, lons_10k, sep = ", ")

test_that("parse_lat stays within 6x the time of gsub (10k strings)", {
  skip_on_cran()
  skip_if_not_installed("bench")
  skip_if_not(
    testthat::is_checking(),
    "only inside R CMD check (installed, optimised build)"
  )

  ratio <- .relative_time(
    f = function() parse_lat(lats_10k),
    baseline = .base_r_baseline(lats_10k)
  )
  expect_lt(
    ratio,
    bench_ratio_max[["parse_lat"]],
    label = sprintf("parse_lat / gsub time ratio = %.2f", ratio)
  )
})

test_that("parse_lon stays within 6x the time of gsub (10k strings)", {
  skip_on_cran()
  skip_if_not_installed("bench")
  skip_if_not(
    testthat::is_checking(),
    "only inside R CMD check (installed, optimised build)"
  )

  ratio <- .relative_time(
    f = function() parse_lon(lons_10k),
    baseline = .base_r_baseline(lons_10k)
  )
  expect_lt(
    ratio,
    bench_ratio_max[["parse_lon"]],
    label = sprintf("parse_lon / gsub time ratio = %.2f", ratio)
  )
})

test_that("parse_llstr stays within 8x the time of gsub (10k strings)", {
  skip_on_cran()
  skip_if_not_installed("bench")
  skip_if_not(
    testthat::is_checking(),
    "only inside R CMD check (installed, optimised build)"
  )

  ratio <- .relative_time(
    f = function() parse_llstr(llstrs_10k),
    baseline = .base_r_baseline(llstrs_10k)
  )
  expect_lt(
    ratio,
    bench_ratio_max[["parse_llstr"]],
    label = sprintf("parse_llstr / gsub time ratio = %.2f", ratio)
  )
})
