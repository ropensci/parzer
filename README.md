parzer
================

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![cran
checks](https://badges.cranchecks.info/worst/parzer.svg)](https://cran.r-project.org/web/checks/check_results_parzer.html)
[![R-CMD-check](https://github.com/ropensci/parzer/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/parzer/actions/)
[![rstudio mirror
downloads](https://cranlogs.r-pkg.org/badges/parzer)](https://github.com/r-hub/cranlogs.app)
[![cran
version](https://www.r-pkg.org/badges/version/parzer)](https://cran.r-project.org/package=parzer)

[![codecov.io](https://codecov.io/github/ropensci/parzer/coverage.svg?branch=main)](https://app.codecov.io/github/ropensci/parzer?branch=main)
[![Ropensci Peer
Reviewed](https://badges.ropensci.org/341_status.svg)](https://github.com/ropensci/software-review/issues/341)

`parzer` parses messy geographic coordinates

Docs: <https://docs.ropensci.org/parzer/>

You may get data from a published study or a colleague where the
coordinates are in some messy character format that you’d like to clean
up to get all decimal degree numeric data.

## `parzer` usage

For example, parse latitude and longitude from messy character vectors.

``` r
parse_lat(c("45N54.2356", "-45.98739874", "40.123°"))
R> [1]  45.90 -45.99  40.12
```

``` r
parse_lon(c("45W54.2356", "-45.98739874", "40.123°"))
R> [1] -45.90 -45.99  40.12
```

And you can even split and parse strings that contain latitude and
longitude together.

``` r
parse_llstr(c("4 51'36\"S, 101 34'7\"W",
              "40.123°; 45W54.2356"))
R>     lat    lon
R> 1 -4.86 -101.6
R> 2 40.12  -45.9
```

See more in the [Introduction to the `parzer` package
vignette](https://docs.ropensci.org/parzer/articles/parzer.html).

## Installation

### Stable version:

``` r
install.packages("parzer")
```

### Development version:

``` r
remotes::install_github("ropensci/parzer")
```

## List of functions:

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

## Similar art

- `sp::char2dms`: is most similar to `parzer::parse_lat` and
  `parzer::parse_lon`. However, with `sp::char2dms` you have to specify
  the termination character for each of degree, minutes and seconds.
  `parzer` does this for the user.
- `biogeo::dms2dd`: very unlike functions in this package. You must pass
  separate degrees, minutes, seconds and direction to `dms2dd`. No exact
  analog is found in `parzer`, whose main focus is parsing messy
  geographic coordinates in strings to a more machine readable version.

## Meta

- Please [report any issues or
  bugs](https://github.com/ropensci/parzer/issues).
- License: MIT
- Get citation information for `parzer` in R doing
  `citation(package = 'parzer')`
- Please note that this package is released with a [Contributor Code of
  Conduct](https://ropensci.org/code-of-conduct/). By contributing to
  this project, you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
