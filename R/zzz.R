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
  out <- format(x, scientific = FALSE, digits = 15, trim = TRUE)
  out[is.na(x)] <- NA_character_
  out
}

scrub <- function(x) {
  x <- num_to_chr(x)
  # NA in, NA out: "" is the one input the C++ parser turns into NA silently
  x[is.na(x)] <- ""
  # Unicode minus sign, en dash and em dash are a minus sign
  x <- gsub(
    pattern = "[\u2212\u2013\u2014]",
    replacement = "-",
    x = x,
    perl = TRUE
  )
  trimws(gsub(
    pattern = "[^A-Za-z0-9. ,'-]|d|g",
    replacement = "'",
    x = x,
    perl = TRUE
  ))
}

stop_form <- function() stop("format handling not ready yet")
