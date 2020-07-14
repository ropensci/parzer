test_that("scrub", {
  expect_is(scrub, "function")

  # degree symbol
  expect_equal(scrub("°"), "'")
  expect_equal(scrub("40° 25.0999"), "40' 25.0999")
  expect_equal(as.character(round(parse_lat("40° 25.0999"), 5)), "40.41833")
  expect_equal(as.character(round(parse_lon("110° 33.6667"), 5)), "110.56111")

  # 'masculine oridinal indicator' symbol
  # changes to single quote
  expect_equal(scrub("º"), "'")
  expect_equal(scrub("40º 25.0999"), "40' 25.0999")
  expect_equal(scrub("``º′″"), "''''")
  expect_equal(scrub(c("N4º51′36″, E101:34′7″","N4:51′36″, E101d34′7″")),
               c("N4'51'36', E101'34'7'", "N4'51'36', E101'34'7'"))
  expect_equal(as.character(round(parse_lat("40º 25.0999"), 5)), "40.41833")
  expect_equal(as.character(round(parse_lon("110º 33.6667"), 5)), "110.56111")
})
