% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dms-fxns.R
\name{dms}
\alias{dms}
\alias{pz_degree}
\alias{pz_minute}
\alias{pz_second}
\alias{print.pz}
\alias{pz_d}
\alias{pz_m}
\alias{pz_s}
\alias{+.pz}
\alias{-.pz}
\alias{/.pz}
\alias{*.pz}
\title{extract degree, minutes, and seconds}
\usage{
pz_degree(lon = NULL, lat = NULL)

pz_minute(lon = NULL, lat = NULL)

pz_second(lon = NULL, lat = NULL)

\method{print}{pz}(x, ...)

pz_d(x)

pz_m(x)

pz_s(x)

\method{+}{pz}(e1, e2)

\method{-}{pz}(e1, e2)

\method{/}{pz}(e1, e2)

\method{*}{pz}(e1, e2)
}
\arguments{
\item{lon, lat}{(numeric/integer/character) one or more longitude or
latitude values. values are internally validated. only one of
lon or lat accepted}

\item{x}{(integer) an integer representing a degree, minute or second}

\item{...}{print dots}

\item{e1, e2}{objects of class pz, from using \code{pz_d()}, \code{pz_m()}, or \code{pz_s()}}
}
\value{
\code{pz_degree}: integer, \code{pz_minute}: integer, \code{pz_second}: numeric,
\code{pz_d}: numeric, \code{pz_m}: numeric, \code{pz_s}: numeric (adding/subtracting
these also gives numeric)
}
\description{
extract degree, minutes, and seconds
}
\details{
Mathematics operators are exported for \code{+}, \code{-}, \code{/}, and \code{*},
but \code{/} and \code{*} are only exported with a stop message to say it's not
supported; otherwise you'd be allow to divide degrees by minutes, leading
to nonsense.
}
\examples{
# extract parts of a coordinate value
pz_degree(-45.23323)
pz_minute(-45.23323)
pz_second(-45.23323)

pz_degree(lon = 178.23423)
pz_minute(lon = 178.23423)
pz_second(lon = 178.23423)
\dontrun{
pz_degree(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 S"))
pz_minute(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 S"))
pz_second(lat = c(45.23323, "40:25:6N", "40° 25´ 5.994 S"))

# invalid
pz_degree(445.23323)

# add or subtract
pz_d(31)
pz_m(44)
pz_s(3)
pz_d(31) + pz_m(44)
pz_d(-31) - pz_m(44)
pz_d(-31) + pz_m(44) + pz_s(59)
pz_d(31) - pz_m(44) + pz_s(59)
pz_d(-121) + pz_m(1) + pz_s(33)
unclass(pz_d(31) + pz_m(44) + pz_s(59))
}
}
