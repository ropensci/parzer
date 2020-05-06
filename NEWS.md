parzer 0.1.4
============

### MINOR IMPROVEMENTS

* add support to internal function for additional degree like symbols (#21)
* fix issue with `parse_parts_lat()`/`parse_parts_lon()` functions where an NA was causing warnings on the cpp side; on cpp side, now check for NA and return list of NAs instead of NAs passing through other code (#23)

parzer 0.1.0
============

### NEW FEATURES

* Released to CRAN.
