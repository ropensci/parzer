# parse_lat

test_that("parse_lat works", {
  aa <- parse_lat("45N54.2356")

  expect_type(aa, "double")
  expect_equal(round(aa), 46)
  expect_match(strsplit(as.character(aa), "\\.")[[1]][2], "903")
})
test_that("parse_lat works: run through test_lats", {
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
  for (i in seq_along(invalid_formats)) {
    expect_warning({
      aa <- parse_lat(invalid_formats[i])
    })
    expect_type(aa, "double")
    expect_identical(aa, NA_real_)
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

test_that("parse_lat reads with format when it is given", {
  # the full set of cases is in test-format.R
  expect_equal(parse_lat("45N", format = "DDH"), 45)
  expect_equal(parse_lat("4530", format = c("DDH", "DDMM")), 45.5)
  expect_error(parse_lat("45N", format = "dms"), "invalid format \"dms\"")
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

test_that("parse_lat: minutes and seconds >= 60 give NA with a warning", {
  expect_warning(
    res <- parse_lat("10°30,12345"),
    "minutes or seconds not within 0/60"
  )
  expect_true(is.na(res))
  expect_warning(
    res <- parse_lat("88,78"),
    "minutes or seconds not within 0/60"
  )
  expect_true(is.na(res))
  expect_warning(
    res <- parse_lat("10°30'75\""),
    "minutes or seconds not within 0/60"
  )
  expect_true(is.na(res))
  expect_equal(parse_lat("10°59'59.9\""), 10 + 59 / 60 + 59.9 / 3600)
})

test_that("parse_lat: 0/60 boundaries, negative and decimal slots", {
  expect_warning(res <- parse_lat("10 60"), "not within 0/60")
  expect_true(is.na(res))
  expect_equal(parse_lat("10 59.999"), 10 + 59.999 / 60)
  expect_warning(res <- parse_lat("10 -30"), "not within 0/60")
  expect_true(is.na(res))
  expect_warning(res <- parse_lat("10 30 -15"), "not within 0/60")
  expect_true(is.na(res))
  expect_warning(res <- parse_lat("45.5 30"), "only the last")
  expect_true(is.na(res))
  expect_warning(res <- parse_lat("10 30.5 20"), "only the last")
  expect_true(is.na(res))
  expect_equal(parse_lat("10 30.5"), 10 + 30.5 / 60)
})

test_that("parse_lat: range warning shows the input", {
  expect_warning(parse_lat("10°30,12345"), "10.30.12345")
  # 12345: 4 or more digits not after a decimal point, so the packed hint
  expect_warning(parse_lat("10°30,12345"), "may be packed together")
})

test_that("parse_lat: packed digits get a hint to format, not to inverted lon and lat", {
  packed <- c(
    "2343 56N",
    "23 4356N",
    "4556.98735",
    "N455698735",
    "512839N",
    "1234"
  )
  for (x in packed) {
    res <- collect_warnings(parse_lat(x))
    expect_identical(res[["value"]], NA_real_, label = x)
    expect_length(res[["warnings"]], 1L)
    expect_match(
      res[["warnings"]],
      "may be packed together \\(e.g. DDMMSS\\): try the format argument",
      label = x
    )
    expect_no_match(res[["warnings"]], "invert", label = x)
  }
  # fewer than 4 digits, or digits after the decimal point: no hint
  for (x in c("92", "-92N", "91.12345", "45 75")) {
    res <- collect_warnings(parse_lat(x))
    expect_identical(res[["value"]], NA_real_, label = x)
    expect_length(res[["warnings"]], 1L)
    expect_no_match(res[["warnings"]], "packed", label = x)
  }
  expect_warning(
    parse_lat("91.12345"),
    "check that you did not invert lon and lat"
  )
  # one warning for each value, each with its own hint
  res <- collect_warnings(parse_lat(c("2343 56N", "92")))
  expect_length(res[["warnings"]], 2L)
  expect_match(res[["warnings"]][[1]], "packed")
  expect_match(res[["warnings"]][[2]], "invert")
  # the hint shows in the functions built on parse_lat() too
  expect_warning(parse_parts_lat("2343 56N"), "packed")
})

test_that("parse_parts_lat() and parse_hemisphere() reject minutes >= 60", {
  expect_warning(res <- parse_parts_lat("10 75"), "not within 0/60")
  expect_true(is.na(res[[1]]))
  expect_warning(
    parse_hemisphere("10 75", "10 30"),
    "not within 0/60"
  )
})

test_that("parse_lat/parse_lon: a dash after a digit separates, a leading dash is a sign", {
  expect_equal(parse_lat("40-25-5.994N"), 40 + 25 / 60 + 5.994 / 3600)
  expect_equal(parse_lat("4-5-6.5S"), -(4 + 5 / 60 + 6.5 / 3600))
  expect_equal(parse_lat("-45-30"), -45.5)
  expect_equal(parse_lat("-12.5-"), -12.5)
  expect_equal(parse_lat("12-"), 12)
  expect_equal(parse_lon("1-2-3"), 1 + 2 / 60 + 3 / 3600)
  expect_equal(parse_lon("-120-30"), -120.5)
  # only a dash right after a digit is turned into a separator
  expect_warning(res <- parse_lat("40--25-6"), "not within 0/60")
  expect_true(is.na(res))
  expect_warning(res <- parse_lat("40 -25"), "not within 0/60")
  expect_true(is.na(res))
})

test_that("parse_lat gives NA without a warning for NA input", {
  expect_no_warning(res <- parse_lat(NA_character_))
  expect_identical(res, NA_real_)
  expect_no_warning(res <- parse_lat(c("45", NA_character_, "-45")))
  expect_equal(res, c(45, NA, -45))
  expect_no_warning(res <- parse_lat(c(45.5, NA_real_, NaN)))
  expect_equal(res, c(45.5, NA, NA))
  expect_no_warning(res <- parse_lat(NA_integer_))
  expect_identical(res, NA_real_)
  # a literal "NA" string is text, not a missing value: it warns
  expect_warning(res <- parse_lat("NA"), "no digits detected")
  expect_identical(res, NA_real_)
  expect_identical(parse_lat(""), NA_real_)
})

test_that("parse_lat reads a Unicode minus sign and dashes as a minus sign", {
  expect_equal(parse_lat("−45.5"), -45.5)
  expect_equal(parse_lat("–45.5"), -45.5)
  expect_equal(parse_lat("—45.5"), -45.5)
  expect_equal(parse_lat("− 45.5"), -45.5)
  expect_equal(parse_lat("−40°25'6\""), -(40 + 25 / 60 + 6 / 3600))
  # between parts a Unicode minus separates, as an ASCII dash does
  expect_equal(parse_lat("40−25−6N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(parse_lat("−40−25−6"), -(40 + 25 / 60 + 6 / 3600))
})

test_that("parse_lat rejects a number with two decimal points", {
  expect_warning(res <- parse_lat("40.25.30"), "invalid number, got: 40.25.30")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("1.2.3"), "invalid number")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("40.5.N"), "invalid number")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("40 25.5.5"), "invalid number")
  expect_identical(res, NA_real_)
  # one decimal point, with or without digits on both sides, still works
  expect_equal(parse_lat("40."), 40)
  expect_equal(parse_lat(".5"), 0.5)
  expect_equal(parse_lat("-.5"), -0.5)
  expect_equal(parse_lat("40 25.5"), 40 + 25.5 / 60)
})

test_that("parse_lat keeps accepting d after degrees and rejects other letters", {
  # the dedicated degree-letter check was removed: these paths cover it
  expect_equal(parse_lat("40d 25' 6\" N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(parse_lat("40D 25' 6\" N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(parse_lat("40N"), 40)
  expect_equal(parse_lat("40 N"), 40)
  expect_warning(res <- parse_lat("40X 25"), "invalid direction letter")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("40 E"), "invalid direction letter")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("40NS"), "invalid cardinal direction")
  expect_identical(res, NA_real_)
})

test_that("parse_lat: a minus sign that disagrees with the letter gives NA", {
  expect_warning(
    res <- parse_lat("N -45"),
    "minus sign and direction letter disagree, got: n -45"
  )
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("N-45"), "disagree")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("-45N"), "disagree")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("-45 N"), "disagree")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lat("−40°25'6\"N"), "disagree")
  expect_identical(res, NA_real_)
  # letter and sign agree: one minus, not two
  expect_equal(parse_lat("S -45"), -45)
  expect_equal(parse_lat("S-45"), -45)
  expect_equal(parse_lat("-45S"), -45)
  expect_equal(parse_lat("-45 S"), -45)
  expect_equal(parse_lat("S-40-25-6"), -(40 + 25 / 60 + 6 / 3600))
  # no letter: the minus sign is the sign, wherever a symbol sits before it
  expect_equal(parse_lat("-45"), -45)
  expect_equal(parse_lat("° -45"), -45)
  expect_equal(parse_lat("45"), 45)
  expect_equal(parse_lat("N 45"), 45)
  expect_equal(parse_lat("-0"), 0)
})

test_that("parse_lat: d and g degree marks are accepted in either case", {
  expect_equal(parse_lat("40d 25' 6\" N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(parse_lat("40D 25' 6\" N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(parse_lat("40g 25' 6\" N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(parse_lat("40G 25' 6\" N"), 40 + 25 / 60 + 6 / 3600)
  expect_equal(scrub("40D 25G"), "40' 25'")
  # the C++ parser itself no longer accepts a d: scrub() must remove it first
  expect_warning(res <- pz_parse_lat("40d 25"), "invalid direction letter")
  expect_identical(res, NA_real_)
})
