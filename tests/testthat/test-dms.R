# degree-minute-second fxns

test_that("pz_degree works", {
  aa <- pz_degree(45.23323)

  expect_type(aa, "integer")
  expect_equal(aa, 45)
})

test_that("pz_minute works", {
  aa <- pz_minute(45.23323)

  expect_type(aa, "integer")
  expect_equal(aa, 13)
})

test_that("pz_second works", {
  aa <- pz_second(45.23323)

  expect_type(aa, "double")
  expect_equal(round(aa), 60)
})

test_lats <- c(
  "40.4183318",
  "40.4183318° N",
  "40° 25´ 5.994\" N",
  "40° 25.0999’",
  "N40°25’5.994",
  "40°25’5.994\"N",
  "40 25 5.994",
  "40.4183318",
  "40.4183318°",
  "40.4183318N",
  "40°25’5.994\"N",
  "N 40 25.0999",
  "40:25:6N",
  "40:25:5.994N",
  "40°25’6\"N",
  "40°25’6\"",
  "40d 25’ 6\" N",
  "40.4183318N",
  "40° 25.0999",
  "40-25-5.994N",
  "40_25_5.994N"
)

test_that("degree works with varied formats", {
  for (i in seq_along(test_lats)) {
    expect_equal(pz_degree(lat = test_lats[[i]]), 40)
    expect_equal(pz_minute(lat = test_lats[[i]]), 25)
    expect_equal(round(pz_second(lat = test_lats[[i]])), 6)
  }
})

test_that("pz_degree - fails well", {
  expect_error(pz_degree(), "is not TRUE")
  expect_error(pz_degree(4, 5), "is not TRUE")
  expect_error(pz_degree(mtcars), "lon must be of class")
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
  "60.1° W",
  "60.1° E",
  "W60.1",
  "E60.1"
  # "-40.4183318, 12.345, 74.6411133"
)

test_that("dms fxns fail as expected", {
  out <- data.frame(
    input = invalid_formats, res = NA_real_,
    stringsAsFactors = FALSE
  )
  for (i in seq_along(invalid_formats)) {
    expect_warning(pz_degree(lat = invalid_formats[i]))
    expect_warning(pz_minute(lat = invalid_formats[i]))
    expect_warning(pz_second(lat = invalid_formats[i]))
  }

  expect_error(pz_d("a"), "x must be of class")
  expect_error(pz_m("a"), "x must be of class")
  expect_error(pz_s("a"), "x must be of class")

  expect_error(pz_d(1) / pz_m(3), "division doesn't make sense here")
  expect_error(pz_d(1) * pz_m(3), "multiplication doesn't make sense here")
})

test_that("dms adder fxns", {
  # basic usage, one at a time
  deg1 <- pz_d(31)
  min1 <- pz_m(44)
  sec1 <- pz_s(17)

  expect_type(deg1, "double")
  expect_type(min1, "double")
  expect_type(sec1, "double")

  expect_equal(deg1[1], 31)
  expect_equal(min1[1], 44)
  expect_equal(sec1[1], 17)

  # addition
  add1 <- pz_d(31) + pz_m(44)
  add2 <- pz_d(31) + pz_m(44) + pz_s(59)

  expect_type(add1, "double")
  expect_type(add2, "double")

  expect_equal(round(add1[1], 2), 31.73)
  expect_equal(round(add2[1], 2), 31.75)

  # subtraction
  sub1 <- pz_d(5) - pz_m(49)
  sub2 <- pz_d(-34) - pz_m(56) - pz_s(3)

  expect_type(sub1, "double")
  expect_type(sub2, "double")

  expect_equal(round(sub1[1], 2), 4.18)
  expect_equal(round(sub2[1], 2), -34.93)
})

test_that("dms fxns: utilities", {
  # unclass_strip_atts
  z <- structure("a", foo = "bar")
  zz <- unclass_strip_atts(z)
  expect_type(attributes(z), "list")
  expect_null(attributes(zz))

  # print.pz
  expect_output(print(pz_d(31)), "31")
})
