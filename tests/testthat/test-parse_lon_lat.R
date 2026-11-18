# parse_lon_lat

test_that("parse_lon_lat works", {
  aa <- parse_lon_lat("45W54.2356", "45N54.2356")

  expect_type(aa, "list")
  expect_equal(NCOL(aa), 2)
  expect_equal(NROW(aa), 1)
  expect_named(aa, c("lon", "lat"))
  expect_type(aa$lat, "double")
  expect_type(aa$lon, "double")
})

test_that("parse_lon_lat - fails well", {
  expect_error(parse_lon_lat(), "argument \"lon\" is missing")
  expect_error(parse_lon_lat(""), "argument \"lat\" is missing")
  expect_error(parse_lon_lat(mtcars), "lon must be of class")
  expect_error(parse_lon_lat("", mtcars), "lat must be of class")

  # src/ error
  expect_warning(parse_lon_lat("45", "190"), "not within -90")
  expect_warning(parse_lon_lat("45", "190"), "check that you did not invert")
})


test_that("parse_lon_lat accepts numeric and integer inputs", {
  expect_equal(parse_lon_lat(-120, 45), parse_lon_lat("-120", "45"))
  expect_equal(parse_lon_lat(-120L, 45L), parse_lon_lat("-120", "45"))
})

test_that("parse_lon_lat correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_lon_lat("S60.1", NA_character_)
    ),
    data.frame(lon = NA_real_, lat = NA_real_)
  )
  expect_equal(
    suppressWarnings(
      parse_lon_lat("12' 30'", NA_character_)
    ),
    data.frame(lon = 12.5, lat = NA_real_)
  )
  expect_equal(
    suppressWarnings(
      parse_lon_lat(NA_character_, "12' 30'")
    ),
    data.frame(lon = NA_real_, lat = 12.5)
  )
})

test_that("parse_lon_lat scrubs symbols like parse_lon and parse_lat do", {
  expect_equal(
    parse_lon_lat("40°25'", "40°25'"),
    data.frame(lon = parse_lon("40°25'"), lat = parse_lat("40°25'"))
  )
  expect_equal(parse_lon_lat("40°25'", "10")$lon, 40 + 25 / 60)
  expect_equal(
    parse_lon_lat("10", "40d 25’ 6\" N")$lat,
    40 + 25 / 60 + 6 / 3600
  )
  expect_equal(
    parse_lon_lat("40:25:6E", "40:25:6N")$lon,
    40 + 25 / 60 + 6 / 3600
  )
})

test_that("parse_lon_lat and parse_lat handle tiny and large numeric input", {
  expect_equal(parse_lat(1e-5), 1e-5)
  expect_equal(parse_lat(-3e-5), -3e-5)
  expect_equal(parse_lon(1e-10), 1e-10)
  expect_equal(parse_lon_lat(1e-5, 2e-5), data.frame(lon = 1e-5, lat = 2e-5))
  expect_no_warning(res <- parse_lat(c(1e-5, 45.5, NA, 0)))
  expect_equal(res, c(1e-5, 45.5, NA, 0))
  expect_equal(parse_lat(45.234234), 45.234234)
  expect_equal(parse_lat(0.1 + 0.2), 0.3)
  expect_equal(parse_lon(100000), NA_real_) |> suppressWarnings()
  expect_warning(parse_lon(1e20), "not within -180/360 range")
  expect_true(is.na(suppressWarnings(parse_lat(c(Inf, NaN)))[[1]]))
  expect_equal(parse_lat(-1e-5), -1e-5)
  expect_equal(parse_lat(0L), 0)
})

test_that("numbers too large for a double give NA with a warning, not a shifted slot", {
  big <- strrep("9", 400)
  expect_warning(res <- parse_lat(paste("10", big, "30")), "invalid number")
  expect_true(is.na(res))
  expect_warning(res <- parse_lon(paste("10", big, "30")), "invalid number")
  expect_true(is.na(res))
  expect_warning(res <- parse_lat(paste0(big, " 30")), "invalid number")
  expect_true(is.na(res))
  expect_warning(
    res <- parse_lon_lat(paste("10", big), "10"),
    "invalid number"
  )
  expect_true(is.na(res$lon))
  expect_equal(res$lat, 10)
})

test_that("numeric input round-trips through the string parser for many magnitudes", {
  set.seed(60)
  lat <- c(
    runif(200, -90, 90),
    10^runif(100, -12, 0) * sample(c(-1, 1), 100, replace = TRUE),
    c(0, 90, -90, 1e-15, 123456789e-15)
  )
  lon <- c(runif(200, -180, 180), lat[abs(lat) <= 90])
  expect_equal(parse_lat(lat), lat, tolerance = 1e-12)
  expect_equal(parse_lon(lon), lon, tolerance = 1e-12)
  res <- parse_lon_lat(lon[seq_along(lat)], lat)
  expect_equal(res$lat, lat, tolerance = 1e-12)
  expect_equal(res$lon, lon[seq_along(lat)], tolerance = 1e-12)
  expect_equal(
    parse_hemisphere(lon[seq_along(lat)], lat),
    paste0(ifelse(lat < 0, "S", "N"), ifelse(lon[seq_along(lat)] < 0, "W", "E"))
  )
})

test_that("parse_hemisphere warns for longitudes above 180", {
  expect_warning(res <- parse_hemisphere(200.5, 10), "within 180/360 range")
  expect_equal(res, "NE")
})

test_that("parse_lon_lat and parse_lat agree on every string form", {
  forms <- c(
    "40°25'6\"",
    "40:25:6",
    "40d 25' 6\"",
    "40 25 6",
    "40,25,6",
    "40.4183"
  )
  expect_equal(parse_lon_lat(forms, forms)$lon, parse_lon(forms))
  expect_equal(parse_lon_lat(forms, forms)$lat, parse_lat(forms))
})

test_that("parse_lon_lat gives NA without a warning for NA input", {
  expect_no_warning(res <- parse_lon_lat(c("-120", NA), c(NA, "45")))
  expect_equal(res, data.frame(lon = c(-120, NA), lat = c(NA, 45)))
  expect_no_warning(res <- parse_lon_lat(NA_real_, NA_real_))
  expect_equal(res, data.frame(lon = NA_real_, lat = NA_real_))
})

test_that("parse_lon_lat reads a Unicode minus sign as a minus sign", {
  expect_equal(
    parse_lon_lat("−120.5", "−45.5"),
    data.frame(lon = -120.5, lat = -45.5)
  )
})

test_that("numeric input of mixed magnitude is formatted as one vector without loss", {
  x <- c(1e-15, 45.123456789012, 89.999999999999, -1e-9, 0)
  expect_equal(parse_lat(x), x, tolerance = 1e-14)
  expect_equal(
    parse_lon(c(x, 180, -180, 359.999999)),
    c(x, 180, -180, 359.999999),
    tolerance = 1e-14
  )
})

test_that("parse_lon_lat and parse_hemisphere name the length mismatch", {
  expect_error(parse_lon_lat(1:2, 1:3), "lon and lat must have the same length")
  expect_error(
    parse_hemisphere("45", c("45", "46")),
    "lon and lat must have the same length"
  )
  expect_error(parse_lon_lat(character(0), "45"), "same length")
  expect_equal(nrow(parse_lon_lat(character(0), character(0))), 0L)
})

test_that("lint_inputs checks class and length", {
  expect_error(lint_inputs(mtcars, "45"), "lon must be of class")
  expect_error(lint_inputs("45", TRUE), "lat must be of class")
  expect_error(lint_inputs("45", c("45", "46")), "same length")
  expect_null(lint_inputs("45", 45))
})

test_that("parse_lon_lat passes lon_format and lat_format on", {
  expect_equal(
    parse_lon_lat(
      "0002741W",
      "512839N",
      lon_format = "DDDMMSSH",
      lat_format = "DDMMSSH"
    ),
    data.frame(lon = -(27 / 60 + 41 / 3600), lat = 51 + 28 / 60 + 39 / 3600)
  )
  # one format only: the other value is read as with format = NULL
  expect_equal(
    parse_lon_lat("-120.43", "4907.2", lat_format = "DDMM.m"),
    data.frame(lon = -120.43, lat = 49.12)
  )
  expect_equal(
    parse_lon_lat("12043W", "49.12", lon_format = "DDDMMH"),
    data.frame(lon = -(120 + 43 / 60), lat = 49.12)
  )
  # the same as parse_lon() and parse_lat() with format
  lons <- c("0743056W", "074 30 56W", "1800001W", NA)
  lats <- c("453015N", "45 30 15N", "512839N", "4530")
  lon_format <- c("DDDMMSSH", "DDD MM SSH")
  lat_format <- c("DDMMSSH", "DD MM SSH", "DDMM")
  res <- collect_warnings(
    parse_lon_lat(lons, lats, lon_format = lon_format, lat_format = lat_format)
  )
  expect_equal(
    res[["value"]],
    data.frame(
      lon = suppressWarnings(parse_lon(lons, format = lon_format)),
      lat = parse_lat(lats, format = lat_format)
    )
  )
  # the out of range longitude gives NA and the latitude is kept
  expect_equal(
    res[["value"]][3, ],
    data.frame(lon = NA_real_, lat = 51 + 28 / 60 + 39 / 3600),
    ignore_attr = TRUE
  )
  expect_length(res[["warnings"]], 1L)
  expect_match(
    res[["warnings"]],
    "\"1800001W\": not within -180/360 range",
    fixed = TRUE
  )
})

test_that("parse_lon_lat checks lon_format and lat_format", {
  expect_error(
    parse_lon_lat("1", "2", lon_format = 5),
    "lon_format must be of class character"
  )
  expect_error(
    parse_lon_lat("1", "2", lat_format = TRUE),
    "lat_format must be of class character"
  )
  expect_error(
    parse_lon_lat("1", "2", lat_format = "MMDD"),
    "invalid format \"MMDD\""
  )
  expect_error(
    parse_lon_lat("1", "2", lon_format = NA_character_),
    "without NA"
  )
})
