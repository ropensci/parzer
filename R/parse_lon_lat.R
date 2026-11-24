#' parse longitude and latitude
#'
#' @export
#' @param lon (character/numeric/integer) one or more longitude values
#' @param lat (character/numeric/integer) one or more latitude values
#' @param lon_format,lat_format (character) `NULL` (the default) or one or
#'   more patterns that say how the longitudes and the latitudes are
#'   written, for example `"DDDMMSSH"` and `"DDMMSSH"`. They are passed to
#'   the `format` argument of [parse_lon()] and [parse_lat()]: see the
#'   Format section of [parse_lat()] for the rules. Each one can be set on
#'   its own: the other values are then read as with `format = NULL`.
#' @details length(lon) == length(lat). Longitude comes first, in the
#'   arguments and in the result.
#' @return A data.frame with the columns lon and lat. An invalid value gives
#'   `NA` with a warning. Each value is read on its own, so the other value
#'   of the row is kept.
#' @section Format examples:
# Every row of this table and every example with a format in @examples is
# mirrored in the lon_lat_cases table of tests/testthat/test-format.R: keep
# the two in sync.
#' | `lon` | `lat` | `lon_format` | `lat_format` | Result lon | Result lat | Why |
#' |---|---|---|---|---|---|---|
#' | `"0002741W"` | `"512839N"` | `"DDDMMSSH"` | `"DDMMSSH"` | -0.46139 | 51.4775 | ICAO |
#' | `"01045.12345W"` | `"4556.98735N"` | `"DDDMM.mH"` | `"DDMM.mH"` | -10.75206 | 45.94979 | NMEA |
#' | `"W0104512345"` | `"N455698735"` | `"HDDDMMmmmmm"` | `"HDDMMmmmmm"` | -10.75206 | 45.94979 | decimal point not written: exactly 5 decimals |
#' | `"-120.43"` | `"4907.2"` | `NULL` | `"DDMM.m"` | -120.43 | 49.12 | a format for the latitude only |
#' | `"12043W"` | `"49.12"` | `"DDDMMH"` | `NULL` | -120.71667 | 49.12 | a format for the longitude only |
#' | `"0743056W"` | `"453015N"` | `c("DDDMMSSH", "DDD MM SSH")` | `c("DDMMSSH", "DD MM SSH")` | -74.51556 | 45.50417 | the first patterns match |
#' | `"074 30 56W"` | `"45 30 15N"` | `c("DDDMMSSH", "DDD MM SSH")` | `c("DDMMSSH", "DD MM SSH")` | -74.51556 | 45.50417 | the second patterns match |
#' | `"1800001W"` | `"512839N"` | `"DDDMMSSH"` | `"DDMMSSH"` | `NA` | 51.4775 | longitude below -180: the latitude is kept |
#' | `"0002741W"` | `"517539N"` | `"DDDMMSSH"` | `"DDMMSSH"` | -0.46139 | `NA` | 75 minutes: the longitude is kept |
#' | `"512839N"` | `"0002741W"` | `"DDDMMSSH"` | `"DDMMSSH"` | `NA` | `NA` | swapped: longitude comes first |
#'
# examples without format are mirrored in tests/testthat/test-doc-examples.R
#' @examples
#' parse_lon_lat("-120.43", "49.12")
#'
#' # with formats (see the Format section of ?parse_lat)
# these examples are mirrored in the lon_lat_cases table of
# tests/testthat/test-format.R
#' # ICAO => -0.46139 51.4775
#' parse_lon_lat(
#'   "0002741W",
#'   "512839N",
#'   lon_format = "DDDMMSSH",
#'   lat_format = "DDMMSSH"
#' )
#' # NMEA => -10.75206 45.94979
#' parse_lon_lat(
#'   "01045.12345W",
#'   "4556.98735N",
#'   lon_format = "DDDMM.mH",
#'   lat_format = "DDMM.mH"
#' )
#' # a format for the latitude only => -120.43 49.12
#' parse_lon_lat("-120.43", "4907.2", lat_format = "DDMM.m")
#' # several formats, tried in order for each value
#' parse_lon_lat(
#'   c("0743056W", "074 30 56W"),
#'   c("453015N", "45 30 15N"),
#'   lon_format = c("DDDMMSSH", "DDD MM SSH"),
#'   lat_format = c("DDMMSSH", "DD MM SSH")
#' )
#' # NA and a warning: longitude below -180, the latitude is kept
#' parse_lon_lat(
#'   "1800001W",
#'   "512839N",
#'   lon_format = "DDDMMSSH",
#'   lat_format = "DDMMSSH"
#' )
#' \dontrun{
#' parse_lon_lat("-120.43", "93")
#' parse_lon_lat("-190", "49.12")
#' parse_lon_lat("240", "49.12")
#' parse_lon_lat("-190", "92")
#' # many
#' lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
#' lats <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' parse_lon_lat(lons, lats)
#' }
parse_lon_lat <- function(lon, lat, lon_format = NULL, lat_format = NULL) {
  lint_inputs(lon, lat)
  assert(lon_format, "character")
  assert(lat_format, "character")
  data.frame(
    lon = parse_lon(lon = lon, format = lon_format),
    lat = parse_lat(lat = lat, format = lat_format)
  )
}
