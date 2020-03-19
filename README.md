parzer
======



[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.com/ropensci/parzer.svg?branch=master)](https://travis-ci.com/ropensci/parzer)
[![Build status](https://ci.appveyor.com/api/projects/status/m1aackjdyp2f2x3f?svg=true)](https://ci.appveyor.com/project/sckott/parzer)
[![codecov.io](https://codecov.io/github/ropensci/parzer/coverage.svg?branch=master)](https://codecov.io/github/ropensci/parzer?branch=master)
[![](https://badges.ropensci.org/341_status.svg)](https://github.com/ropensci/onboarding/issues/341)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/parzer?color=C9A115)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/parzer)](https://cran.r-project.org/package=parzer)

`parzer` parses messy geographic coordinates

You may get data from a published study or a colleague, and the coordinates
may be in some messy format that you'd like to clean up to e.g., have 
all decimal degree numeric data.

`parzer` API:

 - `parse_hemisphere`
 - `parse_lat`
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

## parse

latitudes


```r
parse_lat("45N54.2356")
#> [1] 45.90393
parse_lat("-45.98739874")
#> [1] -45.9874
parse_lat("40.123°")
#> [1] 40.123
parse_lat("40.123N")
#> [1] 40.123
parse_lat("40.123S")
#> [1] -40.123
parse_lat("N45 04.25764")
#> [1] 45.07096
parse_lat("S45 04.25764")
#> [1] -45.07096

# bad values -> NaN
parse_lat("191.89")
#> Warning in pz_parse_lat(lat): not within -90/90 range, got: 191.89
#>   check that you did not invert lon and lat
#> [1] NaN

# many inputs
x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
parse_lat(x)
#> Warning in pz_parse_lat(lat): invalid characters, got: 40.123n74.123w

#> Warning in pz_parse_lat(lat): not within -90/90 range, got: 191.89
#>   check that you did not invert lon and lat
#> [1] 40.12300      NaN      NaN 12.00000 45.07096

# parse_lat("N455698735", "HDDMMmmmmm") # custom formats not ready yet
```

longitudes


```r
parse_lon("45W54.2356")
#> [1] -45.90393
parse_lon("45E54.2356")
#> Warning in pz_parse_lon(lon): invalid characters, got: 45e54.2356
#> [1] NaN
parse_lon("-45.98739874")
#> [1] -45.9874
parse_lon("40.123°")
#> [1] 40.123
parse_lon("74.123W")
#> [1] -74.123
parse_lon("74.123E")
#> [1] 74.123
parse_lon("W45 04.25764")
#> [1] -45.07096

# bad values
parse_lon("361")
#> Warning in pz_parse_lon(lon): not within -180/360 range, got: 361
#> [1] NaN

# many inputs
x <- c("45W54.2356", "361", 45, 45.234234, "-45.98739874")
parse_lon(x)
#> Warning in pz_parse_lon(lon): not within -180/360 range, got: 361
#> [1] -45.90393       NaN  45.00000  45.23423 -45.98740

# parse_lon("N455698735", "HDDMMmmmmm") # custom formats not ready yet
```

both lon and lat together


```r
lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
lats <- c("40.123°", "40.123N", "191.89", 12, "N45 04.25764")
parse_lon_lat(lons, lats)
#>         lon      lat
#> 1 -45.90393 40.12300
#> 2 181.00000 40.12300
#> 3  45.00000      NaN
#> 4  45.23423 12.00000
#> 5 -45.98740 45.07096
```

parse into degree, min, sec parts


```r
parse_parts_lon("-74.6411133")
#>   deg min      sec
#> 1 -74  38 28.00784
parse_parts_lat("45N54.2356")
#>   deg min      sec
#> 1  45  54 14.13674
# many inputs
x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
parse_parts_lon(x)
#>   deg min      sec
#> 1  40   7 22.80395
#> 2  NA  NA      NaN
#> 3 191  53 23.99783
#> 4  12   0  0.00000
#> 5  NA  NA      NaN
```

get hemisphere from lat/lon coords


```r
parse_hemisphere("74.123E", "45N54.2356")
#> [1] "NE"
parse_hemisphere("-120", "40.4183318")
#> [1] "NW"
parse_hemisphere("-120", "-40.4183318")
#> [1] "SW"
parse_hemisphere("120", "-40.4183318")
#> [1] "SE"
```

get degree, minutes, or seconds separately


```r
coords <- c(45.23323, "40:25:6N", "40° 25´ 5.994\" N")
pz_degree(lat = coords)
#> [1] 45 40 40
pz_minute(lat = coords)
#> [1] 13 25 25
pz_second(lat = coords)
#> [1] 59.630119  6.005895  5.992162

coords <- c(15.23323, "40:25:6E", "192° 25´ 5.994\" E")
pz_degree(lon = coords)
#> [1]  15  40 192
pz_minute(lon = coords)
#> [1] 13 25 25
pz_second(lon = coords)
#> [1] 59.626686  6.005895  6.005895
```

add or subtract degrees, minutes, or seconds


```r
pz_d(31)
#> 31
pz_d(31) + pz_m(44)
#> 31.73333
pz_d(31) - pz_m(44)
#> 30.26667
pz_d(31) + pz_m(44) + pz_s(59)
#> 31.74972
pz_d(-121) + pz_m(1) + pz_s(33)
#> -120.9742
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
* Please note that this project is released with a [Contributor Code of Conduct][coc]
By participating in this project you agree to abide by its terms.

[coc]: https://github.com/ropensci/parzer/blob/master/CODE_OF_CONDUCT.md

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
