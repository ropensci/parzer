parzer 0.5.0
============

### BUG FIX

* `parse_lat()` and `parse_lon()` (and the functions built on them) now return `NA` with a warning when minutes or seconds are not within 0/60, instead of silently converting them, e.g. "10°30,12345" (#60). Negative minutes or seconds, and a decimal degree or minute followed by another slot (e.g. "45.5 30"), now also give `NA` with a warning. A comma is a separator, not a decimal mark; this is now documented.
* `parse_parts_lat()` and `parse_parts_lon()` (and `pz_degree()`, `pz_minute()`, `pz_second()`) no longer lose the sign of values between -1 and 0: the sign now sits on the first non-zero part, e.g. -0.5 gives deg 0, min -30. They also no longer return 60 seconds, e.g. 10.35 is now 10 deg 21 min 0 sec, not 10 deg 20 min 60 sec.
* `parse_llstr()` now gives one clear warning ("could not split into latitude and longitude") for each string it cannot split, and keeps the other rows. Before, each such string gave two confusing "no digits" warnings about an internal marker.
* The warning text for an invalid letter after degrees uses plain ASCII quotes.
* `parse_lon_lat()` and `parse_hemisphere()` now clean symbols like `°` the same way `parse_lat()` and `parse_lon()` do (before, "40°25'" gave 40).
* Small numeric inputs such as `1e-5` are no longer misread as two slots, and a number too large for a double now gives `NA` with a warning instead of shifting the other slots.
* `parse_lon_lat()` and `parse_hemisphere()` now accept numeric and integer inputs, as documented.
* `parse_llstr()` now returns NA for unrecognized formats instead of two empty strings.
* Strings that cannot be converted (no digits, or more than 3 numeric slots) now give only one warning, with no spurious second range warning.
* Fixed undefined behaviour in `parse_parts_lat()` and `parse_parts_lon()` when a value could not be parsed (NA was cast to an integer).

### MINOR IMPROVEMENTS

* Faster parsing: regular expressions are compiled once instead of for each coordinate, numbers are read with `std::stod` instead of a new stream for each token, and `parse_parts_*()` no longer allocates an R list for each coordinate.
* `parse_hemisphere()` detects the sign of a value with `std::signbit()` instead of converting it to a string.
* Added performance tests (`bench`) to detect slowdowns, and a larger test suite (about 96% coverage).
* README: local coverage badge, and installation with `pak::pkg_install()`.

parzer 0.4.4
============

### BUG FIX

* Fixed a bug in longitude conversion where "74E5423" would be converted to NA while "74W5423" was correctly converted.
* Improved C++ management of NA values.

parzer 0.4.3
============

### BUG FIX

* Removal of unnecessary files from the package.

parzer 0.4.2
============

### MINOR IMPROVEMENTS

* C++ code was improved by replacing push.backs with direct assignations
in vectors and also by passing arguments by reference where possible.
* Dependence on Rcpp was reduced

### BUG FIX

* having spaces at the beginning of a string could lead to the disappearing of the negative sign

parzer 0.4.1
============

### MINOR IMPROVEMENTS

* documentation and package description describe more clearly `parzer` core objective of parsing messy coordinates in
character strings to convert them to decimal numeric values. Suggestion and work by @robitalec

### ACKNOWLEDGEMENTS CHANGES
* new contributors to the package: @robitalec, @maelle and @yutannihilation
* new maintainer: @AlbanSagouis

parzer 0.4.0
============

### MINOR IMPROVEMENTS

* performance improvement for internal function `scrub()`, used in most exported functions in parzer (#30) work by @AlbanSagouis
* work around for non-UTF8 MBCS locales: now all exported functions go through a modified `.Call()` in which we use `withr::with_locale()` if the user is on a Windows operating system (#31) (#32) work by @yutannihilation

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
