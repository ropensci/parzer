#' parse latitude and longitude as separate inputs
#'
#' @export
#' @param lat (character/numeric/integer) one or more latitude values
#' @param lon (character/numeric/integer) one or more longitude values
#' @details length(lat) == length(lon)
#' @return data.frame, with columns lat, lon
#' @examples
#' parse_lat_lon(49.12, -120.43)
#' parse_lat_lon(93, -120.43)
#' parse_lat_lon(49.12, -190)
#' parse_lat_lon(49.12, 240)
#' parse_lat_lon(92, -190)
#' # many
#' lats <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
#' parse_lat_lon(lats, lons)
parse_lat_lon <- function(lat, lon) {
  lint_inputs(lat, lon, "")
  stopifnot(length(lat) == length(lon))
  data.frame(
    lat = pz_parse_lat(as.character(lat)),
    lon = pz_parse_lon(as.character(lon)),
    stringsAsFactors = FALSE
  )
}
