#' parse string with lat and lon together
#'
#' @export
#' @param str (character) string with latitude and longitude, one or more in a vector.
#' @param order (character) which coordinate comes first in `str`:
#'   `"auto"` (the default), `"lat_lon"` or `"lon_lat"`. With `"auto"`,
#'   latitude comes first, unless the direction letters only fit longitude
#'   first. See Details.
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
#'
#' # add both columns with one call, picking them by name
#' df <- data.frame(x = c("N4.9196, E101.347", "4.9196 -101.347"))
#' cbind(df, parse_llstr(str = df[["x"]])[c("lat", "lon")])
#' # dplyr:      df |> dplyr::mutate(parse_llstr(str = x)[c("lat", "lon")])
#' # data.table: dt[, c("lat", "lon") := parse_llstr(str = x)[c("lat", "lon")]]
#' \dontrun{
#' # not supported: no separator between latitude and longitude
#' parse_llstr("N4.9196E101.347")
#' }
parse_llstr <- function(str, order = c("auto", "lat_lon", "lon_lat")) {
  assert(str, "character")
  order <- match.arg(arg = order)
  halves <- pz_split_llstr(scrub(str))
  first <- halves[["lat"]]
  second <- halves[["lon"]]
  # scrub() keeps letters as typed: only N, S, E and W are direction letters
  has <- function(x, pattern) grepl(pattern = pattern, x = x)
  picked <- pick_order(
    ns1 = has(x = first, pattern = "[NSns]"),
    ew1 = has(x = first, pattern = "[EWew]"),
    ns2 = has(x = second, pattern = "[NSns]"),
    ew2 = has(x = second, pattern = "[EWew]"),
    order = order
  )
  why <- picked[["why"]]
  # "NA_STRING" marks strings that could not be split (see pz_split_llstr())
  unsplit <- first == "NA_STRING"
  why[unsplit] <- NA_character_
  why[unsplit & !is.na(str)] <- "could not split into latitude and longitude"
  ok <- !unsplit & is.na(why)
  lat_first <- picked[["lat_first"]]
  lat_half <- first
  lat_half[!lat_first] <- second[!lat_first]
  lon_half <- second
  lon_half[!lat_first] <- first[!lat_first]
  lat <- rep(NA_real_, times = length(str))
  lon <- rep(NA_real_, times = length(str))
  lat[ok] <- parse_lat(lat_half[ok])
  lon[ok] <- parse_lon(lon_half[ok])
  for (i in which(!is.na(why))) {
    warning(why[[i]], ", got: ", str[[i]], call. = FALSE)
  }
  data.frame(lat = lat, lon = lon)
}

# Which half of each string is the latitude. `ns1` and `ew1` say whether
# the first half has the direction letter N or S, E or W; `ns2` and `ew2`
# say the same of the second half. Returns `lat_first`, `why` (the reason
# for an NA row, or NA) and `can_swap` (both orders fit the letters, which
# means that the string has no direction letter).
pick_order <- function(ns1, ew1, ns2, ew2, order) {
  fits_lat_lon <- !ew1 & !ns2
  fits_lon_lat <- !ns1 & !ew2
  lat_first <- switch(
    EXPR = order,
    auto = fits_lat_lon | !fits_lon_lat,
    lat_lon = rep(TRUE, times = length(ns1)),
    lon_lat = rep(FALSE, times = length(ns1))
  )
  fits <- ifelse(test = lat_first, yes = fits_lat_lon, no = fits_lon_lat)
  why <- rep(NA_character_, times = length(ns1))
  why[!fits] <- if (identical(order, "auto")) {
    "direction letters contradict each other"
  } else {
    paste0("direction letters do not fit order = \"", order, "\"")
  }
  list(
    lat_first = lat_first,
    why = why,
    can_swap = fits_lat_lon & fits_lon_lat
  )
}
