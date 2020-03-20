context("parse_hemisphere")

test_that("parse_hemisphere works", {
  skip_on_cran()
  # NE
  ne <- parse_hemisphere("74.123E", "45N54.2356")
  # NW
  nw <- parse_hemisphere("-120", "40.4183318")
  # SW
  sw <- parse_hemisphere("-120", "-40.4183318")
  # SE
  se <- parse_hemisphere("120", "-40.4183318")

  for (i in c(ne, nw, sw, se)) expect_is(i, "character")
  for (i in c(ne, nw, sw, se)) expect_equal(nchar(i), 2)

  # bad values
  ## one
  expect_equal(
    suppressWarnings(parse_hemisphere("120", "-240.4183318")), "E")
  expect_equal(
    suppressWarnings(parse_hemisphere("420", "-40.4183318")), "S")
  ## both
  expect_equal(
    suppressWarnings(parse_hemisphere("-200", "-240.4183318")), "")
})

test_that("parse_hemisphere - fails well", {
  skip_on_cran()
  expect_error(parse_hemisphere(), "argument \"lon\" is missing")
  expect_error(parse_hemisphere(""), "argument \"lat\" is missing")
  expect_error(parse_hemisphere(mtcars), "lon must be of class")
  expect_error(parse_hemisphere("", mtcars), "lat must be of class")

  expect_warning(parse_hemisphere(45, 190), "not within -90")
  expect_warning(parse_hemisphere(45, 190), "check that you did not invert")
})
