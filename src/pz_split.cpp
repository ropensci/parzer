// [[Rcpp::plugins(cpp11)]]

// #include <string>
// #include <sstream>
// #include <vector>
// #include <iterator>

#include <Rcpp.h>
using namespace Rcpp;

// #include "utils.h"

// adapter from https://stackoverflow.com/a/236803/1091766
// template<typename Out>
// void split(const std::string &s, char delim, Out result) {
//   std::stringstream ss(s);
//   std::string item;
//   while (std::getline(ss, item, delim)) {
//     *(result++) = item;
//   }
// }
//
// std::vector<std::string> split(const std::string &s, char delim) {
//   std::vector<std::string> elems;
//   split(s, delim, std::back_inserter(elems));
//   return elems;
// }

#include <iostream>
#include <string>
#include <regex>

// std::vector<std::string> split(const std::string &s) {
//   // std::string s ("this subject has a submarine as a subsequence");
//   std::regex e ("\\b(sub)([^ ]*)");   // matches words beginning by "sub"
//
//   // default constructor = end-of-sequence:
//   std::regex_token_iterator<std::string::iterator> rend;
//
//   std::vector<std::string> z;
//   std::regex_token_iterator<std::string::iterator> d ( s.begin(), s.end(), e, -1 );
//   while (d!=rend) std::back_inserter(*d++);
//   return z;
// };

std::vector<std::string> split(const std::string& input) {
  std::regex re(",|[0-9]\\s-?[0-9]|[0-9][NSEW][0-9]");
  std::sregex_token_iterator
    first{input.begin(), input.end(), re, -1},
    last;
  return {first, last};
};

// [[Rcpp::export]]
std::vector<std::string> pz_split(std::string x) {
  // std::vector<std::string> y = split(x, ',');
  std::vector<std::string> y = split(x);
  return y;
};
