# hash:sha256:placeholder
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/r-studio:r-4.5.1-1.2204.0-rstudio-server-2025.05.1-513-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'install.packages("BiocManager")' \
    && Rscript -e 'BiocManager::install(c("GSVA", "fgsea"), ask = FALSE, update = FALSE)' \
    && Rscript -e 'install.packages("https://github.com/CCBR/l2p/raw/master/l2p_0.0-14.tar.gz", repos = NULL)' \
    && Rscript -e 'install.packages("https://github.com/CCBR/l2p/raw/master/l2psupp_0.0-14.tar.gz", repos = NULL)' \
    && Rscript -e 'remotes::install_version("dplyr", "1.2.1")' \
    && Rscript -e 'remotes::install_version("optparse", "1.8.2")' \
    && Rscript -e 'remotes::install_version("stringr", "1.6.0")' \
    && Rscript -e 'remotes::install_version("tibble", "3.2.1")'
