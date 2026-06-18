ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="OMIX r-visualization starter"
LABEL org.opencontainers.image.description="Visualization starter environment for OMIX modules"

# Pin all package versions for reproducibility across CO and HPC.
# This image is the single runtime environment for all visualization modules:
# volcano, heatmap, pca, pca3d, tsne_umap, venn_diagram.
RUN Rscript -e "install.packages('remotes', repos = 'https://cloud.r-project.org')" \
    && Rscript -e "remotes::install_version('dplyr', '1.2.1')" \
    && Rscript -e "remotes::install_version('tidyr', '1.3.2')" \
    && Rscript -e "remotes::install_version('ggplot2', '3.5.1')" \
    && Rscript -e "remotes::install_version('ggrepel', '0.9.6')" \
    && Rscript -e "remotes::install_version('stringr', '1.6.0')" \
    && Rscript -e "remotes::install_version('optparse', '1.8.2')" \
    && Rscript -e "remotes::install_version('patchwork', '1.3.0')" \
    && Rscript -e "remotes::install_version('pheatmap', '1.0.12')" \
    && Rscript -e "remotes::install_version('plotly', '4.10.4')"

WORKDIR /workspace

