#include <Rcpp.h>
#include "llstr.h"
using namespace Rcpp;

// [[Rcpp::export]]
DataFrame pz_parse_parts(CharacterVector x, std::string format) {
  const int n = x.size();
  IntegerVector dec;
  NumericVector min;
  NumericVector sec;
  for (int i=0; i < n; ++i) {
    auto w = as<std::string>(x[i]);
    CLongLatString strCoord(w, format, LL_UNKNOWN);
    bool was_error = strCoord.IsError();
    int decx = strCoord.GetIntegerDegree();
    decx = was_error ? NA_INTEGER : decx;
    float minx = strCoord.GetDecimalMinute();
    minx = was_error ? NA_REAL : minx;
    float secx = strCoord.GetDecimalSecond();
    secx = was_error ? NA_REAL : secx;
    dec.push_back(decx);
    min.push_back(minx);
    sec.push_back(secx);
  };
  return DataFrame::create(_["decimal_degree"] = dec,
                           _["decimal_min"] = min,
                           _["decimal_sec"] = sec,
                           _["stringsAsFactors"] = false);
};
