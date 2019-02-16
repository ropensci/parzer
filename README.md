parzer
======



[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

`parzer` parses coordinates

Code originally from: https://www.codeproject.com/Articles/15659/Longitude-Latitude-String-Parser-and-Formatter

Code retrieved from: https://github.com/batela/Gaypu-Src/tree/master/ll2utm


## Installation


```r
devtools::install_github("ropenscilabs/parzer")
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
parse_lat("N455698735", "HDDMMmmmmm")
#> [1] 45.94979
parse_lat("40.123°")
#> [1] 40.123
parse_lat("40.123N74.123W")
#> [1] NaN
parse_lat("N45 04.25764")
#> [1] 45.07096
# bad values -> NaN
parse_lat("191.89")
#> [1] NaN
# many inputs
x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
parse_lat(x)
#> [1] 40.12300      NaN      NaN 12.00000 45.07096
```

longitudes


```r
parse_lon("45W54.2356")
#> [1] -45.90393
parse_lon("-45.98739874")
#> [1] -45.9874
parse_lon("N455698735", "HDDMMmmmmm")
#> [1] 45.94979
parse_lon("40.123°")
#> [1] 40.123
parse_lon("40.123N74.123W")
#> [1] NaN
parse_lon("N45 04.25764")
#> [1] 45.07096
# bad values
parse_lon("181")
#> [1] NaN
# many inputs
x <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
parse_lon(x)
#> [1] -45.90393       NaN  45.00000  45.23423 -45.98740
```

both lat and lon together


```r
lats <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
parse_lat_lon(lats, lons)
#>        lat       lon
#> 1 40.12300 -45.90393
#> 2      NaN       NaN
#> 3      NaN  45.00000
#> 4 12.00000  45.23423
#> 5 45.07096 -45.98740
```
