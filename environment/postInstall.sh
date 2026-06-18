#!/usr/bin/env bash
set -euo pipefail

# Install R packages with versions matching the Dockerfile for reproducibility.
Rscript - <<'RSCRIPT'
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

required <- list(
  jsonlite = "2.0.0",
  dplyr    = "1.2.1",
  tidyr    = "1.3.2",
  ggplot2  = "3.5.1",
  ggrepel  = "0.9.6",
  stringr  = "1.6.0",
  optparse = "1.8.2"
)

for (pkg in names(required)) {
  ver <- required[[pkg]]
  if (!requireNamespace(pkg, quietly = TRUE) ||
      packageVersion(pkg) != ver) {
    remotes::install_version(pkg, version = ver, repos = "https://cloud.r-project.org")
  }
}
RSCRIPT
