#include <Rcpp.h>
#include "latlong.h"

// [[Rcpp::export]]
std::vector<float> pz_parse_lat(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<float> y(n);
  for (int i=0; i < n; ++i) {
    float z = convert_lat(x[i]);
    y[i] = z;
  }
  return y;
}

// [[Rcpp::export]]
std::vector<float> pz_parse_lon(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<float> y(n);
  for (int i=0; i < n; ++i) {
    float z = convert_lon(x[i]);
    y[i] = z;
  }
  return y;
}
