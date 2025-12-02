# parse_lon_lat

test_that("parse_lon_lat works", {
  aa <- parse_lon_lat("45W54.2356", "45N54.2356")

  expect_type(aa, "list")
  expect_equal(NCOL(aa), 2)
  expect_equal(NROW(aa), 1)
  expect_named(aa, c("lon", "lat"))
  expect_type(aa$lat, "double")
  expect_type(aa$lon, "double")
})

test_that("parse_lon_lat - fails well", {
  expect_error(parse_lon_lat(), "argument \"lon\" is missing")
  expect_error(parse_lon_lat(""), "argument \"lat\" is missing")
  expect_error(parse_lon_lat(mtcars), "lon must be of class")
  expect_error(parse_lon_lat("", mtcars), "lat must be of class")

  # src/ error
  expect_warning(parse_lon_lat("45", "190"), "not within -90")
  expect_warning(parse_lon_lat("45", "190"), "check that you did not invert")
})


test_that("parse_lon_lat correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_lon_lat("S60.1", NA_character_)
    ),
    data.frame(lon = NA_real_, lat = NA_real_)
  )
  expect_equal(
    suppressWarnings(
      parse_lon_lat("12' 30'", NA_character_)
    ),
    data.frame(lon = 12.5, lat = NA_real_)
  )
  expect_equal(
    suppressWarnings(
      parse_lon_lat(NA_character_, "12' 30'")
    ),
    data.frame(lon = NA_real_, lat = 12.5)
  )
})
