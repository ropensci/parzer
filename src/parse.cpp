#include <Rcpp.h>
#include "latlong.h"

// [[Rcpp::export]]
Rcpp::NumericVector pz_parse_lat(const Rcpp::CharacterVector& x) {
  const int n = x.size();
  Rcpp::NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float z = convert_lat(w);
    y[i] = z;
  }
  return y;
}

// [[Rcpp::export]]
Rcpp::NumericVector pz_parse_lat_old(Rcpp::CharacterVector x) {
  const int n = x.size();
  Rcpp::NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float z = convert_lat_old(w);
    y[i] = z;
  }
  return y;
}

// [[Rcpp::export]]
Rcpp::NumericVector pz_parse_lon(const Rcpp::CharacterVector& x) {
  const int n = x.size();
  Rcpp::NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float z = convert_lon(w);
    y[i] = z;
  }
  return y;
}

// [[Rcpp::export]]
Rcpp::NumericVector pz_parse_lon_old(Rcpp::CharacterVector x) {
  const int n = x.size();
  Rcpp::NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = Rcpp::as<std::string>(x[i]);
    float z = convert_lon_old(w);
    y[i] = z;
  }
  return y;
}
