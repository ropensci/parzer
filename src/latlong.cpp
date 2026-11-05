#include <Rcpp.h>
// [[Rcpp::plugins(cpp11)]]

#include <string>
#include <regex>
#include <iterator>
#include <sstream>
#include <cstdlib>
#include <cmath>
#include <algorithm>

bool check_lat(const double& lat) {
  return lat >= -90 && lat <= 90;
}

bool check_lon(const double& lon) {
  return lon >= -180 && lon <= 360;
}

void strip_alpha(std::string& x) {
  std::replace_if(x.begin(), x.end(), ::isalpha, ' ');
}

void digits_only(std::string& x) {
  std::replace_if(x.begin(), x.end(),
                  [](char z){ return ::ispunct(z) && z != '.' && z != '-'; }, ' ');
}

void remove_internal_dashes(std::string& x) {
  static const std::regex dash_reg("([0-9]+)(-)");
  x = std::regex_replace(x, dash_reg, "$1 ");
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
      y.push_back(std::stod(temp));
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

int count_direction_matches(const std::string& s, const std::regex& re) {
  auto words_begin = std::sregex_iterator(
    s.begin(), s.end(), re);
  auto words_end = std::sregex_iterator();

  return std::distance(words_begin, words_end);
}

std::string extract_nsew(const std::string& s, const std::regex& reg) {
  std::smatch match;
  std::string out = "";
  if (std::regex_search(s, match, reg))
    out = match[0];
  return out;
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
  // allow "n", "s", "e", "w" for cardinal directions
  // allow "d" for degree delimiter, check below to make sure d used correctly
  bool z = std::string::npos != s.find_first_of(reggex);
  if (z) {
    Rcpp::warning("invalid direction letter, got: " + s);
  }
  return z;
}

// useful to NA on "-45.23232e24"
bool has_e_with_trailing_numbers(const std::string& s) {
  static const std::regex reg("[0-9]+e[0-9]+$");
  std::smatch match;
  if (std::regex_search(s, match, reg)) {
    Rcpp::warning("invalid characters, got: " + s);
    return true;
  }
  return false;
}

bool invalid_degree_letter(const std::string& s, const std::regex& reg2) {
  // matches: 40.
  static const std::regex reg("^-?[0-9]{1,3}[\\s+]?[A-Za-z]");
  std::smatch match;
  std::string out = "";
  if (std::regex_search(s, match, reg)) {
    out = match[0];
    std::smatch match2;
    if (!std::regex_search(out, match2, reg2)) {
      return true;
    }
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
      Rcpp::warning("minutes or seconds not within 0/60 range, got: " + orig);
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

bool is_negative(const std::string& s) {
  static const std::regex reg("^-.+");
  std::smatch match;
  return std::regex_search(s, match, reg);
}

// [[Rcpp::export]]
double convert_lat(std::string& str) {
  static const std::regex ns_reg("[ns]");
  static const std::regex nsd_reg("[nsd]");
  double ret = NA_REAL;
  str_tolower(str);
  const std::string orig = str;
  if (
      str.size() == 0 ||
        !any_digits(str) ||
        has_non_direction_letters(str, "abcefghijklmopqrtuvwxyz")

  ) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, ns_reg) > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else if (invalid_degree_letter(str, nsd_reg)) {
    // to support e.g.: 40d 25' 6\" N
    ret = NA_REAL;
    Rcpp::warning("expected single 'N|S|d' after degrees, got: " + str);
  } else {
    double dir_val = plus_minus(extract_nsew(str, ns_reg));
    if (is_negative(str)) {
      dir_val = -1.0;
    }

    std::vector<double> nums = extract_floats_from_string(str);
    ret = nums_to_decimal(nums, orig, dir_val);

    if (!Rcpp::NumericVector::is_na(ret)) {
      if (!check_lat(ret)) {
        ret = NA_REAL;
        Rcpp::warning("not within -90/90 range, got: " + orig +
          "\n  check that you did not invert lon and lat");
      }
    }
  }
  return ret;
}


// [[Rcpp::export]]
double convert_lon(std::string& str) {
  static const std::regex ew_reg("[ew]");
  static const std::regex ewd_reg("[ewd]");
  double ret = NA_REAL;
  str_tolower(str);
  const std::string orig = str;
  if (
      str.size() == 0 ||
        !any_digits(str) ||
        has_non_direction_letters(str, "abcfghijklmnopqrstuvxyz")  ||
        has_e_with_trailing_numbers(str)
  ) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, ew_reg) > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else if (invalid_degree_letter(str, ewd_reg)) {
    // to support e.g.: 40d 25' 6\" E
    ret = NA_REAL;
    Rcpp::warning("expected single 'E|W|d' after degrees, got: " + str);
  } else {
    double dir_val = plus_minus(extract_nsew(str, ew_reg));
    if (is_negative(str)) {
      dir_val = -1.0;
    }

    std::vector<double> nums = extract_floats_from_string(str);
    ret = nums_to_decimal(nums, orig, dir_val);

    if (!Rcpp::NumericVector::is_na(ret)) {
      if (!check_lon(ret)) {
        ret = NA_REAL;
        Rcpp::warning("not within -180/360 range, got: " + orig);
      }
    }
  }
  return ret;
}
