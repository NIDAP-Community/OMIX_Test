ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-pathway starter"
LABEL org.opencontainers.image.description="Pathway analysis starter environment for OMIX modules"

RUN R -q -e "install.packages(c('BiocManager', 'data.table', 'remotes', 'dplyr', 'tidyr', 'ggplot2', 'stringr', 'scales', 'RCurl', 'plyr'), repos = 'https://cloud.r-project.org'); BiocManager::install(c('fgsea', 'GSVA'), ask = FALSE, update = FALSE)"

RUN R -q -e "remotes::install_github('ccbr/l2p'); remotes::install_github('ccbr/l2psupp')"

WORKDIR /workspace

