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

  # src/ error, then the warning for a latitude that looks like a longitude
  res <- collect_warnings(parse_llstr("190, 45"))
  expect_length(res[["warnings"]], 2L)
  expect_match(res[["warnings"]][[1]], "not within -90")
  expect_match(res[["warnings"]][[1]], "check that you did not invert")
  expect_match(res[["warnings"]][[2]], "try order = \"lon_lat\"", fixed = TRUE)
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

# pz_split_llstr_string semicolon branch (pz_split_llstr.cpp:23-24).
# Note: scrub() replaces ';' with "'" so this branch is only reachable by
# calling the internal C++ function directly.
test_that("pz_split_llstr_string splits on a semicolon separator", {
  expect_equal(pz_split_llstr_string("45.5;-74.5"), c("45.5", "-74.5"))
  expect_equal(pz_split_llstr_string("N45.5;W74.5"), c("N45.5", "W74.5"))
})

test_that("parse_llstr gives one clear warning per unsplittable string", {
  expect_warning(
    res <- parse_llstr("4545"),
    "could not split into latitude and longitude, got: 4545"
  )
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
  # no leftover warning about the internal NA marker
  warnings <- testthat::capture_warnings(parse_llstr("4545"))
  expect_length(warnings, 1L)
  expect_no_match(warnings, "na'string", ignore.case = TRUE)
  expect_no_match(warnings, "no digits")
})

test_that("parse_llstr keeps good rows when others cannot be split", {
  expect_warning(
    res <- parse_llstr(c("45, 90", "4545", "N12.5, W30")),
    "could not split"
  )
  expect_equal(res$lat, c(45, NA, 12.5))
  expect_equal(res$lon, c(90, NA, -30))
  expect_warning(
    res <- parse_llstr(c("45, 45, 45", "1, 2")),
    "got: 45, 45, 45"
  )
  expect_equal(res, data.frame(lat = c(NA, 1), lon = c(NA, 2)))
})

test_that("parse_llstr gives NA without a split warning for NA input", {
  warnings <- testthat::capture_warnings(parse_llstr(c(NA_character_, "1, 2")))
  expect_no_match(warnings, "could not split")
  expect_equal(
    suppressWarnings(parse_llstr(c(NA_character_, "1, 2"))),
    data.frame(lat = c(NA, 1), lon = c(NA, 2))
  )
})

test_that("parse_llstr gives NA without a warning for NA, empty and blank strings", {
  x <- c("", "   ", NA)
  na <- data.frame(lat = rep(NA_real_, 3), lon = rep(NA_real_, 3))
  # the same as parse_lat() and as with format
  expect_no_warning(expect_equal(parse_llstr(x), na))
  expect_no_warning(expect_equal(parse_llstr(x, format = "DD DDD"), na))
  expect_no_warning(parse_lat(x))
})

test_that("parse_llstr handles empty and all-bad input", {
  expect_equal(
    parse_llstr(character(0)),
    data.frame(lat = numeric(0), lon = numeric(0))
  )
  warnings <- testthat::capture_warnings(res <- parse_llstr(c("abc", "123")))
  expect_length(warnings, 2L)
  expect_match(warnings, "could not split")
  expect_true(all(is.na(res$lat)) && all(is.na(res$lon)))
  expect_equal(nrow(res), 2L)
})

test_that("pz_split_llstr_string trims spaces and splits at the only separator", {
  expect_equal(pz_split_llstr_string("  40.5  ,   74.5  "), c("40.5 ", " 74.5"))
  expect_equal(pz_split_llstr_string("40 74"), c("40", "74"))
  expect_equal(pz_split_llstr_string("40.5 74.5"), c("40.5", "74.5"))
  expect_equal(pz_split_llstr_string("40.5;74"), c("40.5", "74"))
  expect_equal(pz_split_llstr_string("40.74"), c("NA_STRING", "NA_STRING"))
  expect_equal(pz_split_llstr_string("40,5,74"), c("NA_STRING", "NA_STRING"))
  # a line break keeps the whole string on that side, as the old regexes did
  expect_equal(pz_split_llstr_string("40,\n74"), c("40,\n74", "\n74"))
  expect_equal(pz_split_llstr_string("\n40, 74"), c("\n40", "\n40, 74"))
})

test_that("parse_llstr cuts at the only space whatever the number of dots", {
  # before, one space with one dot fell through to a cut at the dot
  expect_equal(parse_llstr("45 74.5"), data.frame(lat = 45, lon = 74.5))
  expect_equal(parse_llstr("45.5 74"), data.frame(lat = 45.5, lon = 74))
  expect_equal(parse_llstr("45.5 74.5"), data.frame(lat = 45.5, lon = 74.5))
  expect_equal(parse_llstr("45 74"), data.frame(lat = 45, lon = 74))
  expect_equal(pz_split_llstr_string("45 74.5"), c("45", "74.5"))
  expect_equal(pz_split_llstr_string("45.5 74"), c("45.5", "74"))
})

test_that("parse_llstr never cuts a single number at its dot", {
  expect_warning(res <- parse_llstr("45.74"), "could not split")
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
  expect_warning(res <- parse_llstr("4574.5"), "could not split")
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
  expect_equal(pz_split_llstr_string("4574.5"), c("NA_STRING", "NA_STRING"))
})

# every format listed in ?parse_llstr, so the docs and the code cannot drift
documented_llstr <- data.frame(
  str = c(
    "45.5, -74.5",
    "45 30 15 S , 74 30 15 W",
    "45.5 -74.5",
    "N45.5 W74.5",
    "45.5N 74.5W",
    "45\u00b030'15\"S 74\u00b030'15\"W",
    "45:30:15 -74:30:15",
    "N45.5, W74.5",
    "45.5S, 74.5E",
    "45 30.5, -74 30.5",
    "N45\u00b030.5', W74\u00b030.5'",
    "45\u00b030'15\", -74\u00b030'15\"",
    "45:30:15N, 74:30:15W",
    "45-30-15, 74-30-15",
    "\u221245.5, \u201374.5",
    "4.9196 -101.347",
    "4:51:36S 101:34:7W"
  ),
  lat = c(
    45.5,
    -(45 + 30 / 60 + 15 / 3600),
    45.5,
    45.5,
    45.5,
    -(45 + 30 / 60 + 15 / 3600),
    45 + 30 / 60 + 15 / 3600,
    45.5,
    -45.5,
    45 + 30.5 / 60,
    45 + 30.5 / 60,
    45 + 30 / 60 + 15 / 3600,
    45 + 30 / 60 + 15 / 3600,
    45 + 30 / 60 + 15 / 3600,
    -45.5,
    4.9196,
    -(4 + 51 / 60 + 36 / 3600)
  ),
  lon = c(
    -74.5,
    -(74 + 30 / 60 + 15 / 3600),
    -74.5,
    -74.5,
    -74.5,
    -(74 + 30 / 60 + 15 / 3600),
    -(74 + 30 / 60 + 15 / 3600),
    -74.5,
    74.5,
    -(74 + 30.5 / 60),
    -(74 + 30.5 / 60),
    -(74 + 30 / 60 + 15 / 3600),
    -(74 + 30 / 60 + 15 / 3600),
    74 + 30 / 60 + 15 / 3600,
    -74.5,
    -101.347,
    -(101 + 34 / 60 + 7 / 3600)
  ),
  stringsAsFactors = FALSE
)

test_that("parse_llstr accepts every format listed in its documentation", {
  expect_no_warning(res <- parse_llstr(documented_llstr[["str"]]))
  expect_equal(res[["lat"]], documented_llstr[["lat"]], tolerance = 1e-9)
  expect_equal(res[["lon"]], documented_llstr[["lon"]], tolerance = 1e-9)
  # one at a time too, so a failing row names its input
  for (i in seq_len(nrow(documented_llstr))) {
    expect_equal(
      parse_llstr(documented_llstr[["str"]][[i]]),
      data.frame(
        lat = documented_llstr[["lat"]][[i]],
        lon = documented_llstr[["lon"]][[i]]
      ),
      tolerance = 1e-9,
      label = documented_llstr[["str"]][[i]]
    )
  }
})

test_that("parse_llstr rejects the formats its documentation lists as unsupported", {
  unsupported <- c(
    "N45.5W74.5", # no separator
    "N4.9196E101.347",
    "45, 74, 30", # two commas
    "45 30 74 30", # two spaces, no comma
    "45,5 74,5", # decimal commas
    "45.74"
  )
  for (bad in unsupported) {
    expect_warning(res <- parse_llstr(bad), "could not split", label = bad)
    expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_), label = bad)
  }
})

test_that("parse_llstr gives NA without any warning for NA input", {
  expect_no_warning(res <- parse_llstr(NA_character_))
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
  expect_no_warning(res <- parse_llstr(c("45, 74", NA, "N1, E2")))
  expect_equal(res, data.frame(lat = c(45, NA, 1), lon = c(74, NA, 2)))
})

# order --------------------------------------------------------------------

test_that("order = 'auto': latitude first, unless the letters only fit longitude first", {
  expect_equal(parse_llstr("45.5, -74.5"), data.frame(lat = 45.5, lon = -74.5))
  expect_equal(parse_llstr("-74.5, 45.5"), data.frame(lat = -74.5, lon = 45.5))
  # both halves have a letter
  expect_equal(
    parse_llstr(c("W74.5, N45.5", "74.5E 45.5S", "N45.5 W74.5")),
    data.frame(lat = c(45.5, -45.5, 45.5), lon = c(-74.5, 74.5, -74.5))
  )
  # only one half has a letter: that half decides
  expect_equal(
    parse_llstr(c("74.5W, 45.5", "45.5, 74.5W", "74.5, 45.5n", "45.5n, 74.5")),
    data.frame(
      lat = c(45.5, 45.5, 45.5, 45.5),
      lon = c(-74.5, -74.5, 74.5, 74.5)
    )
  )
  expect_identical(
    parse_llstr("W74.5, N45.5"),
    parse_llstr("W74.5, N45.5", order = "auto")
  )
})

test_that("order = 'auto': letters that contradict each other give NA and a warning", {
  bad <- c("E45, E30", "N45, N30", "s45, 30N", "N45E, 30", "45, 30NE")
  for (x in bad) {
    res <- collect_warnings(parse_llstr(x))
    expect_equal(
      res[["value"]],
      data.frame(lat = NA_real_, lon = NA_real_),
      label = x
    )
    expect_identical(
      res[["warnings"]],
      paste0("direction letters contradict each other, got: ", x),
      label = x
    )
  }
  # the other rows are kept
  expect_warning(
    res <- parse_llstr(c("E45, E30", "N1, E2")),
    "contradict each other, got: E45, E30"
  )
  expect_equal(res, data.frame(lat = c(NA, 1), lon = c(NA, 2)))
})

test_that("order = 'lat_lon' and 'lon_lat' force the order", {
  expect_equal(
    parse_llstr(c("-74.5, 45.5", "W74.5, N45.5"), order = "lon_lat"),
    data.frame(lat = c(45.5, 45.5), lon = c(-74.5, -74.5))
  )
  expect_equal(
    parse_llstr(c("-74.5, 45.5", "N45.5, W74.5"), order = "lat_lon"),
    data.frame(lat = c(-74.5, 45.5), lon = c(45.5, -74.5))
  )
})

test_that("a forced order with letters that do not fit it gives NA and a warning", {
  res <- collect_warnings(
    parse_llstr(c("N45.5, W74.5", "45.5, 74.5"), order = "lon_lat")
  )
  expect_equal(res[["value"]], data.frame(lat = c(NA, 74.5), lon = c(NA, 45.5)))
  expect_identical(
    res[["warnings"]],
    "direction letters do not fit order = \"lon_lat\", got: N45.5, W74.5"
  )
  for (x in c("W74.5, N45.5", "W74.5, 45.5", "74.5, 45.5N")) {
    expect_warning(
      res <- parse_llstr(x, order = "lat_lon"),
      paste0("do not fit order = \"lat_lon\", got: ", x),
      fixed = TRUE
    )
    expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_), label = x)
  }
})

test_that("order must be one of auto, lat_lon and lon_lat", {
  expect_error(parse_llstr("1, 2", order = "latlon"), "should be one of")
  expect_error(parse_llstr("1, 2", order = c("lat_lon", "lon_lat")), "length 1")
  # partial matching, as with match.arg()
  expect_equal(
    parse_llstr("1, 2", order = "lon"),
    data.frame(lat = 2, lon = 1)
  )
})

test_that("order does not change the split warnings or NA input", {
  expect_warning(
    res <- parse_llstr(c("4545", NA, "1, 2"), order = "lon_lat"),
    "could not split into latitude and longitude, got: 4545"
  )
  expect_equal(res, data.frame(lat = c(NA, NA, 2), lon = c(NA, NA, 1)))
  expect_equal(
    parse_llstr(character(0), order = "lon_lat"),
    data.frame(lat = numeric(0), lon = numeric(0))
  )
})

# a latitude that looks like a longitude ------------------------------------

swap_hint <- function(order) {
  paste0("may come first: try order = \"", order, "\"")
}

test_that("a latitude out of range that is a valid longitude gives NA for both", {
  # before, "101.347, 4.9196" gave lat NA and lon 4.9196
  res <- collect_warnings(parse_llstr("101.347, 4.9196"))
  expect_equal(res[["value"]], data.frame(lat = NA_real_, lon = NA_real_))
  expect_length(res[["warnings"]], 2L)
  expect_match(res[["warnings"]][[1]], "not within -90/90 range, got: 101.347")
  expect_identical(
    res[["warnings"]][[2]],
    paste0(
      "latitude out of range but valid as a longitude, so longitude may ",
      "come first: try order = \"lon_lat\", got: 101.347, 4.9196"
    )
  )
  # the order that the warning suggests reads it
  expect_no_warning(res <- parse_llstr("101.347, 4.9196", order = "lon_lat"))
  expect_equal(res, data.frame(lat = 4.9196, lon = 101.347))
  for (x in c(
    "190, 45",
    "-91 30",
    "-180, 4",
    "360, 4",
    "90.5 1",
    "101 30 15, 4"
  )) {
    res <- collect_warnings(parse_llstr(x))
    expect_equal(
      res[["value"]],
      data.frame(lat = NA_real_, lon = NA_real_),
      label = x
    )
    expect_match(
      res[["warnings"]][[2]],
      swap_hint("lon_lat"),
      fixed = TRUE,
      label = x
    )
  }
})

test_that("a latitude that looks like a longitude: forced orders", {
  res <- collect_warnings(parse_llstr("101.347, 4.9196", order = "lat_lon"))
  expect_equal(res[["value"]], data.frame(lat = NA_real_, lon = NA_real_))
  expect_match(res[["warnings"]][[2]], swap_hint("lon_lat"), fixed = TRUE)
  # with longitude first, the latitude is the second value
  res <- collect_warnings(parse_llstr("4.9196, 101.347", order = "lon_lat"))
  expect_equal(res[["value"]], data.frame(lat = NA_real_, lon = NA_real_))
  expect_match(res[["warnings"]][[2]], swap_hint("lat_lon"), fixed = TRUE)
})

test_that("other failures keep the working half, warnings included", {
  cases <- list(
    # input, lat, lon, the one warning
    list("abc, -74.5", NA, -74.5, "no digits detected, got: abc"),
    list("45, abc", 45, NA, "no digits detected, got: abc"),
    # out of the longitude range too
    list("400, 45", NA, 45, "not within -90/90 range, got: 400"),
    list("45:75, 10", NA, 10, "minutes or seconds not within 0/60 range"),
    list("45, 190.5W", 45, NA, "not within -180/360 range"),
    # a direction letter fixes the order, so the order is not in doubt
    list("101.347, 4.9196E", NA, 4.9196, "not within -90/90 range"),
    list("S101.347, 4.9", NA, 4.9, "not within -90/90 range"),
    list("4.9, 101.347N", NA, 4.9, "not within -90/90 range, got: 101.347n")
  )
  for (case in cases) {
    res <- collect_warnings(parse_llstr(case[[1]]))
    expect_equal(
      res[["value"]],
      data.frame(lat = as.numeric(case[[2]]), lon = as.numeric(case[[3]])),
      label = case[[1]]
    )
    expect_length(res[["warnings"]], 1L)
    expect_match(res[["warnings"]], case[[4]], label = case[[1]])
  }
})

test_that("a latitude that looks like a longitude does not change the other rows", {
  res <- collect_warnings(
    parse_llstr(c("101.347, 4.9196", "45, 74", "abc, -74.5", NA))
  )
  expect_equal(
    res[["value"]],
    data.frame(lat = c(NA, 45, NA, NA), lon = c(NA, 74, -74.5, NA))
  )
  expect_length(res[["warnings"]], 3L)
})

test_that("every E is the direction letter E, even between two digits", {
  # same layout as "45W54.2356": the E says that longitude comes first
  expect_no_warning(res <- parse_llstr(c("45E30.5, 10", "10, 45E30.5")))
  lon <- 45 + 30.5 / 60
  expect_equal(res, data.frame(lat = c(10, 10), lon = c(lon, lon)))
  # so the "e" of an exponent is a letter too; parse_lon() cannot read "1.5e2"
  res <- collect_warnings(parse_llstr(c("1.5e2, 4", "45N, 74E", "E74, N45")))
  expect_equal(
    res[["value"]],
    data.frame(lat = c(4, 45, 45), lon = c(NA, 74, 74))
  )
  expect_identical(res[["warnings"]], "invalid characters, got: 1.5e2")
})

test_that("the swap hint needs a latitude out of range", {
  # NA latitude for another reason: no hint, and the longitude is kept
  for (x in c("40.25.30, 10", "45x, 10")) {
    res <- collect_warnings(parse_llstr(x))
    expect_equal(
      res[["value"]],
      data.frame(lat = NA_real_, lon = 10),
      label = x
    )
    expect_length(res[["warnings"]], 1L)
    expect_no_match(res[["warnings"]], "try order", fixed = TRUE, label = x)
  }
  res <- collect_warnings(parse_llstr("120, 45"))
  expect_equal(res[["value"]], data.frame(lat = NA_real_, lon = NA_real_))
  expect_match(res[["warnings"]][[2]], swap_hint("lon_lat"), fixed = TRUE)
})

test_that("format: a latitude that looks like a longitude gives NA for both", {
  res <- collect_warnings(parse_llstr("101.347 4.9196", format = "DDD.d D.d"))
  expect_equal(res[["value"]], data.frame(lat = NA_real_, lon = NA_real_))
  expect_identical(
    res[["warnings"]],
    paste0(
      "NA for 1 value(s) that could not be read with `format`:\n",
      "  \"101.347 4.9196\": latitude out of range but valid as a longitude, ",
      "so longitude may come first: try order = \"lon_lat\""
    )
  )
  expect_equal(
    parse_llstr("101.347 4.9196", format = "DDD.d D.d", order = "lon_lat"),
    data.frame(lat = 4.9196, lon = 101.347)
  )
  expect_warning(
    res <- parse_llstr(
      "4.9196 101.347",
      format = "D.d DDD.d",
      order = "lon_lat"
    ),
    swap_hint("lat_lon"),
    fixed = TRUE
  )
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
})

test_that("format: other failures keep the working half", {
  cases <- list(
    # input, format, lat, lon, the reason in the one warning
    list(
      "401.5 4.9",
      "DDD.d D.d",
      NA,
      4.9,
      "latitude: not within -90/90 range"
    ),
    list("1017530 4.9", "DDDMMSS D.d", NA, 4.9, "latitude: minutes or seconds"),
    list(
      "101.347 4.9196E",
      "DDD.d D.dH",
      NA,
      4.9196,
      "latitude: not within -90/90 range"
    ),
    list(
      "45.5 400.5",
      "DD.d DDD.d",
      45.5,
      NA,
      "longitude: not within -180/360 range"
    )
  )
  for (case in cases) {
    res <- collect_warnings(parse_llstr(case[[1]], format = case[[2]]))
    expect_equal(
      res[["value"]],
      data.frame(lat = as.numeric(case[[3]]), lon = as.numeric(case[[4]])),
      label = case[[1]]
    )
    expect_length(res[["warnings"]], 1L)
    expect_match(res[["warnings"]], case[[5]], fixed = TRUE, label = case[[1]])
    expect_no_match(res[["warnings"]], "try order", fixed = TRUE)
  }
})
