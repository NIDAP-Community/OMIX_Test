# omix-r-pathway

Pre-built R environment for pathway and gene-set analysis.

```
docker pull ghcr.io/nidap-community/omix-r-pathway:latest
```

## What's included

| Category | Packages |
|---|---|
| **Base** | R 4.4.3 (from `omix-r-base`) |
| **Bioconductor** | GSVA, fgsea |
| **Pathway** | l2p 0.0-14, l2psupp 0.0-14 |
| **Data wrangling** | dplyr, tidyr, stringr, tibble, data.table, plyr |
| **Plotting** | ggplot2, scales |
| **Utilities** | optparse, BiocManager, RCurl |
| **Built-in data** | MSigDB v2023.2 at `/data/msigdb_v2023_2.rds` (Human + Mouse, all collections) |

## Modules that use this image

| Module | Description |
|---|---|
| `gsva` | Gene Set Variation Analysis |
| `pathway_gsea` | Gene Set Enrichment Analysis (preranked) |
| `pathway_l2p_single` | L2P for single comparisons |
| `pathway_l2p_multi` | L2P for multiple comparisons |

## Quick start — run GSVA

The GSVA module is at `modules/gsva/runtime/`. Mount your data and run:

```bash
docker run --rm \
  -v /path/to/your/data:/data \
  -v /path/to/output:/results \
  ghcr.io/nidap-community/omix-r-pathway:latest \
  Rscript /workspace/code/main.R \
    --normalized_data /data/normalized_data.tsv \
    --sample_metadata /data/sample_metadata.tsv \
    --species Mouse \
    --collections_to_include "MH: orthology-mapped hallmark gene sets"
```

The built-in MSigDB is used automatically when `--pathways_database` is
omitted. Supply your own file to override:

```bash
    --pathways_database /data/my_pathways.tsv
```

Results are written to `/results/gsva_results.csv` and
`/results/gsva_heatmap.png`.

### Key CLI options

| Option | Default | Description |
|---|---|---|
| `--normalized_data` | — | Expression matrix (TSV/CSV), genes in rows |
| `--sample_metadata` | — | Sample-to-group mapping (TSV/CSV) |
| `--pathways_database` | built-in MSigDB | Custom pathways file (optional) |
| `--gene_column` | `Gene` | Column containing gene names |
| `--sample_name_column` | `Sample` | Column containing sample names in metadata |
| `--species` | `Human` | Species of input data |
| `--database_species` | `Human` | Species in pathways database |
| `--collections_to_include` | `H: hallmark gene sets` | Comma-separated MSigDB collections |
| `--method` | `gsva` | Algorithm: gsva, ssgsea, zscore, plage |
| `--minimum_geneset_size` | `15` | Minimum genes in a gene set |
| `--maximum_geneset_size` | `1200` | Maximum genes in a gene set |

## Using in Code Ocean

Module Dockerfiles can reference this image directly:

```dockerfile
FROM ghcr.io/nidap-community/omix-r-pathway:latest
```

No additional package installs are needed — everything is pre-built.

## Rebuilding the image

From the repo root:

```bash
cd starter-environments/r-pathway
docker build --platform linux/amd64 -t ghcr.io/nidap-community/omix-r-pathway:latest .
docker push ghcr.io/nidap-community/omix-r-pathway:latest
```

The CI workflow `build-starter-environments.yml` rebuilds and pushes
automatically when files under `starter-environments/r-pathway/` change on
`main`.
