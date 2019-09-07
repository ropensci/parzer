context("parse_hemisphere")

test_that("parse_hemisphere works", {
  # NE
  ne <- parse_hemisphere("45N54.2356", "74.123E")
  # NW
  nw <- parse_hemisphere("40.4183318", "-120")
  # SW
  sw <- parse_hemisphere("-40.4183318", "-120")
  # SE
  se <- parse_hemisphere("-40.4183318", "120")

  for (i in c(ne, nw, sw, se)) expect_is(i, "character")
  for (i in c(ne, nw, sw, se)) expect_equal(nchar(i), 2)

  # bad values
  ## one
  expect_equal(
    suppressWarnings(parse_hemisphere("-240.4183318", "120")), "E")
  expect_equal(
    suppressWarnings(parse_hemisphere("-40.4183318", "420")), "S")
  ## both
  expect_equal(
    suppressWarnings(parse_hemisphere("-240.4183318", "-200")), "")
})

test_that("parse_hemisphere - fails well", {
  expect_error(parse_hemisphere(), "argument \"lat\" is missing")
  expect_error(parse_hemisphere(""), "argument \"lon\" is missing")
  expect_error(parse_hemisphere(mtcars), "lat must be of class")
  expect_error(parse_hemisphere("", mtcars), "lon must be of class")
})
