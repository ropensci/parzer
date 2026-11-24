dms_helper <- function(lon = NULL, lat = NULL) {
  stopifnot("give exactly one of lon or lat" = xor(is.null(lon), is.null(lat)))
  assert(lon, c("numeric", "integer", "character"))
  assert(lat, c("numeric", "integer", "character"))
  if (!is.null(lon)) {
    return(pz_parse_parts_lon(scrub(lon)))
  }
  pz_parse_parts_lat(scrub(lat))
}

#' extract degree, minutes, and seconds
#'
#' @name dms
#' @param lon,lat (numeric/integer/character) one or more longitude or
#' latitude values. values are internally validated. only one of
#' lon or lat accepted
#' @param x (integer) an integer representing a degree, minute or second
#' @param e1,e2 objects of class pz, from using `pz_d()`, `pz_m()`, or `pz_s()`
#' @param ... print dots
#' @return `pz_degree`: integer, `pz_minute`: integer, `pz_second`: numeric,
#' `pz_d`: numeric, `pz_m`: numeric, `pz_s`: numeric (adding/subtracting
#' these also gives numeric)
#' @details Mathematics operators are exported for `+`, `-`, `/`, and `*`,
#' but `/` and `*` are only exported with a stop message to say it's not
#' supported; otherwise you'd be allow to divide degrees by minutes, leading
#' to nonsense. Both sides of `+` and `-` must be pz objects: `pz_d(1) + 5`
#' is an error, because a plain number has no unit. Unary minus keeps the
#' unit: `-pz_m(30)` is minus 30 minutes.
#' @examples
#' # extract parts of a coordinate value
#' pz_degree(-45.23323)
#' pz_minute(-45.23323)
#' pz_second(-45.23323)
#'
#' pz_degree(lon = 178.23423)
#' pz_minute(lon = 178.23423)
#' pz_second(lon = 178.23423)
#' \dontrun{
#' pz_degree(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 S"))
#' pz_minute(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 S"))
#' pz_second(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 S"))
#'
#' # invalid
#' pz_degree(445.23323)
#'
#' # add or subtract
#' pz_d(31)
#' pz_m(44)
#' pz_s(3)
#' pz_d(31) + pz_m(44)
#' pz_d(-31) - pz_m(44)
#' pz_d(-31) + pz_m(44) + pz_s(59)
#' pz_d(31) - pz_m(44) + pz_s(59)
#' pz_d(-121) + pz_m(1) + pz_s(33)
#' unclass(pz_d(31) + pz_m(44) + pz_s(59))
#' }
NULL

#' @export
#' @rdname dms
pz_degree <- function(lon = NULL, lat = NULL) {
  dms_helper(lon, lat)$deg
}

#' @export
#' @rdname dms
pz_minute <- function(lon = NULL, lat = NULL) {
  dms_helper(lon, lat)$min
}

#' @export
#' @rdname dms
pz_second <- function(lon = NULL, lat = NULL) {
  dms_helper(lon, lat)$sec
}

# adders
unclass_strip_atts <- function(x) {
  attributes(x) <- NULL
  return(x)
}
# value of a pz object in decimal degrees; a plain number has no unit
pz_to_deg <- function(e) {
  if (!inherits(e, "pz")) {
    stop(
      "both sides must be pz objects, see pz_d(), pz_m() and pz_s()",
      call. = FALSE
    )
  }
  eu <- unclass_strip_atts(e)
  switch(attr(e, "type"), deg = eu, min = eu / 60, sec = eu / 3600)
}
#' @export
#' @rdname dms
print.pz <- function(x, ...) cat(x, sep = "\n")
#' @export
#' @rdname dms
pz_d <- function(x) {
  assert(x, c("integer", "numeric"))
  structure(x, class = "pz", type = "deg")
}
#' @export
#' @rdname dms
pz_m <- function(x) {
  assert(x, c("integer", "numeric"))
  structure(x, class = "pz", type = "min")
}
#' @export
#' @rdname dms
pz_s <- function(x) {
  assert(x, c("integer", "numeric"))
  structure(x, class = "pz", type = "sec")
}
#' @export
#' @rdname dms
`+.pz` <- function(e1, e2) {
  if (missing(e2)) {
    return(e1)
  }
  structure(pz_to_deg(e1) + pz_to_deg(e2), class = "pz", type = "deg")
}
#' @export
#' @rdname dms
`-.pz` <- function(e1, e2) {
  if (missing(e2)) {
    # unary minus keeps the unit: -pz_m(30) is still minutes
    return(structure(
      -unclass_strip_atts(e1),
      class = "pz",
      type = attr(e1, "type")
    ))
  }
  structure(pz_to_deg(e1) - pz_to_deg(e2), class = "pz", type = "deg")
}
#' @export
#' @rdname dms
`/.pz` <- function(e1, e2) {
  stop("division doesn't make sense here :)", call. = FALSE)
}
#' @export
#' @rdname dms
`*.pz` <- function(e1, e2) {
  stop("multiplication doesn't make sense here :)", call. = FALSE)
}
