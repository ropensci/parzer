#' parse string with lat and lon together
#'
#' @export
#' @param str (character) string with latitude and longitude, one or more in a vector.
#' @param format (character) `NULL` (the default) or one or more patterns
#'   that say how the whole string is written, for example
#'   `"DDMMSSH DDDMMSSH"` for `"512839N 0002741W"`. With several patterns,
#'   each string is read with the first pattern that matches it. See the
#'   Format and Format examples sections.
#' @param order (character) which coordinate comes first in `str`:
#'   `"auto"` (the default), `"lat_lon"` or `"lon_lat"`. With `"auto"`,
#'   latitude comes first, unless the direction letters only fit longitude
#'   first. See the Order section.
#' @return A data.frame with the columns `lat` and `lon`, in decimal degrees,
#'   always in this order, whatever the order in `str`.
#'
#'   Each part of a string is read on its own: when one part cannot be read,
#'   it gives `NA` with a warning, and the other part is kept. So
#'   `"abc, -74.5"` gives lat `NA` and lon -74.5. There is one exception:
#'   when the latitude is out of range (-90/90) but would be a valid
#'   longitude (-180/360), and the string has no direction letter, as in
#'   `"101.347, 4.9196"`, the two values are probably swapped. Then both are
#'   `NA`, with a warning that suggests the other `order`.
#'
#'   Both values are also `NA`, with a warning, when a string cannot be cut
#'   into two coordinates, does not match any `format`, or has direction
#'   letters that do not fit the order. `NA`, `""` and blank strings give
#'   `NA` without a warning.
#' @details
#' With `format = NULL`, each string is cut into two parts, then the latitude
#' part goes through [parse_lat()] and the longitude part through
#' [parse_lon()]. The Order section says which part is which. The cut is made
#' at:
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
#' warning: use `format` for them. A dot is never a separator: `"45.74"` is
#' one number, not two coordinates.
#'
#' Each part accepts the formats of [parse_lat()] and [parse_lon()]:
#'
#' - decimal degrees, signed: `"45.5, -74.5"`
#' - a hemisphere letter before or after the number: `"N45.5, W74.5"`,
#'   `"45.5S, 74.5E"`
#' - degrees and decimal minutes: `"45 30.5, -74 30.5"`, `"N45°30.5', W74°30.5'"`
#' - degrees, minutes and seconds with any symbols or a dash between them:
#'   `"45°30'15\", -74°30'15\""`, `"45:30:15N, 74:30:15W"`, `"45-30-15, 74-30-15"`
#' - a Unicode minus sign or a dash (U+2212, `–`) in front of a number is read as a
#'   minus sign
#'
#' @section Order:
#' With `order = "auto"` (the default), the direction letters N, S, E and W
#' (in upper or lower case) say which coordinate comes first:
#'
#' - latitude first, when there is no letter (`"45.5, -74.5"`), or when the
#'   letters fit that (`"N45.5, W74.5"`, `"45.5, 74.5W"`)
#' - longitude first, when the letters only fit that: the first part has E or
#'   W, or the second part has N or S (`"W74.5, N45.5"`, `"74.5W, 45.5"`,
#'   `"-74.5, 45.5N"`). When only one part has a letter, that part decides.
#' - `NA` for both values, with a warning, when the letters contradict each
#'   other: `"E45, E30"`, `"N45, N30"`
#'
#' With `order = "lat_lon"` or `order = "lon_lat"`, the order is forced. Use
#' it for strings with longitude first and no letters:
#' `parse_llstr("-74.5, 45.5", order = "lon_lat")`. A string with letters
#' that do not fit the forced order gives `NA` for both values, with a
#' warning: `"N45.5, W74.5"` with `order = "lon_lat"`.
#'
#' @section Format:
#' With `format`, one pattern describes the whole string: both coordinates and
#' what is between them. For example, `"DDMMSSH DDDMMSSH"` reads
#' `"512839N 0002741W"`. Each coordinate follows the rules of the Format
#' section of [parse_lat()]. In addition:
#'
#' - The pattern needs exactly two `D` blocks, one for each coordinate. It is
#'   cut in two at the start of the second `D` block: `"DDMMSSH DDDMMSSH"`
#'   gives `"DDMMSSH "` and `"DDDMMSSH"`.
#' - The two coordinates need no separator: `"DDMMSSHDDDMMSSH"` reads
#'   `"512839N0002741W"`.
#' - Each coordinate can have at most one `H`. An `H` right between the two
#'   coordinates goes with the first one, as in `"DDMMSSHDDDMMSSH"`, unless
#'   the first one already has an `H`. Then it goes with the second one, as
#'   in `"HD.ddddHDDD.ddd"`, which reads `"N4.9196E101.347"`.
#' - The coordinates follow `order`. With `"lon_lat"`, the first one is the
#'   longitude, as in `"DDDMMSSH DDMMSSH"`. With `"auto"`, the `H` letters say
#'   which one is the latitude, and a pattern without `H` means latitude
#'   first. The number of `D` letters does not decide.
#' - The string is matched as it is: it is not cleaned, and not cut at a
#'   comma or a space, as with `format = NULL`. Spaces at the start and at
#'   the end are ignored.
#' - Strings that do not match any pattern, or that give `NA` for one value
#'   or both, are listed in one warning. They are not read again with
#'   `format = NULL`.
#' - A pattern that cannot work is an error, for example `"DDMMSS"` (only
#'   one `D` block) or `"DDMMSSHH DDDMMSSH"` (two `H` for one coordinate).
#'
#' @section Format examples:
#' The rules for `format` are in the Format section above and in the Format
#' section of [parse_lat()]. `order` is `"auto"` when not given.
#'
# Every row of this table and every example of @examples is mirrored in the
# llstr_cases table of tests/testthat/test-format.R: keep the two in sync.
#' | `str` | `format` | `order` | lat | lon | Why |
#' |---|---|---|---|---|---|
#' | `"512839N 0002741W"` | `"DDMMSSH DDDMMSSH"` | | 51.4775 | -0.46139 | ICAO pair |
#' | `"512839N0002741W"` | `"DDMMSSHDDDMMSSH"` | | 51.4775 | -0.46139 | ICAO pair without a separator |
#' | `"512839N/0002741W"` | `"DDMMSSH/DDDMMSSH"` | | 51.4775 | -0.46139 | any separator, written as in the string |
#' | `"51°28'39\"N 000°27'41\"W"` | `"DD°MM'SS\"H DDD°MM'SS\"H"` | | 51.4775 | -0.46139 | symbols must match exactly |
#' | `"4556.98735N 01045.12345W"` | `"DDMM.mH DDDMM.mH"` | | 45.94979 | -10.75206 | NMEA pair |
#' | `"4916.45,N,12311.12,W"` | `"DDMM.m,H,DDDMM.m,H"` | | 49.27417 | -123.18533 | NMEA sentence, letters in their own fields |
#' | `"N455698735W0104512345"` | `"HDDMMmmmmmHDDDMMmmmmm"` | | 45.94979 | -10.75206 | decimal point not written: exactly 5 decimals |
#' | `"N4.9196E101.347"` | `"HD.ddddHDDD.ddd"` | | 4.9196 | 101.347 | `H` in front of each coordinate, no separator |
#' | `"4.9196N101.347E"` | `"D.dHDDD.dH"` | | 4.9196 | 101.347 | `H` after each coordinate, no separator |
#' | `"-45.5 -074.5"` | `"DD.d DDD.d"` | | -45.5 | -74.5 | minus signs |
#' | `"0002741W 512839N"` | `"DDDMMSSH DDMMSSH"` | | 51.4775 | -0.46139 | longitude first: the letters decide |
#' | `"E101.347N4.9196"` | `"HDDD.dHD.d"` | | 4.9196 | 101.347 | longitude first, no separator |
#' | `"101.347 4.9196"` | `"DDD.d D.d"` | `"lon_lat"` | 4.9196 | 101.347 | longitude first, no letters: say so with `order` |
#' | `"101.347 4.9196"` | `"DDD.d D.d"` | | `NA` | `NA` | no letters, so latitude first, but 101.347 is not a latitude: probably swapped |
#' | `"512839N 0002741W"` | `"DDMMSSH DDDMMSSH"` | `"lon_lat"` | `NA` | `NA` | the letters do not fit the forced order |
#' | `"512839N 0002741N"` | `"DDMMSSH DDDMMSSH"` | | `NA` | `NA` | two latitude letters |
#' | `"517539N 0002741W"` | `"DDMMSSH DDDMMSSH"` | | `NA` | -0.46139 | 75 minutes: the longitude is kept |
#' | `"512839N 1900000W"` | `"DDMMSSH DDDMMSSH"` | | 51.4775 | `NA` | longitude below -180: the latitude is kept |
#' | `"51 28 39N 000 27 41W"` | `"DDMMSSH DDDMMSSH"` | | `NA` | `NA` | does not match the pattern |
#' | `"51 28 39N 000 27 41W"` | `c("DDMMSSH DDDMMSSH", "DD MM SSH DDD MM SSH")` | | 51.4775 | -0.46139 | the second pattern matches |
#' | `"512839N0002741W"` | `c("DDMMSSH DDDMMSSH", "DDMMSSHDDDMMSSH")` | | 51.4775 | -0.46139 | the second pattern matches |
#' | `"45.5, -74.5"` | `NULL` | | 45.5 | -74.5 | no letters: latitude first |
#' | `"W74.5, N45.5"` | `NULL` | | 45.5 | -74.5 | longitude first: the letters decide |
#' | `"74.5W, 45.5"` | `NULL` | | 45.5 | -74.5 | only one part has a letter: it decides |
#' | `"-74.5, 45.5"` | `NULL` | `"lon_lat"` | 45.5 | -74.5 | longitude first, no letters: say so with `order` |
#' | `"N45.5, W74.5"` | `NULL` | `"lon_lat"` | `NA` | `NA` | the letters do not fit the forced order |
#' | `"E45, E30"` | `NULL` | | `NA` | `NA` | two longitude letters |
#' | `"101.347, 4.9196"` | `NULL` | | `NA` | `NA` | no letters, so latitude first, but 101.347 is not a latitude: probably swapped |
#' | `"abc, -74.5"` | `NULL` | | `NA` | -74.5 | the latitude cannot be read: the longitude is kept |
#' | `"N4.9196E101.347"` | `NULL` | | `NA` | `NA` | no separator: use `format` |
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
#' # which coordinate comes first (see the Order section)
#' parse_llstr("W101.347, N4.9196") # the letters say longitude first
#' parse_llstr("101.347E, 4.9196") # one letter is enough
#' parse_llstr("-101.347, 4.9196", order = "lon_lat") # no letters: say it
#' # NA and a warning: the letters contradict each other
#' parse_llstr("E45, E30")
#' # NA for both, and a warning: 101.347 is not a latitude, so the values
#' # are probably swapped
#' parse_llstr("101.347, 4.9196")
#' parse_llstr("101.347, 4.9196", order = "lon_lat")
#' # one part cannot be read: the other one is kept
#' parse_llstr("abc, -74.5")
#'
#' # with format: one pattern for the whole string (see the Format section)
#' parse_llstr("512839N 0002741W", format = "DDMMSSH DDDMMSSH") # ICAO
#' parse_llstr("512839N0002741W", format = "DDMMSSHDDDMMSSH") # no separator
#' parse_llstr("4916.45,N,12311.12,W", format = "DDMM.m,H,DDDMM.m,H") # NMEA
#' parse_llstr("N4.9196E101.347", format = "HD.ddddHDDD.ddd")
#' # longitude first: the letters decide
#' parse_llstr("0002741W 512839N", format = "DDDMMSSH DDMMSSH")
#' # longitude first, without letters
#' parse_llstr("101.347 4.9196", format = "DDD.d D.d", order = "lon_lat")
#' # several formats, tried in order for each string
#' parse_llstr(
#'   c("512839N 0002741W", "512839N0002741W", "51 28 39N 000 27 41W"),
#'   format = c("DDMMSSH DDDMMSSH", "DDMMSSHDDDMMSSH", "DD MM SSH DDD MM SSH")
#' )
#' # NA and one warning: 75 minutes (the longitude is kept), and two
#' # latitude letters
#' parse_llstr(
#'   c("517539N 0002741W", "512839N 0002741N"),
#'   format = "DDMMSSH DDDMMSSH"
#' )
#' # without format, a string with no separator gives NA and a warning
#' parse_llstr("N4.9196E101.347")
#'
#' # add both columns with one call, picking them by name
#' df <- data.frame(x = c("N4.9196, E101.347", "4.9196 -101.347"))
#' cbind(df, parse_llstr(str = df[["x"]])[c("lat", "lon")])
#' # dplyr:      df |> dplyr::mutate(parse_llstr(str = x)[c("lat", "lon")])
#' # data.table: dt[, c("lat", "lon") := parse_llstr(str = x)[c("lat", "lon")]]
parse_llstr <- function(
  str,
  format = NULL,
  order = c("auto", "lat_lon", "lon_lat")
) {
  assert(str, "character")
  assert(format, "character")
  order <- match.arg(arg = order)
  if (!is.null(format)) {
    return(parse_llstr_with_format(str = str, format = format, order = order))
  }
  clean <- scrub(str)
  halves <- pz_split_llstr(clean)
  first <- halves[["lat"]]
  second <- halves[["lon"]]
  # scrub() keeps letters as typed: only N, S, E and W are direction letters
  # perl = TRUE: 3 times faster than the default engine here
  has <- function(x, pattern) grepl(pattern = pattern, x = x, perl = TRUE)
  # every E is the letter E, as in "45E30.5", even in "1.5e2": parse_lat()
  # and parse_lon() never read an exponent
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
  # as in parse_lat(), NA, "" and blank strings (scrub() trims them to "")
  # give NA without a warning
  why[unsplit & !is.na(str) & nzchar(clean)] <-
    "could not split into latitude and longitude"
  ok <- !unsplit & is.na(why)
  lat_first <- picked[["lat_first"]]
  lat_half <- first
  lat_half[!lat_first] <- second[!lat_first]
  lon_half <- second
  lon_half[!lat_first] <- first[!lat_first]
  # the halves come from scrub(str): scrub() again would only trim the spaces
  # left by the split, so trim them and skip the scrub() of parse_lat() and
  # parse_lon()
  lat_half <- trimws(lat_half)
  lon_half <- trimws(lon_half)
  lat <- rep(NA_real_, times = length(str))
  lon <- rep(NA_real_, times = length(str))
  lat[ok] <- pz_parse_lat(lat_half[ok])
  lon[ok] <- pz_parse_lon(lon_half[ok])
  # a latitude out of range that is a valid longitude (see swap_why()). Only
  # rows with an NA latitude are parsed again, so valid input does not pay.
  maybe <- which(ok & is.na(lat) & picked[["can_swap"]])
  as_lon <- withCallingHandlers(
    pz_parse_lon(lat_half[maybe]),
    # pz_parse_lat() already gave a warning for each of them
    warning = function(w) invokeRestart("muffleWarning")
  )
  # above 90: the latitude failed for its range, not for another reason
  swapped <- maybe[which(abs(as_lon) > 90)]
  lon[swapped] <- NA_real_
  why[swapped] <- swap_why(lat_first = lat_first[swapped])
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

# The reason for an NA row whose latitude is out of range but would be a
# valid longitude, in a string without direction letters, as in
# "101.347, 4.9196": longitude and latitude are probably swapped, so the
# other value is probably not a longitude either and gives NA too.
swap_why <- function(lat_first) {
  paste0(
    "latitude out of range but valid as a longitude, so ",
    ifelse(test = lat_first, yes = "longitude", no = "latitude"),
    " may come first: try order = \"",
    ifelse(test = lat_first, yes = "lon_lat", no = "lat_lon"),
    "\""
  )
}
