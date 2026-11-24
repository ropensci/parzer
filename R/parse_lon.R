#' Parse longitude values
#'
#' @export
#' @param lon (numeric/integer/character) one or more longitude values.
#' @inheritParams parse_lat
#' @inheritSection parse_lat Format
#' @return numeric vector
#' @section Format examples:
#' The rules for `format` are in the Format section below.
#'
# Every row of this table and every format example in @examples is mirrored
# in the table of tests/testthat/test-format.R: keep the two in sync.
#' | Value | `format` | Result | Why |
#' |---|---|---|---|
#' | `"0002741W"` | `"DDDMMSSH"` | -0.46139 | ICAO longitude |
#' | `"1452741E"` | `"DDDMMSSH"` | 145.46139 | ICAO longitude, east |
#' | `"01045.5W"` | `"DDDMM.mH"` | -10.75833 | NMEA |
#' | `"01045.12345W"` | `"DDDMM.mH"` | -10.75206 | after a dot, any number of decimals |
#' | `"W0104512345"` | `"HDDDMMmmmmm"` | -10.75206 | decimal point not written: exactly 5 decimals |
#' | `"E0451530"` | `"HDDDMMSS"` | 45.25833 | `H` in front |
#' | `"0451530e"` | `"DDDMMSSH"` | 45.25833 | `H` at the end, in lower case |
#' | `"045E15.5"` | `"DDDHMM.m"` | 45.25833 | `H` in the middle |
#' | `"07443 56W"` | `"DDDMM SSH"` | -74.73222 | |
#' | `"074 3056W"` | `"DDD MMSSH"` | -74.51556 | |
#' | `"074   3056W"` | `"DDD MMSSH"` | -74.51556 | a space matches several spaces |
#' | `"074°30'56\"W"` | `"DDD°MM'SS\"H"` | -74.51556 | symbols must match exactly |
#' | `"074:30:56"` | `"DDD:MM:SS"` | 74.51556 | |
#' | `"120.5"` | `"DDD.d"` | 120.5 | decimal degrees |
#' | `"-0743056"` | `"DDDMMSS"` | -74.51556 | minus sign |
#' | `"\u22120743056"` | `"DDDMMSS"` | -74.51556 | Unicode minus sign |
#' | `"-074W"` | `"DDDH"` | -74 | sign and letter agree |
#' | `"+074W"` | `"DDDH"` | -74 | the letter gives the sign |
#' | `"-074E"` | `"DDDH"` | `NA` | sign and letter disagree |
#' | `"074N"` | `"DDDH"` | `NA` | `N` is not a longitude letter |
#' | `"0743056W"` | `c("DDDMMSSH", "DDD MM SSH")` | -74.51556 | the first pattern matches |
#' | `"074 30 56W"` | `c("DDDMMSSH", "DDD MM SSH")` | -74.51556 | the second pattern matches |
#' | `"74 30 56W"` | `c("DDD MM SSH", "DD MM SSH", "D MM SSH")` | -74.51556 | no leading zero: the second pattern matches |
#' | `"7 30 56W"` | `c("DDD MM SSH", "DD MM SSH", "D MM SSH")` | -7.51556 | no leading zeros: the third pattern matches |
#' | `"74 30 56W"` | `"DDD MM SSH"` | `NA` | `DDD` needs exactly 3 digits |
#' | `"0747530W"` | `"DDDMMSSH"` | `NA` | 75 minutes |
#' | `"1800000W"` | `"DDDMMSSH"` | -180 | lowest longitude |
#' | `"1800001W"` | `"DDDMMSSH"` | `NA` | longitude below -180 |
#' | `"18030W"` | `"DDDMMH"` | `NA` | longitude below -180 |
#' | `"3600000E"` | `"DDDMMSSH"` | 360 | highest longitude |
#' | `"3600001E"` | `"DDDMMSSH"` | `NA` | longitude above 360 |
#'
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
#' - a minus sign that disagrees with the direction letter: minus sign and direction letter disagree, e.g. `"E -45"` or `"-45E"`
#' - a number with two decimal points: invalid number, e.g. `"40.25.30"`
#' - with `format`, a value that does not match any pattern: does not match format, see the Format section
#'
#' A comma or space is always a separator between degrees, minutes and seconds,
#' never a decimal mark.
#'
# examples without format are mirrored in tests/testthat/test-doc-examples.R
#' @examples
#' parse_lon("")
#'
#' # with format: say how the values are written (see the Format section)
# these examples are mirrored in the table of tests/testthat/test-format.R
#' parse_lon("0002741W", format = "DDDMMSSH") # ICAO => -0.46139
#' parse_lon("E0451530", format = "HDDDMMSS") # => 45.25833
#' parse_lon("01045.5W", format = "DDDMM.mH") # NMEA => -10.75833
#' parse_lon(c("0002741W", "000 27 41W"), format = c("DDDMMSSH", "DDD MM SSH"))
#' # no leading zeros: one format for each number of degree digits
#' parse_lon(
#'   c("074 30 56W", "74 30 56W", "7 30 56W"),
#'   format = c("DDD MM SSH", "DD MM SSH", "D MM SSH")
#' )
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
