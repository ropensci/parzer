assert <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
      stop(deparse(substitute(x)), " must be of class ",
           paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}

lint_inputs <- function(lon = NULL, lat = NULL, format) {
  assert(lon, c("character", "numeric", "integer"))
  assert(lat, c("character", "numeric", "integer"))
  assert(format, "character")
}

# FIXME: stopgap for now until figure out how to replace these on on src side
# - single quotes
# - double quotes
# - degree symbols
# - masculine ordinal indicator
# - rare separators
scrub <- function(x) {
  return(scrub_cpp(iconv(x, to = 'UTF-8')))
}

stop_form <- function() stop("format handling not ready yet")
