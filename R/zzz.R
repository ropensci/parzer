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
  gsub(
    "\u0027\u0027|\u2018\u2018|\u2019\u2019|\u02BC\u02BC|\u0060\u0060|\u00BB|\u201C|\u201D|\u2033|\u3003|\u301E|\u301F|\u0022|\u02BA|\u02DD|\u275E|\u030B|\u030E|\u030F|\u05F4|\u2018|\u2019|\u02BC|\u02C8|\u0060|\u030D|\u02B9|\u00B4|\u0301|\u0374|\u0384|\u2032|\u275C|\u05F3|\u055A|\u055B|\u055D|\u0599|\u059C|\u059D|\u059E|\u00B0|\u02DA|\u030A|\u2070|\u0366|\u05AF|\u00BA|d|g|\u003A", "'", x)

}

stop_form <- function() stop("format handling not ready yet")