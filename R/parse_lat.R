#' Parse latitude values
#'
#' @export
#' @param lat (numeric/integer/character) one or more latitude values
#' @param format (character) format, default often works
#' @return numeric vector
#' @section Errors:
#' Throws warnings on parsing errors, and returns `NaN` in each case
#'
#' Types of errors:
#'
#' - invalid argument: e.g., letters passed instead of numbers,
#' see <https://en.cppreference.com/w/cpp/error/invalid_argument>
#' - out of range: numbers of out acceptable range, see
#' <https://en.cppreference.com/w/cpp/error/out_of_range>
#' - out of latitude range: not within -90/90 range
#'
#' @examples
#' parse_lat("")
#' \dontrun{
#' parse_lat("-91")
#' parse_lat("95")
#' parse_lat("asdfaf")
#'
#' parse_lat("45")
#' parse_lat("-45")
#' parse_lat("-45.2323")
#'
#' # out of range with std::stod?
#' parse_lat("-45.23232e24")
#' parse_lat("-45.23232e2")
#'
#' # numeric input
#' parse_lat(1:10)
#' parse_lat(85:94)
#'
#' # different formats
#' parse_lat("40.4183318 N")
#' parse_lat("40.4183318 S")
#' parse_lat("40 25 5.994") # => 40.41833
#'
#' parse_lat("40.4183318N")
#' parse_lat("N40.4183318")
#' parse_lat("40.4183318S")
#' parse_lat("S40.4183318")
#'
#' parse_lat("N 39 21.440") # => 39.35733
#' parse_lat("S 56 1.389") # => -56.02315
#'
#' parse_lat("N40°25’5.994") # => 40.41833
#' parse_lat("40° 25´ 5.994\" N") # => 40.41833
#' parse_lat("40:25:6N")
#' parse_lat("40:25:5.994N")
#' parse_lat("40d 25’ 6\" N")
#' }
parse_lat <- function(lat, format = NULL) {
  assert(lat, c("numeric", "integer", "character"))
  assert(format, "character")
  lat <- scrub(lat)
  if (is.null(format)) pz_parse_lat(lat) else stop_form()
}
