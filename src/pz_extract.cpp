#include <Rcpp.h>
using namespace Rcpp;

#include <iostream>
#include <string>
#include <regex>

// FIXME: \u00B0? matches the degree symbol, but makes other regexes fail

std::string extract(const std::string& s) {
  // std::regex rgx("-?[0-9]{1,3}\\.[0-9]+°\\s[NSEW]");
  std::regex rgx("-?[0-9]{1,3}\\.[0-9]+[NSEW]?");
  std::smatch match;
  std::regex_search(s.begin(), s.end(), match, rgx);
  return match.str(0);
};

// [[Rcpp::export]]
std::string pz_extract(std::string x) {
  std::string y = extract(x);
  return y;
};


// std::vector<std::string> extract(const std::string& s) {
//   std::regex re("-?[0-9]{1,3}\\.[0-9]+[NSEW]?");
//   // std::sregex_token_iterator
//   //   first{s.begin(), s.end(), re, -1},
//   //   last;
//   std::sregex_token_iterator iter(s.begin(), s.end(), re);
//   std::sregex_iterator end;
//   return {first, last};
// };

// std::vector<std::string> pz_extract(std::string x) {
//   std::vector<std::string> y = extract(x);
//   return y;
// };
