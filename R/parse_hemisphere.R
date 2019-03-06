#' get hemisphere from lat/long coordinates
#'
#' BEWARE: EXPERIMENTAL
#'
#' @export
#' @param lat (character/numeric/integer) one or more latitude values
#' @param lon (character/numeric/integer) one or more longitude values
#' @details length(lat) == length(lon)
#' @return character vector of quadrants, one of: NE, NW, SE, SW.
#' if one of the coordinate values is invalid, and one is valid, you get
#' the a length 1 string. if both coordinate values are bad, you get
#' zero length string.
#' @examples
#' # NE
#' parse_hemisphere("45N54.2356", "74.123E")
#' # NW
#' parse_hemisphere("40.4183318", "-120")
#' # SW
#' parse_hemisphere("-40.4183318", "-120")
#' # SE
#' parse_hemisphere("-40.4183318", "120")
#'
#' # bad inputs, get one of the two strings
#' parse_hemisphere("-40.4183318", "-181")
#' parse_hemisphere("-192.4183318", "-120")
#'
#' # many inputs
#' library(randgeo)
#' pts <- rg_position(count = 1000)
#' lats <- as.character(vapply(pts, "[[", 1, 2))
#' lons <- as.character(vapply(pts, "[[", 1, 1))
#' parse_hemisphere(lats, lons)
parse_hemisphere <- function(lat, lon) {
  lint_inputs(lat, lon, "")
  stopifnot(length(lat) == length(lon))
  pz_hemisphere(lat, lon)
}
