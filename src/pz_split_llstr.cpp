#include <Rcpp.h>
#include <algorithm>

// Same as regex_replace(x, "^ +| +$|( ) +", "$1"): drop leading and trailing
// spaces, collapse runs of spaces to one.
static std::string squish_spaces(const std::string& x) {
  std::string out;
  bool gap = false;
  for (char c : x) {
    if (c == ' ') {
      gap = true;
      continue;
    }
    if (gap && !out.empty()) out += ' ';
    gap = false;
    out += c;
  }
  return out;
}

// [[Rcpp::export]]
std::vector<std::string> pz_split_llstr_string (std::string x) {
  x = squish_spaces(x);

  int nbCommas = std::count(x.begin(), x.end(), ',');
  int nbSpaces = std::count(x.begin(), x.end(), ' ');
  int nbSC = std::count(x.begin(), x.end(), ';');
  int nbDots = std::count(x.begin(), x.end(), '.');

  char sep;
  if (nbCommas == 1) {
    sep = ',';
  } else if (nbCommas == 0 && nbSpaces == 1 && nbSC == 0 && (nbDots == 0 || nbDots == 2)) {
    sep = ' ';
  } else if (nbSC == 1) {
    sep = ';';
  } else if (nbDots == 1) {
    sep = '.';
  } else {
    return {"NA_STRING", "NA_STRING"};
  }
  // Split at the only `sep`. Same as the old regexes "sep.*$" and "^.*sep":
  // "." does not match a line break, so a line break on one side leaves that
  // side's part as the whole string.
  std::size_t i = x.find(sep);
  bool break_before = x.find_first_of("\n\r") < i;
  bool break_after = x.find_first_of("\n\r", i + 1) != std::string::npos;
  return {break_after ? x : x.substr(0, i), break_before ? x : x.substr(i + 1)};
}



//’ Splits Latitude and Longitude from multiple strings in character a vector
//’
//’ @param x input character vector
//’ @return data.frame with Latitude and Longitude split in 2 columns.
// [[Rcpp::export]]
Rcpp::DataFrame pz_split_llstr (std::vector<std::string> x) {

  // Rcpp::StringMatrix stringmat(x.size(), 2);
  // Rcpp::StringMatrix::Column lon = stringmat( Rcpp::_, 1);
  // Rcpp::StringMatrix::Column lat = stringmat( Rcpp::_, 0);

  std::vector<std::string> lat(x.size());
  std::vector<std::string> lon(x.size());

  for(int i=0; i < x.size(); i++) {
    std::vector<std::string> temp = pz_split_llstr_string (x[i]);

    lon[i] = temp[1];
    lat[i] = temp[0];

  }
  Rcpp::DataFrame stringdf = Rcpp::DataFrame::create( Rcpp::Named("lon") = lon,
                                                      Rcpp::Named("lat") = lat,
                                                      Rcpp::Named("stringsAsFactors") = false);
  return stringdf;
}

