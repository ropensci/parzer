parzer
======



`parzer` parses coordinates


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
```
