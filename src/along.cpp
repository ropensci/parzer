#include <Rcpp.h>
#include "llstr.h"

// [[Rcpp::export]]
float pz_parse_lat(std::string x, std::string format) {
  CLongLatString strLat(x, format, LL_LATITUDE);
  float z = strLat.GetDecimalDegree();
  // check if 0 ~ invalid according to CLongLatString checker
  // special check because CLongLatString only checks wether in 180
  z = (z == 0 || std::abs(z) > 90) ? NA_REAL : z;
  return z;
};

// [[Rcpp::export]]
float pz_parse_lon(std::string x, std::string format) {
  CLongLatString strLon(x, format, LL_LONGITUDE);
  float z = strLon.GetDecimalDegree();
  z = z == 0 ? NA_REAL : z;
  return z;
};

// float pz_parse_lat_lon(std::string x, std::string format) {
//   CLongLatString strLatLon(x, format, LL_UNKNOWN);
//   float z = strLatLon.GetLongLat();
//   z = z == 0 ? NA_REAL : z;
//   return z;
// };
