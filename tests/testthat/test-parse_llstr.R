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

test_that("parse_llstr correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_llstr(c(NA_character_, "12' 30', 12' 30'"))
    ),
    data.frame(lat = c(NA_real_, 12.5), lon = c(NA_real_, 12.5))
  )
})

test_that("pz_split_llstr_string returns NA_STRING markers for unrecognized formats", {
  # no separator at all: else branch previously returned {"",""} due to
  # a shadowed local variable; now correctly returns {"NA_STRING","NA_STRING"}
  expect_equal(pz_split_llstr_string("4545"), c("NA_STRING", "NA_STRING"))
  # multiple commas also fall through to else branch
  expect_equal(pz_split_llstr_string("45, 45, 45"), c("NA_STRING", "NA_STRING"))
})

test_that("parse_llstr returns NA for unrecognized formats", {
  expect_equal(
    suppressWarnings(parse_llstr("4545")),
    data.frame(lat = NA_real_, lon = NA_real_)
  )
})
