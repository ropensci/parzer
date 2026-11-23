# The `format` argument of parse_lat() and parse_lon(). Each format, such as
# "DDMMSSH", becomes one regular expression that is matched against the raw
# input: scrub() and the C++ parser are not used here. Three steps, kept
# apart so that a format for a lat/lon pair can reuse them:
# - compile_format(): one format to a regular expression and its fields
# - fields_to_degrees(): the matched fields of one coordinate to a value
# - warn_unread(): one warning for all the values that gave NA
# A format for a whole "lat lon" string, as in parse_llstr(), is cut in two
# and each part is compiled with compile_format(): see compile_pair_format().

# Check every format before any parsing. `compile` is compile_format() for
# parse_lat() and parse_lon(), compile_pair_format() for parse_llstr().
check_format <- function(format, compile = compile_format) {
  if (length(format) == 0L || anyNA(format)) {
    stop("format must be one or more strings, without NA", call. = FALSE)
  }
  if (any(Encoding(format) == "bytes")) {
    stop(
      "format is marked as \"bytes\", convert it to UTF-8 first, ",
      "for example with iconv()",
      call. = FALSE
    )
  }
  lapply(X = format, FUN = compile)
}

# runs of the same letter ("DD", "mmm", "H") and single other characters
format_tokens <- function(format) {
  regmatches(
    x = format,
    m = gregexpr(pattern = "([A-Za-z])\\1*|.", text = format, perl = TRUE)
  )[[1]]
}

# Returns a list: `regex` (not anchored, so it can be combined with another
# one), `groups` (the field of each capture group, in order: "sign", "D",
# "M", "S", "dec" or "H") and `dec_unit` (the unit that the decimal digits
# belong to, or ""). `label` names the format in error messages.
compile_format <- function(format, label = paste0("\"", format, "\"")) {
  fail <- function(why) {
    stop("invalid format ", label, ": ", why, call. = FALSE)
  }
  tokens <- format_tokens(format)
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
  check_encoding(x)
  out <- read_formats(
    x = trimws(num_to_chr(x)),
    formats = check_format(format = format),
    convert = function(fields, f) {
      fields_to_degrees(
        fields = fields,
        dec_unit = f[["dec_unit"]],
        what = what
      )
    },
    ncol = 1L
  )
  out[, 1L]
}

# Read each value of `x` with the first of the compiled `formats` that
# matches it. `convert(fields, f)` turns the fields that format `f` matched
# (a character matrix, one row per value) into a list: `value`, one row of
# `ncol` numbers per value, and `why`, the reason for each NA. Gives one
# warning for all the values that gave NA.
read_formats <- function(x, formats, convert, ncol) {
  out <- matrix(data = NA_real_, nrow = length(x), ncol = ncol)
  why <- rep(NA_character_, times = length(x))
  # like format = NULL, NA and "" give NA without a warning
  todo <- which(!is.na(x) & nzchar(x))
  for (f in formats) {
    if (length(todo) == 0L) {
      break
    }
    # regexpr() and its capture attributes: 20 times faster than
    # regmatches(regexec())
    m <- regexpr(
      pattern = paste0("^", f[["regex"]], "$"),
      text = x[todo],
      perl = TRUE
    )
    matched <- c(m) != -1L
    if (!any(matched)) {
      next
    }
    start <- attr(m, "capture.start")[matched, , drop = FALSE]
    len <- attr(m, "capture.length")[matched, , drop = FALSE]
    # positions are in characters: no string or format is marked "bytes"
    # (see check_encoding() and check_format())
    text <- x[todo][matched]
    fields <- matrix(
      data = substring(
        text = rep(text, times = ncol(start)),
        first = start,
        last = start + len - 1L
      ),
      nrow = length(text),
      dimnames = list(NULL, f[["groups"]])
    )
    res <- convert(fields, f)
    out[todo[matched], ] <- res[["value"]]
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
      # paste(sep =) keeps zero rows as zero rows; paste0(x, ".") would not
      digits <- paste(digits, fields[, "dec"], sep = ".")
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

# A format for a whole string with two coordinates, as in parse_llstr(), for
# example "DDMMSSH DDDMMSSH". It is cut in two at the start of the second D
# block, each part is compiled with compile_format(), and the two regular
# expressions are joined. Returns the list of compile_format(), with
# `halves`, the compiled parts, in place of `dec_unit`.
compile_pair_format <- function(format) {
  label <- paste0("\"", format, "\"")
  tokens <- format_tokens(format)
  d_blocks <- which(startsWith(x = tokens, prefix = "D"))
  if (length(d_blocks) != 2L) {
    stop(
      "invalid format ",
      label,
      ": a format for parse_llstr() needs exactly two D blocks, ",
      "one for each coordinate",
      call. = FALSE
    )
  }
  cut <- d_blocks[[2]]
  # an H between the coordinates goes with the second one when the first one
  # already has its own H, as in "HD.dHDDD.d"
  h <- which(startsWith(x = tokens[seq_len(cut - 1L)], prefix = "H"))
  if (length(h) > 1L) {
    cut <- h[[length(h)]]
  }
  parts <- c(
    paste(tokens[seq_len(cut - 1L)], collapse = ""),
    paste(tokens[seq(from = cut, to = length(tokens))], collapse = "")
  )
  halves <- lapply(X = parts, FUN = function(part) {
    compile_format(
      format = part,
      label = paste0(label, ", part \"", part, "\"")
    )
  })
  list(
    regex = paste0(halves[[1]][["regex"]], halves[[2]][["regex"]]),
    groups = c(halves[[1]][["groups"]], halves[[2]][["groups"]]),
    halves = halves
  )
}

# parse_llstr() with `format`: the whole string is matched at once, without
# scrub() or the C++ splitter.
parse_llstr_with_format <- function(str, format, order) {
  check_encoding(str)
  out <- read_formats(
    x = trimws(str),
    formats = check_format(format = format, compile = compile_pair_format),
    convert = function(fields, f) {
      pair_to_degrees(fields = fields, pair = f, order = order)
    },
    ncol = 2L
  )
  data.frame(lat = out[, 1L], lon = out[, 2L])
}

# Latitude and longitude from the fields that one pair format matched (see
# compile_pair_format()). The H letters and `order` say which part is the
# latitude (see pick_order()); then each part goes through
# fields_to_degrees() on its own, except for a latitude that looks like a
# longitude (see swap_why()). `value` has two columns: lat and lon.
pair_to_degrees <- function(fields, pair, order) {
  n_first <- length(pair[["halves"]][[1]][["groups"]])
  parts <- list(
    fields[, seq_len(n_first), drop = FALSE],
    fields[, -seq_len(n_first), drop = FALSE]
  )
  has <- function(part, letters) {
    if (!is.element(el = "H", set = colnames(part))) {
      return(rep(FALSE, times = nrow(part)))
    }
    is.element(el = toupper(part[, "H"]), set = letters)
  }
  picked <- pick_order(
    ns1 = has(part = parts[[1]], letters = c("N", "S")),
    ew1 = has(part = parts[[1]], letters = c("E", "W")),
    ns2 = has(part = parts[[2]], letters = c("N", "S")),
    ew2 = has(part = parts[[2]], letters = c("E", "W")),
    order = order
  )
  ok <- is.na(picked[["why"]])
  lat <- rep(NA_real_, times = nrow(fields))
  lon <- rep(NA_real_, times = nrow(fields))
  why_lat <- rep(NA_character_, times = nrow(fields))
  why_lon <- rep(NA_character_, times = nrow(fields))
  swapped <- rep(FALSE, times = nrow(fields))
  for (k in 1:2) {
    dec_unit <- pair[["halves"]][[k]][["dec_unit"]]
    is_lat <- ok & picked[["lat_first"]] == (k == 1L)
    is_lon <- ok & picked[["lat_first"]] != (k == 1L)
    res <- fields_to_degrees(
      fields = parts[[k]][is_lat, , drop = FALSE],
      dec_unit = dec_unit,
      what = "lat"
    )
    lat[is_lat] <- res[["value"]]
    why_lat[is_lat] <- res[["why"]]
    res <- fields_to_degrees(
      fields = parts[[k]][is_lon, , drop = FALSE],
      dec_unit = dec_unit,
      what = "lon"
    )
    lon[is_lon] <- res[["value"]]
    why_lon[is_lon] <- res[["why"]]
    # a latitude out of range that is a valid longitude: see swap_why()
    maybe <- is_lat &
      picked[["can_swap"]] &
      is.element(el = why_lat, set = "not within -90/90 range")
    res <- fields_to_degrees(
      fields = parts[[k]][maybe, , drop = FALSE],
      dec_unit = dec_unit,
      what = "lon"
    )
    swapped[maybe] <- is.na(res[["why"]])
  }
  # each part is read on its own: a bad part does not change the other one
  why <- picked[["why"]]
  lon_bad <- !is.na(why_lon)
  why[lon_bad] <- paste0("longitude: ", why_lon[lon_bad])
  lat_bad <- !is.na(why_lat)
  why[lat_bad] <- paste0(
    "latitude: ",
    why_lat[lat_bad],
    ifelse(test = lon_bad[lat_bad], yes = paste0("; ", why[lat_bad]), no = "")
  )
  lon[swapped] <- NA_real_
  why[swapped] <- swap_why(lat_first = picked[["lat_first"]][swapped])
  list(value = cbind(lat, lon), why = why)
}
