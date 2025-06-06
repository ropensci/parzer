# parse_llstr

test_that("parse_llstr works", {
  aa <- parse_llstr("45N54.2356,    45W54.2356")

  expect_type(aa, "list")
  expect_equal(NCOL(aa), 2)
  expect_equal(NROW(aa), 1)
  expect_named(aa, c("lat", "lon"))
  expect_type(aa$lat, "double")
  expect_type(aa$lon, "double")

  bb <- parse_llstr("45N54.2356 45W54.2356")

  expect_equal(aa, bb)
})

test_that("parse_llstr works with negative signs", {
  aa <- parse_llstr("45.542356,    -45.542356")

  expect_type(aa, "list")
  expect_equal(NCOL(aa), 2)
  expect_equal(NROW(aa), 1)
  expect_named(aa, c("lat", "lon"))
  expect_type(aa$lat, "double")
  expect_type(aa$lon, "double")

  bb <- parse_llstr("N45.542356,W45.542356")

  expect_equal(aa, bb)
})

test_that("parse_llstr - fails well", {
  expect_error(parse_llstr())
  expect_error(parse_llstr(mtcars), "str must be of class character")
  expect_error(parse_llstr("", mtcars))

  # src/ error
  expect_warning(parse_llstr("190, 45"), "not within -90")
  expect_warning(parse_llstr("190, 45"), "check that you did not invert")
})
