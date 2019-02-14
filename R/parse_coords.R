#' parse latitude
#'
#' @export
#' @param lat (character/numeric/integer) a latitude string/value
#' @param format format, deafult often works
#' @examples
#' parse_lat("45N54.2356")
#' parse_lat("-45.98739874")
#' parse_lat("N455698735", "HDDMMmmmmm")
#' parse_lat("40.123°")
#' parse_lat("40.123N74.123W")
#' parse_lat("N45 04.25764")
#' # bad values -> NaN
#' parse_lat("191.89")
#' # multiple
#' # parse_lat(c("40.123°", "40.123N74.123W"))
parse_lat <- function(lat, format = "") {
  lint_inputs(lat, format = format)
  pz_parse_lat(as.character(lat), format)
}

#' parse longitude
#'
#' @export
#' @param lon (character/numeric/integer) a longitude string/value
#' @param format format, deafult often works
#' @examples
#' parse_lon("45W54.2356")
#' parse_lon("-45.98739874")
#' parse_lon("N455698735", "HDDMMmmmmm")
#' parse_lon("40.123°")
#' parse_lon("40.123N74.123W")
#' parse_lon("N45 04.25764")
#' # bad values
#' parse_lon("181")
parse_lon <- function(lon, format = "") {
  lint_inputs(lon, format = format)
  pz_parse_lon(as.character(lon), format)
}

#' parse latitude and longitude
#'
#' @export
#' @param lat (character/numeric/integer) a latitude string/value
#' @param lon (character/numeric/integer) a longitude string/value
#' @param format format, deafult often works
#' @examples
#' parse_lat_lon(49.12, -120.43)
#' parse_lat_lon(93, -120.43)
#' parse_lat_lon(49.12, -190)
#' parse_lat_lon(92, -190)
parse_lat_lon <- function(lat, lon, format = "") {
  lint_inputs(lat, lon, format)
  c(
    pz_parse_lat(as.character(lat), format),
    pz_parse_lon(as.character(lon), format)
  )
}
