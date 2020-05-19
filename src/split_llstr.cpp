// [[Rcpp::depends(BH)]]

#include <Rcpp.h>
#include <boost/algorithm/string.hpp>

//using namespace Rcpp;

// [[Rcpp::export]]
std::vector<std::string> pz_split_llstr_string (std::string x) {

  int nbCommas = std::count(x.begin(), x.end(), ',');
  int nbSpaces = std::count(x.begin(), x.end(), ' ');
  int nbSC = std::count(x.begin(), x.end(), ';');
  int nbDots = std::count(x.begin(), x.end(), '.');

  std::vector<std::string> splitstr(2);

  if(nbCommas == 1) {
    boost::split(splitstr, x, [](char c){return c == ',';});
  } else if (nbCommas > 0 && nbSpaces > 0) {
    boost::split(splitstr, x, [](char c){return c == ', ';});
  } else if (nbCommas == 0 && nbSpaces ==1 && nbSC == 0) {
    boost::split(splitstr, x, [](char c){return c == ' ';});
  } else if (nbSC == 1) {
    boost::split(splitstr, x, [](char c){return c == ';';});
  } else if (nbDots == 1){
    boost::split(splitstr, x, [](char c){return c == '.';});
  } else {
    Rcpp::StringVector splitstr(2, "NA_STRING");
  }
  return splitstr;
}
// https://www.fluentcpp.com/2017/04/21/how-to-split-a-string-in-c/




// [[Rcpp::export]]
Rcpp::StringMatrix pz_split_llstr (Rcpp::StringVector x) {

  Rcpp::StringMatrix stringvec(x.size(), 2);

  for(int i=0; i < x.size(); i++) {
    Rcpp::StringVector temp =  pz_split_llstr_string (Rcpp::as< std::string >(x[i]))[1];
    // stringvec[i,0] = temp[0];
    // stringvec[i,1] = temp[1];
  //  Rcpp::stringmat(i, 1 ) = Rcpp::as< Rcpp::MatrixRow >(pz_split_llstr_string (x[i]));
    // Rcpp::stringvec.push_back(Rcpp::as< std::vector<std::string> >(pz_split_llstr_string (Rcpp::as< std::string >(x[i]))));
  }

  return stringvec;
}


// and R commands to test these functions when sourced
/***R
pz_split_llstr_string("N45.32''34',23.23'23''E")
pz_split_llstr(c("N4:51′36″, E101:34′7″","N4:51′36″, E101:34′7″"))
*/

