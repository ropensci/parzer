#include <Rcpp.h>
#include "latlong.h"

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector pz_parse_lat(CharacterVector x) {
  const int n = x.size();
  NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float z = convert_lat(w);
    y[i] = z;
  };
  return y;
};

// [[Rcpp::export]]
NumericVector pz_parse_lon(CharacterVector x) {
  const int n = x.size();
  NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float z = convert_lon(w);
    y[i] = z;
  };
  return y;
};
