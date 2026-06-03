ARG BASE_IMAGE=ghcr.io/your-org/omix-r-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-pathway starter"
LABEL org.opencontainers.image.description="Pathway analysis starter environment for OMIX modules"

RUN R -q -e "install.packages(c('BiocManager', 'data.table'), repos = 'https://cloud.r-project.org'); BiocManager::install(c('fgsea', 'GSVA'), ask = FALSE, update = FALSE)"

WORKDIR /workspace

