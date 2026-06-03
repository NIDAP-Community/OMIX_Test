ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-pathway:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-singlecell starter"
LABEL org.opencontainers.image.description="Single-cell starter environment for OMIX modules"

RUN R -q -e "install.packages(c('harmony', 'Seurat'), repos = 'https://cloud.r-project.org'); BiocManager::install(c('SingleCellExperiment'), ask = FALSE, update = FALSE)"

WORKDIR /workspace

