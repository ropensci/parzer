# Performance regression guards
#
# These tests use the `bench` package (listed in Suggests) and are skipped
# on CRAN.  They verify three properties:
#
#   1. Absolute floor  – a given input size must complete within a generous
#                        wall-clock budget (catches catastrophic regressions).
#   2. Linear scaling  – per-item time must not grow more than 3× when input
#                        size increases 10× (catches O(n²) regressions).
#   3. Bounded memory  – bytes allocated per item must stay below a ceiling
#                        (catches memory-leak regressions).
#
# Thresholds are intentionally loose (10–100× typical performance) so that
# slow CI runners and debug builds never trigger false positives.

# ---------------------------------------------------------------------------
# Shared fixtures
# ---------------------------------------------------------------------------

bench_lats <- c(
  "40.4183318N", "-45.23323",   "N40 25 5.994",
  "40:25:5.994N", "40d 25' 6\" N", "45N54.2356"
)
bench_lons <- c(
  "74.6411133W", "-120.5",       "E74 38 28.008",
  "74:38:28W",   "74d 38' 28\" W", "45W54.2356"
)

# n=96 (6 patterns × 16) and n=960 (6 patterns × 160) for 10× ratio
lats_96  <- rep(bench_lats, 16L)
lats_960 <- rep(bench_lats, 160L)
lons_96  <- rep(bench_lons, 16L)
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
    iterations = 10L, check = FALSE
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
    n96  = parse_lat(lats_96),
    n960 = parse_lat(lats_960),
    iterations = 10L, check = FALSE
  )
  ratio <- .scaling_ratio(bm)
  expect_lt(
    ratio, 3,
    label = sprintf("parse_lat per-item scaling ratio = %.2f (must be < 3)", ratio)
  )
})

test_that("parse_lon scales near-linearly (n=96 to n=960)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(
    n96  = parse_lon(lons_96),
    n960 = parse_lon(lons_960),
    iterations = 10L, check = FALSE
  )
  ratio <- .scaling_ratio(bm)
  expect_lt(
    ratio, 3,
    label = sprintf("parse_lon per-item scaling ratio = %.2f (must be < 3)", ratio)
  )
})

test_that("parse_parts_lat scales near-linearly (n=96 to n=960)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(
    n96  = parse_parts_lat(lats_96),
    n960 = parse_parts_lat(lats_960),
    iterations = 10L, check = FALSE
  )
  ratio <- .scaling_ratio(bm)
  expect_lt(
    ratio, 3,
    label = sprintf("parse_parts_lat per-item scaling ratio = %.2f (must be < 3)", ratio)
  )
})

# ---------------------------------------------------------------------------
# 3. Bounded memory allocation per item
#
# bench::mark() mem_alloc reports total bytes allocated in one expression
# evaluation.  Threshold of 10 kB/item is ~10–100× typical; it catches
# any regression that introduces per-item heap growth (e.g. temporary lists
# or unnecessary copies).
# ---------------------------------------------------------------------------

test_that("parse_lat allocates < 10 kB per item (960 items)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_lat(lats_960), iterations = 5L, check = FALSE)
  bytes_per_item <- as.numeric(bm$mem_alloc[[1L]]) / 960
  expect_lt(
    bytes_per_item, 10000,
    label = sprintf("parse_lat bytes/item = %.1f (must be < 10 000)", bytes_per_item)
  )
})

test_that("parse_lon allocates < 10 kB per item (960 items)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_lon(lons_960), iterations = 5L, check = FALSE)
  bytes_per_item <- as.numeric(bm$mem_alloc[[1L]]) / 960
  expect_lt(
    bytes_per_item, 10000,
    label = sprintf("parse_lon bytes/item = %.1f (must be < 10 000)", bytes_per_item)
  )
})

test_that("parse_parts_lat allocates < 10 kB per item (960 items)", {
  skip_on_cran()
  skip_if_not_installed("bench")

  bm <- bench::mark(parse_parts_lat(lats_960), iterations = 5L, check = FALSE)
  bytes_per_item <- as.numeric(bm$mem_alloc[[1L]]) / 960
  expect_lt(
    bytes_per_item, 10000,
    label = sprintf("parse_parts_lat bytes/item = %.1f (must be < 10 000)", bytes_per_item)
  )
})
