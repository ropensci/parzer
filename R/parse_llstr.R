#' parse string with lat and lon together
#'
#' @export
#' @param str (character) string with latitude and longitude, one or more in a vector.
#' @return A data.frame with parsed latitude and longitude in decimal degrees.
#' @examples
#' parse_llstr("N 04.1683, E 101.5823")
#' parse_llstr("N04.82344, E101.61320")
#' parse_llstr("N 04.25164, E 101.70695")
#' parse_llstr("N05.03062, E101.75172")
#' parse_llstr("N05.03062,E101.75172")
#' parse_llstr("N4.9196, E101.345")
#' parse_llstr("N4.9196, E101.346")
#' parse_llstr("N4.9196, E101.347")
#' # no comma
#' parse_llstr("N4.9196 E101.347")
#' # no space
#' parse_llstr("N4.9196E101.347")
#'
#' # DMS
#' parse_llstr("N4 51'36\", E101 34'7\"")
#' parse_llstr(c("4 51'36\"S, 101 34'7\"W", "N4 51'36\", E101 34'7\""))
#'
parse_llstr <- function(str) {

  assert(str, 'character')
  tmp <- pz_split_llstr(scrub(str))

  return(
    data.frame(
      lat = parse_lat(tmp$lat),
      lon = parse_lon(tmp$lon)
    )
  )
}

