test_that("scrub", {
  expect_is(scrub, "function")
  
  # degree symbol 
  expect_equal(scrub("°"), "'")
  expect_equal(scrub("40° 25.0999"), "40' 25.0999")
  expect_equal(as.character(round(parse_lat("40° 25.0999"), 5)), "40.41833")

  # 'masculine oridinal indicator' symbol
  # changes to single quote
  expect_equal(scrub("º"), "'")
  expect_equal(scrub("40º 25.0999"), "40' 25.0999")
  expect_equal(as.character(round(parse_lat("40º 25.0999"), 5)), "40.41833")
})
