parzer
======



[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.com/ropenscilabs/parzer.svg?branch=master)](https://travis-ci.com/ropenscilabs/parzer)
[![codecov.io](https://codecov.io/github/ropenscilabs/parzer/coverage.svg?branch=master)](https://codecov.io/github/ropenscilabs/parzer?branch=master)

`parzer` parses messy coordinates

You may get data from a published study or a colleague, and the coordinates
may be in some messy format that you'd like to clean up to e.g., have
all decimal degree numeric data.

`parzer` API:

 - `d`
 - `m`
 - `parse_hemisphere`
 - `parse_lat`
 - `parse_lat_lon`
 - `parse_lon`
 - `parse_parts_lat`
 - `parse_parts_lon`
 - `pz_degree`
 - `pz_minute`
 - `pz_second`
 - `s`


## Installation


```r
remotes::install_github("ropenscilabs/parzer")
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
parse_lat("N45 04.25764")
#> [1] 45.07096

# bad values -> NaN
parse_lat("191.89")
#> Warning in pz_parse_lat(lat): not within -90/90 range, got: 191.89
#> [1] NaN

# many inputs
x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
parse_lat(x)
#> Warning in pz_parse_lat(lat): invalid characters, got: 40.123n74.123w

#> Warning in pz_parse_lat(lat): not within -90/90 range, got: 191.89
#> [1] 40.12300      NaN      NaN 12.00000 45.07096

# parse_lat("N455698735", "HDDMMmmmmm") # custom formats not ready yet
```

longitudes


```r
parse_lon("45W54.2356")
#> [1] -45.90393
parse_lon("-45.98739874")
#> [1] -45.9874
parse_lon("40.123°")
#> [1] 40.123
parse_lon("74.123W")
#> [1] -74.123
parse_lon("W45 04.25764")
#> [1] -45.07096

# bad values
parse_lon("181")
#> [1] 181

# many inputs
x <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
parse_lon(x)
#> [1] -45.90393 181.00000  45.00000  45.23423 -45.98740

# parse_lon("N455698735", "HDDMMmmmmm") # custom formats not ready yet
```

both lat and lon together


```r
lats <- c("40.123°", "40.123N", "191.89", 12, "N45 04.25764")
lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
parse_lat_lon(lats, lons)
#>        lat       lon
#> 1 40.12300 -45.90393
#> 2 40.12300 181.00000
#> 3      NaN  45.00000
#> 4 12.00000  45.23423
#> 5 45.07096 -45.98740
```

parse into degree, min, sec parts


```r
parse_parts_lat("45N54.2356")
#>   deg min      sec
#> 1  45  54 14.13674
parse_parts_lon("-74.6411133")
#>   deg min      sec
#> 1 -74  38 28.00784
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
parse_hemisphere("45N54.2356", "74.123E")
#> [1] "NE"
parse_hemisphere("40.4183318", "-120")
#> [1] "NW"
parse_hemisphere("-40.4183318", "-120")
#> [1] "SW"
parse_hemisphere("-40.4183318", "120")
#> [1] "SE"
```

get degree, minutes, or seconds separately


```r
coords <- c(45.23323, "40:25:6N", "40° 25´ 5.994\" N")
pz_degree(coords)
#> [1] 45 40 40
pz_minute(coords)
#> [1] 13 25 25
pz_second(coords)
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
d(31)
#> 31
d(31) + m(44)
#> 31.73333
d(31) - m(44)
#> 30.26667
d(31) + m(44) + s(59)
#> 31.74972
d(-121) + m(1) + s(33)
#> -120.9742
```

## Meta

* Please [report any issues or bugs](https://github.com/ropenscilabs/parzer/issues).
* License: MIT
* Get citation information for `parzer` in R doing `citation(package = 'parzer')`
* Please note that this project is released with a [Contributor Code of Conduct][coc]
By participating in this project you agree to abide by its terms.

[coc]: https://github.com/ropenscilabs/parzer/blob/master/CODE_OF_CONDUCT.md
