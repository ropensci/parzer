## Why a new version so soon after 0.5.0

0.5.0 was released on 2026-11-16. This version follows 8 days later because,
after that release, we found several bugs that returned a wrong value without
any warning. For example:

* A minus sign written as a Unicode minus or a dash was lost: "−45.5" gave 45.5.
* A minus sign that disagrees with the direction letter was ignored: "N -45"
  gave 45 and "-45N" gave -45.
* `parse_llstr()` could return a latitude as the longitude when the two values
were swapped, and cut "45 74.5" into lat `NA` and lon 5.
* A number with two decimal points, such as "40.25.30", was read as 40.25.

These cases now give `NA` with a warning, or the correct value. The full list is
in NEWS.md.

Since the bugs are in the core parsing, we preferred to fix them now and not
wait
for a later release. The version also adds the `format` argument, which until
now stopped with "format handling not ready yet", and makes the input cleaning
faster. No function was removed or renamed, and no new dependency was added.

## R CMD check results

0 errors | 0 warnings | 0 notes

Checked locally on ARM64 Mac, on GHA Windows, Linux and MacOS and with
win-builder. The Mac builder did not respond.

## Changes in 0.6.0

* Bug fixes: see above and NEWS.md.
* New: `format` argument in `parse_lat()`, `parse_lon()` and `parse_llstr()`,
`lon_format` and `lat_format` in `parse_lon_lat()`, and `order` argument in
`parse_llstr()`.
* Faster input cleaning (C++, no regular expressions).
* callr, pkgbuild, pkgload and withr are no longer in Suggests.

Thank you for your time reviewing this release.

Dr Alban Sagouis
