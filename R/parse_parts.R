#' parse coordinates into degrees, minutes and seconds
#'
#' @export
#' @name parse_parts
#' @param str (character) string including longitude or latitude
#' @return data.frame with columns for:
#'
#' - deg (integer)
#' - min (integer)
#' - sec (numeric)
#'
#' NA/NaN given upon error
#'
#' @examples
#' parse_parts_lon("140.4183318")
#' \dontrun{
#' parse_parts_lon("174.6411133")
#' parse_parts_lon("-45.98739874")
#' parse_parts_lon("40.123W")
#' 
#' parse_parts_lat("45N54.2356")
#' parse_parts_lat("40.4183318")
#' parse_parts_lat("-74.6411133")
#' parse_parts_lat("-45.98739874")
#' parse_parts_lat("40.123N")
#' parse_parts_lat("N40°25’5.994")
#' 
#' # not working, needs format input
#' parse_parts_lat("N455698735")
#'
#' # multiple
#' x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' parse_parts_lat(x)
#' system.time(parse_parts_lat(rep(x, 10^2)))
#' }

#' @export
#' @rdname parse_parts
parse_parts_lon <- function(str) {
  assert(str, "character")
  pz_parse_parts_lon(scrub(str))
}

#' @export
#' @rdname parse_parts
parse_parts_lat <- function(str) {
  assert(str, "character")
  pz_parse_parts_lat(scrub(str))
}
