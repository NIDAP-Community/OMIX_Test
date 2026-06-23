# omix-r-visualization

Pre-built R environment for plotting and visualization modules (volcano, heatmap, PCA, Venn, tSNE/UMAP, limma stats).

## Quick start

```bash
# Pull the image
singularity pull omix-r-visualization.sif docker://ghcr.io/nidap-community/omix-r-visualization:latest

# Run the volcano module
singularity exec \
  --bind /path/to/data:/data \
  --bind /path/to/output:/results \
  omix-r-visualization.sif \
  Rscript /workspace/code/main.R \
    --deg_table /data/deg_results.csv
```

## Full documentation
See [starter-environments/r-pathway/README.md](https://github.com/NIDAP-Community/OMIX_Test/blob/main/starter-environments/r-pathway/README.md) for complete CLI options, Slurm templates, Docker usage, Code Ocean integration, and rebuild instructions.


