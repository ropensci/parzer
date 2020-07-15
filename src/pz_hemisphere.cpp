#include "cpp11.hpp"
using namespace cpp11;
#include <cpp11/strings.hpp>
#include "latlong.h"

[[cpp11::register]]
cpp11::strings pz_hemisphere(cpp11::strings lon, cpp11::strings lat) {
  const int n = lat.size();
  cpp11::writable::strings out;
  for (int i=0; i < n; ++i) {
    std::string londir = "";
    auto lon_ = as_cpp<std::string>(lon[i]);
    float lon_f = convert_lon(lon_);
    if (R_IsNaN(lon_f)) {
      londir = "";
    } else {
      std::string lon1 = std::to_string(lon_f);
      londir = is_negative(lon1) ? "W" : "E";
    };

    std::string latdir = "";
    auto lat_ = as_cpp<std::string>(lat[i]);
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
