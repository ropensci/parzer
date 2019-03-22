context("degree-minute-second fxns")

test_that("pz_degree works", {
  aa <- pz_degree(45.23323)

  expect_is(aa, "integer")
  expect_type(aa, "integer")
  expect_equal(aa, 45)
})

test_that("pz_minute works", {
  aa <- pz_minute(45.23323)

  expect_is(aa, "integer")
  expect_type(aa, "integer")
  expect_equal(aa, 13)
})

test_that("pz_second works", {
  aa <- pz_second(45.23323)

  expect_is(aa, "numeric")
  expect_type(aa, "double")
  expect_equal(round(aa), 60)
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

test_that("degree works with varied formats", {
  # out <- data.frame(input = test_lats, res = NA_real_,
  #                   stringsAsFactors = FALSE)
  for (i in seq_along(test_lats)) {
    expect_equal(pz_degree(test_lats[i]), 40)
    expect_equal(pz_minute(test_lats[i]), 25)
    expect_equal(round(pz_second(test_lats[i])), 6)
    # out[i, "res"] <- degree(test_lats[i])
  }
})

test_that("pz_degree - fails well", {
  expect_error(pz_degree(), "is not TRUE")
  expect_error(pz_degree(4, 5), "is not TRUE")
  expect_error(pz_degree(mtcars), "lat must be of class")
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
  "E60.1"
  # "-40.4183318, 12.345, 74.6411133"
)

test_that("dms fxns fail as expected", {
  out <- data.frame(input = invalid_formats, res = NA_real_,
                    stringsAsFactors = FALSE)
  for (i in seq_along(invalid_formats)) {
    # out[i, "res"] <- suppressWarnings(degree(invalid_formats[i]))
    expect_warning(pz_degree(invalid_formats[i]))
    expect_warning(pz_minute(invalid_formats[i]))
    expect_warning(pz_second(invalid_formats[i]))
    # expect_is(aa, "numeric")
    # expect_equal(aa, NaN)
  }
})
