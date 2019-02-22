#include <Rcpp.h>
#include "llstr.h"

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector pz_parse_lat(CharacterVector x, std::string format) {
  const int n = x.size();
  NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    CLongLatString strLat(w, format, LL_LATITUDE);
    float z = strLat.GetDecimalDegree();
    // check if 0 ~ invalid according to CLongLatString checker
    // special check because CLongLatString only checks wether in 180
    // give NA if an error occurred in CLongLatString
    z = (z == 0 || std::abs(z) > 90 || strLat.IsError()) ? NA_REAL : z;
    y[i] = z;
  };
  return y;
};

// [[Rcpp::export]]
NumericVector pz_parse_lon(CharacterVector x, std::string format) {
  const int n = x.size();
  NumericVector y(n);
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    CLongLatString strLon(w, format, LL_LONGITUDE);
    float z = strLon.GetDecimalDegree();
    // check if 0 ~ invalid according to CLongLatString checker
    // give NA if an error occurred in CLongLatString
    z = (z == 0 || strLon.IsError()) ? NA_REAL : z;
    y[i] = z;
  };
  return y;
};

