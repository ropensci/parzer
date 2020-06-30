context("split_lon_lat_strings")

test_that("pz_split_llstr_string works", {
  skip_on_cran()
  example_1s <- "N4'51'36',E101'34'7'"
  example_2s <- "N4'51'36';E101'34'7'"
  example_3s <- "N4'51'36' E101'34'7'"

  expect_is(pz_split_llstr_string(example_1s), "character")
  expect_equal(length(pz_split_llstr_string(example_1s)), 2)
  expect_equal(length(pz_split_llstr_string(example_2s)), 2)
  expect_equal(length(pz_split_llstr_string(example_3s)), 2)

  expect_true(
    all(pz_split_llstr_string(example_1s) == pz_split_llstr_string(example_2s)) &&
    all(pz_split_llstr_string(example_2s) == pz_split_llstr_string(example_3s))
  )

})

test_that("pz_split_llstr_string fails well", {
  skip_on_cran()
  expect_error(pz_split_llstr_string(19.5435))
})



test_that("split_llstr works", {
  skip_on_cran()
  example_1 <- c("N4'51'36',E101'34'7'","N4'55'33',E112'13'40'")
  example_2 <- c("N4'51'36';E101'34'7'","N4'55'33';E112'13'40'")
  example_3 <- c("N4'51'36' E101'34'7'","N4'55'33' E112'13'40'")

  ll <- pz_split_llstr(example_1)

  expect_is(ll, "data.frame")
  expect_equal(NCOL(ll), 2)
  expect_equal(NROW(ll), 2)
  expect_named(ll, c("lon", "lat"))
  expect_type(ll$lon, "character")
  expect_type(ll$lat, "character")

  expect_true(
    all(pz_split_llstr(example_1) == pz_split_llstr(example_2)) &&
    all(pz_split_llstr(example_2) == pz_split_llstr(example_3))
  )
})

test_that("split_llstr - fails well", {
  skip_on_cran()
  expect_error(pz_split_llstr())
  # expect_error(pz_split_llstr(c("195431345", "195431345")))
  # expect_error(pz_split_llstr(195431345))
})

