#include <Rcpp.h>
#include "latlong.h"

// [[Rcpp::export]]
std::vector<double> pz_parse_lat(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<double> y(n);
  for (int i=0; i < n; ++i) {
    double z = convert_lat(x[i]);
    y[i] = z;
  }
  return y;
}

// [[Rcpp::export]]
std::vector<double> pz_parse_lon(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<double> y(n);
  for (int i=0; i < n; ++i) {
    double z = convert_lon(x[i]);
    y[i] = z;
  }
  return y;
}
