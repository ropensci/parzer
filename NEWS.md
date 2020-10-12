parzer 0.3.0
============

### BUG FIXES

* fix problem in `parse_llstr()`: on older R versions where `stringsAsFactors=TRUE` by default this function was returning strings as factors from an internal function that caused a problem in a subsequent step in the function (#29)

parzer 0.2.0
============

### NEW FEATURES

* new contributor to the package @AlbanSagouis
* gains new function `parse_llstr()` to parse a string that contains both latitude and longitude (#3) (#24) (#26) (#28) work by @AlbanSagouis

### MINOR IMPROVEMENTS

* updated `scrub()` internal function that strips certain characters to include more things to scrub (#25) work by @AlbanSagouis

parzer 0.1.4
============

### MINOR IMPROVEMENTS

* add support to internal function for additional degree like symbols (#21)
* fix issue with `parse_parts_lat()`/`parse_parts_lon()` functions where an NA was causing warnings on the cpp side; on cpp side, now check for NA and return list of NAs instead of NAs passing through other code (#23)

parzer 0.1.0
============

### NEW FEATURES

* Released to CRAN.
