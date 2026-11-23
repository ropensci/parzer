# The output of scrub() is pinned here, written on 2026-11-19 from the R
# version of scrub() (two gsub() calls and trimws(), commit 8cc953a), so that
# a new implementation must give exactly the same strings.

test_that("scrub() is unchanged on every string literal of the tests", {
  # scrub-cases.csv: each distinct STR_CONST token that getParseData() found
  # in tests/testthat/*.R, and its output from the R scrub(). 1085 rows.
  cases <- utils::read.csv(
    file = test_path("scrub-cases.csv"),
    colClasses = "character",
    na.strings = character(0),
    encoding = "UTF-8"
  )
  expect_identical(object = nrow(cases), expected = 1085L)
  expect_identical(
    object = scrub(cases[["input"]]),
    expected = cases[["expected"]]
  )
})

latin1 <- function(...) {
  x <- rawToChar(as.raw(c(...)))
  Encoding(x) <- "latin1"
  x
}

# input, expected output
edge_cases <- list(
  c(NA, ""),
  c("", ""),
  c(" ", ""),
  # Unicode minus sign, en dash and em dash
  c("\u2212", "-"),
  c("\u2013", "-"),
  c("\u2014", "-"),
  c("\u221245.5", "-45.5"),
  c("40\u221225\u20136\u2014", "40-25-6-"),
  # degree marks
  c("°", "'"),
  c("º", "'"),
  c("40° 25º", "40' 25'"),
  c("d", "'"),
  c("g", "'"),
  c("D", "'"),
  c("G", "'"),
  c("40d 25g 6D 7G", "40' 25' 6' 7'"),
  # quotes
  c("’", "'"),
  c("´", "'"),
  c("″", "'"),
  c("40°25’54.5″N", "40'25'54.5'N"),
  c("‘ “ ” ′ `", "' ' ' ' '"),
  # latin1 and UTF-8 non-ASCII text: one "'" per character, not per byte
  c(latin1(0x34, 0x30, 0xb0, 0x20, 0x32, 0x35, 0x27, 0x20, 0x4e), "40' 25' N"),
  c(latin1(0x63, 0x61, 0x66, 0xe9), "caf'"),
  c("café", "caf'"),
  # "e" and a combining acute accent are two characters
  c("e\u0301", "e'"),
  # a no-break space is not a space
  c("N\u00a040", "N'40"),
  c("中文 40", "'' 40"),
  c("\U0001F600", "'"),
  c("40\U0001F600N", "40'N"),
  # tabs and line breaks are replaced, so only spaces are trimmed
  c("\t40\n", "'40'"),
  c("40\r\n", "40''"),
  c("  40 N  ", "40 N"),
  c("   ", ""),
  c(" °40° ", "'40'")
)

test_that("scrub() is unchanged on edge cases, one by one and together", {
  for (case in edge_cases) {
    expect_identical(
      object = scrub(case[[1L]]),
      expected = case[[2L]],
      label = encodeString(case[[1L]], quote = "\"")
    )
  }
  expect_identical(
    object = scrub(unlist(lapply(X = edge_cases, FUN = `[[`, 1L))),
    expected = unlist(lapply(X = edge_cases, FUN = `[[`, 2L))
  )
})

test_that("scrub() is unchanged on numeric input", {
  # num_to_chr() writes each number on its own
  expect_identical(
    object = scrub(c(1e5, -0.5, 1e-10)),
    expected = c("100000", "-0.5", "0.0000000001")
  )
  expect_identical(
    object = scrub(c(40.4183318, NA, NaN, Inf, -Inf)),
    expected = c("40.4183318", "", "", "Inf", "-Inf")
  )
  expect_identical(
    object = scrub(c(-45L, NA, 120L)),
    expected = c("-45", "", "120")
  )
  expect_identical(object = scrub(0), expected = "0")
})

test_that("scrub() stops on invalid UTF-8, as the R version did", {
  # marked as UTF-8: in a latin1 locale, unmarked bytes are valid text
  bad <- c(
    "40\xb0",
    # overlong form of "/" and a surrogate: validUTF8() rejects them too
    "40\xc0\xaf",
    "40\xed\xa0\x80",
    # a cut UTF-8 sequence: the first two bytes of a minus sign
    "40\xe2\x88"
  )
  Encoding(bad) <- "UTF-8"
  expect_error(
    object = scrub(c("40", bad[[1]])),
    regexp = "input string 2 is invalid UTF-8"
  )
  for (s in bad[-1]) {
    expect_error(object = scrub(s), regexp = "invalid UTF-8")
  }
  expect_error(object = parse_lat(bad[[1]]), regexp = "invalid UTF-8")
})

test_that("scrub() stops on strings marked \"bytes\"", {
  x <- "40\xb0"
  Encoding(x) <- "bytes"
  expect_error(
    object = scrub(c("40", x)),
    regexp = "input string 2 is marked as \"bytes\"",
    fixed = TRUE
  )
  expect_error(object = parse_lon(x), regexp = "bytes", fixed = TRUE)
})

test_that("scrub() stops on latin1 bytes that Windows-1252 leaves undefined", {
  # enc2utf8() would turn them into "<81>" and so on, read as 81
  x <- c("\x81", "\x8d", "\x8f", "\x90", "\x9045", "\x9d")
  Encoding(x) <- "latin1"
  for (s in x) {
    expect_error(
      object = scrub(c("40", s)),
      regexp = "input string 2 is marked as \"latin1\" but has a byte",
      fixed = TRUE
    )
  }
  expect_error(object = parse_lat(x[[1]]), regexp = "latin1", fixed = TRUE)
  expect_error(object = parse_lon(x[[5]]), regexp = "latin1", fixed = TRUE)
  pair <- "\x81, \x90"
  Encoding(pair) <- "latin1"
  expect_error(object = parse_llstr(pair), regexp = "latin1", fixed = TRUE)
  expect_error(
    object = parse_parts_lat(x[[1]]),
    regexp = "latin1",
    fixed = TRUE
  )
  # other latin1 bytes are characters and are cleaned as usual
  y <- c("45\xb0", "\x80 5", "\xff")
  Encoding(y) <- "latin1"
  expect_identical(object = scrub(y), expected = c("45'", "' 5", "'"))
})

test_that("\"bytes\" and latin1 junk give the same error with or without format", {
  # each case: one value, one "lat lon" string, the start of the error
  bytes <- c("45\xb0", "45\xb0 30")
  Encoding(bytes) <- "bytes"
  junk <- c("\x9045", "\x81 \x90")
  Encoding(junk) <- "latin1"
  cases <- list(
    bytes = list(
      x = bytes,
      msg = "input string 2 is marked as \"bytes\", convert it to UTF-8 first"
    ),
    latin1 = list(
      x = junk,
      msg = "input string 2 is marked as \"latin1\" but has a byte"
    )
  )
  for (case in cases) {
    x <- c("45", case[["x"]][[1]])
    pair <- c("45 45", case[["x"]][[2]])
    calls <- list(
      function() parse_lat(x),
      function() parse_lat(x, format = "DD"),
      function() parse_lon(x),
      function() parse_lon(x, format = "DD"),
      function() parse_llstr(pair),
      function() parse_llstr(pair, format = "DD DD")
    )
    for (f in calls) {
      expect_error(object = f(), regexp = case[["msg"]], fixed = TRUE)
    }
  }
})
