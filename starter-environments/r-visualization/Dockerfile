ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-visualization starter"
LABEL org.opencontainers.image.description="Visualization starter environment for OMIX modules"

RUN R -q -e " \
  install.packages('remotes', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('dplyr', version = '1.2.1', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('tidyr', version = '1.3.2', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('ggplot2', version = '3.5.1', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('ggrepel', version = '0.9.6', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('stringr', version = '1.6.0', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('optparse', version = '1.8.2', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('patchwork', version = '1.3.0', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('pheatmap', version = '1.0.12', repos = 'https://cloud.r-project.org'); \
  remotes::install_version('plotly', version = '4.10.4', repos = 'https://cloud.r-project.org') \
"

WORKDIR /workspace

