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

scrub <- function(x) gsub("[^A-Za-z0-9\\.\\ ,'-]|d|g", "'", x)

stop_form <- function() stop("format handling not ready yet")

# Because of a std::regex's bug, all Rcpp functions hangs on Windows with MBCS
# locale (#31). As a workaround for this, we can wrap the functions with
# `withr::with_locale()` and force C locale temporarily. To ensure all the Rcpp
# functions are wrapped with this, override `.Call()` inside the package.
.Call <- function(...) {
  if (identical(tolower(Sys.info()[["sysname"]]), "windows")) {
    withr::with_locale(
      c(LC_COLLATE = "C"),
      base::.Call(...)
    )
  } else {
    base::.Call(...)
  }
}
