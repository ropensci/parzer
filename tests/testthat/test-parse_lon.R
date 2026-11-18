# parse_lon

test_that("parse_lon works", {
  aa <- parse_lon("45W54.2356")

  expect_type(aa, "double")
  expect_equal(round(aa), -46)
  expect_match(strsplit(as.character(aa), "\\.")[[1]][2], "903")
})

test_lons <- c(
  "-74.6411133",
  "74.6411133° W",
  "74° 38´ 28.008\" W",
  "-74° 38.4668’",
  "W74°38’28.008\"",
  "74°38’28.008\"W",
  "-74 38 28.008",
  "-74.6411133",
  "-74.6411133°",
  "74.6411133W",
  "74°38’28.008\"W",
  "W 74 38.4668",
  "74:38:28W",
  "74:38:28.008W",
  "74°38’28\"W",
  "-74°38’28\"",
  "74d 38’ 28\" W",
  "74.6411133W",
  "-74° 38.4668",
  "74-38-28W",
  "74_38_28W"
)

test_that("parse_lon works: run through test_lons", {
  for (i in seq_along(test_lons)) {
    expect_equal(round(parse_lon(test_lons[i]), 5), -74.64111)
  }
})

test_that("parse_lon works with cardinal letters among the numbers", {
  expect_equal(
    parse_lon(c("74W30'45\"", "74E30'45\"")),
    c(-74.5125, 74.5125)
  )
  expect_equal(
    parse_lon(c("74  E30'45\"", "74E   30'45\"")),
    c(74.5125, 74.5125)
  )
})

test_that("parse_lon - fails well", {
  expect_error(parse_lon(), "argument \"lon\" is missing")
  expect_error(parse_lon(mtcars), "lon must be of class")
  expect_error(parse_lon("", 5), "format must be of class character")
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
  "60.1° N",
  "60.1° S",
  "N60.1",
  "S60.1",
  "-45.23232e24",
  # "-40.4183318, 12.345, 74.6411133"
  "400",
  "-200",
  "400E",
  "200W",
  "400E45",
  "200W45"
)

# res column should all give NaN
test_that("parse_lon works: invalid formats fail as expected", {
  for (i in seq_along(invalid_formats)) {
    expect_warning({
      aa <- parse_lon(invalid_formats[i])
    })
    expect_type(aa, "double")
    expect_identical(aa, NA_real_)
  }
})

test_that("parse_lon with >3 numeric tokens emits only the format warning", {
  # Mirror of the parse_lat equivalent: ensure the if-else-if chain prevents
  # a spurious range warning from firing after the "invalid format" warning.
  warns <- character(0)
  withCallingHandlers(
    parse_lon("40 25 6 7"),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_length(warns, 1)
  expect_match(warns, "invalid format, more than 3 numeric slots")
})

test_that("parse_lon correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_lon(c("S60.1", NA, NA_character_, "12' 30'"))
    ),
    c(NA_real_, NA_real_, NA_real_, 12.5)
  )
})

test_that("parse_lon reads with format when it is given", {
  # the full set of cases is in test-format.R
  expect_equal(parse_lon("074W", format = "DDDH"), -74)
  expect_error(parse_lon("74E", format = "dms"), "invalid format \"dms\"")
})

test_that("parse_lon: packed digits get a hint to format", {
  for (x in c("2343 56E", "0002741W", "174 3075")) {
    res <- collect_warnings(parse_lon(x))
    expect_identical(res[["value"]], NA_real_, label = x)
    expect_length(res[["warnings"]], 1L)
    expect_match(res[["warnings"]], "may be packed together", label = x)
  }
  # fewer than 4 digits, or digits after the decimal point: no hint
  for (x in c("400", "400.12345", "45 75")) {
    res <- collect_warnings(parse_lon(x))
    expect_length(res[["warnings"]], 1L)
    expect_no_match(res[["warnings"]], "packed", label = x)
  }
})

test_that("parse_lon accepts numeric and integer inputs", {
  # scrub() coerces numeric/integer to character internally
  expect_equal(parse_lon(74.5), 74.5)
  expect_equal(parse_lon(180L), 180)
  expect_equal(parse_lon(-74.5), -74.5)
  # vector: 355:360 valid (<=360), 361:365 out of range -> NA_real_
  result <- suppressWarnings(parse_lon(355:365))
  expect_equal(result[1:6], as.double(355:360))
  expect_true(all(is.na(result[7:11])))
})

test_that("parse_lon: minutes and seconds >= 60 give NA with a warning", {
  expect_warning(
    res <- parse_lon("10°30,12345"),
    "minutes or seconds not within 0/60"
  )
  expect_true(is.na(res))
  expect_warning(
    res <- parse_lon("100°75'"),
    "minutes or seconds not within 0/60"
  )
  expect_true(is.na(res))
  expect_equal(parse_lon("10°59'59.9\""), 10 + 59 / 60 + 59.9 / 3600)
})

test_that("parse_lon: 0/60 boundaries, negative and decimal slots", {
  expect_warning(res <- parse_lon("10 60"), "not within 0/60")
  expect_true(is.na(res))
  expect_equal(parse_lon("10 59.999"), 10 + 59.999 / 60)
  expect_warning(res <- parse_lon("10 -30"), "not within 0/60")
  expect_true(is.na(res))
  expect_warning(res <- parse_lon("10 30 -15"), "not within 0/60")
  expect_true(is.na(res))
  expect_warning(res <- parse_lon("45.5 30"), "only the last")
  expect_true(is.na(res))
  expect_warning(res <- parse_lon("10 30.5 20"), "only the last")
  expect_true(is.na(res))
  expect_equal(parse_lon("10 30.5"), 10 + 30.5 / 60)
})

test_that("parse_lon: range warning shows the input", {
  expect_warning(parse_lon("10°30,12345"), "10.30.12345")
})

test_that("parse_parts_lon() and parse_hemisphere() reject minutes >= 60", {
  expect_warning(res <- parse_parts_lon("10 75"), "not within 0/60")
  expect_true(is.na(res[[1]]))
  expect_warning(
    parse_hemisphere("10 75", "10 30"),
    "not within 0/60"
  )
})

test_that("parse_lon/parse_lat: exponents, repeated directions and signs", {
  expect_warning(res <- parse_lon("45e2"), "invalid characters")
  expect_true(is.na(res))
  expect_warning(res <- parse_lon("-45.23232e24"), "invalid characters")
  expect_true(is.na(res))
  expect_warning(res <- parse_lon("74ew"), "invalid cardinal direction")
  expect_true(is.na(res))
  expect_warning(res <- parse_lat("40ns"), "invalid cardinal direction")
  expect_true(is.na(res))
  expect_equal(parse_lon("74 W"), -74)
  expect_equal(parse_lat("40 s"), -40)
  expect_equal(parse_lat("-40.5"), -40.5)
})

test_that("parse_lon gives NA without a warning for NA input", {
  expect_no_warning(res <- parse_lon(NA_character_))
  expect_identical(res, NA_real_)
  expect_no_warning(res <- parse_lon(c("74", NA_character_, "-74")))
  expect_equal(res, c(74, NA, -74))
  expect_no_warning(res <- parse_lon(c(74.5, NA_real_, NaN)))
  expect_equal(res, c(74.5, NA, NA))
  expect_no_warning(res <- parse_lon(NA_integer_))
  expect_identical(res, NA_real_)
})

test_that("parse_lon reads a Unicode minus sign and dashes as a minus sign", {
  expect_equal(parse_lon("−120.5"), -120.5)
  expect_equal(parse_lon("–120.5"), -120.5)
  expect_equal(parse_lon("—120.5"), -120.5)
  expect_equal(parse_lon("−74°38'28\""), -(74 + 38 / 60 + 28 / 3600))
  expect_equal(parse_lon("74−38−28W"), -(74 + 38 / 60 + 28 / 3600))
})

test_that("parse_lon rejects a number with two decimal points", {
  expect_warning(res <- parse_lon("74.6.4W"), "invalid number, got: 74.6.4")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lon("1.2.3"), "invalid number")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lon("74 38.5.5"), "invalid number")
  expect_identical(res, NA_real_)
  expect_equal(parse_lon("74."), 74)
  expect_equal(parse_lon("-.5"), -0.5)
})

test_that("parse_lon keeps accepting d after degrees and rejects other letters", {
  expect_equal(parse_lon("74d 38' 28\" W"), -(74 + 38 / 60 + 28 / 3600))
  expect_equal(parse_lon("74D 38' 28\" W"), -(74 + 38 / 60 + 28 / 3600))
  expect_equal(parse_lon("74W"), -74)
  expect_warning(res <- parse_lon("74X 38"), "invalid direction letter")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lon("74 N"), "invalid direction letter")
  expect_identical(res, NA_real_)
})

test_that("parse_lon: a minus sign that disagrees with the letter gives NA", {
  expect_warning(
    res <- parse_lon("E -120"),
    "minus sign and direction letter disagree, got: e -120"
  )
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lon("-120E"), "disagree")
  expect_identical(res, NA_real_)
  expect_warning(res <- parse_lon("E-120"), "disagree")
  expect_identical(res, NA_real_)
  expect_equal(parse_lon("W -120"), -120)
  expect_equal(parse_lon("-120W"), -120)
  expect_equal(parse_lon("W-120-30"), -120.5)
  expect_equal(parse_lon("-120"), -120)
  expect_equal(parse_lon("E 120"), 120)
  # the disagreement check runs before the range check
  expect_warning(res <- parse_lon("E -400"), "disagree")
  expect_identical(res, NA_real_)
})

test_that("parse_lon: d and g degree marks are accepted in either case", {
  expect_equal(parse_lon("74D 38' 28\" W"), -(74 + 38 / 60 + 28 / 3600))
  expect_equal(parse_lon("74G 38' 28\" W"), -(74 + 38 / 60 + 28 / 3600))
  expect_warning(res <- pz_parse_lon("74d 38"), "invalid direction letter")
  expect_identical(res, NA_real_)
})
