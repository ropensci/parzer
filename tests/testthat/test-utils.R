test_that("scrub", {
  expect_type(scrub, "closure")

  # degree symbol
  expect_equal(scrub("°"), "'")
  expect_equal(scrub("40° 25.0999"), "40' 25.0999")
  expect_equal(as.character(round(parse_lat("40° 25.0999"), 5)), "40.41833")
  expect_equal(as.character(round(parse_lon("110° 33.6667"), 5)), "110.56111")

  # 'masculine oridinal indicator' symbol
  # changes to single quote
  expect_equal(scrub("º"), "'")
  expect_equal(scrub("40º 25.0999"), "40' 25.0999")
  expect_equal(scrub("``º′″"), "'''''")
  expect_equal(
    scrub(c("N4º51′36″, E101:34′7″", "N4:51′36″, E101d34′7″")),
    c("N4'51'36', E101'34'7'", "N4'51'36', E101'34'7'")
  )
  expect_equal(as.character(round(parse_lat("40º 25.0999"), 5)), "40.41833")
  expect_equal(as.character(round(parse_lon("110º 33.6667"), 5)), "110.56111")
})

test_that("scrub reads a Unicode minus sign, en dash and em dash as a minus", {
  expect_equal(scrub("−45.5"), "-45.5")
  expect_equal(scrub("–45.5"), "-45.5")
  expect_equal(scrub("—45.5"), "-45.5")
  # between parts they become a separator, like an ASCII dash
  expect_equal(scrub("40−25−6N"), "40-25-6N")
  expect_equal(scrub(c("−45.5", "45.5")), c("-45.5", "45.5"))
})

test_that("scrub turns NA into the empty string so the parser stays silent", {
  expect_equal(scrub(NA_character_), "")
  expect_equal(scrub(c("45", NA_character_)), c("45", ""))
  expect_equal(scrub(c(1.5, NA_real_, NaN)), c("1.5", "", ""))
  expect_equal(scrub(NA_integer_), "")
})

test_that("scrub keeps the symbols it replaced before the perl switch", {
  expect_equal(scrub("40°25′54.5″N"), "40'25'54.5'N")
  expect_equal(scrub("\t40\n"), "'40'")
  expect_equal(scrub("40.123°; 45W54.2356"), "40.123'' 45W54.2356")
  expect_equal(scrub("40d 25g"), "40' 25'")
  expect_equal(scrub("  40  "), "40")
})

test_that("num_to_chr formats each number on its own, without scientific notation", {
  expect_equal(num_to_chr(1e-5), "0.00001")
  # each number keeps its own decimals: `format` matches this text
  expect_equal(num_to_chr(c(1e-5, 45.5)), c("0.00001", "45.5"))
  expect_equal(num_to_chr(c(4530, 45.5)), c("4530", "45.5"))
  expect_equal(
    num_to_chr(c(1e5, 0.5, -1e-10)),
    c("100000", "0.5", "-0.0000000001")
  )
  expect_equal(num_to_chr(c(1, NA, NaN)), c("1", NA_character_, NA_character_))
  expect_equal(num_to_chr(c(-120L, 45L)), c("-120", "45"))
  expect_equal(num_to_chr(c("a", NA)), c("a", NA_character_))
  expect_equal(num_to_chr(1e20), "100000000000000000000")
  expect_equal(num_to_chr(Inf), "Inf")
  expect_no_match(num_to_chr(c(1e-12, 1e12)), "e")
  # one wide-ranged vector must not lose precision for its small elements
  x <- c(1e-15, 123456789e-15, 45.123456789012, 1e12)
  expect_equal(as.numeric(num_to_chr(x)), x, tolerance = 1e-14)
})

test_that("scrub replaces d and g degree marks in either case", {
  expect_equal(scrub("40d 25g 6"), "40' 25' 6")
  expect_equal(scrub("40D 25G 6"), "40' 25' 6")
  # other letters are left for the parser to reject
  expect_equal(scrub("40X 25"), "40X 25")
  expect_equal(scrub("N40 S E W"), "N40 S E W")
})
