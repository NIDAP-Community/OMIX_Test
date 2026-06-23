# OMIX GSVA

Run Gene Set Variation Analysis (GSVA) on normalized expression data with curated or custom pathway databases.

## What Does This Do?

GSVA computes gene set enrichment scores per sample, producing a matrix of pathway activity that can be used for downstream clustering, visualization, or statistical testing.

## Quick Start

### Use Your Own Data

1. Upload a **normalized expression table** (genes × samples, TSV)
2. Upload a **sample metadata table** (TSV)
3. Upload a **pathways database** (TSV with columns: collection, gene_set_name, gene_symbol, species)
4. Select collections, species, and method
5. Click **Run**

## What Data Do I Need?

### 1. Normalized Expression Data
A tab-delimited table with one gene per row. First column is gene identifiers; remaining columns are sample expression values.

### 2. Sample Metadata
A tab-delimited table with at least a sample name column matching the expression column headers.

### 3. Pathways Database
A tab-delimited table with columns: `collection`, `gene_set_name`, `gene_symbol`, `species`.
The default MSigDB v2023.2 database is available as a NIDAP dataset.

## Key Features

- **Multiple methods** — GSVA, ssGSEA, z-score, PLAGE
- **Species support** — Human, Mouse, and cross-species ortholog mapping
- **Gene symbol updating** — Optional l2psupp-based gene name updates
- **Collection filtering** — Select specific MSigDB collections (H, C2, C5, etc.)
- **Heatmap output** — Automatic enrichment score heatmap

## What Will I Get?

- `gsva_results.csv` — Enrichment scores (gene sets × samples)
- `gsva_heatmap.png` — Publication-ready heatmap

## Need Help?

- Contact your Code Ocean administrator
- CCBR support: NCICCBRNIDAP@mail.nih.gov

---

**For developers:** See `code/functions/GSVA_v1.R` for the implementation.
