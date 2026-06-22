# OMIX GSVA

Gene Set Variation Analysis (GSVA) for pathway-level expression profiling.

## What Does This Do?

GSVA transforms gene-level expression data into pathway-level scores, allowing you to assess biological pathway activity across samples. This is particularly useful for:
- Comparing pathway enrichment between conditions
- Identifying activated/suppressed biological processes
- Reducing dimensionality from thousands of genes to hundreds of pathways

## Quick Start

### Try the Example Data

1. Click **Reproducible Run** 
2. Leave all file parameters blank (will use built-in example data)
3. Click **Run**
4. View results in the Timeline tab when complete

### Use Your Own Data

1. **Prepare three input files:**
   - **Normalized Expression Data**: Genes in rows, samples in columns (TSV/CSV/RDS)
   - **Sample Metadata**: Sample annotations with sample IDs matching expression data
   - **Pathways Database** (optional): Leave blank to use MSigDB v2023.2

2. **Upload files** using the App Panel file parameters

3. **Configure settings:**
   - Select your species (Human, Mouse, etc.)
   - Choose gene set collections (e.g., "H: hallmark gene sets")
   - Adjust method and geneset size filters if needed

4. Click **Run**

## What Data Do I Need?

### 1. Normalized Expression Data (Required)
**Format:** TSV, CSV, or RDS (R data frame) with genes in rows and samples in columns

**Example structure:**
```
Gene      Sample1   Sample2   Sample3
STAT1     8.234     7.891     9.012
IRF7      5.678     6.234     5.891
MX1       7.123     6.789     7.456
```

**Requirements:**
- First column contains gene symbols
- Remaining columns are sample expression values
- Data should be normalized (log2-transformed, TPM, or FPKM)
- RDS files must contain a data frame in the same format

### 2. Sample Metadata Table (Required)
**Format:** TSV, CSV, or RDS (R data frame) with sample annotations

**Example structure:**
```
Sample      Condition   Batch
Sample1     Control     1
Sample2     Treated     1  
Sample3     Treated     2
```

**Requirements:**
- Must include a column with sample names that match expression data column names
- Can include additional metadata columns for downstream analysis
- RDS files must contain a data frame in the same format

### 3. Pathways Database (Optional)
**Default:** MSigDB v2023.2 (Human and Mouse gene sets)

**Custom format** (TSV, CSV, or RDS):
- Must include columns: `collection`, `gene_set_name`, `gene_symbol`, `species`
- One row per gene-pathway relationship
- RDS files must contain a data frame in the same format

## Key Features

🧬 **Multiple GSVA Methods** - Choose from GSVA, ssGSEA, z-score, or PLAGE algorithms  
🐭 **Multi-Species Support** - Human, Mouse, Rat, and 6 other species  
📚 **MSigDB Integration** - Built-in access to Hallmark, C2, and other MSigDB collections  
🔄 **Gene Symbol Updates** - Automatically updates outdated gene nomenclature  
🎯 **Flexible Filtering** - Set minimum/maximum geneset sizes  
📊 **Visual Output** - Generates enrichment heatmap and results table

## What Will I Get?

- **gsva_results.csv**: Enrichment scores matrix (pathways × samples)
- **gsva_heatmap.png**: Clustered heatmap visualization of pathway activity

## Understanding the Results

**GSVA Enrichment Scores:**
- Range typically from -1 to +1
- **Positive scores**: Pathway is up-regulated/activated in that sample
- **Negative scores**: Pathway is down-regulated/suppressed in that sample
- **Zero/near-zero**: Pathway shows no differential activity

**Common MSigDB Collections:**
- **H: Hallmark** - 50 well-defined biological processes
- **C2: Curated** - Gene sets from online pathway databases, publications
- **C5: Ontology** - GO terms (Biological Process, Molecular Function, Cellular Component)
- **C6: Oncogenic** - Cancer-related gene sets
- **C7: Immunologic** - Immune cell types and states

## Methods Overview

**GSVA (default)** - Non-parametric, unsupervised method calculating enrichment scores per sample  
**ssGSEA** - Single sample GSEA, rank-based enrichment  
**Z-score** - Combines Z-scores of genes in a set  
**PLAGE** - Pathway Level Analysis of Gene Expression

## Need Help?

- **Example data included** - Just click Run to see how it works
- **App Panel tooltips** - Hover over any parameter for guidance
- **Support** - Contact your Code Ocean administrator

## Citation

If you use this tool in your research, please cite:
- **GSVA**: Hänzelmann S, Castelo R, Guinney J. (2013). GSVA: gene set variation analysis for microarray and RNA-seq data. BMC Bioinformatics 14:7.
- **MSigDB**: Liberzon A, et al. (2015). The Molecular Signatures Database (MSigDB) hallmark gene set collection. Cell Systems 1(6):417-425.

---

**For developers:** Technical implementation details are available in `/code/functions/GSVA_v1.R`

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
