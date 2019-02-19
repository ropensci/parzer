#' parse coordinates into degrees, minutes and seconds
#'
#' BEWARE: EXPERIMENTAL
#'
#' @export
#' @param str (character) string including latitude or longitude
#' @param format format, deafult often works
#' @return data.frame with columns for:
#'
#' - degrees (integer)
#' - minutes (numeric)
#' - seconds (numeric)
#'
#' NA given upon error
#'
#' @examples
#' # not working
#' parse_parts("45N54.2356")
#' parse_parts("40.4183318")
#' parse_parts("-74.6411133")
#' parse_parts("-45.98739874")
#' parse_parts("40.123N")
#' parse_parts("40.123°")
#'
#' # working
#' parse_parts("N455698735")
#'
#' # multiple
#' x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
#' parse_parts(x)
#' # system.time(parse_parts(rep(x, 10^4)))
parse_parts <- function(str, format = "") {
  assert(str, "character")
  pz_parse_parts(str, format)
}
