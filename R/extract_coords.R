#' extract coordinates from a string
#'
#' BEWARE: EXPERIMENTAL
#'
#' @export
#' @param str (character) string including latitude and longitude
#' @return length 1 or 2 character vector
#' @examples
#' # not working
#' extract_coords("N455698735")
#'
#' # working
#' extract_coords("40.4183318, -74.6411133")
#' extract_coords("45N54.2356")
#' extract_coords("-45.98739874")
#' extract_coords("40.123N")
#' extract_coords("40.123°")
#'
#' # multiple
#' # x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' # extract_coords(x)
#' # system.time(parse_lat(rep(x, 10^4)))
extract_coords <- function(str) {
  assert(str, "character")
  stopifnot(length(str) == 1)
  pz_extract(str)
}
