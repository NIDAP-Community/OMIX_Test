# omix-r-pathway

Pre-built R environment for pathway and gene-set analysis (GSVA, GSEA, L2P).

## Quick start

```bash
# Pull the image
singularity pull omix-r-pathway.sif docker://ghcr.io/nidap-community/omix-r-pathway:latest

# Run GSVA with built-in MSigDB
singularity exec \
  --bind /path/to/data:/data \
  --bind /path/to/output:/results \
  omix-r-pathway.sif \
  Rscript /workspace/code/main.R \
    --normalized_data /data/normalized_data.tsv \
    --sample_metadata /data/sample_metadata.tsv \
    --species Human \
    --collections_to_include "H: hallmark gene sets"
```

## What's included
R 4.4.3 with GSVA, fgsea, l2p, l2psupp, optparse, dplyr, tidyr, ggplot2, and more
MSigDB v2023.2 (Human + Mouse, all collections) baked in at /data/msigdb_v2023_2.rds

## Full documentation
See [starter-environments/r-pathway/README.md](https://github.com/NIDAP-Community/OMIX_Test/blob/main/starter-environments/r-pathway/README.md) for complete CLI options, Slurm templates, Docker usage, Code Ocean integration, and rebuild instructions.


