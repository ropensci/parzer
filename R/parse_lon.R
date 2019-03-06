#' Parse longitude values
#'
#' @export
#' @param lon (numeric/integer/character) one or more longitude values
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
#' - out of longitude range: not within -90/90 range
#'
#' @examples
#' parse_lon("")
#' parse_lon("-181")
#' parse_lon("-361")
#' parse_lon("95")
#' parse_lon("asdfaf")
#'
#' parse_lon("45")
#' parse_lon("-45")
#' parse_lon("-45.2323")
#' parse_lon("334")
#'
#' # out of range with std::stod?
#' parse_lon("-45.23232e24")
#' parse_lon("-45.23232e2")
#' parse_lon("-45.23232")
#'
#' # numeric input
#' parse_lon(1:10)
#' parse_lon(85:94)
#'
#' # different formats
#' parse_lon("40.4183318 N")
#' parse_lon("40.4183318 S")
#' parse_lon("40 25 5.994") # => 40.41833
#'
#' parse_lon("40.4183318W")
#' parse_lon("W40.4183318")
#' parse_lon("E40.4183318S")
#' parse_lon("N40.4183318")
#'
#' parse_lon("N 39 21.440") # => 39.35733
#' parse_lon("S 56 1.389") # => -56.02315
#'
#' parse_lon("N40°25’5.994") # => 40.41833
#' parse_lon("40° 25´ 5.994\" N") # => 40.41833
#' parse_lon("40:25:6N")
#' parse_lon("40:25:5.994N")
#' parse_lon("40d 25’ 6\" N")
#'
#' # user specfied format
#' # %C, %c, %H %h %D, %d, %M, %m, %S, and %s
#' # parse_lon("40.255994", "")
parse_lon <- function(lon, format = NULL) {
  assert(lon, c("numeric", "integer", "character"))
  assert(format, "character")
  # FIXME: stopgap for now until figure out how to replace these on on src side
  ## -> smart quote and degree symbol
  lon <- gsub("\u2019|\u00b0", "'", lon)
  if (is.null(format)) pz_parse_lon(lon) else stop("format handling not ready yet")
}
