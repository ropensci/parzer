#include <Rcpp.h>
#include "latlong.h"

#include <regex>

using namespace Rcpp;

// eg string: "N 04.25164, E 101.70695"

// [[Rcpp::export]]
CharacterVector foo_bar (std::string x) {
  std::regex rgx(",?\\s*[NnSsEeWw]");
  std::sregex_token_iterator iter(x.begin(), x.end(), rgx, -1);
  std::sregex_token_iterator end;
  CharacterVector y;
  for ( ; iter != end; ++iter)
    y.push_back(*iter);
  return y;
};

// List pz_split_llstr (std::string x) {
//   // attempt to split the string
//   // "N\\h*([\\d\\.]+),\\h*E\\h*([\\d\\.]+)"
//
//   // if successful, process lats and lons
//   NumericVector lat_strs = pz_parse_lat(lats);
//   NumericVector lon_strs = pz_parse_lat(lons);
//
//   // return a list
//   return List::create(lat_strs, lon_strs);
// };

// [[Rcpp::export]]
int pz_split_llstr (std::string x) {

  int nbDots = std::count(x.begin(), x.end(), 'e');
  return nbDots;

}


//comma_number <- stringi::stri_count(str=coords, fixed=",")
//  space_number <- stringi::stri_count(str=coords, fixed=" ")
//  semicolon_number <- stringi::stri_count(str=coords, fixed=";")
//  dot_number <- stringi::stri_count(str=coords, fixed="."))
