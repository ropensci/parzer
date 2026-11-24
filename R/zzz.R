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

# Each number is written on its own, so that its text does not depend on the
# other numbers of the vector: format() on the whole vector gives them all
# the same number of decimals ("4530.0"), which `format` does not match.
# as.character() is fast and gives the same 15 significant digits as
# format(), but writes "1e-05" for small numbers, which the parser misreads:
# those few go through format() one by one.
num_to_chr <- function(x) {
  out <- as.character(x)
  if (!is.numeric(x)) {
    return(out)
  }
  sci <- which(grepl(pattern = "e", x = out, fixed = TRUE))
  out[sci] <- vapply(
    X = x[sci],
    FUN = format,
    FUN.VALUE = character(1L),
    scientific = FALSE,
    digits = 15,
    trim = TRUE
  )
  out[is.na(x)] <- NA_character_
  out
}

# Cleans every input before the C++ parser reads it. The rules (NA, dashes,
# degree marks and other symbols, trimming) are in src/scrub.cpp.
scrub <- function(x) {
  check_encoding(x)
  pz_scrub(enc2utf8(num_to_chr(x)))
}

# Stops on strings that are not text, with or without `format`: strings
# marked "bytes", and strings marked "latin1" with one of the 5 bytes that
# Windows-1252 leaves undefined. enc2utf8() reads latin1 as Windows-1252 and
# turns these bytes into text such as "<81>", whose digits would be read as
# a coordinate. Invalid UTF-8 is caught later: by pz_scrub(), or by the
# regular expressions of the `format` path.
check_encoding <- function(x) {
  # numbers have no encoding: they pay nothing
  if (!is.character(x)) {
    return(invisible(NULL))
  }
  enc <- Encoding(x)
  marked <- which(enc == "bytes" | enc == "latin1")
  bad <- marked[
    enc[marked] == "bytes" |
      grepl(
        pattern = "[\\x81\\x8d\\x8f\\x90\\x9d]",
        x = x[marked],
        perl = TRUE,
        useBytes = TRUE
      )
  ]
  if (length(bad) == 0L) {
    return(invisible(NULL))
  }
  i <- bad[[1]]
  if (enc[[i]] == "bytes") {
    stop(
      "input string ",
      i,
      " is marked as \"bytes\", convert it to UTF-8 first, ",
      "for example with iconv()",
      call. = FALSE
    )
  }
  stop(
    "input string ",
    i,
    " is marked as \"latin1\" but has a byte that is not a character ",
    "(0x81, 0x8D, 0x8F, 0x90 or 0x9D)",
    call. = FALSE
  )
}
