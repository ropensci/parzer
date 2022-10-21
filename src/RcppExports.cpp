// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// convert_lat
float convert_lat(std::string& str);
RcppExport SEXP _parzer_convert_lat(SEXP strSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string& >::type str(strSEXP);
    rcpp_result_gen = Rcpp::wrap(convert_lat(str));
    return rcpp_result_gen;
END_RCPP
}
// convert_lat_old
float convert_lat_old(std::string str);
RcppExport SEXP _parzer_convert_lat_old(SEXP strSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type str(strSEXP);
    rcpp_result_gen = Rcpp::wrap(convert_lat_old(str));
    return rcpp_result_gen;
END_RCPP
}
// convert_lon
float convert_lon(std::string& str);
RcppExport SEXP _parzer_convert_lon(SEXP strSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string& >::type str(strSEXP);
    rcpp_result_gen = Rcpp::wrap(convert_lon(str));
    return rcpp_result_gen;
END_RCPP
}
// convert_lon_old
float convert_lon_old(std::string str);
RcppExport SEXP _parzer_convert_lon_old(SEXP strSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type str(strSEXP);
    rcpp_result_gen = Rcpp::wrap(convert_lon_old(str));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_lat
std::vector<float> pz_parse_lat(std::vector<std::string>& x);
RcppExport SEXP _parzer_pz_parse_lat(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<std::string>& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_lat(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_lat_old
Rcpp::NumericVector pz_parse_lat_old(Rcpp::CharacterVector x);
RcppExport SEXP _parzer_pz_parse_lat_old(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_lat_old(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_lon
std::vector<float> pz_parse_lon(std::vector<std::string>& x);
RcppExport SEXP _parzer_pz_parse_lon(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<std::string>& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_lon(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_lon_old
Rcpp::NumericVector pz_parse_lon_old(Rcpp::CharacterVector x);
RcppExport SEXP _parzer_pz_parse_lon_old(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_lon_old(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_hemisphere
std::vector<std::string> pz_hemisphere(std::vector<std::string> lon, std::vector<std::string> lat);
RcppExport SEXP _parzer_pz_hemisphere(SEXP lonSEXP, SEXP latSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<std::string> >::type lon(lonSEXP);
    Rcpp::traits::input_parameter< std::vector<std::string> >::type lat(latSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_hemisphere(lon, lat));
    return rcpp_result_gen;
END_RCPP
}
// split_decimal_degree
std::vector<float> split_decimal_degree(const float& x, const std::string& fmt);
RcppExport SEXP _parzer_split_decimal_degree(SEXP xSEXP, SEXP fmtSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const float& >::type x(xSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type fmt(fmtSEXP);
    rcpp_result_gen = Rcpp::wrap(split_decimal_degree(x, fmt));
    return rcpp_result_gen;
END_RCPP
}
// split_decimal_degree_old
Rcpp::List split_decimal_degree_old(float x, std::string fmt);
RcppExport SEXP _parzer_split_decimal_degree_old(SEXP xSEXP, SEXP fmtSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< float >::type x(xSEXP);
    Rcpp::traits::input_parameter< std::string >::type fmt(fmtSEXP);
    rcpp_result_gen = Rcpp::wrap(split_decimal_degree_old(x, fmt));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_parts_lat
Rcpp::DataFrame pz_parse_parts_lat(std::vector<std::string>& x);
RcppExport SEXP _parzer_pz_parse_parts_lat(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<std::string>& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_parts_lat(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_parts_lat_old
Rcpp::DataFrame pz_parse_parts_lat_old(Rcpp::CharacterVector x);
RcppExport SEXP _parzer_pz_parse_parts_lat_old(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_parts_lat_old(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_parts_lon
Rcpp::DataFrame pz_parse_parts_lon(std::vector<std::string>& x);
RcppExport SEXP _parzer_pz_parse_parts_lon(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<std::string>& >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_parts_lon(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_parse_parts_lon_old
Rcpp::DataFrame pz_parse_parts_lon_old(Rcpp::CharacterVector x);
RcppExport SEXP _parzer_pz_parse_parts_lon_old(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_parse_parts_lon_old(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_split_llstr_string
std::vector<std::string> pz_split_llstr_string(std::string x);
RcppExport SEXP _parzer_pz_split_llstr_string(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_split_llstr_string(x));
    return rcpp_result_gen;
END_RCPP
}
// pz_split_llstr
Rcpp::DataFrame pz_split_llstr(Rcpp::StringVector x);
RcppExport SEXP _parzer_pz_split_llstr(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::StringVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(pz_split_llstr(x));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_parzer_convert_lat", (DL_FUNC) &_parzer_convert_lat, 1},
    {"_parzer_convert_lat_old", (DL_FUNC) &_parzer_convert_lat_old, 1},
    {"_parzer_convert_lon", (DL_FUNC) &_parzer_convert_lon, 1},
    {"_parzer_convert_lon_old", (DL_FUNC) &_parzer_convert_lon_old, 1},
    {"_parzer_pz_parse_lat", (DL_FUNC) &_parzer_pz_parse_lat, 1},
    {"_parzer_pz_parse_lat_old", (DL_FUNC) &_parzer_pz_parse_lat_old, 1},
    {"_parzer_pz_parse_lon", (DL_FUNC) &_parzer_pz_parse_lon, 1},
    {"_parzer_pz_parse_lon_old", (DL_FUNC) &_parzer_pz_parse_lon_old, 1},
    {"_parzer_pz_hemisphere", (DL_FUNC) &_parzer_pz_hemisphere, 2},
    {"_parzer_split_decimal_degree", (DL_FUNC) &_parzer_split_decimal_degree, 2},
    {"_parzer_split_decimal_degree_old", (DL_FUNC) &_parzer_split_decimal_degree_old, 2},
    {"_parzer_pz_parse_parts_lat", (DL_FUNC) &_parzer_pz_parse_parts_lat, 1},
    {"_parzer_pz_parse_parts_lat_old", (DL_FUNC) &_parzer_pz_parse_parts_lat_old, 1},
    {"_parzer_pz_parse_parts_lon", (DL_FUNC) &_parzer_pz_parse_parts_lon, 1},
    {"_parzer_pz_parse_parts_lon_old", (DL_FUNC) &_parzer_pz_parse_parts_lon_old, 1},
    {"_parzer_pz_split_llstr_string", (DL_FUNC) &_parzer_pz_split_llstr_string, 1},
    {"_parzer_pz_split_llstr", (DL_FUNC) &_parzer_pz_split_llstr, 1},
    {NULL, NULL, 0}
};

RcppExport void R_init_parzer(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
