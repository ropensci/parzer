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

  # src/ error
  expect_warning(parse_llstr("190, 45"), "not within -90")
  expect_warning(parse_llstr("190, 45"), "check that you did not invert")
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
