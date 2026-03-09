# parse_lat

test_that("parse_lat works", {
  aa <- parse_lat("45N54.2356")

  expect_type(aa, "double")
  expect_equal(round(aa), 46)
  expect_match(strsplit(as.character(aa), "\\.")[[1]][2], "903")
})

# FIXME: look into commented out values
test_lats <- c(
  "40.4183318",
  "40.4183318° N",
  "40° 25´ 5.994\" N",
  "40° 25.0999’",
  "N40°25’5.994",
  "40°25’5.994\"N",
  "40 25 5.994",
  "40.4183318",
  "40.4183318°",
  "40.4183318N",
  "40°25’5.994\"N",
  "N 40 25.0999",
  "40:25:6N",
  "40:25:5.994N",
  "40°25’6\"N",
  "40°25’6\"",
  "40d 25’ 6\" N",
  "40.4183318N",
  "40° 25.0999",
  "40-25-5.994N",
  "40_25_5.994N"
)

test_that("parse_lat works: run through test_lats", {
  out <- data.frame(
    input = test_lats,
    res = NA_real_,
    stringsAsFactors = FALSE
  )
  for (i in seq_along(test_lats)) {
    expect_equal(round(parse_lat(test_lats[i]), 5), 40.41833)
  }
})

test_that("parse_lat - fails well", {
  expect_error(parse_lat(), "argument \"lat\" is missing")
  expect_error(parse_lat(mtcars), "lat must be of class")
})

# invalid formats
invalid_formats <- c(
  "blablabla",
  "5 Fantasy street 12",
  "-40.1X, 74",
  "-40.1 X, 74",
  "-40.1, 74X",
  "-40.1, 74 X",
  "1 2 3 4 5 6 7 8",
  "1 2 3 4 5 6 7",
  "1 2 3 4 5",
  "1 2 3 4",
  "40.1° SS",
  "60.1° NN",
  "60.1° W",
  "60.1° E",
  "W60.1",
  "E60.1",
  "-45.23232e24",
  # "-40.4183318, 12.345, 74.6411133"
  "92",
  "-92",
  "92N",
  "92S"
)

# res column should all give NaN
test_that("parse_lat works: invalid formats fail as expected", {
  out <- data.frame(
    input = invalid_formats,
    res = NA_real_,
    stringsAsFactors = FALSE
  )
  for (i in seq_along(invalid_formats)) {
    out[i, "res"] <- suppressWarnings({
      parse_lat(invalid_formats[i])
    })
    expect_warning({
      aa <- parse_lat(invalid_formats[i])
    })
    expect_type(aa, "double")
    expect_equal(aa, NaN)
  }
})


test_that("parse_lat with >3 numeric tokens emits only the format warning", {
  # Previously the if-chain let ret = NA_REAL fall through to ret * dir_val,
  # potentially breaking the NA bit pattern so the range check also fired,
  # producing a spurious second warning.
  warns <- character(0)
  withCallingHandlers(
    parse_lat("40 25 6 7"),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_length(warns, 1)
  expect_match(warns, "invalid format, more than 3 numeric slots")
})

test_that("parse_lat correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_lat(c("W60.1", NA, NA_character_, "12' 30'"))
    ),
    c(NA_real_, NA_real_, NA_real_, 12.5)
  )
})

test_that("parse_lat errors with 'format handling not ready yet' when format is supplied", {
  # Covers the stop_form() else-branch at parse_lat.R:60 and zzz.R:22
  expect_error(parse_lat("45N", format = "dms"), "format handling not ready yet")
  expect_error(parse_lat("40.41833", format = "decimal"), "format handling not ready yet")
})

test_that("parse_lat accepts numeric and integer inputs", {
  # scrub() coerces numeric/integer to character internally
  expect_equal(parse_lat(45.5), 45.5)
  expect_equal(parse_lat(45L), 45)
  expect_equal(parse_lat(-45.0), -45.0)
  # vector input: 85:90 are valid, 91:95 are out of range -> NA_real_
  result <- suppressWarnings(parse_lat(85:95))
  expect_equal(result[1:6], as.double(85:90))
  expect_true(all(is.na(result[7:11])))
})
