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

lint_inputs <- function(lon, lat) {
  assert(lon, c("numeric", "integer", "character"))
  assert(lat, c("numeric", "integer", "character"))
  stopifnot(
    "lon and lat must have the same length" = length(lon) == length(lat)
  )
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

# Cleans every input before the C++ parser reads it. The rules (NA, dashes,
# degree marks and other symbols, trimming) are in src/scrub.cpp.
scrub <- function(x) pz_scrub(enc2utf8(num_to_chr(x)))
