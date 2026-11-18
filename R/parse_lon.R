#' Parse longitude values
#'
#' @export
#' @param lon (numeric/integer/character) one or more longitude values.
#' @inheritParams parse_lat
#' @inheritSection parse_lat Format
#' @return numeric vector
#' @section Errors:
#' Throws warnings on parsing errors, and returns `NA` in each case
#'
#' Types of errors:
#'
#' - invalid argument: e.g., letters passed instead of numbers,
#' see <https://en.cppreference.com/cpp/error/invalid_argument>
#' - out of range: numbers of out acceptable range, see
#' <https://en.cppreference.com/cpp/error/out_of_range>
#' - out of longitude range: not within -180/360 range
#' - minutes or seconds out of range (negative or 60 and above): not within 0/60 range, e.g. `"10 30,12345"`
#' is read as 10 degrees, 30 minutes and 12345 seconds, so it gives a warning and `NA`
#' - a decimal degree or minute followed by another slot: only the last slot can be decimal, e.g. `"45.5 30"`
#'
#' A comma or space is always a separator between degrees, minutes and seconds,
#' never a decimal mark.
#'
#' @examples
#' parse_lon("")
#'
#' # with format: say how the values are written (see the Format section)
# these examples are mirrored in the table of tests/testthat/test-format.R
#' parse_lon("0002741W", format = "DDDMMSSH") # ICAO => -0.46139
#' parse_lon("E0451530", format = "HDDDMMSS") # => 45.25833
#' parse_lon("01045.5W", format = "DDDMM.mH") # NMEA => -10.75833
#' parse_lon(c("0002741W", "000 27 41W"), format = c("DDDMMSSH", "DDD MM SSH"))
#' # NA and one warning: N is not a longitude letter, below -180
#' parse_lon(c("045N", "18030W"), format = c("DDDH", "DDDMMH"))
#'
#' \dontrun{
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
#' parse_lon("40.4183318 E")
#' parse_lon("40.4183318 W")
#' parse_lon("40 25 5.994") # => 40.41833
#'
#' parse_lon("40.4183318W")
#' parse_lon("W40.4183318")
#' parse_lon("E40.4183318")
#' parse_lon("40.4183318E")
#'
#' parse_lon("E 39 21.440") # => 39.35733
#' parse_lon("W 56 1.389") # => -56.02315
#'
#' parse_lon("E40°25’5.994") # => 40.41833
#' parse_lon("40° 25´ 5.994\" E") # => 40.41833
#' parse_lon("40:25:6E")
#' parse_lon("40:25:5.994E")
#' parse_lon("40d 25’ 6\" E")
#' }
parse_lon <- function(lon, format = NULL) {
  assert(lon, c("numeric", "integer", "character"))
  assert(format, "character")
  if (is.null(format)) {
    return(pz_parse_lon(scrub(lon)))
  }
  parse_with_format(x = lon, format = format, what = "lon")
}
