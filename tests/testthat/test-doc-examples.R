# Every example without `format` in the docs of parse_lat(), parse_lon() and
# parse_lon_lat() (including the \dontrun{} ones), written exactly as in the
# docs. Examples with `format` are in the tables of test-format.R. Keep this
# table in sync with the @examples sections.

dms <- function(d, m = 0, s = 0) d + m / 60 + s / 3600
lons <- c("45W54.2356", "181", 45, 45.234234, "-45.98739874")
lats <- c("40.123°", "40.123N74.123W", "191.89", 12, "N45 04.25764")

doc_cases <- list(
  # parse_lat()
  list(expr = quote(parse_lat("")), expected = NA_real_),
  list(
    expr = quote(parse_lat("2343 56N")),
    expected = NA_real_,
    warnings = "may be packed together"
  ),
  list(
    expr = quote(parse_lat("-91")),
    expected = NA_real_,
    warnings = "not within -90/90 range"
  ),
  list(
    expr = quote(parse_lat("95")),
    expected = NA_real_,
    warnings = "not within -90/90 range"
  ),
  list(
    expr = quote(parse_lat("asdfaf")),
    expected = NA_real_,
    warnings = "no digits detected"
  ),
  list(expr = quote(parse_lat("45")), expected = 45),
  list(expr = quote(parse_lat("-45")), expected = -45),
  list(expr = quote(parse_lat("-45.2323")), expected = -45.2323),
  list(
    expr = quote(parse_lat("-45.23232e24")),
    expected = NA_real_,
    warnings = "invalid direction letter"
  ),
  list(
    expr = quote(parse_lat("-45.23232e2")),
    expected = NA_real_,
    warnings = "invalid direction letter"
  ),
  list(expr = quote(parse_lat(1:10)), expected = as.numeric(1:10)),
  list(
    expr = quote(parse_lat(85:94)),
    expected = c(85:90, rep(NA_real_, times = 4L)),
    warnings = rep("not within -90/90 range", times = 4L)
  ),
  list(expr = quote(parse_lat("40.4183318 N")), expected = 40.4183318),
  list(expr = quote(parse_lat("40.4183318 S")), expected = -40.4183318),
  list(expr = quote(parse_lat("40 25 5.994")), expected = dms(40, 25, 5.994)),
  list(expr = quote(parse_lat("40.4183318N")), expected = 40.4183318),
  list(expr = quote(parse_lat("N40.4183318")), expected = 40.4183318),
  list(expr = quote(parse_lat("40.4183318S")), expected = -40.4183318),
  list(expr = quote(parse_lat("S40.4183318")), expected = -40.4183318),
  list(expr = quote(parse_lat("N 39 21.440")), expected = dms(39, 21.44)),
  list(expr = quote(parse_lat("S 56 1.389")), expected = -dms(56, 1.389)),
  list(
    expr = quote(parse_lat("N40°25’5.994")),
    expected = dms(40, 25, 5.994)
  ),
  list(
    expr = quote(parse_lat("40° 25´ 5.994\" N")),
    expected = dms(40, 25, 5.994)
  ),
  list(expr = quote(parse_lat("40:25:6N")), expected = dms(40, 25, 6)),
  list(expr = quote(parse_lat("40:25:5.994N")), expected = dms(40, 25, 5.994)),
  list(expr = quote(parse_lat("40d 25’ 6\" N")), expected = dms(40, 25, 6)),
  # parse_lon()
  list(expr = quote(parse_lon("")), expected = NA_real_),
  list(
    expr = quote(parse_lon("-181")),
    expected = NA_real_,
    warnings = "not within -180/360 range"
  ),
  list(
    expr = quote(parse_lon("-361")),
    expected = NA_real_,
    warnings = "not within -180/360 range"
  ),
  list(expr = quote(parse_lon("95")), expected = 95),
  list(
    expr = quote(parse_lon("asdfaf")),
    expected = NA_real_,
    warnings = "no digits detected"
  ),
  list(expr = quote(parse_lon("45")), expected = 45),
  list(expr = quote(parse_lon("-45")), expected = -45),
  list(expr = quote(parse_lon("-45.2323")), expected = -45.2323),
  list(expr = quote(parse_lon("334")), expected = 334),
  list(
    expr = quote(parse_lon("-45.23232e24")),
    expected = NA_real_,
    warnings = "invalid characters"
  ),
  list(
    expr = quote(parse_lon("-45.23232e2")),
    expected = NA_real_,
    warnings = "invalid characters"
  ),
  list(expr = quote(parse_lon("-45.23232")), expected = -45.23232),
  list(expr = quote(parse_lon(1:10)), expected = as.numeric(1:10)),
  list(expr = quote(parse_lon(85:94)), expected = as.numeric(85:94)),
  list(expr = quote(parse_lon("40.4183318 E")), expected = 40.4183318),
  list(expr = quote(parse_lon("40.4183318 W")), expected = -40.4183318),
  list(expr = quote(parse_lon("40 25 5.994")), expected = dms(40, 25, 5.994)),
  list(expr = quote(parse_lon("40.4183318W")), expected = -40.4183318),
  list(expr = quote(parse_lon("W40.4183318")), expected = -40.4183318),
  list(expr = quote(parse_lon("E40.4183318")), expected = 40.4183318),
  list(expr = quote(parse_lon("40.4183318E")), expected = 40.4183318),
  list(expr = quote(parse_lon("E 39 21.440")), expected = dms(39, 21.44)),
  list(expr = quote(parse_lon("W 56 1.389")), expected = -dms(56, 1.389)),
  list(
    expr = quote(parse_lon("E40°25’5.994")),
    expected = dms(40, 25, 5.994)
  ),
  list(
    expr = quote(parse_lon("40° 25´ 5.994\" E")),
    expected = dms(40, 25, 5.994)
  ),
  list(expr = quote(parse_lon("40:25:6E")), expected = dms(40, 25, 6)),
  list(expr = quote(parse_lon("40:25:5.994E")), expected = dms(40, 25, 5.994)),
  list(expr = quote(parse_lon("40d 25’ 6\" E")), expected = dms(40, 25, 6)),
  # parse_lon_lat()
  list(
    expr = quote(parse_lon_lat("-120.43", "49.12")),
    expected = data.frame(lon = -120.43, lat = 49.12)
  ),
  list(
    expr = quote(parse_lon_lat("-120.43", "93")),
    expected = data.frame(lon = -120.43, lat = NA_real_),
    warnings = "not within -90/90 range"
  ),
  list(
    expr = quote(parse_lon_lat("-190", "49.12")),
    expected = data.frame(lon = NA_real_, lat = 49.12),
    warnings = "not within -180/360 range"
  ),
  list(
    expr = quote(parse_lon_lat("240", "49.12")),
    expected = data.frame(lon = 240, lat = 49.12)
  ),
  list(
    expr = quote(parse_lon_lat("-190", "92")),
    expected = data.frame(lon = NA_real_, lat = NA_real_),
    warnings = c("not within -180/360 range", "not within -90/90 range")
  ),
  list(
    expr = quote(parse_lon_lat(lons, lats)),
    expected = data.frame(
      lon = c(-dms(45, 54.2356), 181, 45, 45.234234, -45.98739874),
      lat = c(40.123, NA, NA, 12, dms(45, 4.25764))
    ),
    warnings = c("invalid direction letter", "not within -90/90 range")
  )
)

test_that("every example without format in the docs gives the documented result", {
  for (case in doc_cases) {
    label <- deparse(case[["expr"]])
    res <- collect_warnings(eval(case[["expr"]]))
    expect_equal(
      res[["value"]],
      case[["expected"]],
      tolerance = 1e-9,
      label = label
    )
    expected_warnings <- if (is.null(case[["warnings"]])) {
      character(0)
    } else {
      case[["warnings"]]
    }
    expect_identical(
      length(res[["warnings"]]),
      length(expected_warnings),
      label = label
    )
    for (i in seq_along(expected_warnings)) {
      expect_match(
        res[["warnings"]][[i]],
        expected_warnings[[i]],
        label = label
      )
    }
  }
})
