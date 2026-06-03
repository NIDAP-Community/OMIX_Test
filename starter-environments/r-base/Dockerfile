ARG R_VERSION=4.4.3
FROM rocker/r-ver:${R_VERSION}

LABEL org.opencontainers.image.title="OMIX r-base starter"
LABEL org.opencontainers.image.description="Base R starter environment for OMIX modules"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -q -e "install.packages(c('renv', 'jsonlite', 'yaml'), repos = 'https://cloud.r-project.org')"

WORKDIR /workspace

