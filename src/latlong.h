#include <Rcpp.h> // is this necessary?
using namespace Rcpp; // is this necessary?

float convert_lat(std::string& str);
float convert_lat_old(std::string str);
float convert_lon(std::string& str);
float convert_lon_old(std::string str);
bool is_negative(const std::string& s);
bool is_negative_old(std::string s);
