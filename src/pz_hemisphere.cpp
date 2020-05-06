#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::plugins(cpp11)]]
#include "latlong.h"

// [[Rcpp::export]]
CharacterVector pz_hemisphere(CharacterVector lon, CharacterVector lat) {
  const int n = lat.size();
  CharacterVector out;
  for (int i=0; i < n; ++i) {
    std::string londir = "";
    auto lon_ = as<std::string>(lon[i]);
    float lon_f = convert_lon(lon_);
    if (R_IsNaN(lon_f)) {
      londir = "";
    } else {
      std::string lon1 = std::to_string(lon_f);
      londir = is_negative(lon1) ? "W" : "E";
    };

    std::string latdir = "";
    auto lat_ = as<std::string>(lat[i]);
    float lat_f = convert_lat(lat_);
    if (R_IsNaN(lat_f)) {
      latdir = "";
    } else {
      std::string lat1 = std::to_string(lat_f);
      latdir = is_negative(lat1) ? "S" : "N";
    };

    std::string ss = latdir + londir;
    out.push_back(ss);
  };
  return out;
};
