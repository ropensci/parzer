#include <Rcpp.h>
// [[Rcpp::plugins(cpp11)]]
#include "latlong.h"

// [[Rcpp::export]]
std::vector<std::string> pz_hemisphere(std::vector<std::string> lon, std::vector<std::string> lat) {
  const int n = lat.size();
  std::vector<std::string> out;
  for (int i=0; i < n; ++i) {
    std::string londir = "";
    float lon_f = convert_lon(lon[i]);
    if (R_IsNaN(lon_f)) {
      londir = "";
    } else {
      std::string lon1 = std::to_string(lon_f);
      londir = is_negative(lon1) ? "W" : "E";
    }

    std::string latdir = "";
    float lat_f = convert_lat(lat[i]);
    if (R_IsNaN(lat_f)) {
      latdir = "";
    } else {
      std::string lat1 = std::to_string(lat_f);
      latdir = is_negative(lat1) ? "S" : "N";
    }

    std::string ss = latdir + londir;
    out.push_back(ss);
  }
  return out;
}
