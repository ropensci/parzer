context("parse_lat")

test_that("parse_lat works", {
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
  "40° 25.0999"
)

test_that("parse_lat works: run through test_lats", {
  out <- data.frame(input = test_lats, res = NA_real_,
    stringsAsFactors = FALSE)
  for (i in seq_along(test_lats)) {
    # cat(test_lats[i], sep = "\n")
    out[i, "res"] <- parse_lat(test_lats[i])
    # expect_is(out[i, "res"], "numeric")
    expect_equal(round(parse_lat(test_lats[i]), 5), 40.41833)
  }
  # out
})

test_that("parse_lat - fails well", {
  expect_error(parse_lat(), "argument \"lat\" is missing")
  expect_error(parse_lat(mtcars), "lat must be of class")
  expect_error(parse_lat("", 5), "format must be of class character")
})

