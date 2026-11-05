#include <Rcpp.h>
#include "latlong.h"

struct DMS { int deg; int min; double sec; };

// The sign goes on the first non-zero field, so -0.5 is 0 deg, -30 min, 0 sec.
static DMS split_dms(double x) {
  const double eps = 1e-9; // seconds; absorbs floating-point error
  double x_abs = std::fabs(x);
  int d = static_cast<int>(x_abs);
  int m = static_cast<int>((x_abs - d) * 60.0);
  double s = ((x_abs - d) - (m / 60.0)) * 3600.0;
  if (s < eps) {
    s = 0.;
  } else if (s > 60. - eps) {
    // truncation left almost a full minute in the seconds: carry it
    s = 0.;
    ++m;
  }
  if (m == 60) {
    m = 0;
    ++d;
  }
  if (x < 0.) {
    if (d != 0) {
      d = -d;
    } else if (m != 0) {
      m = -m;
    } else {
      s = -s;
    }
  }
  return {d, m, s};
}

// [[Rcpp::export]]
Rcpp::List split_decimal_degree(const double& x, const std::string& fmt = "dms") {
  if (std::isnan(x)) {
    return Rcpp::List::create(NA_REAL, NA_REAL, NA_REAL);
  }
  DMS dms = split_dms(x);
  return Rcpp::List::create(dms.deg, dms.min, dms.sec);
}

// [[Rcpp::export]]
Rcpp::DataFrame pz_parse_parts_lat(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<int> deg(n, 0);
  std::vector<int> min(n, 0);
  std::vector<double> sec(n, 0.);

  for (int i=0; i < n; ++i) {
    double out = convert_lat(x[i]); // passed as a reference.
    if (R_IsNA(out)) {
      deg[i] = NA_INTEGER;
      min[i] = NA_INTEGER;
      sec[i] = NA_REAL;
    } else {
      DMS parts = split_dms(out);
      deg[i] = parts.deg;
      min[i] = parts.min;
      sec[i] = parts.sec;
    }
  }
  return Rcpp::DataFrame::create(Rcpp::_["deg"] = deg,
                                 Rcpp::_["min"] = min,
                                 Rcpp::_["sec"] = sec,
                                 Rcpp::_["stringsAsFactors"] = false);
}

// [[Rcpp::export]]
Rcpp::DataFrame pz_parse_parts_lon(std::vector<std::string>& x) {
  const int n = x.size();
  std::vector<int> deg(n, 0);
  std::vector<int> min(n, 0);
  std::vector<double> sec(n, 0.);

  for (int i=0; i < n; ++i) {
    double out = convert_lon(x[i]); // passed as a reference.
    if (R_IsNA(out)) {
      deg[i] = NA_INTEGER;
      min[i] = NA_INTEGER;
      sec[i] = NA_REAL;
    } else {
      DMS parts = split_dms(out);
      deg[i] = parts.deg;
      min[i] = parts.min;
      sec[i] = parts.sec;
    }
  }
  return Rcpp::DataFrame::create(Rcpp::_["deg"] = deg,
                                 Rcpp::_["min"] = min,
                                 Rcpp::_["sec"] = sec,
                                 Rcpp::_["stringsAsFactors"] = false);
}
