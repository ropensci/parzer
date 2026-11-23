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
scrub <- function(x) {
  x <- num_to_chr(x)
  # enc2utf8() reads latin1 as Windows-1252 and turns the 5 bytes it leaves
  # undefined into text such as "<81>", whose digits would be read as a
  # coordinate. Only strings marked "latin1" are checked.
  latin1 <- which(Encoding(x) == "latin1")
  bad <- latin1[grepl(
    pattern = "[\x81\x8d\x8f\x90\x9d]",
    x = x[latin1],
    useBytes = TRUE
  )]
  if (length(bad) > 0L) {
    stop(
      "input string ",
      bad[[1]],
      " is marked as \"latin1\" but has a byte that is not a character ",
      "(0x81, 0x8D, 0x8F, 0x90 or 0x9D)",
      call. = FALSE
    )
  }
  pz_scrub(enc2utf8(x))
}
