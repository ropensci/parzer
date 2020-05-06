context("parse_lon")

test_that("parse_lon works", {
  skip_on_cran()
  aa <- parse_lon("45W54.2356")

  expect_is(aa, "numeric")
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
  # "-268708007.88",
  "74.6411133W",
  # "7438.4668W",
  "74°38’28.008\"W",
  # "743828.008W",
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
  skip_on_cran()
  out <- data.frame(input = test_lons, res = NA_real_,
    stringsAsFactors = FALSE)
  for (i in seq_along(test_lons)) {
    expect_equal(round(parse_lon(test_lons[i]), 5), -74.64111)
    # out[i, "res"] <- parse_lon(test_lons[i])
  }
  # out
})

test_that("parse_lon - fails well", {
  skip_on_cran()
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
  "-45.23232e24"
  # "-40.4183318, 12.345, 74.6411133"
)

# res column should all give NaN
test_that("parse_lon works: invalid formats fail as expected", {
  skip_on_cran()
  out <- data.frame(input = invalid_formats, res = NA_real_,
                    stringsAsFactors = FALSE)
  for (i in seq_along(invalid_formats)) {
    out[i, "res"] <- suppressWarnings(parse_lon(invalid_formats[i]))
    expect_warning(aa <- parse_lon(invalid_formats[i]))
    expect_is(aa, "numeric")
    expect_equal(aa, NaN)
  }
})
