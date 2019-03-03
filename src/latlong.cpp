#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::plugins(cpp11)]]
// #include "latlong.h"

#include <regex>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include <string>
#include <cstdio>
#include <cmath>
#include <functional>
#include <algorithm>

// check if latitude within acceptable range, etc.
bool check_lat(float lat) {
  bool lat_check = false;
  if (lat >= -90  && lat <= 90) {
    lat_check = true;
  };
  return lat_check;
};

// check if longitude within acceptable range, etc.
bool check_lon(float lon) {
  bool lon_check = false;
  if (lon >= -180  && lon <= 360) {
    lon_check = true;
  };
  return lon_check;
};

std::string strip_alpha(std::string x) {
  std::replace_if(x.begin(), x.end(), ::isalpha, ' ');
  return x;
};

std::string digits_only(std::string x) {
  std::replace_if(x.begin(), x.end(),
                  [](char z){ return ::ispunct(z) && z != '.'; }, ' ');
  return x;
};

NumericVector extract_floats_from_string(std::string str) {
  // str = strip_alpha(str);
  str = digits_only(strip_alpha(str));
  // Rprintf("within extract_floats_from_string: %s \n", str.c_str());
  std::stringstream ss(str);
  std::string temp;
  double found;
  NumericVector y;
  while (!ss.eof()) {
    /* extracting chunck by chunk from stream */
    ss >> temp;
    /* Checking the given word is integer or not */
    if (std::stringstream(temp) >> found)
      y.push_back(found);
    /* To save from space at the end of string */
    temp = "";
  };
  return y;
};

int count_direction_matches(std::string s, std::string re) {
  std::regex words_regex(re);
  auto words_begin = std::sregex_iterator(
    s.begin(), s.end(), words_regex);
  auto words_end = std::sregex_iterator();

  return std::distance(words_begin, words_end);
};

std::string extract_ns(std::string s) {
  std::regex reg("[NSns]");
  std::smatch match;
  std::string out = "";
  if (std::regex_search(s, match, reg))
    out = match[0];
  // Rprintf("extract_ns length: %f \n", match.size());
  // Rprintf("extract_ns result: %s \n", out.c_str());
  return out;
};

std::string str_tolower(std::string s) {
  std::transform(s.begin(), s.end(), s.begin(),
                 [](unsigned char c){ return std::tolower(c); }
  );
  return s;
};

double plus_minus(std::string x) {
  double out = 1.0;
  x = str_tolower(x);
  // Rprintf("within plus_minus = %s \n", x.c_str());
  if (x == "n") {
    out = 1.0;
  };
  if (x == "s") {
    out = -1.0;
  };
  return out;
};

double decimal_minute(double x) {
  return (x / 60.0);
};

double decimal_second(double x) {
  return (x / 3600.0);
};

float convert_lat(std::string str) {
  float ret;
  if (str.size() == 0) {
    ret = NA_REAL;
  } else {
    try {
      ret = std::stod(str);
    } catch (std::invalid_argument) {
      ret = NA_REAL;
      Rcpp::warning("invalid argument, got: " + str);
    } catch (std::out_of_range) {
      ret = NA_REAL;
      Rcpp::warning("out of range, got: " + str);
    };
    if (!check_lat(ret)) {
      ret = NA_REAL;
      Rcpp::warning("not within -90/90 range, got: " + str);
    };
  };
  return ret;
};

bool any_digits(std::string s) {
  bool z = std::string::npos != s.find_first_of("0123456789");
  if (!z) {
    Rcpp::warning("no digits detected, got: " + s);
  };
  return z;
};

bool has_non_direction_letters(std::string s) {
  s = str_tolower(s);
  // allow "n", "s", "e", "w" for cardinal directions
  // allow "d" for degree delimiter, check below to make sure d used correctly
  bool z = std::string::npos != s.find_first_of("abcfghijklmopqrtuvwxyz");
  if (z) {
    Rcpp::warning("invalid characters, got: " + s);
  };
  return z;
};

bool invalid_degree_letter(std::string s) {
  bool res = false;

  std::regex reg("^-?[0-9]{1,3}[\\s+]?[A-Za-z]");
  std::smatch match;
  std::string out = "";
  if (std::regex_search(s, match, reg)) {
    out = match[0];
    // Rprintf("invalid_degree_letter result:  %s \n", out.c_str());
    std::regex reg2("[nsewdNSEWD]");
    std::smatch match2;
    std::string out2 = "";
    if (!std::regex_search(out, match2, reg2)) {
      res = true;
    };
  };
  return res;
};

// [[Rcpp::export]]
float convert_lat2(std::string str) {
  float ret;
  if (str.size() == 0 || !any_digits(str) || has_non_direction_letters(str)) {
    ret = NA_REAL;
  } else if (count_direction_matches(str, "[NSns]") > 1) {
    ret = NA_REAL;
    Rcpp::warning("invalid cardinal direction, got: " + str);
  } else if (invalid_degree_letter(str)) {
    ret = NA_REAL;
    Rcpp::warning("expected single 'N|S|E|W|d' after degrees, got: " + str);
  } else {
    std::string dir = extract_ns(str);
    double dir_val = 1.0;
    if (dir != "") {
      dir_val = plus_minus(dir);
    };

    NumericVector nums = extract_floats_from_string(str);
    // Rprintf("nums: %f \n", nums.size());
    // Rprintf("nums[0]: %d \n", nums[0]);
    // bool nums_size_0 = nums.size() == 0;
    // Rprintf("nums_size_0 result: %d \n", nums_size_0 );
    if (nums.size() == 0) {
      ret = NA_REAL;
    };
    if (nums.size() == 1) {
      ret = nums[0];
    };
    if (nums.size() == 2) {
      ret = nums[0] + decimal_minute(nums[1]);
    };
    if (nums.size() == 3) {
      ret = nums[0] + decimal_minute(nums[1]) + decimal_second(nums[2]);
    };
    if (nums.size() > 3) {
      Rcpp::warning("invalid format, more than 3 numeric slots, got: " + str);
      ret = NA_REAL;
    };

    // apply direction
    ret = ret * dir_val;

    // FIXME: need to do is na check
    // bool fart = !NumericVector::is_na(ret);
    // Rprintf("R_IsNA result: %d \n", fart );
    if (!NumericVector::is_na(ret)) {
      if (!check_lat(ret)) {
        ret = NA_REAL;
        Rcpp::warning("not within -90/90 range, got: " + str);
      };
    };
  };
  return ret;
};
