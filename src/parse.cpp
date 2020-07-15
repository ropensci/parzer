#include "cpp11.hpp"
using namespace cpp11;
#include "cpp11/doubles.hpp"
#include "latlong.h"

[[cpp11::register]]
cpp11::writable::doubles pz_parse_lat(cpp11::strings x) {
  const int n = x.size();
  cpp11::writable::doubles y(n);
  for (int i=0; i < n; ++i) {
    auto w = as_cpp<std::string>(x[i]);
    float z = convert_lat(w);
    y[i] = z;
  };
  return y;
};

[[cpp11::register]]
cpp11::writable::doubles pz_parse_lon(cpp11::strings x) {
  const int n = x.size();
  cpp11::writable::doubles y(n);
  for (int i=0; i < n; ++i) {
    auto w = as_cpp<std::string>(x[i]);
    float z = convert_lon(w);
    y[i] = z;
  };
  return y;
};
