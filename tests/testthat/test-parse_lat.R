context("parse_lat")

test_that("parse_lat works", {
  skip_on_cran()
  aa <- parse_lat("45N54.2356")

  expect_is(aa, "numeric")
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
  # "145505994.48",
  "40.4183318N",
  # "4025.0999N",
  "40°25’5.994\"N",
  # "402505.994N",
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
  skip_on_cran()
  out <- data.frame(input = test_lats, res = NA_real_,
    stringsAsFactors = FALSE)
  for (i in seq_along(test_lats)) {
    expect_equal(round(parse_lat(test_lats[i]), 5), 40.41833)
    # cat(test_lats[i], sep = "\n")
    # out[i, "res"] <- parse_lat(test_lats[i])
    # expect_is(out[i, "res"], "numeric")
  }
  # out
})

test_that("parse_lat - fails well", {
  skip_on_cran()
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
  "-45.23232e24"
  # "-40.4183318, 12.345, 74.6411133"
)

# res column should all give NaN
test_that("parse_lat works: invalid formats fail as expected", {
  skip_on_cran()
  out <- data.frame(input = invalid_formats, res = NA_real_,
                    stringsAsFactors = FALSE)
  for (i in seq_along(invalid_formats)) {
    out[i, "res"] <- suppressWarnings(parse_lat(invalid_formats[i]))
    expect_warning(aa <- parse_lat(invalid_formats[i]))
    expect_is(aa, "numeric")
    expect_equal(aa, NaN)
  }
})
