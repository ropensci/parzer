#include <Rcpp.h>
#include "latlong.h"

// [[Rcpp::export]]
std::vector<double> split_decimal_degree(const double& x, const std::string& fmt = "dms") {
  const double sixty = 60;
  const double thirtysixh = 3600;
  double dir_val = 1.0;

  if ( R_IsNA(x)) {
    std::vector<double>{0, 0, 0}; // this has to be updated
    // return Rcpp::List::create(NA_REAL, NA_REAL, NA_REAL);
  }
  // auto x_str = Rcpp::toString(x); // Rcpp should be replaced here
  // if (is_negative(x)) { // does not use Rcpp but uses regex
  if (x < 0.) {
    dir_val = -1.0;
  }
  double x_abs = std::fabs(x);

  double d = static_cast<int>(x_abs); // is this : "double X = static_cast<int>(Y);" OK? it works...
  double m = static_cast<int>((x_abs - d) * sixty);
  double s = ((x_abs - d) - (m/sixty)) * thirtysixh;
  d = d * dir_val;

  return std::vector<double>{d, m, s};
}

// [[Rcpp::export]]
Rcpp::DataFrame pz_parse_parts_lat(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<int> deg(n, 0);
  std::vector<int> min(n, 0);
  std::vector<double> sec(n, 0.);

  for (int i=0; i < n; ++i) {
    double out = convert_lat(x[i]); // passed as a reference.
    std::vector<double> parts = split_decimal_degree(out); // passed as a const reference.
    deg[i] = parts[0];
    min[i] = parts[1];
    sec[i] = parts[2];
  }
  return Rcpp::DataFrame::create(Rcpp::_["deg"] = deg,
                                 Rcpp::_["min"] = min,
                                 Rcpp::_["sec"] = sec,
                                 Rcpp::_["stringsAsFactors"] = false);
}

// [[Rcpp::export]]
Rcpp::DataFrame pz_parse_parts_lon(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<int> deg(n, 0);
  std::vector<int> min(n, 0);
  std::vector<double> sec(n, 0.);

  for (int i=0; i < n; ++i) {
    double out = convert_lon(x[i]); // passed as a reference.
    std::vector<double> parts = split_decimal_degree(out); // passed as a const reference.
    deg[i] = parts[0];
    min[i] = parts[1];
    sec[i] = parts[2];
  }
  return Rcpp::DataFrame::create(Rcpp::_["deg"] = deg,
                                 Rcpp::_["min"] = min,
                                 Rcpp::_["sec"] = sec,
                                 Rcpp::_["stringsAsFactors"] = false);
}

