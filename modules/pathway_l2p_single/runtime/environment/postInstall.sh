#!/usr/bin/env bash
set -euo pipefail

Rscript - <<'RSCRIPT'
cran_packages <- c(
  "jsonlite",
  "dplyr",
  "tidyr",
  "magrittr",
  "ggplot2",
  "stringr",
  "RCurl",
  "plyr",
  "scales",
  "remotes"
)

missing_cran <- cran_packages[!vapply(cran_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_cran) > 0) {
  install.packages(missing_cran, repos = "https://cloud.r-project.org")
}

if (!requireNamespace("l2p", quietly = TRUE)) {
  remotes::install_github("ccbr/l2p")
}

if (!requireNamespace("l2psupp", quietly = TRUE)) {
  remotes::install_github("ccbr/l2psupp")
}
RSCRIPT
