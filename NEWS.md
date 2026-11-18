parzer 0.5.0.9000
============

### NEW FEATURES

* `parse_lat()` and `parse_lon()` have a working `format` argument (#7, #11). A pattern such as `"DDMMSSH"` says how the values are written, so packed digits can be read: ICAO `"512839N"`, NMEA `"4556.98735"` with `"DDMM.mmmmm"`, or `"N455698735"` with `"HDDMMmmmmm"` (decimal point not written). Several patterns can be given; each value is read with the first one that matches. Values that do not match, or are out of range, give `NA` and are listed in one warning. See the new Format section of `?parse_lat`.
* `parse_llstr()` has an `order` argument: `"auto"` (the default), `"lat_lon"` or `"lon_lat"`. With `"auto"`, latitude comes first, unless the direction letters only fit longitude first: "W74.5, N45.5" and "74.5W, 45.5" now give lat 45.5 and lon -74.5. Letters that contradict each other ("E45, E30"), or that do not fit a forced order, give `NA` for both values with a warning. Only rows that gave at least one `NA` before can change.

### BUG FIX

* A Unicode minus sign (U+2212), an en dash or an em dash in front of a number is now read as a minus sign. Before, "−45.5" gave 45.5 without a warning.
* `parse_llstr()` cuts at the only space whatever the number of decimal points: "45 74.5" gave lat `NA` and lon 5. A single decimal number such as "45.74" is no longer cut at the dot into two coordinates; it gives `NA` with a warning. The accepted formats are now listed in the documentation.
* A number with two decimal points, e.g. "40.25.30", gives `NA` with a warning instead of silently reading 40.25.
* `NA` input gives `NA` without a warning in all functions. Before, every `NA` gave a "no digits detected, got: na" warning.
* A minus sign that disagrees with the hemisphere letter, e.g. "N -45" or "-45N", gives `NA` with a warning. Before, "N -45" gave 45 and "-45N" gave -45, both silently. "S -45" still gives -45.
* The degree marks `d` and `g` are accepted in upper case too: "40G 25 6N" gave `NA`.
* `pz_d(1) + 5` and the like now fail with a clear message ("both sides must be pz objects"); unary minus works and keeps the unit: `-pz_m(30)`.
* `pz_degree()`, `parse_lon_lat()` and `parse_hemisphere()` give plain error messages for a missing argument or a length mismatch.
* The lifecycle badge figure is now shipped with the package, so the help page no longer shows a broken image.
* Documentation: invalid values give `NA`, not `NaN`.

### MINOR IMPROVEMENTS

* When a value with 4 or more digits in a row (not after a decimal point), such as "2343 56N", gives `NA` because its degrees, minutes or seconds are out of range, the warning now says that the digits may be packed together and points to the `format` argument. Before, a latitude warning said to check that lon and lat were not inverted.
* Faster input cleaning: `parse_lat()` and `parse_lon()` are about 7 times faster on numeric input and about 25% faster on character input.
* Removed a check in the C++ code that could never fire, and the Japanese-locale test for the old `std::regex` bug. callr, pkgbuild, pkgload and withr are no longer suggested.

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

* Faster parsing: the C++ code no longer uses regular expressions (`std::regex`), numbers are read with `std::stod` instead of a new stream for each token, and `parse_parts_*()` no longer allocates an R list for each coordinate. `parse_lat()`, `parse_lon()`, `parse_llstr()` and `parse_parts_lat()` are about 9 to 12 times faster than in 0.4.4.
* withr is no longer a required dependency (it moved to Suggests). The Windows-only `.Call()` wrapper that forced the C locale (#31) is removed, because it only worked around a `std::regex` bug.
* `parse_hemisphere()` detects the sign of a value with `std::signbit()` instead of converting it to a string.
* Added performance tests (`bench`) to detect slowdowns, and a larger test suite (about 98% coverage).
* The use cases vignette now runs its sf and leaflet code only when both packages are installed.
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
