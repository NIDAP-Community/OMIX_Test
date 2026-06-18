ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-visualization starter"
LABEL org.opencontainers.image.description="Visualization starter environment for OMIX modules"

RUN R -q -e "install.packages(c('dplyr', 'ggplot2', 'ggrepel', 'patchwork', 'pheatmap', 'plotly'), repos = 'https://cloud.r-project.org')"

WORKDIR /workspace

