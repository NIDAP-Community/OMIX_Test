#!/usr/bin/env bash
set -euo pipefail

# Install or verify R packages needed by the GSVA module.
# The shared r-pathway starter image should already have these;
# this script fills any gaps when running outside the container.
Rscript - <<'RSCRIPT'
cran_packages <- c(
  "optparse",
  "dplyr",
  "stringr",
  "tibble",
  "remotes"
)

bioc_packages <- c("GSVA", "fgsea")

missing_cran <- cran_packages[!vapply(cran_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_cran) > 0) {
  install.packages(missing_cran, repos = "https://cloud.r-project.org")
}

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}
missing_bioc <- bioc_packages[!vapply(bioc_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_bioc) > 0) {
  BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
}

if (!requireNamespace("l2psupp", quietly = TRUE)) {
  remotes::install_github("ccbr/l2psupp")
}
RSCRIPT
