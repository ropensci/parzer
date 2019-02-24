#' parse coordinates into degrees, minutes and seconds
#'
#' BEWARE: EXPERIMENTAL
#'
#' @export
#' @param lat (character/numeric/integer) one or more latitude values
#' @param lon (character/numeric/integer) one or more longitude values
#' @param format format, deafult often works
#' @return character vector of quadrants, one of: NE, NW, SE, SW
#' @examples
#' # NE
#' parse_hemisphere("45N54.2356", "40.123N74.123W")
#' # NW
#' parse_hemisphere("40.4183318", "-120")
#' # SW
#' parse_hemisphere("-40.4183318", "-120")
#' # SE
#' parse_hemisphere("-40.4183318", "120")
#'
#' # many inputs
#' library(randgeo)
#' pts <- rg_position(count = 1000)
#' lats <- as.character(vapply(pts, "[[", 1, 1))
#' lons <- as.character(vapply(pts, "[[", 1, 2))
 #' parse_hemisphere(lats, lons)
parse_hemisphere <- function(lat, lon, format = "") {
  assert(lat, "character")
  assert(lon, "character")
  pz_hemisphere(lat, lon, format)
}
