// Originally from: https://www.codeproject.com/Articles/15659/Longitude-Latitude-String-Parser-and-Formatter
// Code retried from: https://github.com/batela/Gaypu-Src/blob/master/ll2utm/include/llstr.h
// Code below has not been modified from the version at batela/Gaypu-Src
//
// Program: Long-Lat String
// Purpose: To provide a utility for parsing longitudes and latitudes in their many
//         and varied string formats.
//
// Note:   This is not designed to hold co-ordinates
//         just a temporary variable to parse and store it until it can be
//         transfered or streamed.
//
// Author:  Jeffrey D. Bogan
// E-Mail:  jbogan@stransim.com
// Started: Sep 20, 2006
// Updated: Sep 22, 2006 - Removed redundent InFormat, fixed GetHemisphere,
//         Changed Set method, increased the comments in the header
// Updated: Sep 23, 2006 - Fixed ParseDigit, Changed Set method again.
//
// Output Format:
//   %H hemisphere - single character of N,S,E,W
//   %C integer degrees, may be negative or positive
//   %c decimal degrees, may be negative or positive
//   %D integer degrees, always positive
//   %d decimal degrees, always positive
//   %M integer degrees, always positive
//   %m decimal minutes, always positive
//   %S integer seconds, always positive, rounded
//   %s decimal seconds, always positive
//   %% for %
//
// Standard C formats may be used e.g. %03D to create leading zeroes for
// degrees or %.5m to write decimal minutes out five places
//
// East is positive, West is negative, North is positive, South is negative
//
// Input Format
// is different e.g. // "HDD MM.mmmmm"	for "N45 04.25764"
// for most case in which the degrees, minute, seconds are separated
// by any whitespace, default formatting should work (strFormat = "")
//
// ======== LEGAL-TYPE DEMANDS ==========
// Copyright 2006 Jeffrey D. Bogan, All Rights Reserved.
// Released for public use. May not be misrepresented as belonging to anyone but
// the author. If altered in any way for business use, alterations must be
// documented so as to distinguish them from the original work.
// All header documentation must be preserved. Thank you.
//

#ifndef __LONG_LAT_STRING__
#define __LONG_LAT_STRING__

#include <string>
#include <strings.h>
#include <string.h>



enum eLongLat	{	LL_UNKNOWN, LL_LONGITUDE, LL_LATITUDE, LL_ERROR	};
const static std::string DEFAULT_COORD_FORMAT = "%H%D %m";
#define LONG_LAT_STRING_ERROR_CHECK	// Comment this out to remove error checking from the code - this is mostly range checking

class CLongLatString
{
  eLongLat eLL;					// Longitude or Latitude, used for error flag as well.
  std::string strCoord;	// Original String or Last Converted Double.
  double dCoord;				// Decimal Degrees.
public :
  CLongLatString();	// Default Constructor
  CLongLatString(eLongLat n);	// Constructor to define it as a longitude or latitude with the value to be defined later
  CLongLatString(std::string strC, eLongLat n=LL_UNKNOWN);	// String Construction
  CLongLatString(std::string strC, std::string strIF, eLongLat n=LL_UNKNOWN);	// String construction with a specific input format
  CLongLatString(std::string strH, std::string strD,	// String construction with separate strings for each term
                 std::string strM, std::string strS = "");
  CLongLatString(char cH, int nD, int nM, int nS, std::string strF="");	// Integer construction with separate integers for each term, has an optional output format
  CLongLatString(double dC, eLongLat n, std::string strF="");	// Double prec. construction, must specify LL_LONGITUDE or LL_LATITUDE, has an optional output format
  CLongLatString(const CLongLatString& costr);	// Copy constructor
  void Clear();	// Zero's the values and sets the string to empty
  operator double();	// Conversion operator for double
  operator std::string();	// Conversion operator for string
  CLongLatString& operator = (CLongLatString& costr);	// Standard Assignment operator
  CLongLatString& operator = (double dC);	// Assignment operator for double - need to be told in a previous method if the value is a longitude or latitude.
  CLongLatString& operator = (std::string strC);	// Assignment operator for string
  std::string Format(std::string strF);	// Output format. See header for more information.
  void Set(std::string strC, std::string strIF="", eLongLat n=LL_UNKNOWN);	// For more control over the asignment to a string with an input format - see header
  void Set(double dC, std::string strF="", eLongLat n=LL_UNKNOWN);	// Sets a value to a double, similar to asignment with a double but with an important ability to control the output format and longitude/latitude identity
  eLongLat GetLongLat();	// Gets the enum for Longitude / Latitude
  void SetLongLat(eLongLat eLL);	// Sets the enum for Longitude / Latitude
  char GetHemisphere();	// Returns a character for the hemisphere, or null character if this is indeterminent
  int GetIntegerDegree();	// Returns integer portion of degrees - always positive
  int GetIntegerMinute();	// Returns integer portion of minutes - always positive
  int GetIntegerSecond();	// Returns integer portion of seconds - always positive, extra step of rounding is taken
  double GetDecimalDegree();	// Returns decimal degrees, or essentially just the double value, can be positive or negative
  double GetDecimalMinute();	// Returns positive decimal minutes portion, range of (0 to 60)
  double GetDecimalSecond();	// Returns positive decimal seconds portion, range of (0 to 60)
  bool IsLongitude();	// returns true if contained value is longitude
  bool IsLatitude();	// returns true if contained value is longitude
  bool IsError();	// returns true if an error occured when parsing the string data, or the double is out of range
private :
  void ConvertStringToDouble(std::string strF = "");
  void ConvertDoubleToString(std::string strF = "");
  void ParseDigit(char cC, double& dD, int& nD, bool bDec);
  double ParseFloat(int& n);
  double ParseHemisphere(char cH);
  bool CheckRange(double d, double dLo, double dHi);
};

#endif
