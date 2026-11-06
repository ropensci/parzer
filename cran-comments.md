## R CMD check results

0 errors | 0 warnings | 0 notes

* Checked locally (macOS, R 4.6.1), on win-builder (R-devel and R-release) and on GitHub Actions (Windows, Ubuntu R-devel, R-release and R-oldrel-1).
* revdepcheck: 2 reverse dependencies checked, 0 new problems.
* The ror.org URLs in the package help return 429 (Too Many Requests) on win-builder. They are valid; the server limits automated requests.

## Changes in 0.5.0

* Bug fixes: `NA` with a warning for minutes or seconds outside 0-60, correct sign for values between -1 and 0, clearer warnings in `parse_llstr()`, and correct handling of very small and very large numbers.
* The C++ code no longer uses `std::regex`; parsing is about 9 to 12 times faster.
* withr moved from Imports to Suggests.

Thank you for your time reviewing this release.

Dr Alban Sagouis
