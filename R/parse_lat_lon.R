#' parse longitude and latitude
#'
#' @export
#' @param lon (character/numeric/integer) one or more longitude values
#' @param lat (character/numeric/integer) one or more latitude values
#' @details length(lon) == length(lat)
#' @return data.frame, with columns lon, lat. on an invalid values, an `NA`
#' is returned. In addition, warnings are thrown on invalid values
#' @examples
#' parse_lon_lat(-120.43, 49.12)
#' \dontrun{
#' parse_lon_lat(-120.43, 93)
#' parse_lon_lat(-190, 49.12)
#' parse_lon_lat(240, 49.12)
#' parse_lon_lat(-190, 92)
#' # many
#' lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
#' lats <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' parse_lon_lat(lons, lats)
#' }
parse_lon_lat <- function(lon, lat) {
  lint_inputs(lon, lat, "")
  stopifnot(length(lon) == length(lat))
  data.frame(
    lon = pz_parse_lon(as.character(lon)),
    lat = pz_parse_lat(as.character(lat)),
    stringsAsFactors = FALSE
  )
}
