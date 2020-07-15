#include "cpp11.hpp"
using namespace cpp11;

#include "cpp11/strings.hpp"
#include "cpp11/data_frame.hpp"
#include "cpp11/matrix.hpp"
#include <regex>

std::vector<std::string> pz_split_llstr_string (std::string x) {
  x = std::regex_replace(x, std::regex("^ +| +$|( ) +"), "$1");

  int nbCommas = std::count(x.begin(), x.end(), ',');
  int nbSpaces = std::count(x.begin(), x.end(), ' ');
  int nbSC = std::count(x.begin(), x.end(), ';');
  int nbDots = std::count(x.begin(), x.end(), '.');

  std::vector<std::string> splitstr(2);

  if(nbCommas == 1) {
    splitstr[0] = std::regex_replace(x, std::regex(",.*$"), "$1");
    splitstr[1] = std::regex_replace(x, std::regex("^.*,"), "$1");
  } else if (nbCommas == 0 && nbSpaces == 1 && nbSC == 0 && (nbDots == 0 | nbDots == 2)) {
    splitstr[0] = std::regex_replace(x, std::regex(" .*$"), "$1");
    splitstr[1] = std::regex_replace(x, std::regex("^.* "), "$1");
  } else if (nbSC == 1) {
    splitstr[0] = std::regex_replace(x, std::regex(";.*$"), "$1");
    splitstr[1] = std::regex_replace(x, std::regex("^.*;"), "$1");
  } else if (nbDots == 1){
    splitstr[0] = std::regex_replace(x, std::regex("\\..*$"), "$1");
    splitstr[1] = std::regex_replace(x, std::regex("^.*\\."), "$1");
  } else {
    std::vector<std::string> splitstr(2, "NA_STRING");
  }
  return splitstr;
}



[[cpp11::register]]
cpp11::data_frame pz_split_llstr(cpp11::strings x) {
  cpp11::writable::strings lon;
  cpp11::writable::strings lat;

  for(int i=0; i < x.size(); i++) {
    std::vector<std::string> temp = pz_split_llstr_string (as_cpp< std::string >(x[i]));
    lon[i] = temp[1];
    lat[i] = temp[0];
  };
  return cpp11::writable::data_frame({"lon"_nm = lon, "lat"_nm = lat});
};
