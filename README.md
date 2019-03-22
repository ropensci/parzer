parzer
======



[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

`parzer` parses coordinates

`parzer` API:

 - `parse_hemisphere`
 - `parse_lat`
 - `parse_lat_lon`
 - `parse_lon`
 - `parse_parts_lat`
 - `parse_parts_lon`


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
parse_lat("40.123°")
#> [1] 40.123
parse_lat("40.123N")
#> [1] 40.123
parse_lat("N45 04.25764")
#> [1] 45.07096

# bad values -> NaN
parse_lat("191.89")
#> [1] NaN

# many inputs
x <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")
parse_lat(x)
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
