#' parse latitude
#'
#' @export
#' @param lat (character/numeric/integer) one or more latitude values
#' @param format format, deafult often works
#' @return numeric vector of decimal degree coordinates
#' @examples
#' parse_lat("45N54.2356")
#' parse_lat("-45.98739874")
#' parse_lat("N455698735", "HDDMMmmmmm")
#' parse_lat("40.123°")
#' parse_lat("40.123N")
#' parse_lat("N45 04.25764")
#' # bad values -> NaN
#' parse_lat("191.89")
#' # multiple
#' x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' parse_lat(x)
#' system.time(parse_lat(rep(x, 10^4)))
parse_lat <- function(lat, format = "") {
  lint_inputs(lat, format = format)
  pz_parse_lat(as.character(lat), format)
}

#' parse longitude
#'
#' @export
#' @param lon (character/numeric/integer) one or more longitude values
#' @param format format, deafult often works
#' @return numeric vector of decimal degree coordinates
#' @examples
#' parse_lon("45W54.2356")
#' parse_lon("-45.98739874")
#' parse_lon("N455698735", "HDDMMmmmmm")
#' parse_lon("40.123°")
#' parse_lon("74.123W")
#' parse_lon("N45 04.25764")
#' # bad values
#' parse_lon("181")
#' # many
#' x <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
#' parse_lon(x)
#' system.time(parse_lon(rep(x, 10^4)))
parse_lon <- function(lon, format = "") {
  lint_inputs(NULL, lon, format = format)
  pz_parse_lon(as.character(lon), format)
}

#' parse latitude and longitude
#'
#' @export
#' @param lat (character/numeric/integer) one or more latitude values
#' @param lon (character/numeric/integer) one or more longitude values
#' @param format format, deafult often works
#' @details length(lat) == length(lon)
#' @return data.frame, with columns lat, lon
#' @examples
#' parse_lat_lon(49.12, -120.43)
#' parse_lat_lon(93, -120.43)
#' parse_lat_lon(49.12, -190)
#' parse_lat_lon(92, -190)
#' # many
#' lats <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
#' parse_lat_lon(lats, lons)
parse_lat_lon <- function(lat, lon, format = "") {
  lint_inputs(lat, lon, format)
  stopifnot(length(lat) == length(lon))
  data.frame(
    lat = pz_parse_lat(as.character(lat), format),
    lon = pz_parse_lon(as.character(lon), format),
    stringsAsFactors = FALSE
  )
}
