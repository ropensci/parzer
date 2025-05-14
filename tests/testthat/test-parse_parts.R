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
