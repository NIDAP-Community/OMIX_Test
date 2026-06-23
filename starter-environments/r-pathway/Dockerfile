ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-pathway starter"
LABEL org.opencontainers.image.description="Pathway analysis starter environment for OMIX modules"

# Note: CURL_SSL_NO_REVOKE and download.file.extra=-k work around enterprise TLS
# inspection during build only. Remove once building outside managed networks.
ENV CURL_SSL_NO_REVOKE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    zlib1g-dev libpng-dev libmagick++-dev && \
    rm -rf /var/lib/apt/lists/*

RUN R -q -e "options(download.file.method='curl', download.file.extra='-kL'); \
  install.packages(c('BiocManager', 'data.table', 'dplyr', 'tidyr', 'ggplot2', 'stringr', 'scales', 'RCurl', 'plyr', 'optparse'), repos = 'https://cloud.r-project.org'); \
  BiocManager::install(c('fgsea', 'GSVA'), ask = FALSE, update = FALSE)"

RUN curl -kL -o /tmp/l2p_0.0-14.tar.gz https://github.com/CCBR/l2p/raw/master/l2p_0.0-14.tar.gz && \
    curl -kL -o /tmp/l2psupp_0.0-14.tar.gz https://github.com/CCBR/l2p/raw/master/l2psupp_0.0-14.tar.gz && \
    R -q -e "install.packages(c('/tmp/l2p_0.0-14.tar.gz', '/tmp/l2psupp_0.0-14.tar.gz'), repos = NULL)" && \
    rm /tmp/l2p_0.0-14.tar.gz /tmp/l2psupp_0.0-14.tar.gz

# Clear the insecure download workaround for runtime
ENV CURL_SSL_NO_REVOKE=

COPY msigdb_v2023_2.rds /data/msigdb_v2023_2.rds

WORKDIR /workspace
