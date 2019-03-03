# context("parse_lon")

# test_that("parse_lon works", {
#   aa <- parse_lon("45W54.2356")
#
#   expect_is(aa, "numeric")
#   expect_equal(round(aa), -46)
#   expect_match(strsplit(as.character(aa), "\\.")[[1]][2], "903")
# })
#
# test_lons <- c(
#     "-74.6411133",
#     "74.6411133° W",
#     "74° 38´ 28.008\" W",
#     "-74° 38.4668’",
#     "W74°38’28.008\"",
#     "74°38’28.008\"W",
#     "-74 38 28.008",
#     "-74.6411133",
#     "-74.6411133°",
#     # "-268708007.88",
#     "74.6411133W",
#     # "7438.4668W",
#     "74°38’28.008\"W",
#     # "743828.008W",
#     "W 74 38.4668",
#     "74:38:28W",
#     "74:38:28.008W",
#     "74°38’28\"W",
#     "-74°38’28\"",
#     "74d 38’ 28\" W",
#     "74.6411133W",
#     "-74° 38.4668"
# )
#
# test_that("parse_lon works: run through test_lons", {
#   out <- data.frame(input = test_lons, res = NA_real_,
#     stringsAsFactors = FALSE)
#   for (i in seq_along(test_lons)) {
#     # cat(test_lons[i], sep = "\n")
#     out[i, "res"] <- parse_lon(test_lons[i])
#     # expect_is(out[i, "res"], "numeric")
#     expect_equal(round(parse_lon(test_lons[i]), 5), -74.64111)
#   }
#   # out
# })
#
# test_that("parse_lon - fails well", {
#   expect_error(parse_lon(), "argument \"lon\" is missing")
#   expect_error(parse_lon(mtcars), "lon must be of class")
#   expect_error(parse_lon("", 5), "format must be of class character")
# })
