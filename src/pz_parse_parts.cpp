#include <Rcpp.h>
#include "latlong.h"

// [[Rcpp::export]]
Rcpp::List split_decimal_degree(float& x, const std::string& fmt = "dms") {
  const float sixty = 60;
  const float thirtysixh = 3600;

  double dir_val = 1.0;
  if ( R_IsNA(x)) {
    return Rcpp::List::create(NA_REAL, NA_REAL, NA_REAL);
  }
  auto x_str = Rcpp::toString(x);
  if (is_negative(x_str)) {
    dir_val = -1.0;
  }
  x = fabs(x);

  int d = static_cast<int>(x);
  int m = static_cast<int>((x - d) * sixty);
  double s = ((x - d) - (m/sixty)) * thirtysixh;
  d = static_cast<int>(d * dir_val);
  return Rcpp::List::create(d, m, s); // should be an std::tuple?
}

// [[Rcpp::export]]
Rcpp::List split_decimal_degree_old(float x, std::string fmt = "dms") {
  float sixty = 60;
  float thirtysixh = 3600;

  double dir_val = 1.0;
  if ( R_IsNA(x)) {
    return Rcpp::List::create(NA_REAL, NA_REAL, NA_REAL);
  }
  auto x_str = Rcpp::toString(x);
  if (is_negative_old(x_str)) {
    dir_val = -1.0;
  }
  x = fabs(x);

  int d = static_cast<int>(x);
  int m = static_cast<int>((x - d) * sixty);
  double s = ((x - d) - (m/sixty)) * thirtysixh;
  d = static_cast<int>(d * dir_val);
  return Rcpp::List::create(d, m, s); // should be an std::tuple?
}

// [[Rcpp::export]]
Rcpp::DataFrame pz_parse_parts_lat(Rcpp::CharacterVector& x) {
  const int n = x.size();
  std::vector<int> deg(n, 0); // IntegerVector.push_back copies the whole vector a each pushback
  std::vector<int> min(n, 0);
  std::vector<double> sec(n, 0.);

  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float out = convert_lat(w); // passed as a reference.
    Rcpp::List parts = split_decimal_degree(out); // passed as a reference.
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
Rcpp::DataFrame pz_parse_parts_lat_old(Rcpp::CharacterVector x) {
  const int n = x.size();
  Rcpp::IntegerVector deg;
  Rcpp::IntegerVector min;
  Rcpp::NumericVector sec;
  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float out = convert_lat_old(w);
    Rcpp::List parts = split_decimal_degree_old(out);
    deg.push_back(parts[0]);
    min.push_back(parts[1]);
    sec.push_back(parts[2]);
  }
  return Rcpp::DataFrame::create(Rcpp::_["deg"] = deg,
                                 Rcpp::_["min"] = min,
                                 Rcpp::_["sec"] = sec,
                                 Rcpp::_["stringsAsFactors"] = false);
}

// [[Rcpp::export]]
Rcpp::DataFrame pz_parse_parts_lon(Rcpp::CharacterVector& x) {
  const int n = x.size();
  std::vector<int> deg(n, 0); // IntegerVector.push_back copies the whole vector a each pushback
  std::vector<int> min(n, 0);
  std::vector<double> sec(n, 0.);

  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float out = convert_lon(w); // passed as a reference.
    Rcpp::List parts = split_decimal_degree(out); // passed as a reference.
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
Rcpp::DataFrame pz_parse_parts_lon_old(Rcpp::CharacterVector x) {
  const int n = x.size();
  Rcpp::IntegerVector deg;
  Rcpp::IntegerVector min;
  Rcpp::NumericVector sec;
  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float out = convert_lon_old(w);
    Rcpp::List parts = split_decimal_degree_old(out);
    deg.push_back(parts[0]);
    min.push_back(parts[1]);
    sec.push_back(parts[2]);
  }
  return Rcpp::DataFrame::create(Rcpp::_["deg"] = deg,
                                 Rcpp::_["min"] = min,
                                 Rcpp::_["sec"] = sec,
                                 Rcpp::_["stringsAsFactors"] = false);
}
