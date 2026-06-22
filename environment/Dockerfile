# hash:sha256:71dc8f26b2d515869dbef3931f8258dd9af8a6b74497b92be47be46fea797e0a
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite:v0.3.0.9000_ba73bcc

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("optparse")'
