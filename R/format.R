# The `format` argument of parse_lat() and parse_lon(). Each format, such as
# "DDMMSSH", becomes one regular expression that is matched against the raw
# input: scrub() and the C++ parser are not used here. Three steps, kept
# apart so that a format for a lat/lon pair can reuse them:
# - compile_format(): one format to a regular expression and its fields
# - fields_to_degrees(): the matched fields of one coordinate to a value
# - warn_unread(): one warning for all the values that gave NA

# Check every format before any parsing.
check_format <- function(format) {
  if (length(format) == 0L || anyNA(format)) {
    stop("format must be one or more strings, without NA", call. = FALSE)
  }
  lapply(X = format, FUN = compile_format)
}

# Returns a list: `regex` (not anchored, so it can be combined with another
# one), `groups` (the field of each capture group, in order: "sign", "D",
# "M", "S", "dec" or "H") and `dec_unit` (the unit that the decimal digits
# belong to, or "").
compile_format <- function(format) {
  fail <- function(why) {
    stop("invalid format \"", format, "\": ", why, call. = FALSE)
  }
  # runs of the same letter ("DD", "mmm", "H") and single other characters
  tokens <- regmatches(
    x = format,
    m = gregexpr(pattern = "([A-Za-z])\\1*|.", text = format, perl = TRUE)
  )[[1]]
  first <- substr(x = tokens, start = 1L, stop = 1L)
  is_letter <- grepl(pattern = "^[A-Za-z]$", x = first)

  unknown <- setdiff(
    x = first[is_letter],
    y = c("D", "M", "S", "d", "m", "s", "H")
  )
  if (length(unknown) > 0L) {
    fail(paste0(
      "unknown letter ",
      paste(unknown, collapse = ", "),
      ", use only D, M, S, d, m, s and H"
    ))
  }
  if (!is.element(el = "D", set = first)) {
    fail("D (degrees) is missing")
  }
  if (sum(nchar(tokens[first == "H"])) > 1L) {
    fail("more than one H")
  }

  # decimal digits: only one block, attached to the last unit
  dec <- which(is.element(el = first, set = c("d", "m", "s")))
  dec_unit <- ""
  if (length(dec) > 0L) {
    i <- dec[[1]]
    dec_unit <- toupper(first[[i]])
    attached <- (i > 1L && first[[i - 1L]] == dec_unit) ||
      (i > 2L && tokens[[i - 1L]] == "." && first[[i - 2L]] == dec_unit)
    if (!attached) {
      fail(paste0(
        first[[i]],
        " must come right after ",
        dec_unit,
        ", or after a \".\" that follows ",
        dec_unit
      ))
    }
    after <- first[seq_along(first) > i]
    if (any(is.element(el = after, set = c("D", "M", "S", "d", "m", "s")))) {
      fail("only the last of D, M and S can have decimal digits (d, m, s)")
    }
  }

  units <- first[is.element(el = first, set = c("D", "M", "S"))]
  if (anyDuplicated(units) > 0L) {
    fail("D, M and S can each be used only once, as one block of letters")
  }
  if (is.element(el = "S", set = units) && !is.element(el = "M", set = units)) {
    fail("S (seconds) needs M (minutes)")
  }
  if (!identical(units, c("D", "M", "S")[seq_along(units)])) {
    fail("D, M and S must come in this order")
  }

  groups <- character(0)
  pieces <- character(length(tokens))
  for (i in seq_along(tokens)) {
    tok <- tokens[[i]]
    if (is.element(el = first[[i]], set = c("D", "M", "S"))) {
      digits <- paste0("([0-9]{", nchar(tok), "})")
      if (first[[i]] == "D") {
        # the signs that format = NULL reads (see scrub()): + - and the
        # Unicode minus, en dash and em dash
        pieces[[i]] <- paste0("([-+\u2212\u2013\u2014]?)", digits)
        groups <- c(groups, "sign", "D")
      } else {
        pieces[[i]] <- digits
        groups <- c(groups, first[[i]])
      }
    } else if (is.element(el = first[[i]], set = c("d", "m", "s"))) {
      # after a written "." any number of digits, else exactly as many as letters
      pieces[[i]] <- if (tokens[[i - 1L]] == ".") {
        "([0-9]+)"
      } else {
        paste0("([0-9]{", nchar(tok), "})")
      }
      groups <- c(groups, "dec")
    } else if (tok == "H") {
      pieces[[i]] <- "([NSEWnsew])"
      groups <- c(groups, "H")
    } else if (tok == " ") {
      pieces[[i]] <- "\\s+"
    } else {
      # any other character matches itself: escape regex metacharacters
      pieces[[i]] <- gsub(
        pattern = "([][{}()^$.|*+?\\\\])",
        replacement = "\\\\\\1",
        x = tok,
        perl = TRUE
      )
    }
  }
  list(
    regex = paste(pieces, collapse = ""),
    groups = groups,
    dec_unit = dec_unit
  )
}

# Parse `x` with the formats in `format`, tried in order for each value.
# `what` is "lat" or "lon".
parse_with_format <- function(x, format, what) {
  formats <- check_format(format)
  x <- trimws(num_to_chr(x))
  out <- rep(NA_real_, times = length(x))
  why <- rep(NA_character_, times = length(x))
  # like format = NULL, NA and "" give NA without a warning
  todo <- which(!is.na(x) & nzchar(x))
  for (f in formats) {
    if (length(todo) == 0L) {
      break
    }
    found <- regmatches(
      x = x[todo],
      m = regexec(
        pattern = paste0("^", f[["regex"]], "$"),
        text = x[todo],
        perl = TRUE
      )
    )
    matched <- lengths(found) > 0L
    if (!any(matched)) {
      next
    }
    fields <- do.call(what = rbind, args = found[matched])[, -1L, drop = FALSE]
    colnames(fields) <- f[["groups"]]
    res <- fields_to_degrees(
      fields = fields,
      dec_unit = f[["dec_unit"]],
      what = what
    )
    out[todo[matched]] <- res[["value"]]
    why[todo[matched]] <- res[["why"]]
    todo <- todo[!matched]
  }
  why[todo] <- "does not match format"
  warn_unread(x = x, why = why)
  out
}

# One warning that lists each value of `x` with a reason in `why`.
warn_unread <- function(x, why) {
  bad <- which(!is.na(why))
  if (length(bad) == 0L) {
    return(invisible(NULL))
  }
  lines <- paste0("  ", encodeString(x[bad], quote = "\""), ": ", why[bad])
  if (length(lines) > 10L) {
    lines <- c(lines[1:10], paste0("  ... and ", length(lines) - 10L, " more"))
  }
  warning(
    "NA for ",
    length(bad),
    " value(s) that could not be read with `format`:\n",
    paste(lines, collapse = "\n"),
    call. = FALSE
  )
}

# Signed decimal degrees from the matched fields of one coordinate (a
# character matrix: one row per value, one column per capture group, named
# as in compile_format()). Applies the sign and H rules and the range
# checks; `why` gives the reason for each NA. `what` is "lat" or "lon".
fields_to_degrees <- function(fields, dec_unit, what) {
  unit_value <- function(unit) {
    if (!is.element(el = unit, set = colnames(fields))) {
      return(0)
    }
    digits <- fields[, unit]
    if (identical(unit, dec_unit)) {
      digits <- paste0(digits, ".", fields[, "dec"])
    }
    as.numeric(digits)
  }
  deg <- unit_value("D")
  min <- unit_value("M")
  sec <- unit_value("S")
  minus <- !is.element(el = fields[, "sign"], set = c("", "+"))
  pair <- if (identical(what, "lat")) c("N", "S") else c("E", "W")

  why <- rep(NA_character_, times = nrow(fields))
  sgn <- ifelse(test = minus, yes = -1, no = 1)
  if (is.element(el = "H", set = colnames(fields))) {
    letter <- toupper(fields[, "H"])
    why[!is.element(el = letter, set = pair)] <- paste0(
      "direction letter must be ",
      pair[[1]],
      " or ",
      pair[[2]]
    )
    # as with format = NULL: "-45N" is NA, "-45S" and "+45S" are -45
    why[is.na(why) & minus & letter == pair[[1]]] <-
      "minus sign and direction letter disagree"
    sgn <- ifelse(test = letter == pair[[2]], yes = -1, no = 1)
  }
  why[is.na(why) & (min >= 60 | sec >= 60)] <-
    "minutes or seconds not within 0/60 range"
  value <- sgn * (deg + min / 60 + sec / 3600)
  if (identical(what, "lat")) {
    why[is.na(why) & abs(value) > 90] <- "not within -90/90 range"
  } else {
    why[
      is.na(why) & (value < -180 | value > 360)
    ] <- "not within -180/360 range"
  }
  value[!is.na(why)] <- NA_real_
  # a one-row matrix gives named columns: drop the names
  list(value = unname(value), why = why)
}
