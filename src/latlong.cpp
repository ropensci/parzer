#include <Rcpp.h>

#include <string>
#include <iterator>
#include <sstream>
#include <cstdlib>
#include <cmath>
#include <algorithm>
#include <cctype>

bool check_lat(const double& lat) {
  return lat >= -90 && lat <= 90;
}

bool check_lon(const double& lon) {
  return lon >= -180 && lon <= 360;
}

// casts: the <cctype> functions take an unsigned char, a plain char may be negative
void strip_alpha(std::string& x) {
  std::replace_if(x.begin(), x.end(),
                  [](char z){ return std::isalpha(static_cast<unsigned char>(z)); }, ' ');
}

void digits_only(std::string& x) {
  std::replace_if(x.begin(), x.end(),
                  [](char z){ return std::ispunct(static_cast<unsigned char>(z)) && z != '.' && z != '-'; }, ' ');
}

// A '-' right after a digit is a separator, not a sign: "40-25" -> "40 25".
// Plain loop: the equivalent std::regex took about half of convert_lat's time.
void remove_internal_dashes(std::string& x) {
  for (std::size_t i = 1; i < x.size(); ++i) {
    if (x[i] == '-' && std::isdigit(static_cast<unsigned char>(x[i - 1]))) {
      x[i] = ' ';
    }
  }
}

std::vector<double> extract_floats_from_string(std::string& str) {
  strip_alpha(str);
  digits_only(str);
  remove_internal_dashes(str);
  std::istringstream ss(str);
  std::string temp;
  std::vector<double> y;
  while (ss >> temp) {
    try {
      std::size_t used = 0;
      double value = std::stod(temp, &used);
      // stod stops at the second '.' of "40.25.30" and would keep 40.25
      if (used != temp.size()) {
        Rcpp::warning("invalid number, got: " + temp);
        return std::vector<double>();
      }
      y.push_back(value);
    } catch (...) {
      // lone "-" or "." are separators, anything with a digit is a bad number
      if (temp.find_first_of("0123456789") != std::string::npos) {
        Rcpp::warning("invalid number, got: " + temp);
        return std::vector<double>();
      }
    }
  }
  return y;
}

bool is_digit(char c) {
  return c >= '0' && c <= '9';
}

// A run of 4 or more digits that is not right after a decimal point, as in
// "2343 56n", is probably degrees and minutes written together. Only called
// when a warning is given, so valid input does not pay for it.
std::string packed_hint(const std::string& s) {
  std::size_t i = 0;
  while (i < s.size()) {
    if (!is_digit(s[i])) {
      ++i;
      continue;
    }
    const bool after_dot = i > 0 && s[i - 1] == '.';
    const std::size_t start = i;
    while (i < s.size() && is_digit(s[i])) ++i;
    if (!after_dot && i - start >= 4) {
      return "\n  degrees, minutes and seconds may be packed together (e.g. DDMMSS):"
             " try the format argument of parse_lat() or parse_lon()";
    }
  }
  return "";
}

// how many characters of s are one of `chars`, e.g. "ns"
int count_direction_matches(const std::string& s, const std::string& chars) {
  return std::count_if(s.begin(), s.end(),
                       [&chars](char c) { return chars.find(c) != std::string::npos; });
}

// first character of s that is one of `chars`, or ""
std::string extract_nsew(const std::string& s, const std::string& chars) {
  std::size_t i = s.find_first_of(chars);
  return i == std::string::npos ? "" : s.substr(i, 1);
}

void str_tolower(std::string &s) {
  std::transform(s.begin(), s.end(), s.begin(),
                 [](unsigned char c){ return std::tolower(c); }
  );
}

// x is already lower case (convert_lat/lon lower it); "" and n/e are positive
double plus_minus(const std::string& x) {
  return (x == "s" || x == "w") ? -1.0 : 1.0;
}

// -1 or 1 from the hemisphere letter ("" when absent) and the minus sign;
// NA with a warning when the two disagree, e.g. "N -45" or "-45N"
double direction(const std::string& letter, bool minus, const std::string& orig) {
  if (letter.empty()) return minus ? -1.0 : 1.0;
  const double from_letter = plus_minus(letter);
  if (minus && from_letter > 0) {
    Rcpp::warning("minus sign and direction letter disagree, got: " + orig);
    return NA_REAL;
  }
  return from_letter;
}

double decimal_minute(const double& x) {
  return (x / 60.0);
}

double decimal_second(const double& x) {
  return (x / 3600.0);
}

bool any_digits(const std::string& s) {
  bool z = std::string::npos != s.find_first_of("0123456789");
  if (!z) {
    Rcpp::warning("no digits detected, got: " + s);
  }
  return z;
}

bool has_non_direction_letters(std::string& s, const std::string& reggex) {
  // only "n", "s", "e", "w" are allowed; scrub() in R already replaced "d"
  bool z = std::string::npos != s.find_first_of(reggex);
  if (z) {
    Rcpp::warning("invalid direction letter, got: " + s);
  }
  return z;
}

// useful to NA on "-45.23232e24"
// same as the regex "[0-9]+e[0-9]+$": digits, "e", digits at the end
bool has_e_with_trailing_numbers(const std::string& s) {
  std::size_t i = s.find_last_not_of("0123456789");
  if (i != std::string::npos && i > 0 && i + 1 < s.size() &&
      s[i] == 'e' && is_digit(s[i - 1])) {
    Rcpp::warning("invalid characters, got: " + s);
    return true;
  }
  return false;
}

// Combine degree/minute/second slots into signed decimal degrees, NA on
// invalid input. `orig` is the input before extract_floats_from_string
// altered it, so warnings show what the user typed.
double nums_to_decimal(const std::vector<double>& nums, const std::string& orig, double dir_val) {
  std::size_t n = nums.size();
  if (n == 0) return NA_REAL;
  if (n > 3) {
    Rcpp::warning("invalid format, more than 3 numeric slots, got: " + orig);
    return NA_REAL;
  }
  for (std::size_t i = 1; i < n; ++i) {
    // negative or >= 60 minutes/seconds
    if (!(nums[i] >= 0 && nums[i] < 60)) {
      Rcpp::warning("minutes or seconds not within 0/60 range, got: " + orig +
        packed_hint(orig));
      return NA_REAL;
    }
  }
  for (std::size_t i = 0; i + 1 < n; ++i) {
    // a fraction is only allowed in the last slot, e.g. not "45.5 30"
    if (nums[i] != std::floor(nums[i])) {
      Rcpp::warning("only the last of degrees, minutes, seconds can be decimal, got: " + orig);
      return NA_REAL;
    }
  }
  double ret = fabs(nums[0]);
  if (n >= 2) ret += decimal_minute(nums[1]);
  if (n == 3) ret += decimal_second(nums[2]);
  return ret * dir_val;
}

// same as the regex "^-.+"; "." does not match a line break
bool is_negative(const std::string& s) {
  return s.size() >= 2 && s[0] == '-' && s[1] != '\n' && s[1] != '\r';
}

double convert_lat(std::string& str) {
  double ret = NA_REAL;
  str_tolower(str);
  const std::string orig = str;
  if (
      str.size() == 0 ||
        !any_digits(str) ||
        has_non_direction_letters(str, "abcdefghijklmopqrtuvwxyz")

  ) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, "ns") > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else {
    const std::string letter = extract_nsew(str, "ns");
    const bool leading_minus = is_negative(str);
    std::vector<double> nums = extract_floats_from_string(str);
    // "N -45": the minus sign sits after the letter, so it is in the first slot
    const bool minus = leading_minus || (!nums.empty() && std::signbit(nums[0]));
    const double dir_val = direction(letter, minus, orig);
    ret = Rcpp::NumericVector::is_na(dir_val) ? NA_REAL : nums_to_decimal(nums, orig, dir_val);

    if (!Rcpp::NumericVector::is_na(ret)) {
      if (!check_lat(ret)) {
        ret = NA_REAL;
        // packed digits, not inverted coordinates, are the likely cause then
        const std::string hint = packed_hint(orig);
        Rcpp::warning("not within -90/90 range, got: " + orig +
          (hint.empty() ? "\n  check that you did not invert lon and lat" : hint));
      }
    }
  }
  return ret;
}


double convert_lon(std::string& str) {
  double ret = NA_REAL;
  str_tolower(str);
  const std::string orig = str;
  if (
      str.size() == 0 ||
        !any_digits(str) ||
        has_non_direction_letters(str, "abcdfghijklmnopqrstuvxyz")  ||
        has_e_with_trailing_numbers(str)
  ) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, "ew") > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else {
    const std::string letter = extract_nsew(str, "ew");
    const bool leading_minus = is_negative(str);
    std::vector<double> nums = extract_floats_from_string(str);
    // "N -45": the minus sign sits after the letter, so it is in the first slot
    const bool minus = leading_minus || (!nums.empty() && std::signbit(nums[0]));
    const double dir_val = direction(letter, minus, orig);
    ret = Rcpp::NumericVector::is_na(dir_val) ? NA_REAL : nums_to_decimal(nums, orig, dir_val);

    if (!Rcpp::NumericVector::is_na(ret)) {
      if (!check_lon(ret)) {
        ret = NA_REAL;
        Rcpp::warning("not within -180/360 range, got: " + orig + packed_hint(orig));
      }
    }
  }
  return ret;
}
