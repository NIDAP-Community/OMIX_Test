FROM rocker/r-ver:4.5.1

LABEL org.opencontainers.image.title="OMIX Volcano Plot"
LABEL org.opencontainers.image.description="Standalone volcano plot module for HPC/local use"
LABEL org.opencontainers.image.source="https://github.com/NIDAP-Community/OMIX_Test"

RUN install2.r --error --skipinstalled \
    remotes dplyr tidyr ggplot2 ggrepel stringr optparse jsonlite

COPY code/ /code/
COPY run.sh /run.sh

WORKDIR /work
ENTRYPOINT ["bash", "/run.sh"]
