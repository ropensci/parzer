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
  if(is.character(x)){
    if(length(x) == 1 && Encoding(x) != "UTF-8") x <- iconv(x, to = 'UTF-8')
    if(length(x) > 1) x <- ifelse(Encoding(x) == 'UTF-8', x, iconv(x, to = "UTF-8"))
  }
  return(scrub_cpp(x))
}

stop_form <- function() stop("format handling not ready yet")
