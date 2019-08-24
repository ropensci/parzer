dms_helper <- function(lat = NULL, lon = NULL) {
  stopifnot(xor(is.null(lat), is.null(lon)))
  assert(lat, c("numeric", "integer", "character"))
  assert(lon, c("numeric", "integer", "character"))
  if (!is.null(lat)) return(pz_parse_parts_lat(scrub(lat)))
  if (!is.null(lon)) return(pz_parse_parts_lon(scrub(lon)))
}

#' extract degree, minutes, and seconds
#'
#' @name dms
#' @param lat,lon (numeric/integer/character) one or more latitude or
#' longitude values. values are internally validated. only one of
#' lat or lon accepted
#' @param x (integer) an integer representing a degree, minute or second
#' @param e1,e2 objects of class pz, from using `d()`, `m()`, or `s()`
#' @param ... print dots
#' @return `pz_degree`: integer, `pz_minute`: integer, `pz_second`: numeric
#' @examples
#' # extract parts of a coordinate value
#' pz_degree(45.23323)
#' pz_minute(45.23323)
#' pz_second(45.23323)
#'
#' pz_degree(lon = 178.23423)
#' pz_minute(lon = 178.23423)
#' pz_second(lon = 178.23423)
#'
#' pz_degree(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 N"))
#' pz_minute(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 N"))
#' pz_second(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 N"))
#'
#' # invalid
#' pz_degree(445.23323)
#'
#' # add together
#' d(31)
#' d(31) + m(44)
#' d(31) + m(44) + s(59)
#' d(-121) + m(1) + s(33)
#' unclass(d(31) + m(44) + s(59))
NULL

#' @export
#' @rdname dms
pz_degree <- function(lat = NULL, lon = NULL) {
  dms_helper(lat, lon)$deg
}

#' @export
#' @rdname dms
pz_minute <- function(lat = NULL, lon = NULL) {
  dms_helper(lat, lon)$min
}

#' @export
#' @rdname dms
pz_second <- function(lat = NULL, lon = NULL) {
  dms_helper(lat, lon)$sec
}

# adders
unclass_strip_atts <- function(x) {
  attributes(x) <- NULL
  return(x)
}
#' @export
#' @rdname dms
print.pz <- function(x, ...) cat(x, sep = "\n")
#' @export
#' @rdname dms
d <- function(x) structure(x, class = "pz", type = "deg")
#' @export
#' @rdname dms
m <- function(x) structure(x, class = "pz", type = "min")
#' @export
#' @rdname dms
s <- function(x) structure(x, class = "pz", type = "sec")
#' @export
#' @rdname dms
`+.pz` <- function(e1, e2) {
  e1u <- unclass_strip_atts(e1)
  e2u <- unclass_strip_atts(e2)
  e1 <- switch(attr(e1, "type"), deg = e1u, min  = e1u/60, sec = e1u/3600)
  e2 <- switch(attr(e2, "type"), deg = e2u, min  = e2u/60, sec = e2u/3600)
  structure(e1 + e2, class = "pz", type = "deg")
}
