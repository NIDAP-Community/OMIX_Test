#!/usr/bin/env bash
set -euo pipefail

Rscript - <<'RSCRIPT'
cran_packages <- c(
  "jsonlite",
  "dplyr",
  "tidyr",
  "ggplot2",
  "ggrepel",
  "stringr"
)

missing_cran <- cran_packages[!vapply(cran_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_cran) > 0) {
  install.packages(missing_cran, repos = "https://cloud.r-project.org")
}
RSCRIPT
