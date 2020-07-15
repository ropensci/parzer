#include "cpp11.hpp"
using namespace cpp11;

#include "cpp11/strings.hpp"
#include "cpp11/doubles.hpp"
#include "cpp11/integers.hpp"
#include "cpp11/list.hpp"
#include "cpp11/data_frame.hpp"
#include <string>
#include "latlong.h"

[[cpp11::register]]
cpp11::list split_decimal_degree(float x, std::string fmt = "dms") {
  float sixty = 60;
  float thirtysixh = 3600;

  double dir_val = 1.0;
  if ( R_IsNA(x)) {
    return cpp11::writable::list({as_sexp(NA_REAL), as_sexp(NA_REAL), as_sexp(NA_REAL)});
  };
  // auto x_str = Rcpp::toString(x);
  auto x_str = std::to_string(x);
  if (is_negative(x_str)) {
    dir_val = -1.0;
  };
  x = fabs(x);

  int d = static_cast<int>(x);
  int m = static_cast<int>((x - d) * sixty);
  double s = ((x - d) - (m/sixty)) * thirtysixh;
  d = static_cast<int>(d * dir_val);
  return cpp11::writable::list({as_sexp(d), as_sexp(m), as_sexp(s)});
  // z.push_back(cpp11::writable::integers(d));
  // z.push_back(cpp11::writable::integers(m));
  // z.push_back(cpp11::writable::doubles(s));
  // return z;
};

[[cpp11::register]]
cpp11::data_frame pz_parse_parts_lat(cpp11::strings x) {
  const int n = x.size();
  cpp11::writable::integers deg;
  cpp11::writable::integers min;
  cpp11::writable::doubles sec;
  for (int i=0; i < n; ++i) {
    auto w = as_cpp<std::string>(x[i]);
    float out = convert_lat(w);
    cpp11::list parts = split_decimal_degree(out);
    cpp11::integers first(parts[0]);
    cpp11::integers second(parts[1]);
    cpp11::doubles third(parts[2]);
    deg.push_back(first[0]);
    min.push_back(second[0]);
    sec.push_back(third[0]);
  };
  return cpp11::writable::data_frame({"deg"_nm = deg, "min"_nm = min, "sec"_nm = sec});
};

[[cpp11::register]]
cpp11::data_frame pz_parse_parts_lon(cpp11::strings x) {
  const int n = x.size();
  cpp11::writable::integers deg;
  cpp11::writable::integers min;
  cpp11::writable::doubles sec;
  for (int i=0; i < n; ++i) {
    auto w = as_cpp<std::string>(x[i]);
    float out = convert_lon(w);
    cpp11::list parts = split_decimal_degree(out);
    // deg.push_back(parts[0]);
    // min.push_back(parts[1]);
    // sec.push_back(parts[2]);
    // cpp11::integers first(parts[0]);
    // cpp11::integers second(parts[1]);
    // cpp11::doubles third(parts[2]);
    // deg.push_back(first[0]);
    // min.push_back(second[0]);
    // sec.push_back(third[0]);
  };
  return cpp11::writable::data_frame({"deg"_nm = deg, "min"_nm = min, "sec"_nm = sec});
};

[[cpp11::register]]
cpp11::list pz_play(cpp11::strings x) {
  const int n = x.size();
  cpp11::writable::integers deg;
  cpp11::writable::integers min;
  cpp11::writable::doubles sec;
  auto w = as_cpp<std::string>(x[0]);
  float out = convert_lon(w);
  cpp11::list parts = split_decimal_degree(out);
  return parts;
};
