# The format argument of parse_lat() and parse_lon().
#
# ONE table of cases. It holds every example of the Format and Format
# examples sections and of @examples in ?parse_lat and ?parse_lon, then edge cases, so the docs and
# the code cannot drift. Each row: input, format (NULL is the default path),
# what ("lat" or "lon"), expected value, and `warning`: a regular expression
# that the one expected warning must match, or NA for no warning.
fc <- function(input, format, what, expected, warning = NA_character_) {
  list(
    input = input,
    format = format,
    what = what,
    expected = expected,
    warning = warning
  )
}
no_match <- "does not match format"
disagree <- "minus sign and direction letter disagree"
min_sec <- "minutes or seconds not within 0/60 range"

format_cases <- list(
  # the Format examples table of ?parse_lat, in the same order
  fc("512839N", "DDMMSSH", "lat", 51 + 28 / 60 + 39 / 3600),
  fc("4556.98735", "DDMM.mmmmm", "lat", 45 + 56.98735 / 60),
  fc("4556.98735", "DDMM.m", "lat", 45 + 56.98735 / 60),
  fc("4556.9", "DDMM.m", "lat", 45 + 56.9 / 60),
  fc("N455698735", "HDDMMmmmmm", "lat", 45 + 56.98735 / 60),
  fc("2343 56N", "DDMM SSH", "lat", 23 + 43 / 60 + 56 / 3600),
  fc("23 4356N", "DD MMSSH", "lat", 23 + 43 / 60 + 56 / 3600),
  fc("23   4356N", "DD MMSSH", "lat", 23 + 43 / 60 + 56 / 3600),
  fc("2343.5N", "DDMM.mH", "lat", 23 + 43.5 / 60),
  fc("45N54.2356", "DDHMM.m", "lat", 45 + 54.2356 / 60),
  fc("s4530", "HDDMM", "lat", -45.5),
  fc("40°25'06\"N", "DD°MM'SS\"H", "lat", 40 + 25 / 60 + 6 / 3600),
  fc("40:25:06", "DD:MM:SS", "lat", 40 + 25 / 60 + 6 / 3600),
  fc("40.25", "DD.MM", "lat", 40 + 25 / 60),
  fc("45.5", "DD.d", "lat", 45.5),
  fc("-4530", "DDMM", "lat", -45.5),
  fc("−4530", "DDMM", "lat", -45.5),
  fc("-45S", "DDH", "lat", -45),
  fc("+45S", "DDH", "lat", -45),
  fc("-45N", "DDH", "lat", NA_real_, disagree),
  fc("45E", "DDH", "lat", NA_real_, "direction letter must be N or S"),
  fc("4530", c("DDMM", "DD MM"), "lat", 45.5),
  fc("45 30", c("DDMM", "DD MM"), "lat", 45.5),
  fc("453", "DDMM", "lat", NA_real_, no_match),
  fc("45 03 02N", c("DD MM SSH", "D MM SSH"), "lat", 45 + 3 / 60 + 2 / 3600),
  fc("5 03 02N", c("DD MM SSH", "D MM SSH"), "lat", 5 + 3 / 60 + 2 / 3600),
  fc("5°3'2\"N", "DD°MM'SS\"H", "lat", NA_real_, no_match),
  fc("4575", "DDMM", "lat", NA_real_, min_sec),
  fc("9000S", "DDMMH", "lat", -90),
  fc("9130", "DDMM", "lat", NA_real_, "not within -90/90 range"),

  # the Format examples table of ?parse_lon, in the same order
  fc("0002741W", "DDDMMSSH", "lon", -(27 / 60 + 41 / 3600)),
  fc("1452741E", "DDDMMSSH", "lon", 145 + 27 / 60 + 41 / 3600),
  fc("01045.5W", "DDDMM.mH", "lon", -(10 + 45.5 / 60)),
  fc("01045.12345W", "DDDMM.mH", "lon", -(10 + 45.12345 / 60)),
  fc("W0104512345", "HDDDMMmmmmm", "lon", -(10 + 45.12345 / 60)),
  fc("E0451530", "HDDDMMSS", "lon", 45 + 15 / 60 + 30 / 3600),
  fc("0451530e", "DDDMMSSH", "lon", 45 + 15 / 60 + 30 / 3600),
  fc("045E15.5", "DDDHMM.m", "lon", 45 + 15.5 / 60),
  fc("07443 56W", "DDDMM SSH", "lon", -(74 + 43 / 60 + 56 / 3600)),
  fc("074 3056W", "DDD MMSSH", "lon", -(74 + 30 / 60 + 56 / 3600)),
  fc("074   3056W", "DDD MMSSH", "lon", -(74 + 30 / 60 + 56 / 3600)),
  fc("074°30'56\"W", "DDD°MM'SS\"H", "lon", -(74 + 30 / 60 + 56 / 3600)),
  fc("074:30:56", "DDD:MM:SS", "lon", 74 + 30 / 60 + 56 / 3600),
  fc("120.5", "DDD.d", "lon", 120.5),
  fc("-0743056", "DDDMMSS", "lon", -(74 + 30 / 60 + 56 / 3600)),
  fc("−0743056", "DDDMMSS", "lon", -(74 + 30 / 60 + 56 / 3600)),
  fc("-074W", "DDDH", "lon", -74),
  fc("+074W", "DDDH", "lon", -74),
  fc("-074E", "DDDH", "lon", NA_real_, disagree),
  fc("074N", "DDDH", "lon", NA_real_, "direction letter must be E or W"),
  fc(
    "0743056W",
    c("DDDMMSSH", "DDD MM SSH"),
    "lon",
    -(74 + 30 / 60 + 56 / 3600)
  ),
  fc(
    "074 30 56W",
    c("DDDMMSSH", "DDD MM SSH"),
    "lon",
    -(74 + 30 / 60 + 56 / 3600)
  ),
  fc(
    "74 30 56W",
    c("DDD MM SSH", "DD MM SSH", "D MM SSH"),
    "lon",
    -(74 + 30 / 60 + 56 / 3600)
  ),
  fc(
    "7 30 56W",
    c("DDD MM SSH", "DD MM SSH", "D MM SSH"),
    "lon",
    -(7 + 30 / 60 + 56 / 3600)
  ),
  fc("74 30 56W", "DDD MM SSH", "lon", NA_real_, no_match),
  fc("0747530W", "DDDMMSSH", "lon", NA_real_, min_sec),
  fc("1800000W", "DDDMMSSH", "lon", -180),
  fc("1800001W", "DDDMMSSH", "lon", NA_real_, "not within -180/360 range"),
  fc("18030W", "DDDMMH", "lon", NA_real_, "not within -180/360 range"),
  fc("3600000E", "DDDMMSSH", "lon", 360),
  fc("3600001E", "DDDMMSSH", "lon", NA_real_, "not within -180/360 range"),

  # the text of the Format section
  fc("05", "DD", "lat", 5),
  fc("5", "DD", "lat", NA_real_, no_match),
  fc(2741, "DDDMMSS", "lon", NA_real_, no_match),
  fc("0002741", "DDDMMSS", "lon", 27 / 60 + 41 / 3600),

  # @examples of parse_lat()
  fc("512839N", "DDMMSSH", "lat", 51.4775),
  fc(
    c("4556.9", "4556.98735"),
    "DDMM.m",
    "lat",
    c(45 + 56.9 / 60, 45 + 56.98735 / 60)
  ),
  fc(c("-45S", "+45S"), "DDH", "lat", c(-45, -45)),
  fc(4530, "DDMM", "lat", 45.5),
  fc(
    c("4530", "45 30", "N4530"),
    c("DDMM", "DD MM", "HDDMM"),
    "lat",
    c(45.5, 45.5, 45.5)
  ),
  fc(
    c("45 03 02N", "5 03 02N"),
    c("DD MM SSH", "D MM SSH"),
    "lat",
    c(45 + 3 / 60 + 2 / 3600, 5 + 3 / 60 + 2 / 3600)
  ),
  fc(
    c("-45N", "45E", "4575"),
    c("DDH", "DDMM"),
    "lat",
    c(NA_real_, NA_real_, NA_real_),
    "NA for 3 value"
  ),
  fc("2343 56N", NULL, "lat", NA_real_, "may be packed together"),

  # @examples of parse_lon()
  fc("E0451530", "HDDDMMSS", "lon", 45 + 15 / 60 + 30 / 3600),
  fc("01045.5W", "DDDMM.mH", "lon", -(10 + 45.5 / 60)),
  fc(
    c("0002741W", "000 27 41W"),
    c("DDDMMSSH", "DDD MM SSH"),
    "lon",
    rep(-(27 / 60 + 41 / 3600), times = 2)
  ),
  fc(
    c("074 30 56W", "74 30 56W", "7 30 56W"),
    c("DDD MM SSH", "DD MM SSH", "D MM SSH"),
    "lon",
    c(
      -(74 + 30 / 60 + 56 / 3600),
      -(74 + 30 / 60 + 56 / 3600),
      -(7 + 30 / 60 + 56 / 3600)
    )
  ),
  fc(
    c("045N", "18030W"),
    c("DDDH", "DDDMMH"),
    "lon",
    c(NA_real_, NA_real_),
    "NA for 2 value"
  ),

  # edge cases: white space
  fc("  512839N\t", "DDMMSSH", "lat", 51 + 28 / 60 + 39 / 3600),
  fc("45\t30", "DD MM", "lat", 45.5),
  fc("4530", "DD MM", "lat", NA_real_, no_match),
  fc("40° 25' 06\" N", "DD° MM' SS\" H", "lat", 40 + 25 / 60 + 6 / 3600),
  # edge cases: regex metacharacters match themselves
  fc("40x25", "DD.MM", "lat", NA_real_, no_match),
  fc("(45)", "(DD)", "lat", 45),
  fc("[45]", "[DD]", "lat", 45),
  fc("{45}", "{DD}", "lat", 45),
  fc("45*", "DD*", "lat", 45),
  fc("45?", "DD?", "lat", 45),
  fc("45|", "DD|", "lat", 45),
  fc("45+30", "DD+MM", "lat", 45.5),
  fc("45^30$", "DD^MM$", "lat", 45.5),
  fc("45\\30", "DD\\MM", "lat", 45.5),
  # edge cases: the input is not cleaned as with format = NULL
  fc("40d25", "DD°MM", "lat", NA_real_, no_match),
  fc("40°25", "DD°MM", "lat", 40 + 25 / 60),
  fc("45.5", "DDMM", "lat", NA_real_, no_match),
  # edge cases: decimal digits
  fc("N45569873", "HDDMMmmmmm", "lat", NA_real_, no_match),
  fc("N4556987350", "HDDMMmmmmm", "lat", NA_real_, no_match),
  fc("4556.", "DDMM.m", "lat", NA_real_, no_match),
  fc("45123", "DDddd", "lat", 45.123),
  fc("45.123456789", "DD.d", "lat", 45.123456789),
  fc("403025.5N", "DDMMSS.sH", "lat", 40 + 30 / 60 + 25.5 / 3600),
  fc("40302555N", "DDMMSSssH", "lat", 40 + 30 / 60 + 25.55 / 3600),
  fc("4559.999", "DDMM.m", "lat", 45 + 59.999 / 60),
  # edge cases: range
  fc("4560", "DDMM", "lat", NA_real_, min_sec),
  fc("453060", "DDMMSS", "lat", NA_real_, min_sec),
  fc("9000", "DDMM", "lat", 90),
  fc("-9000", "DDMM", "lat", -90),
  fc("9001", "DDMM", "lat", NA_real_, "not within -90/90 range"),
  fc("180W", "DDDH", "lon", -180),
  fc("18001W", "DDDMMH", "lon", NA_real_, "not within -180/360 range"),
  fc("360E", "DDDH", "lon", 360),
  fc("36001E", "DDDMMH", "lon", NA_real_, "not within -180/360 range"),
  fc("045", "DDD", "lat", 45),
  # edge cases: signs and letters
  fc("+4530", "DDMM", "lat", 45.5),
  fc("–4530", "DDMM", "lat", -45.5),
  fc("—4530", "DDMM", "lat", -45.5),
  fc("−45S", "DDH", "lat", -45),
  fc("−45N", "DDH", "lat", NA_real_, disagree),
  fc("+45N", "DDH", "lat", 45),
  fc("N-45", "HDD", "lat", NA_real_, disagree),
  fc("S-45", "HDD", "lat", -45),
  fc("N -45", "H DD", "lat", NA_real_, disagree),
  fc("S -45", "H DD", "lat", -45),
  fc("-N45", "HDD", "lat", NA_real_, no_match),
  fc("--45", "DD", "lat", NA_real_, no_match),
  fc("45-", "DD", "lat", NA_real_, no_match),
  fc("45n", "DDH", "lat", 45),
  fc("45w", "DDH", "lon", -45),
  fc("045e", "DDDH", "lon", 45),
  fc("-045E", "DDDH", "lon", NA_real_, disagree),
  fc("-045W", "DDDH", "lon", -45),
  fc("45W", "DDH", "lat", NA_real_, "direction letter must be N or S"),
  fc("45n", "DDH", "lon", NA_real_, "direction letter must be E or W"),
  fc("45X", "DDH", "lat", NA_real_, no_match),
  # edge cases: missing values give NA without a warning
  fc(NA_character_, "DDMM", "lat", NA_real_),
  fc("", "DDMM", "lat", NA_real_),
  fc("   ", "DDMM", "lat", NA_real_),
  fc(c("4530", NA), "DDMM", "lat", c(45.5, NA)),
  # edge cases: numbers
  fc(4530L, "DDMM", "lat", 45.5),
  fc(-4530, "DDMM", "lat", -45.5),
  fc(4556.98735, "DDMM.m", "lat", 45 + 56.98735 / 60),
  fc(c(4530, NA, NaN), "DDMM", "lat", c(45.5, NA, NA)),
  # edge cases: the first format that matches wins, even if the value is bad
  fc("1234", c("DDMM", "DDDM"), "lon", 12 + 34 / 60),
  fc("1234", c("DDDM", "DDMM"), "lon", 123 + 4 / 60),
  fc("4575", c("DDMM", "DDMm"), "lat", NA_real_, min_sec),
  fc("4575", c("DDMm", "DDMM"), "lat", 45 + 7.5 / 60)
)

parse_case <- function(case) {
  fun <- if (identical(case[["what"]], "lat")) parse_lat else parse_lon
  collect_warnings(fun(case[["input"]], format = case[["format"]]))
}

test_that("format: every documented example and edge case", {
  for (case in format_cases) {
    label <- paste0(
      "parse_",
      case[["what"]],
      "(",
      deparse(case[["input"]]),
      ", format = ",
      deparse(case[["format"]]),
      ")"
    )
    res <- parse_case(case)
    expect_equal(res[["value"]], case[["expected"]], label = label)
    if (is.na(case[["warning"]])) {
      expect_identical(res[["warnings"]], character(0), label = label)
    } else {
      expect_identical(length(res[["warnings"]]), 1L, label = label)
      expect_match(res[["warnings"]], case[["warning"]], label = label)
    }
  }
})

# item by item: the one warning ---------------------------------------------

test_that("format: values that do not match give NA and one warning listing them", {
  res <- collect_warnings(
    parse_lat(c("453", "4530", "45.5", NA, ""), format = "DDMM")
  )
  expect_equal(res[["value"]], c(NA, 45.5, NA, NA, NA))
  expect_length(res[["warnings"]], 1L)
  expect_match(
    res[["warnings"]],
    "NA for 2 value\\(s\\) that could not be read"
  )
  expect_match(
    res[["warnings"]],
    "\"453\": does not match format",
    fixed = TRUE
  )
  expect_match(
    res[["warnings"]],
    "\"45.5\": does not match format",
    fixed = TRUE
  )
  # no fallback to format = NULL, which reads "45.5"
  expect_equal(parse_lat("45.5"), 45.5)
})

test_that("format: values out of range give NA and are listed in the same warning", {
  expect_warning(
    res <- parse_lat(c("9130", "4575", "453"), format = "DDMM"),
    paste0(
      "NA for 3 value\\(s\\).*\n",
      "  \"9130\": not within -90/90 range\n",
      "  \"4575\": minutes or seconds not within 0/60 range\n",
      "  \"453\": does not match format"
    )
  )
  expect_equal(res, c(NA_real_, NA_real_, NA_real_))
  expect_warning(
    parse_lon("18030W", format = "DDDMMH"),
    "\"18030W\": not within -180/360 range"
  )
})

test_that("format: a long list of bad values is cut after 10", {
  res <- collect_warnings(parse_lat(as.character(1:12), format = "DDMM"))
  expect_length(res[["warnings"]], 1L)
  expect_match(res[["warnings"]], "NA for 12 value")
  expect_match(res[["warnings"]], "\"10\": does not match format")
  expect_no_match(res[["warnings"]], "\"11\"")
  expect_match(res[["warnings"]], "\\.\\.\\. and 2 more$")
})

test_that("format: a number is read the same way whatever the other numbers", {
  expect_equal(parse_lat(4530, format = "DDMM"), 45.5)
  expect_no_warning(
    res <- parse_lat(c(4530, 45.5), format = c("DDMM", "DD.d"))
  )
  expect_equal(res, c(45.5, 45.5))
  expect_no_warning(
    res <- parse_lon(c(1452741, 0.5), format = c("DDDMMSS", "D.d"))
  )
  expect_equal(res, c(145 + 27 / 60 + 41 / 3600, 0.5))
  expect_no_warning(
    res <- parse_lon_lat(
      lon = c(12043, 1.5),
      lat = c(4530, 45.5),
      lon_format = c("DDDMM", "D.d"),
      lat_format = c("DDMM", "DD.d")
    )
  )
  expect_equal(
    res,
    data.frame(lon = c(120 + 43 / 60, 1.5), lat = c(45.5, 45.5))
  )
})

test_that("format: fields are cut by characters, not bytes", {
  # the minus sign and the degree sign take several bytes in UTF-8
  expect_equal(
    parse_lat(c("45°30", "−45°30"), format = "DD°MM"),
    c(45.5, -45.5)
  )
  # a format marked "bytes" would make the regular expression count bytes
  fmt <- "DD°MM"
  Encoding(fmt) <- "bytes"
  expect_error(
    object = parse_lat("45°30", format = fmt),
    regexp = "format is marked as \"bytes\"",
    fixed = TRUE
  )
  expect_error(
    object = parse_llstr("45°30 45", format = paste(fmt, "DD")),
    regexp = "format is marked as \"bytes\"",
    fixed = TRUE
  )
})

test_that("format: NA input gives NA without a warning", {
  expect_no_warning(res <- parse_lat(c(NA_character_, NA), format = "DDMM"))
  expect_equal(res, c(NA_real_, NA_real_))
  expect_no_warning(res <- parse_lon(NA_real_, format = "DDDH"))
  expect_identical(res, NA_real_)
  expect_identical(parse_lat(character(0), format = "DDMM"), numeric(0))
})

# item by item: sign and letter ---------------------------------------------

test_that("format: a minus sign and N or E disagree, as with format = NULL", {
  expect_warning(
    res <- parse_lat("-45N", format = "DDH"),
    "\"-45N\": minus sign and direction letter disagree"
  )
  expect_identical(res, NA_real_)
  expect_warning(parse_lat("-45N"), "disagree")
  expect_warning(
    res <- parse_lon("−045E", format = "DDDH"),
    "minus sign and direction letter disagree"
  )
  expect_identical(res, NA_real_)
  # agree, or a plus sign: the letter gives the sign, as with format = NULL
  expect_equal(
    parse_lat(c("-45S", "+45S", "+45N"), format = "DDH"),
    c(-45, -45, 45)
  )
  expect_equal(parse_lat(c("-45S", "+45S", "+45N")), c(-45, -45, 45))
})

test_that("format: H only accepts the letters of its own pair", {
  expect_warning(
    res <- parse_lat(c("45E", "45w"), format = "DDH"),
    "\"45E\": direction letter must be N or S\n  \"45w\": direction letter must be N or S"
  )
  expect_equal(res, c(NA_real_, NA_real_))
  expect_warning(
    res <- parse_lon("045s", format = "DDDH"),
    "\"045s\": direction letter must be E or W"
  )
  expect_identical(res, NA_real_)
})

# item by item: a format that cannot work is an error ------------------------

test_that("format: a format that cannot work is an error", {
  bad_formats <- c(
    "MM" = "D \\(degrees\\) is missing",
    ".ddd" = "D \\(degrees\\) is missing",
    "dms" = "D \\(degrees\\) is missing",
    "DDXX" = "unknown letter X, use only D, M, S, d, m, s and H",
    "DDN" = "unknown letter N",
    "DDmmSS" = "m must come right after M, or after a \".\" that follows M",
    "DDmm" = "m must come right after M",
    "DD.mm" = "m must come right after M",
    "DDMMs" = "s must come right after S",
    "DDdMM" = "only the last of D, M and S can have decimal digits",
    "DD.dMM" = "only the last of D, M and S can have decimal digits",
    "MMDD" = "D, M and S must come in this order",
    "DDSSMM" = "D, M and S must come in this order",
    "DDMMDD" = "D, M and S can each be used only once",
    "DD DD" = "D, M and S can each be used only once",
    "DDSS" = "S \\(seconds\\) needs M \\(minutes\\)",
    "HDDH" = "more than one H",
    "HHDD" = "more than one H"
  )
  for (f in names(bad_formats)) {
    expect_error(parse_lat("4530", format = f), bad_formats[[f]], label = f)
    expect_error(parse_lon("4530", format = f), bad_formats[[f]], label = f)
  }
  expect_error(parse_lat("4530", format = ""), "D \\(degrees\\) is missing")
  # the message names the format
  expect_error(
    parse_lat("4530", format = "DD.mm"),
    "invalid format \"DD.mm\": m must come",
    fixed = TRUE
  )
})

test_that("format: every format is checked before any parsing", {
  expect_error(
    parse_lat("4530", format = c("DDMM", "MMDD")),
    "invalid format \"MMDD\""
  )
  expect_error(parse_lat("4530", format = NA_character_), "without NA")
  expect_error(parse_lat("4530", format = character(0)), "one or more strings")
  expect_error(
    parse_lat("4530", format = 5),
    "format must be of class character"
  )
})

# the helpers that a lat/lon pair format can reuse ----------------------------

test_that("compile_format() gives an unanchored regex and its fields", {
  f <- compile_format("HDDMM.mm")
  expect_identical(f[["groups"]], c("H", "sign", "D", "M", "dec"))
  expect_identical(f[["dec_unit"]], "M")
  expect_false(startsWith(f[["regex"]], "^"))
  fields <- matrix(
    c("S", "", "45", "30", "5"),
    nrow = 1L,
    dimnames = list(NULL, f[["groups"]])
  )
  expect_equal(
    fields_to_degrees(fields = fields, dec_unit = "M", what = "lat"),
    list(value = -(45 + 30.5 / 60), why = NA_character_)
  )
})

# parse_llstr(format =): one format for the whole string ---------------------

test_that("pair format: a format that cannot work is an error", {
  bad_pairs <- c(
    "DDMMSSH" = "needs exactly two D blocks, one for each coordinate",
    "DD DD DD" = "needs exactly two D blocks",
    "MM SS" = "needs exactly two D blocks",
    "HHDD DDD" = "invalid format \"HHDD DDD\", part \"HHDD \": more than one H",
    "DDMMSSH DDDMMSSHH" = "part \"DDDMMSSHH\": more than one H",
    "HDDHMM HDDD" = "part \"HDDHMM \": more than one H",
    "DDX DDD" = "part \"DDX \": unknown letter X",
    "DDmm DDD" = "part \"DDmm \": m must come right after M",
    "MMDD DDD" = "part \"MMDD \": D, M and S must come in this order",
    "DD DDDSS" = "part \"DDDSS\": S \\(seconds\\) needs M \\(minutes\\)"
  )
  for (f in names(bad_pairs)) {
    expect_error(
      parse_llstr("45 074", format = f),
      bad_pairs[[f]],
      fixed = !grepl(pattern = "\\\\", x = bad_pairs[[f]]),
      label = f
    )
  }
  expect_error(parse_llstr("45 074", format = ""), "two D blocks")
})

test_that("pair format: every format is checked before any parsing", {
  expect_error(
    parse_llstr("45 074", format = c("DD DDD", "DDMMSS")),
    "invalid format \"DDMMSS\""
  )
  expect_error(parse_llstr("45 074", format = NA_character_), "without NA")
  expect_error(parse_llstr("45 074", format = character(0)), "one or more")
  expect_error(parse_llstr("45 074", format = 5), "format must be of class")
  # one format of parse_lat() is not a pair format
  expect_error(parse_llstr("512839N", format = "DDMMSSH"), "two D blocks")
})

test_that("pair format: the format is cut at the start of the second D block", {
  halves <- function(f) {
    vapply(
      X = compile_pair_format(f)[["halves"]],
      FUN = function(h) paste(h[["groups"]], collapse = " "),
      FUN.VALUE = ""
    )
  }
  expect_identical(
    halves("DDMMSSH DDDMMSSH"),
    c("sign D M S H", "sign D M S H")
  )
  expect_identical(halves("DD.d DDD.d"), c("sign D dec", "sign D dec"))
  # an H between the coordinates: with the first one, unless it has an H
  expect_identical(halves("DDMMSSHDDDMMSSH"), c("sign D M S H", "sign D M S H"))
  expect_identical(halves("HD.dHDDD.d"), c("H sign D dec", "H sign D dec"))
  expect_identical(halves("DDH HDDD"), c("sign D H", "H sign D"))
  expect_identical(halves("HDD HDDD"), c("H sign D", "H sign D"))
  expect_identical(halves("HDDH DDD"), c("H sign D", "H sign D"))
  expect_identical(halves("DDHDDD"), c("sign D H", "sign D"))
  f <- compile_pair_format("HD.dHDDD.d")
  expect_identical(
    f[["groups"]],
    c("H", "sign", "D", "dec", "H", "sign", "D", "dec")
  )
  expect_false(startsWith(f[["regex"]], "^"))
})

test_that("pair format: one warning lists every string that gave an NA", {
  res <- collect_warnings(
    parse_llstr(
      c(
        "512839N 0002741W",
        "51 28 39N 000 27 41W",
        "517539N 0002741W",
        "512839N 1900000W",
        "917539N 1900000W",
        "512839N 0002741N",
        NA,
        "",
        "  "
      ),
      format = "DDMMSSH DDDMMSSH"
    )
  )
  lat <- 51 + 28 / 60 + 39 / 3600
  lon <- -(27 / 60 + 41 / 3600)
  expect_equal(
    res[["value"]],
    data.frame(
      lat = c(lat, NA, NA, lat, NA, NA, NA, NA, NA),
      lon = c(lon, NA, lon, NA, NA, NA, NA, NA, NA)
    )
  )
  expect_identical(
    res[["warnings"]],
    paste0(
      "NA for 5 value(s) that could not be read with `format`:\n",
      "  \"51 28 39N 000 27 41W\": does not match format\n",
      "  \"517539N 0002741W\": latitude: minutes or seconds not within 0/60 range\n",
      "  \"512839N 1900000W\": longitude: not within -180/360 range\n",
      "  \"917539N 1900000W\": latitude: minutes or seconds not within 0/60 range; ",
      "longitude: not within -180/360 range\n",
      "  \"512839N 0002741N\": direction letters contradict each other"
    )
  )
})

test_that("pair format: NA, empty and all-good input give no warning", {
  expect_no_warning(
    res <- parse_llstr(c(NA, "", "45 074"), format = "DD DDD")
  )
  expect_equal(res, data.frame(lat = c(NA, NA, 45), lon = c(NA, NA, 74)))
  expect_equal(
    parse_llstr(character(0), format = "DD DDD"),
    data.frame(lat = numeric(0), lon = numeric(0))
  )
})

test_that("pair format: the string is matched as it is, without cleaning", {
  expect_equal(
    parse_llstr(
      "  51°28'39\"N 000°27'41\"W ",
      format = "DD°MM'SS\"H DDD°MM'SS\"H"
    ),
    data.frame(lat = 51 + 28 / 60 + 39 / 3600, lon = -(27 / 60 + 41 / 3600))
  )
  expect_warning(
    res <- parse_llstr(
      "51d28'39\"N 000d27'41\"W",
      format = "DD°MM'SS\"H DDD°MM'SS\"H"
    ),
    "does not match format"
  )
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
  # signs, as in parse_lat(format =)
  expect_equal(
    parse_llstr(
      c("-45.5 −074.5", "+45.5S 074.5W"),
      format = c("DD.d DDD.d", "DD.dH DDD.dH")
    ),
    data.frame(lat = c(-45.5, -45.5), lon = c(-74.5, -74.5))
  )
  expect_warning(
    res <- parse_llstr("-45.5N 074.5W", format = "DD.dH DDD.dH"),
    "latitude: minus sign and direction letter disagree"
  )
  expect_equal(res, data.frame(lat = NA_real_, lon = -74.5))
})

test_that("pair format: the first format that matches wins", {
  formats <- c("DDMMSSH DDDMMSSH", "DDMMSSHDDDMMSSH", "DD MM SSH DDD MM SSH")
  expect_equal(
    parse_llstr(
      c("51 28 39N 000 27 41W", "512839N0002741W", "512839N 0002741W"),
      format = formats
    ),
    data.frame(
      lat = rep(51 + 28 / 60 + 39 / 3600, times = 3),
      lon = rep(-(27 / 60 + 41 / 3600), times = 3)
    )
  )
  # a string that matches a format but gives NA is not read again
  expect_warning(
    res <- parse_llstr("4575 07430", format = c("DDMM DDDMM", "DDMm DDDMm")),
    "latitude: minutes or seconds not within 0/60 range"
  )
  expect_equal(res, data.frame(lat = NA_real_, lon = 74.5))
})

test_that("pair format: the blocks follow order", {
  lat <- 51 + 28 / 60 + 39 / 3600
  lon <- -(27 / 60 + 41 / 3600)
  # auto: the H letters decide; no H means latitude first
  expect_equal(
    parse_llstr(
      c("512839N 0002741W", "0002741W 512839N"),
      format = c("DDMMSSH DDDMMSSH", "DDDMMSSH DDMMSSH")
    ),
    data.frame(lat = c(lat, lat), lon = c(lon, lon))
  )
  expect_equal(
    parse_llstr("0002741W 512839", format = "DDDMMSSH DDMMSS"),
    data.frame(lat = lat, lon = lon)
  )
  expect_equal(
    parse_llstr("45 074", format = "DD DDD"),
    data.frame(lat = 45, lon = 74)
  )
  # forced
  expect_equal(
    parse_llstr("074 45", format = "DDD DD", order = "lon_lat"),
    data.frame(lat = 45, lon = 74)
  )
  expect_equal(
    parse_llstr(
      "0002741W 512839N",
      format = "DDDMMSSH DDMMSSH",
      order = "lon_lat"
    ),
    data.frame(lat = lat, lon = lon)
  )
  # letters that do not fit the forced order
  res <- collect_warnings(
    parse_llstr(
      "0002741W 512839N",
      format = "DDDMMSSH DDMMSSH",
      order = "lat_lon"
    )
  )
  expect_equal(res[["value"]], data.frame(lat = NA_real_, lon = NA_real_))
  expect_match(
    res[["warnings"]],
    "\"0002741W 512839N\": direction letters do not fit order = \"lat_lon\"",
    fixed = TRUE
  )
  expect_length(res[["warnings"]], 1L)
  # the order does not change which strings match
  expect_warning(
    res <- parse_llstr(
      "512839N 0002741W",
      format = "DDDMMSSH DDMMSSH",
      order = "lon_lat"
    ),
    "\"512839N 0002741W\": does not match format",
    fixed = TRUE
  )
  expect_equal(res, data.frame(lat = NA_real_, lon = NA_real_))
})

test_that("fields_to_degrees() takes zero rows without a warning", {
  fields <- matrix(
    character(0),
    nrow = 0L,
    ncol = 4L,
    dimnames = list(NULL, c("sign", "D", "M", "dec"))
  )
  expect_no_warning(
    res <- fields_to_degrees(fields = fields, dec_unit = "M", what = "lat")
  )
  expect_identical(res, list(value = numeric(0), why = character(0)))
})

# parse_lon_lat(lon_format =, lat_format =) ----------------------------------

# ONE table for the Format examples section and the @examples with a format
# of ?parse_lon_lat. Each row: lon, lat, lon_format, lat_format, the expected
# lon and lat, and `warnings`: one regular expression per expected warning.
llc <- function(
  lon,
  lat,
  lon_format,
  lat_format,
  exp_lon,
  exp_lat,
  warnings = character(0)
) {
  list(
    lon = lon,
    lat = lat,
    lon_format = lon_format,
    lat_format = lat_format,
    expected = data.frame(lon = exp_lon, lat = exp_lat),
    warnings = warnings
  )
}
icao_lat <- 51 + 28 / 60 + 39 / 3600
icao_lon <- -(27 / 60 + 41 / 3600)
nmea_lat <- 45 + 56.98735 / 60
nmea_lon <- -(10 + 45.12345 / 60)

lon_lat_cases <- list(
  # the Format examples table of ?parse_lon_lat, in the same order
  llc("0002741W", "512839N", "DDDMMSSH", "DDMMSSH", icao_lon, icao_lat),
  llc("01045.12345W", "4556.98735N", "DDDMM.mH", "DDMM.mH", nmea_lon, nmea_lat),
  llc(
    "W0104512345",
    "N455698735",
    "HDDDMMmmmmm",
    "HDDMMmmmmm",
    nmea_lon,
    nmea_lat
  ),
  llc("-120.43", "4907.2", NULL, "DDMM.m", -120.43, 49.12),
  llc("12043W", "49.12", "DDDMMH", NULL, -(120 + 43 / 60), 49.12),
  llc(
    "0743056W",
    "453015N",
    c("DDDMMSSH", "DDD MM SSH"),
    c("DDMMSSH", "DD MM SSH"),
    -(74 + 30 / 60 + 56 / 3600),
    45 + 30 / 60 + 15 / 3600
  ),
  llc(
    "074 30 56W",
    "45 30 15N",
    c("DDDMMSSH", "DDD MM SSH"),
    c("DDMMSSH", "DD MM SSH"),
    -(74 + 30 / 60 + 56 / 3600),
    45 + 30 / 60 + 15 / 3600
  ),
  llc(
    "1800001W",
    "512839N",
    "DDDMMSSH",
    "DDMMSSH",
    NA_real_,
    icao_lat,
    "\"1800001W\": not within -180/360 range"
  ),
  llc(
    "0002741W",
    "517539N",
    "DDDMMSSH",
    "DDMMSSH",
    icao_lon,
    NA_real_,
    "\"517539N\": minutes or seconds not within 0/60 range"
  ),
  llc(
    "512839N",
    "0002741W",
    "DDDMMSSH",
    "DDMMSSH",
    NA_real_,
    NA_real_,
    c(
      "\"512839N\": does not match format",
      "\"0002741W\": does not match format"
    )
  ),
  # @examples of parse_lon_lat() with a format
  llc(
    c("0743056W", "074 30 56W"),
    c("453015N", "45 30 15N"),
    c("DDDMMSSH", "DDD MM SSH"),
    c("DDMMSSH", "DD MM SSH"),
    rep(-(74 + 30 / 60 + 56 / 3600), times = 2),
    rep(45 + 30 / 60 + 15 / 3600, times = 2)
  )
)

test_that("parse_lon_lat: every documented example with a format", {
  for (case in lon_lat_cases) {
    label <- paste0(
      "parse_lon_lat(",
      deparse(case[["lon"]]),
      ", ",
      deparse(case[["lat"]]),
      ")"
    )
    res <- collect_warnings(
      parse_lon_lat(
        lon = case[["lon"]],
        lat = case[["lat"]],
        lon_format = case[["lon_format"]],
        lat_format = case[["lat_format"]]
      )
    )
    expect_equal(
      res[["value"]],
      case[["expected"]],
      tolerance = 1e-9,
      label = label
    )
    expect_identical(
      length(res[["warnings"]]),
      length(case[["warnings"]]),
      label = label
    )
    for (i in seq_along(case[["warnings"]])) {
      expect_match(
        res[["warnings"]][[i]],
        case[["warnings"]][[i]],
        label = label
      )
    }
  }
})

# parse_llstr(format =, order =) --------------------------------------------

# ONE table for the Format examples section and the @examples of
# ?parse_llstr. Each row: str, format (NULL is the default path), order, the
# expected lat and lon, and `warnings`: one regular expression per expected
# warning, in order.
lc <- function(str, format, order, lat, lon, warnings = character(0)) {
  list(
    str = str,
    format = format,
    order = order,
    expected = data.frame(lat = lat, lon = lon),
    warnings = warnings
  )
}
swapped <- "may come first: try order"
dms_lat <- 4 + 51 / 60 + 36 / 3600
dms_lon <- 101 + 34 / 60 + 7 / 3600

llstr_cases <- list(
  # the Format examples table of ?parse_llstr, in the same order
  lc("512839N 0002741W", "DDMMSSH DDDMMSSH", "auto", icao_lat, icao_lon),
  lc("512839N0002741W", "DDMMSSHDDDMMSSH", "auto", icao_lat, icao_lon),
  lc("512839N/0002741W", "DDMMSSH/DDDMMSSH", "auto", icao_lat, icao_lon),
  lc(
    "51°28'39\"N 000°27'41\"W",
    "DD°MM'SS\"H DDD°MM'SS\"H",
    "auto",
    icao_lat,
    icao_lon
  ),
  lc(
    "4556.98735N 01045.12345W",
    "DDMM.mH DDDMM.mH",
    "auto",
    nmea_lat,
    nmea_lon
  ),
  lc(
    "4916.45,N,12311.12,W",
    "DDMM.m,H,DDDMM.m,H",
    "auto",
    49 + 16.45 / 60,
    -(123 + 11.12 / 60)
  ),
  lc(
    "N455698735W0104512345",
    "HDDMMmmmmmHDDDMMmmmmm",
    "auto",
    nmea_lat,
    nmea_lon
  ),
  lc("N4.9196E101.347", "HD.ddddHDDD.ddd", "auto", 4.9196, 101.347),
  lc("4.9196N101.347E", "D.dHDDD.dH", "auto", 4.9196, 101.347),
  lc("-45.5 -074.5", "DD.d DDD.d", "auto", -45.5, -74.5),
  lc("0002741W 512839N", "DDDMMSSH DDMMSSH", "auto", icao_lat, icao_lon),
  lc("E101.347N4.9196", "HDDD.dHD.d", "auto", 4.9196, 101.347),
  lc("101.347 4.9196", "DDD.d D.d", "lon_lat", 4.9196, 101.347),
  lc("101.347 4.9196", "DDD.d D.d", "auto", NA_real_, NA_real_, swapped),
  lc(
    "512839N 0002741W",
    "DDMMSSH DDDMMSSH",
    "lon_lat",
    NA_real_,
    NA_real_,
    "do not fit order = \"lon_lat\""
  ),
  lc(
    "512839N 0002741N",
    "DDMMSSH DDDMMSSH",
    "auto",
    NA_real_,
    NA_real_,
    "contradict each other"
  ),
  lc(
    "517539N 0002741W",
    "DDMMSSH DDDMMSSH",
    "auto",
    NA_real_,
    icao_lon,
    "latitude: minutes or seconds not within 0/60 range"
  ),
  lc(
    "512839N 1900000W",
    "DDMMSSH DDDMMSSH",
    "auto",
    icao_lat,
    NA_real_,
    "longitude: not within -180/360 range"
  ),
  lc(
    "51 28 39N 000 27 41W",
    "DDMMSSH DDDMMSSH",
    "auto",
    NA_real_,
    NA_real_,
    "does not match format"
  ),
  lc(
    "51 28 39N 000 27 41W",
    c("DDMMSSH DDDMMSSH", "DD MM SSH DDD MM SSH"),
    "auto",
    icao_lat,
    icao_lon
  ),
  lc(
    "512839N0002741W",
    c("DDMMSSH DDDMMSSH", "DDMMSSHDDDMMSSH"),
    "auto",
    icao_lat,
    icao_lon
  ),
  lc("45.5, -74.5", NULL, "auto", 45.5, -74.5),
  lc("W74.5, N45.5", NULL, "auto", 45.5, -74.5),
  lc("74.5W, 45.5", NULL, "auto", 45.5, -74.5),
  lc("-74.5, 45.5", NULL, "lon_lat", 45.5, -74.5),
  lc(
    "N45.5, W74.5",
    NULL,
    "lon_lat",
    NA_real_,
    NA_real_,
    "do not fit order = \"lon_lat\""
  ),
  lc("E45, E30", NULL, "auto", NA_real_, NA_real_, "contradict each other"),
  lc(
    "101.347, 4.9196",
    NULL,
    "auto",
    NA_real_,
    NA_real_,
    c("not within -90/90 range", swapped)
  ),
  lc("abc, -74.5", NULL, "auto", NA_real_, -74.5, "no digits detected"),
  lc("N4.9196E101.347", NULL, "auto", NA_real_, NA_real_, "could not split"),

  # @examples of parse_llstr(), in the same order
  lc("N 04.1683, E 101.5823", NULL, "auto", 4.1683, 101.5823),
  lc("N04.82344, E101.61320", NULL, "auto", 4.82344, 101.6132),
  lc("N 04.25164, E 101.70695", NULL, "auto", 4.25164, 101.70695),
  lc("N05.03062, E101.75172", NULL, "auto", 5.03062, 101.75172),
  lc("N05.03062,E101.75172", NULL, "auto", 5.03062, 101.75172),
  lc("N4.9196, E101.345", NULL, "auto", 4.9196, 101.345),
  lc("N4.9196, E101.346", NULL, "auto", 4.9196, 101.346),
  lc("N4.9196, E101.347", NULL, "auto", 4.9196, 101.347),
  lc("N4.9196 E101.347", NULL, "auto", 4.9196, 101.347),
  lc("4.9196 -101.347", NULL, "auto", 4.9196, -101.347),
  lc("N4 51'36\", E101 34'7\"", NULL, "auto", dms_lat, dms_lon),
  lc(
    c("4 51'36\"S, 101 34'7\"W", "N4 51'36\", E101 34'7\""),
    NULL,
    "auto",
    c(-dms_lat, dms_lat),
    c(-dms_lon, dms_lon)
  ),
  lc("4:51:36S 101:34:7W", NULL, "auto", -dms_lat, -dms_lon),
  lc("W101.347, N4.9196", NULL, "auto", 4.9196, -101.347),
  lc("101.347E, 4.9196", NULL, "auto", 4.9196, 101.347),
  lc("-101.347, 4.9196", NULL, "lon_lat", 4.9196, -101.347),
  lc("E45, E30", NULL, "auto", NA_real_, NA_real_, "contradict each other"),
  lc(
    "101.347, 4.9196",
    NULL,
    "auto",
    NA_real_,
    NA_real_,
    c("not within -90/90 range", swapped)
  ),
  lc("101.347, 4.9196", NULL, "lon_lat", 4.9196, 101.347),
  lc("abc, -74.5", NULL, "auto", NA_real_, -74.5, "no digits detected"),
  lc("512839N 0002741W", "DDMMSSH DDDMMSSH", "auto", icao_lat, icao_lon),
  lc("512839N0002741W", "DDMMSSHDDDMMSSH", "auto", icao_lat, icao_lon),
  lc(
    "4916.45,N,12311.12,W",
    "DDMM.m,H,DDDMM.m,H",
    "auto",
    49 + 16.45 / 60,
    -(123 + 11.12 / 60)
  ),
  lc("N4.9196E101.347", "HD.ddddHDDD.ddd", "auto", 4.9196, 101.347),
  lc("0002741W 512839N", "DDDMMSSH DDMMSSH", "auto", icao_lat, icao_lon),
  lc("101.347 4.9196", "DDD.d D.d", "lon_lat", 4.9196, 101.347),
  lc(
    c("512839N 0002741W", "512839N0002741W", "51 28 39N 000 27 41W"),
    c("DDMMSSH DDDMMSSH", "DDMMSSHDDDMMSSH", "DD MM SSH DDD MM SSH"),
    "auto",
    rep(icao_lat, times = 3),
    rep(icao_lon, times = 3)
  ),
  lc(
    c("517539N 0002741W", "512839N 0002741N"),
    "DDMMSSH DDDMMSSH",
    "auto",
    c(NA_real_, NA_real_),
    c(icao_lon, NA_real_),
    paste0(
      "NA for 2 value.*\n",
      ".*\"517539N 0002741W\": latitude: minutes or seconds.*\n",
      ".*\"512839N 0002741N\": direction letters contradict each other"
    )
  ),
  lc("N4.9196E101.347", NULL, "auto", NA_real_, NA_real_, "could not split"),
  lc(
    c("N4.9196, E101.347", "4.9196 -101.347"),
    NULL,
    "auto",
    c(4.9196, 4.9196),
    c(101.347, -101.347)
  )
)

test_that("parse_llstr: every documented example", {
  for (case in llstr_cases) {
    label <- paste0(
      "parse_llstr(",
      deparse(case[["str"]]),
      ", format = ",
      deparse(case[["format"]]),
      ", order = ",
      deparse(case[["order"]]),
      ")"
    )
    res <- collect_warnings(
      parse_llstr(
        case[["str"]],
        format = case[["format"]],
        order = case[["order"]]
      )
    )
    expect_equal(
      res[["value"]],
      case[["expected"]],
      tolerance = 1e-9,
      label = label
    )
    expect_identical(
      length(res[["warnings"]]),
      length(case[["warnings"]]),
      label = label
    )
    for (i in seq_along(case[["warnings"]])) {
      expect_match(
        res[["warnings"]][[i]],
        case[["warnings"]][[i]],
        label = label
      )
    }
  }
})

# examples given in the text of the docs, outside the example tables
test_that("examples from the text of the docs", {
  # parse_llstr(): when only one part has a letter, that part decides
  expect_equal(
    collect_warnings(parse_llstr(str = "-74.5, 45.5N")),
    list(value = data.frame(lat = 45.5, lon = -74.5), warnings = character(0))
  )
  expect_error(
    parse_llstr(str = "x", format = "DDMMSSHH DDDMMSSH"),
    regexp = "more than one H"
  )
  # parse_lat(): decimal digits right after their unit
  expect_equal(
    parse_lat(lat = "4556987", format = "DDMMmmm"),
    45 + 56.987 / 60
  )
  expect_error(
    parse_lat(lat = "4530", format = "DDX"),
    regexp = "unknown letter X"
  )
  # numbers lose their leading zeros: 0002741 is seen as "2741"
  res <- collect_warnings(parse_lon(lon = 0002741, format = "DDDMMSS"))
  expect_equal(res[["value"]], NA_real_)
  expect_match(res[["warnings"]], regexp = "\"2741\": does not match format")
  # the default path: minutes out of range
  res <- collect_warnings(parse_lat(lat = "10 30,12345"))
  expect_equal(res[["value"]], NA_real_)
  expect_match(
    res[["warnings"]],
    regexp = "minutes or seconds not within 0/60 range"
  )
})
