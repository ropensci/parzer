parzer
======



[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![cran checks](https://cranchecks.info/badges/worst/parzer)](https://cranchecks.info/pkgs/parzer)
[![R-check](https://github.com/ropensci/parzer/workflows/R-check/badge.svg)](https://github.com/ropensci/parzer/actions/)
[![codecov.io](https://codecov.io/github/ropensci/parzer/coverage.svg?branch=master)](https://codecov.io/github/ropensci/parzer?branch=master)
[![](https://badges.ropensci.org/341_status.svg)](https://github.com/ropensci/software-review/issues/341)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/parzer?color=C9A115)](https://github.com/r-hub/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/parzer)](https://cran.r-project.org/package=parzer)

`parzer` parses messy geographic coordinates

Docs: https://docs.ropensci.org/parzer/

You may get data from a published study or a colleague, and the coordinates
may be in some messy format that you'd like to clean up to e.g., have 
all decimal degree numeric data.

`parzer` API:

 - `parse_hemisphere`
 - `parse_lat`
 - `parse_llstr`
 - `parse_lon`
 - `parse_lon_lat`
 - `parse_parts_lat`
 - `parse_parts_lon`
 - `pz_d`
 - `pz_degree`
 - `pz_m`
 - `pz_minute`
 - `pz_s`
 - `pz_second`


## Installation

Stable version


```r
install.packages("parzer")
```

Development version


```r
remotes::install_github("ropensci/parzer")
```


```r
library("parzer")
```


## Similar art

- `sp::char2dms`: is most similar to `parzer::parse_lat` and `parzer::parse_lon`. However,
with `sp::char2dms` you have to specify the termination character for each of degree,
minutes and seconds. `parzer` does this for the user.
- `biogeo::dms2dd`: very unlike functions in this package. You must pass separate degrees,
minutes, seconds and direction to `dms2dd`. No exact analog is found in `parzer`, whos
main focus is parsing messy geographic coordinates in strings to a more machine readable
version

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/parzer/issues).
* License: MIT
* Get citation information for `parzer` in R doing `citation(package = 'parzer')`
* Please note that this package is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By contributing to this project, you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
