// Originally from: https://www.codeproject.com/Articles/15659/Longitude-Latitude-String-Parser-and-Formatter
// Code retried from: https://github.com/batela/Gaypu-Src/blob/master/ll2utm/src/llstr.cpp
//
// Program: Longitude-Latitude String
// Purpose: To provide a utility for parsing long-lat strings to a double and formatting
//         a double precision value to a long-lat string.
//
// Note:   This is not designed to hold co-ordinates for a long time,
//         just a temporary variable to parse and store it until it can be
//         transfered or streamed.
//
// Written: Jeffrey D. Bogan
// Started: Sep 20, 2006
//
// ======== LEGAL-TYPE DEMANDS ==========
// Copyright 2006 Jeffrey D. Bogan, All Rights Reserved.
// Released for public use. May not be misrepresented as belonging to anyone but
// the author. If altered in any way for business use, alterations must be
// documented so as to distinguish them from the original work.
// All header documentation should be preserved. Thank you.
//
#include <Rcpp.h>

#include "llstr.h"
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <strstream>

static const double ROUND_OFF = 0.00000001;

CLongLatString::CLongLatString()
{
  Clear();
}

CLongLatString::CLongLatString(eLongLat n)
{
  Clear();
  eLL = n;
}

CLongLatString::CLongLatString(std::string strC, eLongLat n)
{
  eLL = n;
  strCoord = strC;
  ConvertStringToDouble();
}

CLongLatString::CLongLatString(std::string strC, std::string strIF, eLongLat n)
{
  eLL = n;
  strCoord = strC;
  ConvertStringToDouble(strIF);
}

CLongLatString::CLongLatString(std::string strH, std::string strD,
                               std::string strM, std::string strS)
{
  strCoord = strH + strD;
  if (!strM.empty())
  { strCoord += std::string(" ") + strM;	}
  if (!strS.empty())
  { strCoord += std::string(" ") + strS;	}
  ConvertStringToDouble();
}

CLongLatString::CLongLatString(double dC, eLongLat n, std::string strF)
{
  eLL = n;
  dCoord = dC;
  ConvertDoubleToString(strF);
}

CLongLatString::CLongLatString(char cH, int nD, int nM, int nS,
                               std::string strF)
{
  double dSn = ParseHemisphere(cH);
  dCoord = dSn * ((double)nD + (double)nM/60.0 + (double)nS/60.0/60.0);
  ConvertDoubleToString(strF);
}

CLongLatString::CLongLatString(const CLongLatString& costr)
{
  eLL = costr.eLL;
  dCoord = costr.dCoord;
  strCoord = costr.strCoord;
}

CLongLatString& CLongLatString::operator = (CLongLatString& costr)
{
  eLL = costr.eLL;
  dCoord = costr.dCoord;
  strCoord = costr.strCoord;
  return *this;
}

CLongLatString& CLongLatString::operator = (double dC)
{
  dCoord = dC;
  ConvertDoubleToString();
  return *this;
}

CLongLatString& CLongLatString::operator = (std::string strC)
{
  strCoord = strC;
  ConvertStringToDouble();
  return *this;
}

void CLongLatString::Clear()
{
  eLL = LL_UNKNOWN;
  strCoord = "";
  dCoord = 0.0;
}

CLongLatString::operator double()
{
  return dCoord;
}

CLongLatString::operator std::string()
{
  return strCoord;
}

void CLongLatString::Set(std::string strC, std::string strIF, eLongLat n)
{
  eLL = n;
  strCoord = strC;
  ConvertStringToDouble(strIF);
}

void CLongLatString::Set(double dC, std::string strF, eLongLat n)
{
  eLL = n;
  dCoord = dC;
  ConvertDoubleToString(strF);
}

std::string CLongLatString::Format(std::string strF)
{
  ConvertDoubleToString(strF);
  return strCoord;
}

char CLongLatString::GetHemisphere()
{
  char cH = '\0';
  if (eLL == LL_LATITUDE)
  {
    if (dCoord >= 0.0)
    {	cH = 'N';	}
    else
    {	cH = 'S';	}
  }
  else
  {
    if (dCoord >= 0.0)
    {	cH = 'E';	}
    else
    {	cH = 'W';	}
  }
  return cH;
}

int CLongLatString::GetIntegerDegree()
{
  return (int)(fabs(GetDecimalDegree())+ROUND_OFF);
}

int CLongLatString::GetIntegerMinute()
{
  return (int)(GetDecimalMinute());
}

int CLongLatString::GetIntegerSecond()
{
  return (int)(GetDecimalSecond() + 0.5);	// Round the seconds off
}

double CLongLatString::GetDecimalDegree()
{
  return dCoord;
}

double CLongLatString::GetDecimalMinute()
{
  double dC = fabs(dCoord) + ROUND_OFF;
  return (dC - (double)(int)dC) * 60.0;
}

double CLongLatString::GetDecimalSecond()
{
  double dM = fabs(dCoord) * 60.0 + ROUND_OFF;
  return (dM - (double)(int)dM) * 60.0;
}

bool CLongLatString::IsLongitude()
{
  return (eLL == LL_LONGITUDE);
}

bool CLongLatString::IsLatitude()
{
  return (eLL == LL_LATITUDE);
}

bool CLongLatString::IsError()
{
  return (eLL == LL_ERROR);
}

eLongLat CLongLatString::GetLongLat()
{
  return eLL;
}


void CLongLatString::ConvertStringToDouble(std::string strIF)
{
  using namespace std;
  int i, n = 0, nL, nH;
  char cH, cF, cC;
  double dSn = 1.0;
  double dDeg = 0.0, dMin = 0.0, dSec = 0.0;
  int nDDeg = 0, nDMin = 0, nDSec = 0;
#ifdef LONG_LAT_STRING_ERROR_CHECK
  if (strCoord.empty())
  {	eLL = LL_ERROR;	dCoord = 0.0;	return;	}
#endif
  if (strIF.empty())
  {
    nH = strCoord.find_first_of("NSEW", 0);
    if (nH != string::npos)
    {
      cH = strCoord[nH];
      dSn = ParseHemisphere(cH);
    }
    else	// check to see if the first non space is a negative sign
    {
      nH = strCoord.find_first_not_of(" \t", 0);
      if (nH != string::npos)
      {
        if (strCoord[nH] == '-')
        {	dSn = -1.0;	}
      }
    }
    n = 0;
    dDeg = ParseFloat(n);
    dMin = ParseFloat(n);
    dSec = ParseFloat(n);
  }
  else
  {
    nL = strIF.length();
    if (strCoord.length() < strIF.length())
    {	nL = strCoord.length();	}
    for (i=0; i<nL; i++)
    {
      cF = strIF[i];
      cC = strCoord[i];
      if (cF == 'H' || cF == 'h')
      {	dSn = ParseHemisphere(cC);	}
      else if (cF == 'D')
      {	ParseDigit(cC, dDeg, nDDeg, false);	}
      else if (cF == 'd')
      {	ParseDigit(cC, dDeg, nDDeg, true);	}
      else if (cF == 'M')
      {	ParseDigit(cC, dMin, nDMin, false);	}
      else if (cF == 'm')
      {	ParseDigit(cC, dMin, nDMin, true);	}
      else if (cF == 'S')
      {	ParseDigit(cC, dSec, nDSec, false);	}
      else if (cF == 's')
      {	ParseDigit(cC, dSec, nDSec, true);	}
    }
  }
  dCoord = dSn * (dDeg + dMin/60.0 + dSec/60.0/60.0);
#ifdef LONG_LAT_STRING_ERROR_CHECK
  CheckRange(dDeg, 0.0, 180.0);
  CheckRange(dMin, 0.0, 60.0);
  CheckRange(dSec, 0.0, 60.0);
#endif
}

void CLongLatString::ParseDigit(char cC, double& dD, int& nD, bool bDec)
{
  double d;
  if (cC <= '9' && cC >= '0')
  {
    d = (double)(cC-'0');
    if (!bDec)
    {
      dD *= 10.0;
      dD += d;
    }
    else
    {	dD += pow(10.0, --nD) * d;	}
  }
}

double CLongLatString::ParseHemisphere(char cH)
{
  if (cH == 'N')
  {
    eLL = LL_LATITUDE;
    return 1.0;
  }
  else if (cH == 'S')
  {
    eLL = LL_LATITUDE;
    return -1.0;
  }
  else if (cH == 'E')
  {
    eLL = LL_LONGITUDE;
    return 1.0;
  }
  else if (cH == 'W')
  {
    eLL = LL_LONGITUDE;
    return -1.0;
  }
  return 1.0;
}

double CLongLatString::ParseFloat(int& n)
{
  using namespace std;
  int n1, n2;
  string strFloat;
  double dD = 0.0;
  if (n < strCoord.length())
  {
    n1 = strCoord.find_first_of("0123456789.", n);
    if (n1 != string::npos)
    {
      n2 = strCoord.find_first_not_of("0123456789.", n1);
      if (n2 == string::npos)
      {	n2 = strCoord.length()+1;	}
      strFloat = strCoord.substr(n1, n2-n1);
      dD = atof(strFloat.c_str());
      n = n2;
    }
    else
    {	n = strCoord.length();	}
  }
  return dD;
}

void CLongLatString::ConvertDoubleToString(std::string strF)
{
  using namespace std;
  int n1 = 0;
  int n2 = 0;
  int np, nL;
  string strP, strS;
  ostrstream ostrmR;
  char sFloat[128] = "";
  char sForm[128] = "";
  char cP;
#ifdef LONG_LAT_STRING_ERROR_CHECK
  if (CheckRange(dCoord, -180.0, 180.0))
  {	return;	}
#endif
  if (strF.empty())
  {	strF = DEFAULT_COORD_FORMAT;	}
  do
  {
    n1 = n2;
    n2 = strF.find_first_of('%', n2);
    if (n2 != string::npos)
    {
      if (n2-n1 > 0)
      {	ostrmR << strF.substr(n1, n2-n1);	}
      if (n2 < strF.length()-1)
      {
        np = strF.find_first_of("HDMSChdmsc%", n2+1);
        if (np != string::npos && np > n2)
        {
          cP = strF[np];
          if (cP == '%')
          {	ostrmR << "%";	}
          else if (cP == 'H' || cP == 'h')
          {	ostrmR << GetHemisphere();	}
          else if (cP == 'C' || cP == 'D' || cP == 'M' || cP == 'S')
          {
            strP = strF.substr(n2, np+1-n2);
            strcpy(sForm, strP.c_str());
            sFloat[0] = '\0';
            nL = strlen(sForm);
            if (nL > 1)
            {
              sForm[nL-1] = 'd';
              if (cP == 'D')
              {	snprintf(sFloat, 127, sForm, GetIntegerDegree());	}
              else if (cP == 'C')
              {	snprintf(sFloat, 127, sForm, (int)dCoord);	}
              else if (cP == 'M')
              {	snprintf(sFloat, 127, sForm, GetIntegerMinute());	}
              else if (cP == 'S')
              {	snprintf(sFloat, 127, sForm, GetIntegerSecond());	}
              ostrmR << sFloat;
            }
          }
          else
          {
            strP = strF.substr(n2, np+1-n2);
            strcpy(sForm, strP.c_str());
            sFloat[0] = '\0';
            nL = strlen(sForm);
            if (nL > 1)
            {
              sForm[nL-1] = 'f';
              if (cP == 'd')
              {	snprintf(sFloat, 127, sForm, fabs(dCoord));	}
              else if (cP == 'c')
              {	snprintf(sFloat, 127, sForm, dCoord);	}
              else if (cP == 'm')
              {	snprintf(sFloat, 127, sForm, GetDecimalMinute());	}
              else if (cP == 's')
              {	snprintf(sFloat, 127, sForm, GetDecimalSecond());	}
              ostrmR << sFloat;
            }
          }
        }
        else
        {	ostrmR << strF.substr(n2, strF.length()-n2);	}
        if (np != string::npos)
        {	n2 = np+1;	}
        else
        {	n2 = string::npos;	}
      }
    }
    else
    {
      if (n1 < strF.length())
      {	ostrmR << strF.substr(n1, strF.length()-n1);	}
    }
  }
  while (n2 != string::npos && n2 < strF.length());
  ostrmR << '\0' << '\0';
  strCoord = ostrmR.str();
}

bool CLongLatString::CheckRange(double d, double dLo, double dHi)
{
  if (d < dLo || d > dHi)
  {
    eLL = LL_ERROR;
    strCoord = "";
    dCoord = 0.0;
  }
  return IsError();
}
