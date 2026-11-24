#include <Rcpp.h>

// scrub() in R/zzz.R: cleans every input string before the parser reads it,
// one code point at a time and without regular expressions. The strings come
// from enc2utf8(), after check_encoding() has stopped on strings marked
// "bytes", so they are UTF-8 (or ASCII). The output is always ASCII.

// Reads the UTF-8 code point that starts at p into cp and returns its length
// in bytes, or 0 if it is not valid UTF-8. The rules are those of R's
// validUTF8(): no overlong forms, no surrogates, nothing above U+10FFFF.
static int read_utf8(const unsigned char* p, unsigned int& cp) {
  int len;
  if (p[0] < 0x80) {
    cp = p[0];
    return 1;
  } else if ((p[0] & 0xE0) == 0xC0) {
    len = 2;
    cp = p[0] & 0x1F;
  } else if ((p[0] & 0xF0) == 0xE0) {
    len = 3;
    cp = p[0] & 0x0F;
  } else if ((p[0] & 0xF8) == 0xF0) {
    len = 4;
    cp = p[0] & 0x07;
  } else {
    return 0;
  }
  for (int k = 1; k < len; ++k) {
    // the NUL at the end of the string fails this test too
    if ((p[k] & 0xC0) != 0x80) return 0;
    cp = (cp << 6) | (p[k] & 0x3F);
  }
  const unsigned int smallest[] = {0, 0, 0x80, 0x800, 0x10000};
  if (cp < smallest[len] || (cp >= 0xD800 && cp <= 0xDFFF) || cp > 0x10FFFF) {
    return 0;
  }
  return len;
}

// [A-Za-z0-9. ,'-] without d, g, D and G
static bool is_kept(unsigned int cp) {
  if (cp == 'd' || cp == 'g' || cp == 'D' || cp == 'G') return false;
  return (cp >= 'A' && cp <= 'Z') || (cp >= 'a' && cp <= 'z') ||
         (cp >= '0' && cp <= '9') || cp == '.' || cp == ' ' || cp == ',' ||
         cp == '\'' || cp == '-';
}

// [[Rcpp::export]]
Rcpp::CharacterVector pz_scrub(Rcpp::CharacterVector x) {
  const R_xlen_t n = x.size();
  Rcpp::CharacterVector out(n);  // every element starts as ""
  std::string buf;               // one buffer, reused for every string
  for (R_xlen_t i = 0; i < n; ++i) {
    SEXP s = STRING_ELT(x, i);
    // R: x[is.na(x)] <- ""
    // NA in, NA out: "" is the one input the C++ parser turns into NA silently
    if (s == NA_STRING) continue;
    buf.clear();
    const unsigned char* p = reinterpret_cast<const unsigned char*>(CHAR(s));
    while (*p) {
      unsigned int cp;
      const int len = read_utf8(p, cp);
      if (len == 0) Rcpp::stop("input string %d is invalid UTF-8", i + 1);
      p += len;
      if (cp == 0x2212 || cp == 0x2013 || cp == 0x2014) {
        // R: gsub("[\u2212\u2013\u2014]", "-", x)
        // Unicode minus sign, en dash and em dash are a minus sign
        buf += '-';
      } else if (is_kept(cp)) {
        buf += static_cast<char>(cp);
      } else {
        // R: gsub("[^A-Za-z0-9. ,'-]|[dgDG]", "'", x), one "'" per code point
        // d and g are degree marks ("40d 25' 6\"") and are replaced in
        // either case
        buf += '\'';
      }
    }
    // R: trimws(x). Tabs and line breaks are "'" by now: only spaces are left
    const size_t first = buf.find_first_not_of(' ');
    if (first == std::string::npos) continue;
    const size_t last = buf.find_last_not_of(' ');
    SET_STRING_ELT(out, i, Rf_mkCharLen(buf.data() + first, last - first + 1));
  }
  return out;
}
