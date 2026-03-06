# parse_hemisphere

test_that("parse_hemisphere works", {
  # NE
  ne <- parse_hemisphere("74.123E", "45N54.2356")
  # NW
  nw <- parse_hemisphere("-120", "40.4183318")
  # SW
  sw <- parse_hemisphere("-120", "-40.4183318")
  # SE
  se <- parse_hemisphere("120", "-40.4183318")

  for (i in c(ne, nw, sw, se)) expect_type(i, "character")
  for (i in c(ne, nw, sw, se)) expect_equal(nchar(i), 2)

  # bad values
  ## one
  expect_equal(
    suppressWarnings(parse_hemisphere("120", "-240.4183318")),
    "E"
  )
  expect_equal(
    suppressWarnings(parse_hemisphere("420", "-40.4183318")),
    "S"
  )
  ## both
  expect_equal(
    suppressWarnings(parse_hemisphere("-200", "-240.4183318")),
    ""
  )
})

test_that("parse_hemisphere accepts numeric and integer inputs", {
  expect_equal(parse_hemisphere(-120, 40.4183318), parse_hemisphere("-120", "40.4183318"))
  expect_equal(parse_hemisphere(-120L, 40L), parse_hemisphere("-120", "40"))
})

test_that("parse_hemisphere correctly handles negative zero longitude", {
  # -0.0 carries a negative sign bit; std::signbit(-0.0) == true so it should
  # be classified as West, matching the behaviour of the previous string-based
  # is_negative(std::to_string(-0.0)) check which also returned true.
  expect_equal(parse_hemisphere("-0", "45"), "NW")
  expect_equal(parse_hemisphere("-0", "-45"), "SW")
})

test_that("parse_hemisphere - fails well", {
  expect_error(parse_hemisphere(), "argument \"lon\" is missing")
  expect_error(parse_hemisphere(""), "argument \"lat\" is missing")
  expect_error(parse_hemisphere(mtcars), "lon must be of class")
  expect_error(parse_hemisphere("", mtcars), "lat must be of class")

  expect_warning(parse_hemisphere("45", "190"), "not within -90")
  expect_warning(parse_hemisphere("45", "190"), "check that you did not invert")
  expect_warning(
    parse_hemisphere("190", "45"),
    "longitude value within 180/360 range, got: 190"
  )
})
