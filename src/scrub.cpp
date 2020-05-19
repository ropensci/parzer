#include <Rcpp.h>
#include <regex>

using namespace Rcpp;
// This is 10 times slower than the R equivalent.
// [[Rcpp::export]]

CharacterVector scrub_cpp (CharacterVector x) {
  std::regex rgx("\u0027\u0027|\u2018\u2018|\u2019\u2019|\u02BC\u02BC|\u0060\u0060|\u00BB|\u201C|\u201D|\u2033|\u3003|\u301E|\u301F|\u0022|\u02BA|\u02DD|\u275E|\u030B|\u030E|\u030F|\u05F4|\u2018|\u2019|\u02BC|\u02C8|\u0060|\u030D|\u02B9|\u00B4|\u0301|\u0374|\u0384|\u2032|\u275C|\u05F3|\u055A|\u055B|\u055D|\u0599|\u059C|\u059D|\u059E|\u00B0|\u02DA|\u030A|\u2070|\u0366|\u05AF|\u00BA|d|g|\u003A");
  CharacterVector results;

  const int n = x.size();
  for (int i=0; i < n; ++i) {
    std::string tmp = as<std::string>(x[i]);
    std::string scrubbed = std::regex_replace(tmp, rgx,  "'");
    results.push_back(scrubbed);
  };
  return(results);
}

