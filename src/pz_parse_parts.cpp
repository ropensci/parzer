#include <Rcpp.h>
#include "latlong.h"

using namespace Rcpp;

// [[Rcpp::export]]
List split_decimal_degree(float &x, std::string fmt = "dms") {
  const float sixty = 60;
  const float thirtysixh = 3600;

  double dir_val = 1.0;
  if ( R_IsNA(x)) {
    return List::create(NA_REAL, NA_REAL, NA_REAL);
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
  return List::create(d, m, s); // should be an std::tuple?
}

// [[Rcpp::export]]
List split_decimal_degree_old(float x, std::string fmt = "dms") {
  float sixty = 60;
  float thirtysixh = 3600;

  double dir_val = 1.0;
  if ( R_IsNA(x)) {
    return List::create(NA_REAL, NA_REAL, NA_REAL);
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
  return List::create(d, m, s); // should be an std::tuple?
}

// [[Rcpp::export]]
DataFrame pz_parse_parts_lat(CharacterVector x) {
  const int n = x.size();
  IntegerVector deg(n, 0); // pushback.IntegerVector copies the whole vector a each pushback
  IntegerVector min(n, 0); // replace with std::vector?
  NumericVector sec(n, 0.);

  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float out = convert_lat(w); // w could be passed as a reference?
    List parts = split_decimal_degree(out);
    deg(i) = parts[0];
    min(i) = parts[1];
    sec(i) = parts[2];
  }
  return DataFrame::create(_["deg"] = deg,
                           _["min"] = min,
                           _["sec"] = sec,
                           _["stringsAsFactors"] = false);
}

// [[Rcpp::export]]
DataFrame pz_parse_parts_lat_old(CharacterVector x) {
  const int n = x.size();
  IntegerVector deg;
  IntegerVector min;
  NumericVector sec;
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float out = convert_lat(w);
    List parts = split_decimal_degree_old(out);
    deg.push_back(parts[0]);
    min.push_back(parts[1]);
    sec.push_back(parts[2]);
  }
  return DataFrame::create(_["deg"] = deg,
                           _["min"] = min,
                           _["sec"] = sec,
                           _["stringsAsFactors"] = false);
}

// [[Rcpp::export]]
DataFrame pz_parse_parts_lon(CharacterVector x) {
  const int n = x.size();
  IntegerVector deg(n, 0);
  IntegerVector min(n, 0);
  NumericVector sec(n, 0.);
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float out = convert_lon(w); // passed as a reference?
    List parts = split_decimal_degree(out);
    deg(i) = parts[0];
    min(i) = parts[1];
    sec(i) = parts[2];
  }
  return DataFrame::create(_["deg"] = deg,
                           _["min"] = min,
                           _["sec"] = sec,
                           _["stringsAsFactors"] = false);
}
// [[Rcpp::export]]
DataFrame pz_parse_parts_lon_old(CharacterVector x) {
  const int n = x.size();
  IntegerVector deg;
  IntegerVector min;
  NumericVector sec;
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float out = convert_lon(w);
    List parts = split_decimal_degree_old(out);
    deg.push_back(parts[0]);
    min.push_back(parts[1]);
    sec.push_back(parts[2]);
  }
  return DataFrame::create(_["deg"] = deg,
                           _["min"] = min,
                           _["sec"] = sec,
                           _["stringsAsFactors"] = false);
}
