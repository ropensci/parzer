dms_helper <- function(lat = NULL, lon = NULL) {
  stopifnot(xor(is.null(lat), is.null(lon)))
  assert(lat, c("numeric", "integer", "character"))
  assert(lon, c("numeric", "integer", "character"))
  if (!is.null(lat)) return(pz_parse_parts_lat(scrub(lat)))
  if (!is.null(lon)) return(pz_parse_parts_lon(scrub(lon)))
}

#' extract degree, minutes, and seconds
#'
#' @export
#' @name dms
#' @aliases degrees minutes seconds
#' @param lat,lon (numeric/integer/character) one or more latitude or
#' longitude values. values are internally validated. only one of
#' lat or lon accepted.
#' @return `pz_degree`: integer, `pz_minute`: integer, `pz_second`: numeric
#' @examples
#' pz_degree(45.23323)
#' pz_minute(45.23323)
#' pz_second(45.23323)
#'
#' pz_degree(lon = 178.23423)
#' pz_minute(lon = 178.23423)
#' pz_second(lon = 178.23423)
#'
#' pz_degree(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994\" N"))
#' pz_minute(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994\" N"))
#' pz_second(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994\" N"))
#'
#' # invalid
#' pz_degree(445.23323)
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

# print.pz <- function(x, ...) {
#   cat(x, sep = "\n")
# }
# deg <- function(x) structure(x, class = "pz", type = "deg")
# min2 <- function(x) structure(x, class = "pz", type = "min")
# sec <- function(x) structure(x, class = "pz", type = "sec")
# `+.pz` <- function(x, y) {
#   x <- switch(attr(x, "type"), deg = x, min  = x/60, sec = x/3600)
#   y <- switch(attr(x, "type"), deg = x, min  = x/60, sec = x/3600)
#   x + y
# }
