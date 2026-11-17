#' parse string with lat and lon together
#'
#' @export
#' @param str (character) string with latitude and longitude, one or more in a vector.
#' @return A data.frame with parsed latitude and longitude in decimal degrees.
#' A string that cannot be cut into two coordinates gives `NA` in both columns
#' and a warning.
#' @details
#' Each string is cut into a latitude part and a longitude part, in that
#' order, then the parts go through [parse_lat()] and [parse_lon()]. The cut
#' is made at:
#'
#' - the comma, when the string has exactly one comma. Spaces around the comma
#'   and inside each part are fine: `"45.5, -74.5"`, `"45 30 15 S , 74 30 15 W"`
#' - the only space, when the string has no comma and exactly one space:
#'   `"45.5 -74.5"`, `"N45.5 W74.5"`, `"45.5N 74.5W"`. Degrees, minutes and
#'   seconds then need a symbol between them, not a space:
#'   `"45°30'15\"S 74°30'15\"W"`, `"45:30:15 -74:30:15"`
#'
#' Strings with no separator (`"N45.5W74.5"`), with two or more commas, or
#' with two or more spaces and no comma (`"45 30 74 30"`) give `NA` with a
#' warning. A dot is never a separator: `"45.74"` is one number, not two
#' coordinates.
#'
#' Each part accepts the formats of [parse_lat()] and [parse_lon()]:
#'
#' - decimal degrees, signed: `"45.5, -74.5"`
#' - a hemisphere letter before or after the number: `"N45.5, W74.5"`,
#'   `"45.5S, 74.5E"`
#' - degrees and decimal minutes: `"45 30.5, -74 30.5"`, `"N45°30.5', W74°30.5'"`
#' - degrees, minutes and seconds with any symbols or a dash between them:
#'   `"45°30'15\", -74°30'15\""`, `"45:30:15N, 74:30:15W"`, `"45-30-15, 74-30-15"`
#' - a Unicode minus sign or a dash (`−`, `–`) in front of a number is read as a
#'   minus sign
#'
#' @examples
#' parse_llstr("N 04.1683, E 101.5823")
#' parse_llstr("N04.82344, E101.61320")
#' parse_llstr("N 04.25164, E 101.70695")
#' parse_llstr("N05.03062, E101.75172")
#' parse_llstr("N05.03062,E101.75172")
#' parse_llstr("N4.9196, E101.345")
#' parse_llstr("N4.9196, E101.346")
#' parse_llstr("N4.9196, E101.347")
#' # no comma: the only space is the separator
#' parse_llstr("N4.9196 E101.347")
#' # signed decimal degrees
#' parse_llstr("4.9196 -101.347")
#'
#' # DMS
#' parse_llstr("N4 51'36\", E101 34'7\"")
#' parse_llstr(c("4 51'36\"S, 101 34'7\"W", "N4 51'36\", E101 34'7\""))
#' parse_llstr("4:51:36S 101:34:7W")
#' \dontrun{
#' # not supported: no separator between latitude and longitude
#' parse_llstr("N4.9196E101.347")
#' }
parse_llstr <- function(str) {
  assert(str, "character")
  tmp <- pz_split_llstr(scrub(str))
  # "NA_STRING" marks strings that could not be split (see pz_split_llstr())
  unsplit <- tmp$lat == "NA_STRING"
  for (bad in str[unsplit & !is.na(str)]) {
    warning(
      "could not split into latitude and longitude, got: ",
      bad,
      call. = FALSE
    )
  }
  lat <- rep(NA_real_, times = length(str))
  lon <- rep(NA_real_, times = length(str))
  lat[!unsplit] <- parse_lat(tmp$lat[!unsplit])
  lon[!unsplit] <- parse_lon(tmp$lon[!unsplit])
  data.frame(lat = lat, lon = lon)
}
