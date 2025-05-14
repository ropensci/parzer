#include <Rcpp.h>
// [[Rcpp::plugins(cpp11)]]

#include <string>
#include <regex>
#include <iterator>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <functional>
#include <algorithm>

// check if latitude within acceptable range, etc.
bool check_lat(const double& lat) {
  bool lat_check = false;
  if (lat >= -90  && lat <= 90) {
    lat_check = true;
  }
  return lat_check;
}

// check if longitude within acceptable range, etc.
bool check_lon(const double& lon) {
  bool lon_check = false;
  if (lon >= -180  && lon <= 360) {
    lon_check = true;
  }
  return lon_check;
}

void strip_alpha(std::string& x) {
  std::replace_if(x.begin(), x.end(), ::isalpha, ' ');
}

void digits_only(std::string& x) {
  std::replace_if(x.begin(), x.end(),
                  [](char z){ return ::ispunct(z) && z != '.' && z != '-'; }, ' ');
}

void remove_internal_dashes(std::string& x) {
  std::regex dash_reg("([0-9]+)(-)");
  x = std::regex_replace(x, dash_reg, "$1 ");
}

std::vector<double> extract_floats_from_string(std::string& str) {
  // str = remove_internal_dashes(digits_only(strip_alpha(str)));
  strip_alpha(str);
  digits_only(str);
  remove_internal_dashes(str);
  // Rprintf("within extract_floats_from_string: %s \n", str.c_str());
  std::stringstream ss(str);
  std::string temp;
  double found;
  std::vector<double> y;
  while (!ss.eof()) {
    /* extracting chunk by chunk from stream */
    ss >> temp;
    /* Checking the given word is integer or not */
    if (std::stringstream(temp) >> found)
      y.push_back(found);
    /* To save from space at the end of string */
    temp = "";
  }
  return y;
}

int count_direction_matches(const std::string& s, const std::string& re) {
  std::regex words_regex(re);
  auto words_begin = std::sregex_iterator(
    s.begin(), s.end(), words_regex);
  auto words_end = std::sregex_iterator();

  return std::distance(words_begin, words_end);
}

std::string extract_nsew(const std::string& s, const std::string& reggex) {
  std::regex reg(reggex);
  std::smatch match;
  std::string out = "";
  if (std::regex_search(s, match, reg))
    out = match[0];
  // Rprintf("extract_ns length: %f \n", match.size());
  // Rprintf("extract_nsew result: %s \n", out.c_str());
  return out;
}

void str_tolower(std::string &s) {
  std::transform(s.begin(), s.end(), s.begin(),
                 [](unsigned char c){ return std::tolower(c); }
  );
}

double plus_minus(const std::string& x) {
  double out = 1.0;
  // x = str_tolower(x); // deactivated because it is done before in convert_lat or convert_lon
  // Rprintf("within plus_minus = %s \n", x.c_str());
  if (x == "n" || x == "e") {
    out = 1.0;
  }
  if (x == "s" || x == "w") {
    out = -1.0;
  }
  return out;
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
  // s = str_tolower(s);
  // allow "n", "s", "e", "w" for cardinal directions
  // allow "d" for degree delimiter, check below to make sure d used correctly
  bool z = std::string::npos != s.find_first_of(reggex);
  if (z) {
    Rcpp::warning("invalid direction letter, got: " + s);
  }
  return z;
}

bool has_e_with_trailing_numbers(const std::string& s) {
  bool res = false;
  // s = str_tolower(s);
  std::regex reg("[0-9]+e[0-9]+");
  std::smatch match;
  if (std::regex_search(s, match, reg)) {
    res = true;
    Rcpp::warning("invalid characters, got: " + s);
  }
  return res;
}

bool invalid_degree_letter(const std::string& s, const std::string& reggex) {
  bool res = false;

  // matches: 40.
  std::regex reg("^-?[0-9]{1,3}[\\s+]?[A-Za-z]");
  std::smatch match;
  std::string out = "";
  if (std::regex_search(s, match, reg)) {
    out = match[0];
    // Rprintf("invalid_degree_letter result:  %s \n", out.c_str());
    // std::regex reg2("[nsewdNSEWD]");
    std::regex reg2(reggex);
    std::smatch match2;
    std::string out2 = "";
    if (!std::regex_search(out, match2, reg2)) {
      res = true;
    }
  }
  return res;
}

bool is_negative(const std::string& s) {
  bool res = false;
  std::regex reg("^-.+");
  std::smatch match;
  if (std::regex_search(s, match, reg)) {
    res = true;
  }
  return res;
}

// [[Rcpp::export]]
double convert_lat(std::string& str) {
  double ret;
  str_tolower(str);
  if (
      str.size() == 0 ||
        !any_digits(str) ||
        has_non_direction_letters(str, "abcefghijklmopqrtuvwxyz")

  ) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, "[ns]") > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else if (invalid_degree_letter(str, "[nsd]")) {
    // to support e.g.: 40d 25’ 6\" N
    ret = NA_REAL;
    Rcpp::warning("expected single 'N|S|d' after degrees, got: " + str);
  } else {
    std::string dir = extract_nsew(str, "[ns]");
    double dir_val = 1.0;
    if (dir != "") {
      dir_val = plus_minus(dir);
    }
    if (is_negative(str)) {
      dir_val = -1.0;
    }

    std::vector<double> nums = extract_floats_from_string(str);
    if (nums.size() == 0) {
      ret = NA_REAL;
    }
    if (nums.size() == 1) {
      ret = fabs(nums[0]);
    }
    if (nums.size() == 2) {
      ret = fabs(nums[0]) + decimal_minute(nums[1]);
    }
    if (nums.size() == 3) {
      ret = fabs(nums[0]) + decimal_minute(nums[1]) + decimal_second(nums[2]);
    }
    if (nums.size() > 3) {
      Rcpp::warning("invalid format, more than 3 numeric slots, got: " + str);
      ret = NA_REAL;
    }

    // apply direction
    ret = ret * dir_val;

    if (!Rcpp::NumericVector::is_na(ret)) {
      if (!check_lat(ret)) {
        ret = NA_REAL;
        Rcpp::warning("not within -90/90 range, got: " + str +
          "\n  check that you did not invert lon and lat");
      }
    }
  }
  return ret;
}


// [[Rcpp::export]]
double convert_lon(std::string& str) {
  double ret;
  str_tolower(str);
  if (
      str.size() == 0 ||
        !any_digits(str) ||
        has_non_direction_letters(str, "abcfghijklmnopqrstuvxyz") ||
        has_e_with_trailing_numbers(str)
  ) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, "[ew]") > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else if (invalid_degree_letter(str, "[ewd]")) {
    // to support e.g.: 40d 25’ 6\" E
    ret = NA_REAL;
    Rcpp::warning("expected single 'E|W|d' after degrees, got: " + str);
  } else {
    std::string dir = extract_nsew(str, "[ew]");
    double dir_val = 1.0;
    if (dir != "") {
      dir_val = plus_minus(dir);
    }
    if (is_negative(str)) {
      dir_val = -1.0;
    }

    std::vector<double> nums = extract_floats_from_string(str);
    if (nums.size() == 0) {
      ret = NA_REAL;
    }
    if (nums.size() == 1) {
      ret = fabs(nums[0]);
    }
    if (nums.size() == 2) {
      ret = fabs(nums[0]) + decimal_minute(nums[1]);
    }
    if (nums.size() == 3) {
      ret = fabs(nums[0]) + decimal_minute(nums[1]) + decimal_second(nums[2]);
    }
    if (nums.size() > 3) {
      Rcpp::warning("invalid format, more than 3 numeric slots, got: " + str);
      ret = NA_REAL;
    }

    // apply direction
    ret = ret * dir_val;

    if (!Rcpp::NumericVector::is_na(ret)) {
      if (!check_lon(ret)) {
        ret = NA_REAL;
        Rcpp::warning("not within -180/360 range, got: " + str);
      }
    }
  }
  return ret;
}

