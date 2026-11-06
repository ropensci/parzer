assert <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
      stop(
        deparse(substitute(x)),
        " must be of class ",
        paste0(y, collapse = ", "),
        call. = FALSE
      )
    }
  }
}

lint_inputs <- function(lon = NULL, lat = NULL, format) {
  assert(lon, c("numeric", "integer", "character"))
  assert(lat, c("numeric", "integer", "character"))
  assert(format, "character")
}

# as.character() gives "1e-05" for small numbers, which the parser misreads
num_to_chr <- function(x) {
  if (!is.numeric(x)) {
    return(as.character(x))
  }
  vapply(
    x,
    function(value) {
      if (is.na(value)) {
        NA_character_
      } else {
        format(value, scientific = FALSE, digits = 15, trim = TRUE)
      }
    },
    FUN.VALUE = character(1L)
  )
}

scrub <- function(x) {
  trimws(gsub("[^A-Za-z0-9\\.\\ ,'-]|d|g", "'", num_to_chr(x)))
}

stop_form <- function() stop("format handling not ready yet")
