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

  for (i in c(ne, nw, sw, se)) {
    expect_type(i, "character")
  }
  for (i in c(ne, nw, sw, se)) {
    expect_equal(nchar(i), 2)
  }

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
  expect_equal(
    parse_hemisphere(-120, 40.4183318),
    parse_hemisphere("-120", "40.4183318")
  )
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

test_that("parse_hemisphere scrubs symbols and handles tiny numbers", {
  expect_equal(parse_hemisphere("40°25'W", "40°25'S"), "SW")
  expect_equal(parse_hemisphere("40d 25’ 6\" E", "40:25:6N"), "NE")
  expect_equal(parse_hemisphere(1e-5, 1e-5), "NE")
  expect_equal(parse_hemisphere(-1e-5, -1e-5), "SW")
  expect_warning(
    res <- parse_hemisphere(c(1e-5, NA), c(-2e-5, 10)),
    "no digits detected"
  )
  expect_equal(res, c("SE", "N"))
})
