context("parse_lon_lat")

test_that("parse_lon_lat works", {
  skip_on_cran()
  aa <- parse_lon_lat("45W54.2356", "45N54.2356")

  expect_is(aa, "data.frame")
  expect_equal(NCOL(aa), 2)
  expect_equal(NROW(aa), 1)
  expect_named(aa, c("lon", "lat"))
  expect_type(aa$lat, "double")
  expect_type(aa$lon, "double")
})

test_that("parse_lon_lat - fails well", {
  skip_on_cran()
  expect_error(parse_lon_lat(), "argument \"lon\" is missing")
  expect_error(parse_lon_lat(""), "argument \"lat\" is missing")
  expect_error(parse_lon_lat(mtcars), "lon must be of class")
  expect_error(parse_lon_lat("", mtcars), "lat must be of class")

  # src/ error
  expect_warning(parse_lon_lat(45, 190), "not within -90")
  expect_warning(parse_lon_lat(45, 190), "check that you did not invert")
})
