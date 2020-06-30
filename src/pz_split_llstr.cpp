// [[Rcpp::depends(BH)]]

#include <Rcpp.h>
#include <boost/algorithm/string.hpp>

// [[Rcpp::export]]
std::vector<std::string> pz_split_llstr_string (std::string x) {

//  x = std::regex_replace(x, std::regex("^ +| +$|( ) +"), "$1");   // does not work even with // [[Rcpp::plugins(cpp11)]]

  int nbCommas = std::count(x.begin(), x.end(), ',');
  int nbSpaces = std::count(x.begin(), x.end(), ' ');
  int nbSC = std::count(x.begin(), x.end(), ';');
  int nbDots = std::count(x.begin(), x.end(), '.');

  std::vector<std::string> splitstr(2);

  if(nbCommas == 1) {
    boost::split(splitstr, x, [](char c){return c == ',';});
  } else if (nbCommas > 0 && nbSpaces > 0) {
    boost::split(splitstr, x, [](char c){return c == ', ';});
  } else if (nbCommas == 0 && nbSpaces == 1 && nbSC == 0) {
    boost::split(splitstr, x, [](char c){return c == ' ';});
  } else if (nbSC == 1) {
    boost::split(splitstr, x, [](char c){return c == ';';});
  } else if (nbDots == 1){
    boost::split(splitstr, x, [](char c){return c == '.';});
  } else {
    std::vector<std::string> splitstr(2, "NA_STRING");
  }
  return splitstr;
}
// https://www.fluentcpp.com/2017/04/21/how-to-split-a-string-in-c/


//’ Splits Latitude and Longitude from multiple strings in character a vector
//’
//’ @param x input character vector
//’ @return data.frame with Latitude and Longitude split in 2 columns.
// [[Rcpp::export]]
Rcpp::DataFrame pz_split_llstr (Rcpp::StringVector x) {

  Rcpp::StringMatrix stringmat(x.size(), 2);
  Rcpp::StringMatrix::Column lon = stringmat( Rcpp::_, 1);
  Rcpp::StringMatrix::Column lat = stringmat( Rcpp::_, 0);


  for(int i=0; i < x.size(); i++) {
    std::vector<std::string> temp = pz_split_llstr_string (Rcpp::as< std::string >(x[i]));

    lon[i] = temp[1];
    lat[i] = temp[0];

  }
  Rcpp::DataFrame stringdf = Rcpp::DataFrame::create( Rcpp::Named("lon") = lon,
                                                      Rcpp::Named("lat") = lat );
  return stringdf;
}

