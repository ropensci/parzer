# parse_parts_lat

test_that("parse_parts_lat works", {
  aa <- parse_parts_lat("45N54.2356")

  expect_type(aa, "list")
  expect_type(aa$deg, "integer")
  expect_type(aa$min, "integer")
  expect_type(aa$sec, "double")

  expect_equal(NROW(aa), 1)

  expect_equal(aa$deg, 45)
  expect_equal(aa$min, 54)
  expect_equal(round(aa$sec, 2), 14.14)
})

test_that("parse_parts_lat - fails well", {
  expect_error(parse_parts_lat(), "argument \"str\" is missing")
  expect_error(parse_parts_lat(mtcars), "str must be of class")
})

test_that("parse_parts_lat correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_parts_lat(c("45N54.30", NA_character_, "45N54.30"))
    ),
    data.frame(
      deg = c(45, NA_integer_, 45),
      min = c(54, NA_integer_, 54),
      sec = c(18, NA_real_, 18)
    )
  )
})


test_that("parse_parts_lon works", {
  aa <- parse_parts_lon("45W54.2356")

  expect_type(aa, "list")
  expect_type(aa$deg, "integer")
  expect_type(aa$min, "integer")
  expect_type(aa$sec, "double")

  expect_equal(NROW(aa), 1)

  expect_equal(aa$deg, -45)
  expect_equal(aa$min, 54)
  expect_equal(round(aa$sec, 2), 14.14)
})

test_that("parse_parts_lon - fails well", {
  expect_error(parse_parts_lon(), "argument \"str\" is missing")
  expect_error(parse_parts_lon(mtcars), "str must be of class")
})

test_that("parse_parts_lon correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_parts_lon(c("45W54.30", NA_character_, "45W54.30"))
    ),
    data.frame(
      deg = c(-45, NA_integer_, -45),
      min = c(54, NA_integer_, 54),
      sec = c(18, NA_real_, 18)
    )
  )
})

test_that("parse_parts_lat/lon return NA_integer_ in deg/min for invalid inputs", {
  # Previously, convert_lat/lon returning NA_REAL was passed to split_decimal_degree
  # which returned NA_REAL, then cast to int (UB). Now NA is detected first and
  # NA_INTEGER is set directly.
  lat_na <- suppressWarnings(parse_parts_lat(c("blablabla", "W60.1")))
  expect_equal(lat_na$deg, c(NA_integer_, NA_integer_))
  expect_equal(lat_na$min, c(NA_integer_, NA_integer_))
  expect_equal(lat_na$sec, c(NA_real_, NA_real_))

  lon_na <- suppressWarnings(parse_parts_lon(c("blablabla", "N60.1")))
  expect_equal(lon_na$deg, c(NA_integer_, NA_integer_))
  expect_equal(lon_na$min, c(NA_integer_, NA_integer_))
  expect_equal(lon_na$sec, c(NA_real_, NA_real_))
})

# split_decimal_degree is [[Rcpp::export]]-ed but not called by any R-level wrapper;
# these tests exercise it directly (covers pz_parse_parts.cpp lines 15-21).
test_that("split_decimal_degree returns all-NA list for NaN input", {
  result <- split_decimal_degree(NaN)
  expect_length(result, 3)
  expect_true(all(vapply(result, is.na, logical(1))))
})

test_that("split_decimal_degree returns correct integer deg/min and double sec for a positive value", {
  result <- split_decimal_degree(40.41833)
  expect_type(result[[1]], "integer")
  expect_type(result[[2]], "integer")
  expect_type(result[[3]], "double")
  expect_equal(result[[1]], 40L)
  expect_equal(result[[2]], 25L)
  expect_true(result[[3]] >= 0 && result[[3]] < 60)
})

test_that("split_decimal_degree returns negative degree for a negative value", {
  result <- split_decimal_degree(-74.64111)
  expect_equal(result[[1]], -74L)
  expect_equal(result[[2]], 38L)
  expect_true(result[[3]] >= 0 && result[[3]] < 60)
})
