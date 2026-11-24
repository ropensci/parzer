#' Parse latitude values
#'
#' @export
#' @param lat (numeric/integer/character) one or more latitude values
#' @param format (character) `NULL` (the default) or one or more patterns
#'   that say how the values are written, for example `"DDMMSSH"`. With
#'   `NULL`, parzer finds the degrees, minutes and seconds by itself. Give a
#'   pattern when it cannot, for example when the digits are packed together
#'   with no separator, as in `"512839N"`. With several patterns, each value
#'   is read with the first pattern that matches it. See the Format and
#'   Format examples sections.
#' @return numeric vector
#' @section Format:
#' A pattern describes how the values are written. It is made of letters and
#' other characters. The idea comes from `AngleFormat` in Apache SIS and from
#' `CLongLatString`.
#'
#' - `D`, `M` and `S` stand for the digits of the whole degrees, minutes and
#'   seconds. The number of letters is the exact number of digits: `DD` means
#'   exactly 2 digits, so it reads `"05"` but not `"5"`, and `DDD` means
#'   exactly 3 digits, as longitudes often need. Values written without
#'   leading zeros need a second pattern, for example
#'   `c("DD MM SSH", "D MM SSH")` reads both `"45 03 02N"` and `"5 03 02N"`.
#'   `D` is required. `M` and `S` are optional, but `S` needs `M`, and they
#'   come in the order `D`, `M`, `S`.
#' - `d`, `m` and `s` stand for the decimal digits of the degrees, minutes or
#'   seconds. Only the last unit can have them. They come right after it, as
#'   in `"DDMMmmm"`, or after a dot that follows it, as in `"DDMM.m"`.
#'   - Without a dot, the decimal point is not written in the value. The
#'     number of letters is then the exact number of decimal digits: it is the
#'     only way to know where the hidden decimal point is. `"HDDMMmmmmm"`
#'     reads `"N455698735"` as N 45 degrees 56.98735 minutes.
#'   - After a dot, the value has a decimal point and one or more decimal
#'     digits, as many as you like: `"DDMM.m"` reads both `"4556.9"` and
#'     `"4556.98735"`.
#' - `H` stands for the hemisphere letter: `N` or `S` in `parse_lat()`, `E`
#'   or `W` in `parse_lon()`, in upper or lower case. `S` and `W` give a
#'   negative value. `H` can be at the start, at the end or in the middle, but
#'   only once. A letter of the other pair, for example `E` in `parse_lat()`,
#'   gives `NA`.
#' - A space matches one or more spaces (or other white space).
#' - Any other character, for example `°`, `'`, `"`, `:`, or a dot that is not
#'   followed by `d`, `m` or `s`, must be in the value exactly as in the
#'   pattern.
#' - A sign can always be written right before the degrees: `+`, `-`, or a
#'   Unicode minus (U+2212), en dash `–` or em dash `—`. With `H`, the rules are
#'   the same as with `format = NULL`: `"-45S"` and `"+45S"` give -45, but
#'   `"-45N"` gives `NA`, because the minus sign and the letter disagree.
#'
#' Spaces at the start and at the end of a value are ignored. The pattern is
#' matched against the value as it is given: the cleaning done with
#' `format = NULL`, for example reading `d` or `º` as a degree mark, does not
#' happen.
#'
#' A value gives `NA` when it does not match any pattern, when its minutes or
#' seconds are 60 or more, or when the result is out of range (latitude
#' outside -90/90, longitude outside -180/360). All these values are listed in
#' one warning. They are not read again with `format = NULL`. A missing value
#' (`NA`) or an empty string gives `NA` without a warning. A pattern that
#' cannot work, for example `"MMDD"`, `"DDmmSS"` or `"DDX"`, is an error.
#'
#' Numbers are turned into text first, so they lose their leading zeros:
#' `parse_lon(0002741, format = "DDDMMSS")` sees `"2741"` and gives `NA`.
#' Give such values as text: `parse_lon("0002741", format = "DDDMMSS")`.
#'
#' See the Format examples section for many examples.
#'
#' @section Format examples:
# Every row of this table and every format example in @examples is mirrored
# in the table of tests/testthat/test-format.R: keep the two in sync.
#' | Value | `format` | Result | Why |
#' |---|---|---|---|
#' | `"512839N"` | `"DDMMSSH"` | 51.4775 | ICAO latitude |
#' | `"4556.98735"` | `"DDMM.mmmmm"` | 45.94979 | NMEA |
#' | `"4556.98735"` | `"DDMM.m"` | 45.94979 | after a dot, any number of decimals |
#' | `"4556.9"` | `"DDMM.m"` | 45.94833 | after a dot, any number of decimals |
#' | `"N455698735"` | `"HDDMMmmmmm"` | 45.94979 | decimal point not written: exactly 5 decimals |
#' | `"2343 56N"` | `"DDMM SSH"` | 23.73222 | |
#' | `"23 4356N"` | `"DD MMSSH"` | 23.73222 | |
#' | `"23   4356N"` | `"DD MMSSH"` | 23.73222 | a space matches several spaces |
#' | `"2343.5N"` | `"DDMM.mH"` | 23.725 | |
#' | `"45N54.2356"` | `"DDHMM.m"` | 45.90393 | `H` in the middle |
#' | `"s4530"` | `"HDDMM"` | -45.5 | `H` in front, in lower case |
#' | `"40°25'06\"N"` | `"DD°MM'SS\"H"` | 40.41833 | symbols must match exactly |
#' | `"40:25:06"` | `"DD:MM:SS"` | 40.41833 | |
#' | `"40.25"` | `"DD.MM"` | 40.41667 | a dot before `M` is a plain dot |
#' | `"45.5"` | `"DD.d"` | 45.5 | decimal degrees |
#' | `"-4530"` | `"DDMM"` | -45.5 | minus sign |
#' | `"\u22124530"` | `"DDMM"` | -45.5 | Unicode minus sign |
#' | `"-45S"` | `"DDH"` | -45 | sign and letter agree |
#' | `"+45S"` | `"DDH"` | -45 | the letter gives the sign |
#' | `"-45N"` | `"DDH"` | `NA` | sign and letter disagree |
#' | `"45E"` | `"DDH"` | `NA` | `E` is not a latitude letter |
#' | `"4530"` | `c("DDMM", "DD MM")` | 45.5 | the first pattern matches |
#' | `"45 30"` | `c("DDMM", "DD MM")` | 45.5 | the second pattern matches |
#' | `"453"` | `"DDMM"` | `NA` | 3 digits do not match 4 letters |
#' | `"45 03 02N"` | `c("DD MM SSH", "D MM SSH")` | 45.05056 | the first pattern matches |
#' | `"5 03 02N"` | `c("DD MM SSH", "D MM SSH")` | 5.05056 | no leading zero: the second pattern matches |
#' | `"5°3'2\"N"` | `"DD°MM'SS\"H"` | `NA` | `DD` needs exactly 2 digits |
#' | `"4575"` | `"DDMM"` | `NA` | 75 minutes |
#' | `"9000S"` | `"DDMMH"` | -90 | lowest latitude |
#' | `"9130"` | `"DDMM"` | `NA` | latitude above 90 |
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
#' - out of latitude range: not within -90/90 range
#' - minutes or seconds out of range (negative or 60 and above): not within 0/60 range, e.g. `"10 30,12345"`
#' is read as 10 degrees, 30 minutes and 12345 seconds, so it gives a warning and `NA`
#' - a decimal degree or minute followed by another slot: only the last slot can be decimal, e.g. `"45.5 30"`
#' - a minus sign that disagrees with the direction letter: minus sign and direction letter disagree, e.g. `"N -45"` or `"-45N"`
#' - a number with two decimal points: invalid number, e.g. `"40.25.30"`
#' - with `format`, a value that does not match any pattern: does not match format, see the Format section
#'
#' A comma or space is always a separator between degrees, minutes and seconds,
#' never a decimal mark.
#'
# examples without format are mirrored in tests/testthat/test-doc-examples.R
#' @examples
#' parse_lat("")
#'
#' # with format: say how the values are written (see the Format section)
# these examples are mirrored in the table of tests/testthat/test-format.R
#' parse_lat("512839N", format = "DDMMSSH") # ICAO => 51.4775
#' parse_lat("4556.98735", format = "DDMM.mmmmm") # NMEA => 45.94979
#' # after a dot, any number of decimals
#' parse_lat(c("4556.9", "4556.98735"), format = "DDMM.m")
#' # no dot: 5 letters, so exactly 5 decimals => 45.94979
#' parse_lat("N455698735", format = "HDDMMmmmmm")
#' parse_lat("2343 56N", format = "DDMM SSH") # => 23.73222
#' parse_lat("23 4356N", format = "DD MMSSH") # => 23.73222
#' parse_lat("2343.5N", format = "DDMM.mH") # => 23.725
#' parse_lat("45N54.2356", format = "DDHMM.m") # => 45.90393
#' parse_lat("40°25'06\"N", format = "DD°MM'SS\"H") # => 40.41833
#' parse_lat(c("-45S", "+45S"), format = "DDH") # => -45 -45
#' parse_lat(4530, format = "DDMM") # numbers work too => 45.5
#' # several formats, tried in order for each value
#' parse_lat(c("4530", "45 30", "N4530"), format = c("DDMM", "DD MM", "HDDMM"))
#' # no leading zero: a second format with one D
#' parse_lat(c("45 03 02N", "5 03 02N"), format = c("DD MM SSH", "D MM SSH"))
#' # NA and one warning: sign and letter disagree, wrong letter, 75 minutes
#' parse_lat(c("-45N", "45E", "4575"), format = c("DDH", "DDMM"))
#' # without format, packed digits give NA and a warning that points to format
#' parse_lat("2343 56N")
#'
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
  if (is.null(format)) {
    return(pz_parse_lat(scrub(lat)))
  }
  parse_with_format(x = lat, format = format, what = "lat")
}
