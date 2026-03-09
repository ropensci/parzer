#!/usr/bin/env Rscript
#
# Compare the performance of the current parzer source tree against a past
# version identified by a git SHA.
#
# Interactive usage (after source()ing this file):
#   source("benchmarks/compare_with_ref.R")
#   result <- compare_with_ref("97de845")
#
# Command-line usage:
#   Rscript benchmarks/compare_with_ref.R <git-sha>
#
# The function:
#   1. Creates a git worktree at the requested SHA in a temp directory.
#   2. Installs both the reference and the current source into separate
#      temporary R libraries.
#   3. Runs identical bench::mark() calls for each version in isolated
#      callr subprocesses so the two library paths never interfere.
#   4. Prints a side-by-side comparison and a ratio table.
#      Ratios > 1 mean the current code is slower than the reference.
#   5. Returns a list with $time and $mem data frames (invisibly).
#      A non-zero $status element signals timing regressions.
#
# Requirements (all in Suggests or available as dev tools):
#   bench, callr, pkgbuild

# ---------------------------------------------------------------------------
# Helper: locate the package root reliably from any working directory
# ---------------------------------------------------------------------------

find_pkg_root <- function() {
  root <- tryCatch(
    rprojroot::find_package_root_file(),
    error = function(e) NULL
  )
  if (!is.null(root) && file.exists(file.path(root, "DESCRIPTION"))) {
    return(root)
  }
  wd <- normalizePath(".", mustWork = TRUE)
  if (file.exists(file.path(wd, "DESCRIPTION"))) {
    return(wd)
  }
  stop(
    "Cannot locate the package root. Either run from the package root or\n",
    "pass pkg_root= explicitly:\n",
    "  compare_with_ref('97de845', pkg_root = '/path/to/parzer')",
    call. = FALSE
  )
}

# ---------------------------------------------------------------------------
# Main comparison function
# ---------------------------------------------------------------------------

compare_with_ref <- function(ref_sha,
                             n_iter = 30L,
                             pkg_root = find_pkg_root()) {
  # 0. Validate inputs
  if (missing(ref_sha) || !nzchar(trimws(ref_sha))) {
    stop("'ref_sha' must be a non-empty git SHA string.", call. = FALSE)
  }
  ref_sha <- trimws(ref_sha)

  for (pkg in c("bench", "callr", "pkgbuild")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(
        sprintf(
          "Package '%s' is required. Install it with: install.packages('%s')",
          pkg, pkg
        ),
        call. = FALSE
      )
    }
  }

  cat(sprintf("Package root : %s\n", pkg_root))
  cat(sprintf("Reference SHA: %s\n", ref_sha))
  cat(sprintf("R version    : %s\n\n", R.version.string))

  # 1. Create a git worktree for the reference SHA
  worktree_dir <- file.path(tempdir(), paste0("parzer_ref_", ref_sha))
  on.exit(
    {
      cat("\nCleaning up worktree ...\n")
      system2(
        "git",
        c("worktree", "remove", "--force", worktree_dir),
        stdout = FALSE, stderr = FALSE
      )
      unlink(worktree_dir, recursive = TRUE)
    },
    add = TRUE
  )

  cat("Creating git worktree at", worktree_dir, "...\n")
  ret <- system2(
    "git",
    c("-C", shQuote(pkg_root), "worktree", "add", "--detach",
      shQuote(worktree_dir), ref_sha),
    stdout = "", stderr = ""
  )
  if (ret != 0L) {
    stop(
      sprintf(
        "git worktree add failed (exit code %d). Is '%s' a valid SHA?",
        ret, ref_sha
      ),
      call. = FALSE
    )
  }

  # 2. Install both versions to separate temporary libraries
  install_pkg <- function(src_dir, label) {
    lib <- file.path(tempdir(), paste0("parzer_lib_", label))
    dir.create(lib, showWarnings = FALSE)
    cat(sprintf("Building & installing %s version from %s ...\n", label, src_dir))
    pkg_file <- pkgbuild::build(
      src_dir,
      dest_path = tempdir(),
      vignettes = FALSE,
      quiet = TRUE
    )
    on.exit(unlink(pkg_file))
    install.packages(
      pkg_file,
      lib = lib,
      repos = NULL,
      type = "source",
      quiet = TRUE,
      INSTALL_opts = c("--no-multiarch", "--no-build-vignettes")
    )
    lib
  }

  ref_lib <- install_pkg(worktree_dir, paste0("ref_", ref_sha))
  cur_lib <- install_pkg(pkg_root, "current")

  # 3. Benchmark fixtures (mirror tests/testthat/test-benchmarks.R)
  bench_fixtures <- list(
    lats_96 = rep(
      c(
        "40.4183318N", "-45.23323", "N40 25 5.994",
        "40:25:5.994N", "40d 25' 6\" N", "45N54.2356"
      ),
      16L
    ),
    lats_960 = rep(
      c(
        "40.4183318N", "-45.23323", "N40 25 5.994",
        "40:25:5.994N", "40d 25' 6\" N", "45N54.2356"
      ),
      160L
    ),
    lons_96 = rep(
      c(
        "74.6411133W", "-120.5", "E74 38 28.008",
        "74:38:28W", "74d 38' 28\" W", "45W54.2356"
      ),
      16L
    ),
    lons_960 = rep(
      c(
        "74.6411133W", "-120.5", "E74 38 28.008",
        "74:38:28W", "74d 38' 28\" W", "45W54.2356"
      ),
      160L
    )
  )

  # 4. Run bench::mark in an isolated subprocess for one library path
  run_benchmarks <- function(lib_path, fixtures, n_iter = 30L) {
    callr::r(
      func = function(lib, fx, n_iter) {
        library(parzer, lib.loc = lib, quietly = TRUE)
        list(
          parse_lat_96 = bench::mark(
            parse_lat(fx$lats_96),
            iterations = n_iter, check = FALSE
          ),
          parse_lon_96 = bench::mark(
            parse_lon(fx$lons_96),
            iterations = n_iter, check = FALSE
          ),
          parse_parts_96 = bench::mark(
            parse_parts_lat(fx$lats_96),
            iterations = n_iter, check = FALSE
          ),
          parse_lat_960 = bench::mark(
            parse_lat(fx$lats_960),
            iterations = n_iter, check = FALSE
          ),
          parse_lon_960 = bench::mark(
            parse_lon(fx$lons_960),
            iterations = n_iter, check = FALSE
          ),
          parse_parts_960 = bench::mark(
            parse_parts_lat(fx$lats_960),
            iterations = n_iter, check = FALSE
          )
        )
      },
      args = list(lib = lib_path, fx = fixtures, n_iter = n_iter)
    )
  }

  cat("\nRunning benchmarks for the reference version ...\n")
  ref_bm <- run_benchmarks(ref_lib, bench_fixtures, n_iter)

  cat("Running benchmarks for the current version ...\n")
  cur_bm <- run_benchmarks(cur_lib, bench_fixtures, n_iter)

  # 5. Extract and display results
  extract_median_s <- function(bm_list, key) {
    as.numeric(median(bm_list[[key]]$time[[1L]])) # seconds
  }
  extract_mem_bytes <- function(bm_list, key) {
    as.numeric(bm_list[[key]]$mem_alloc[[1L]]) # bytes
  }
  format_time <- function(s) {
    if (s >= 1) sprintf("%.3f s", s)
    else if (s >= 1e-3) sprintf("%.2f ms", s * 1e3)
    else sprintf("%.1f \u00b5s", s * 1e6)
  }
  format_mem <- function(b) {
    if (b >= 1e6) sprintf("%.2f MB", b / 1e6)
    else if (b >= 1e3) sprintf("%.1f kB", b / 1e3)
    else sprintf("%.0f B", b)
  }

  benchmarks <- c(
    "parse_lat_96", "parse_lon_96", "parse_parts_96",
    "parse_lat_960", "parse_lon_960", "parse_parts_960"
  )
  labels <- c(
    "parse_lat(n=96)", "parse_lon(n=96)", "parse_parts_lat(n=96)",
    "parse_lat(n=960)", "parse_lon(n=960)", "parse_parts_lat(n=960)"
  )

  ref_times <- vapply(benchmarks, extract_median_s, numeric(1L), bm_list = ref_bm)
  cur_times <- vapply(benchmarks, extract_median_s, numeric(1L), bm_list = cur_bm)
  ref_mems <- vapply(benchmarks, extract_mem_bytes, numeric(1L), bm_list = ref_bm)
  cur_mems <- vapply(benchmarks, extract_mem_bytes, numeric(1L), bm_list = cur_bm)

  time_ratio <- cur_times / ref_times # > 1  -> current is SLOWER
  mem_ratio <- cur_mems / ref_mems # > 1  -> current uses MORE memory

  # -- timing table
  cat(sprintf(
    "\n%s\n%-26s  %10s  %10s  %8s  %s\n%s\n",
    strrep("=", 70),
    "Benchmark",
    sprintf("ref (%s)", substr(ref_sha, 1L, 7L)),
    "current",
    "ratio",
    "verdict",
    strrep("-", 70)
  ))
  for (i in seq_along(benchmarks)) {
    verdict <- if (time_ratio[i] > 1.20) "\u26a0\ufe0f  SLOWER"
    else if (time_ratio[i] < 0.80) "\u2705  faster"
    else "  \u2248 same"
    cat(sprintf(
      "%-26s  %10s  %10s  %8.3f  %s\n",
      labels[i],
      format_time(ref_times[i]),
      format_time(cur_times[i]),
      time_ratio[i],
      verdict
    ))
  }
  cat(strrep("=", 70), "\n")
  cat("  ratio = current / reference  |  > 1.20 flagged as slower  |  < 0.80 as faster\n")

  # -- memory table
  cat(sprintf(
    "\n%s\n%-26s  %10s  %10s  %8s\n%s\n",
    strrep("=", 70),
    "Memory allocated",
    sprintf("ref (%s)", substr(ref_sha, 1L, 7L)),
    "current",
    "ratio",
    strrep("-", 70)
  ))
  for (i in seq_along(benchmarks)) {
    cat(sprintf(
      "%-26s  %10s  %10s  %8.3f\n",
      labels[i],
      format_mem(ref_mems[i]),
      format_mem(cur_mems[i]),
      mem_ratio[i]
    ))
  }
  cat(strrep("=", 70), "\n")

  # 6. Build return value and report regressions
  result <- list(
    ref_sha = ref_sha,
    time = data.frame(
      benchmark = labels,
      ref_s = ref_times,
      cur_s = cur_times,
      ratio = time_ratio,
      stringsAsFactors = FALSE
    ),
    mem = data.frame(
      benchmark = labels,
      ref_bytes = ref_mems,
      cur_bytes = cur_mems,
      ratio = mem_ratio,
      stringsAsFactors = FALSE
    ),
    status = 0L
  )

  regressions <- labels[time_ratio > 1.20]
  if (length(regressions) > 0L) {
    cat(sprintf(
      "\nFAIL: %d benchmark(s) are >20%% slower than the reference:\n  %s\n",
      length(regressions),
      paste(regressions, collapse = "\n  ")
    ))
    result$status <- 1L
  } else {
    cat("\nPASS: no timing regressions detected.\n")
  }

  invisible(result)
}

# ---------------------------------------------------------------------------
# Command-line entry point (only runs when called via Rscript, not source())
# ---------------------------------------------------------------------------

if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L || !nzchar(trimws(args[[1L]]))) {
    stop(
      "Usage: Rscript benchmarks/compare_with_ref.R <git-sha>\n",
      "Example: Rscript benchmarks/compare_with_ref.R 97de845",
      call. = FALSE
    )
  }
  result <- compare_with_ref(args[[1L]])
  quit(status = result$status)
}
