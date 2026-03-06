#include <Rcpp.h>
// [[Rcpp::plugins(cpp11)]]
#include "latlong.h"

// [[Rcpp::export]]
std::vector<std::string> pz_hemisphere(std::vector<std::string> lon, std::vector<std::string> lat) {
  const int n = lat.size();
  std::vector<std::string> out;
  for (int i=0; i < n; ++i) {
    std::string londir = "";
    double lon_f = convert_lon(lon[i]);
    if (R_IsNA(lon_f)) {
      londir = "";
    } else {
      londir = std::signbit(lon_f) ? "W" : "E";
      if (lon_f > 180) {
        Rcpp::warning("longitude value within 180/360 range, got: " + std::to_string(lon_f));
      }
    }

    std::string latdir = "";
    double lat_f = convert_lat(lat[i]);
    if (R_IsNA(lat_f)) {
      latdir = "";
    } else {
      latdir = std::signbit(lat_f) ? "S" : "N";
    }

    std::string ss = latdir + londir;
    out.push_back(ss);
  }
  return out;
}
