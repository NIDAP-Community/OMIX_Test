# Output Schema

## GSVA Results CSV

Enrichment score matrix with one row per gene set and one column per sample.

- First column: `Geneset` — gene set name
- Remaining columns: per-sample GSVA enrichment scores

## GSVA Heatmap PNG

Clustered heatmap of enrichment scores across samples and gene sets.

Dimensions are controlled by `image_width` and `image_height` parameters (in inches).
