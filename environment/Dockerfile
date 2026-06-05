# hash:sha256:2db5b6f9141e890bde1df4ecd0575fe09c08db2870dc6095fc99b17083f7e705
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/r-studio:r-4.5.1-1.2204.0-rstudio-server-2025.05.1-513-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("dplyr", "1.2.1")' \
    && Rscript -e 'remotes::install_version("ggrepel", "0.9.6")' \
    && Rscript -e 'remotes::install_version("ggplot2", "3.5.1")' \
    && Rscript -e 'remotes::install_version("jsonlite", "2.0.0")' \
    && Rscript -e 'remotes::install_version("optparse", "1.8.2")' \
    && Rscript -e 'remotes::install_version("stringr", "1.6.0")' \
    && Rscript -e 'remotes::install_version("tidyr", "1.3.2")'
