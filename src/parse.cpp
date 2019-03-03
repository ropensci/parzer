#include <Rcpp.h>
#include "latlong.h"

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector pz_parse_lat(CharacterVector x) {
  const int n = x.size();
  NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    float z = convert_lat2(w);
    y[i] = z;
  };
  return y;
};
