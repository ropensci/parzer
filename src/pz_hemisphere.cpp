#include <Rcpp.h>
#include "llstr.h"
using namespace Rcpp;

// [[Rcpp::export]]
CharacterVector pz_hemisphere(CharacterVector lat, CharacterVector lon, std::string format) {
  const int n = lat.size();
  CharacterVector out;
  for (int i=0; i < n; ++i) {
    auto w_lat = as<std::string>(lat[i]);
    CLongLatString strLat(w_lat, format, LL_LATITUDE);
    char hem_lat = strLat.GetHemisphere();
    std::string ss_lat(1, hem_lat);
    ss_lat = strLat.IsError() ? "" : ss_lat;

    auto w_lon = as<std::string>(lon[i]);
    CLongLatString strLon(w_lon, format, LL_LONGITUDE);
    char hem_lon = strLon.GetHemisphere();
    std::string ss_lon(1, hem_lon);
    ss_lon = strLon.IsError() ? "" : ss_lon;

    std::string ss = ss_lat + ss_lon;
    out.push_back(ss);
  };
  return out;
};
