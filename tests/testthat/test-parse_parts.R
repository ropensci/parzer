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

test_that("parse_parts_lat correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_parts_lat(c("45N54.30", NA_character_, "45N54.30"))
    ),
    data.frame(
      deg = c(45, NA_integer_, 45),
      min = c(54, NA_integer_, 54),
      sec = c(18, NA_real_, 18)
    )
  )
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

test_that("parse_parts_lon correctly processes NA values", {
  expect_equal(
    suppressWarnings(
      parse_parts_lon(c("45W54.30", NA_character_, "45W54.30"))
    ),
    data.frame(
      deg = c(-45, NA_integer_, -45),
      min = c(54, NA_integer_, 54),
      sec = c(18, NA_real_, 18)
    )
  )
})

test_that("parse_parts_lat/lon return NA_integer_ in deg/min for invalid inputs", {
  # Previously, convert_lat/lon returning NA_REAL was passed to split_decimal_degree
  # which returned NA_REAL, then cast to int (UB). Now NA is detected first and
  # NA_INTEGER is set directly.
  lat_na <- suppressWarnings(parse_parts_lat(c("blablabla", "W60.1")))
  expect_equal(lat_na$deg, c(NA_integer_, NA_integer_))
  expect_equal(lat_na$min, c(NA_integer_, NA_integer_))
  expect_equal(lat_na$sec, c(NA_real_, NA_real_))

  lon_na <- suppressWarnings(parse_parts_lon(c("blablabla", "N60.1")))
  expect_equal(lon_na$deg, c(NA_integer_, NA_integer_))
  expect_equal(lon_na$min, c(NA_integer_, NA_integer_))
  expect_equal(lon_na$sec, c(NA_real_, NA_real_))
})

# sign convention: the sign sits on the first non-zero of deg, min, sec
rebuild_dms <- function(parts) {
  fields <- cbind(parts[["deg"]], parts[["min"]], parts[["sec"]])
  first_nonzero <- apply(fields, 1L, function(row) {
    which(row != 0)[1L]
  })
  sign_of <- vapply(
    seq_len(nrow(fields)),
    function(i) {
      if (is.na(first_nonzero[[i]])) 1 else sign(fields[i, first_nonzero[[i]]])
    },
    FUN.VALUE = numeric(1L)
  )
  sign_of *
    (abs(fields[, 1L]) + abs(fields[, 2L]) / 60 + abs(fields[, 3L]) / 3600)
}

test_that("parse_parts_lat keeps the sign for values between -1 and 0", {
  res <- parse_parts_lat("-0.5")
  expect_equal(res[["deg"]], 0L)
  expect_equal(res[["min"]], -30L)
  expect_equal(res[["sec"]], 0)
  res <- parse_parts_lon("-0.5")
  expect_equal(res[["min"]], -30L)
  # below one minute, the sign goes on the seconds
  res <- parse_parts_lat("-0.001")
  expect_equal(res[["deg"]], 0L)
  expect_equal(res[["min"]], 0L)
  expect_equal(res[["sec"]], -3.6)
  # south/west letters behave the same as a minus sign
  expect_equal(parse_parts_lat("0.5S"), parse_parts_lat("-0.5"))
  expect_equal(parse_parts_lon("0.5W"), parse_parts_lon("-0.5"))
  # existing convention is kept when degrees are not zero
  expect_equal(parse_parts_lat("-45.5")[["deg"]], -45L)
  expect_equal(parse_parts_lat("-45.5")[["min"]], 30L)
  # zero stays zero and positive values keep positive fields
  expect_equal(parse_parts_lat("0"), parse_parts_lat("-0"))
  expect_equal(parse_parts_lat("0.5")[["min"]], 30L)
  expect_equal(pz_minute(lat = -0.5), -30L)
})

test_that("parse_parts never returns 60 seconds or 60 minutes", {
  tricky <- c(
    "10.35",
    "0.1",
    "0.7",
    "1.15",
    "20.2",
    "33.3",
    "89.99999999999",
    "59.99999999999",
    "0.99999999999",
    "10.999999999999",
    "-10.35",
    "-89.99999999999",
    "45.0833333333333",
    "12.0166666666667"
  )
  for (fn in list(parse_parts_lat, parse_parts_lon)) {
    res <- fn(tricky)
    expect_true(all(abs(res[["min"]]) < 60L))
    expect_true(all(abs(res[["sec"]]) < 60))
    expect_true(all(abs(res[["sec"]]) >= 0))
  }
  res <- parse_parts_lat("10.35")
  expect_equal(res[["deg"]], 10L)
  expect_equal(res[["min"]], 21L)
  expect_equal(res[["sec"]], 0, tolerance = 1e-6)
  # carry reaches the degrees
  res <- parse_parts_lat("10.99999999999999")
  expect_equal(res[["deg"]], 11L)
  expect_equal(res[["min"]], 0L)
  expect_equal(res[["sec"]], 0, tolerance = 1e-6)
  res <- parse_parts_lat("-10.99999999999999")
  expect_equal(res[["deg"]], -11L)
  expect_equal(res[["min"]], 0L)
})

test_that("parse_parts round-trips to the decimal value", {
  set.seed(60)
  values <- c(
    runif(300, -90, 90),
    round(runif(300, -90, 90), 2),
    seq(-5, 5, by = 0.05),
    c(0, 1 / 3, -1 / 3, 0.1 + 0.2, 90, -90, 1e-6, -1e-6, 1e-9, -1e-9)
  )
  values <- values[abs(values) <= 90]
  for (fn in list(parse_parts_lat, parse_parts_lon)) {
    res <- fn(num_to_chr(values))
    expect_equal(rebuild_dms(res), values, tolerance = 1e-9)
    expect_true(all(abs(res[["min"]]) < 60L))
    expect_true(all(abs(res[["sec"]]) < 60))
  }
})

test_that("pz_degree/minute/second agree with parse_parts for lat and lon", {
  x <- c("10.35", "-0.5", "45", "-45.25", "0.001", "-0.001")
  expect_equal(pz_degree(lat = x), parse_parts_lat(x)[["deg"]])
  expect_equal(pz_minute(lat = x), parse_parts_lat(x)[["min"]])
  expect_equal(pz_second(lat = x), parse_parts_lat(x)[["sec"]])
  expect_equal(pz_minute(lon = x), parse_parts_lon(x)[["min"]])
})

test_that("parse_parts splits plain decimal degrees", {
  res <- parse_parts_lat("40.41833")
  expect_equal(res[["deg"]], 40L)
  expect_equal(res[["min"]], 25L)
  expect_equal(res[["sec"]], 5.988, tolerance = 1e-3)
  res <- parse_parts_lon("-74.64111")
  expect_equal(res[["deg"]], -74L)
  expect_equal(res[["min"]], 38L)
  expect_equal(res[["sec"]], 28, tolerance = 1e-3)
})
