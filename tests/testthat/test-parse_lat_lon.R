context("parse_lat_lon")

test_that("parse_lat_lon works", {
  aa <- parse_lat_lon("45N54.2356", "45W54.2356")

  expect_is(aa, "data.frame")
  expect_equal(NCOL(aa), 2)
  expect_equal(NROW(aa), 1)
  expect_named(aa, c("lat", "lon"))
  expect_type(aa$lat, "double")
  expect_type(aa$lon, "double")
})

test_that("parse_lat_lon - fails well", {
  expect_error(parse_lat_lon(), "argument \"lat\" is missing")
  expect_error(parse_lat_lon(""), "argument \"lon\" is missing")
  expect_error(parse_lat_lon(mtcars), "lat must be of class")
  expect_error(parse_lat_lon("", mtcars), "lon must be of class")
  # expect_error(parse_lat_lon("", "", 5), "format must be of class character")
})
