# OMIX Volcano Plot

Create publication-ready volcano plots from your differential expression analysis results.

## What Does This Do?

This tool visualizes differential gene expression data as volcano plots, helping you identify significantly up-regulated and down-regulated genes at a glance. Upload your differential expression results and get beautiful, customizable plots in seconds.

## Quick Start

### Try the Example Data

1. Click **Run** without uploading any data
2. The tool will generate example volcano plots automatically
3. View your results in the `/results` folder

### Use Your Own Data

1. Prepare a CSV file with your differential expression results
2. Upload it using the **DEG Table CSV** parameter
3. Adjust thresholds and colors as needed
4. Click **Run**

## What Data Do I Need?

Your CSV file should include these three types of columns:

### 1. Gene/Feature Identifier Column
**Expected names:** `Gene`, `Feature_ID`, `FeatureID`, `gene`, `gene_id`, or any text column  
**Example:** STAT1, IRF7, ENSG00000012345

### 2. P-value Columns (one or more comparisons)
**For nominal p-values, column names should contain:** `pval`, `p_value`, or `pvalue`  
**Examples:** `Treatment_vs_Control_pval`, `GroupA-GroupB_pval`

**For adjusted p-values, column names should contain:** `adjpval`, `adj`, or `fdr`  
**Examples:** `Treatment_vs_Control_adjpval`, `GroupA-GroupB_fdr`

### 3. Log2 Fold Change Columns (matching your p-value comparisons)
**Expected patterns:** `logfc`, `log2fc`, or `log2_fold_change`  
**Examples:** `Treatment_vs_Control_logFC`, `GroupA-GroupB_log2FC`

### Column Naming Tips
- Use **consistent comparison names** across p-value and fold change columns
- The tool automatically detects columns based on these patterns (case-insensitive)
- If you have multiple comparisons (e.g., A-B, A-C, B-C), include the comparison name in each column
- Example full column names: `GeneSymbol`, `TreatmentA_vs_Control_pval`, `TreatmentA_vs_Control_adjpval`, `TreatmentA_vs_Control_logFC`

## Key Features

✨ **P-value Type Selection** - Choose between nominal or adjusted (FDR) p-values  
📊 **Auto Axis Capping** - Reduces outlier impact for better visualization  
🎨 **Custom Colors** - Personalize colors for each quadrant  
🏷️ **Smart Gene Labeling** - Automatically labels top significant genes  
📐 **Flexible Layout** - Adjust fonts, sizes, and dimensions  
🔧 **Advanced Controls** - Fine-tune thresholds, axis limits, and label spacing

## What Will I Get?

- **Volcano plot images** (PNG format, publication-ready at 300 DPI)
- **One plot per comparison** in your data
- **Automatically named files** indicating the comparison and p-value type used

## Need Help?

- **Example data included** - Just click Run to see how it works
- **App Panel tooltips** - Hover over any parameter for guidance
- **Support** - Contact your Code Ocean administrator

## Citation

If you use this tool in your research, please cite the OMIX Volcano Plot capsule and Code Ocean platform.

---

**For developers:** Technical implementation details are available in `/code/DEVELOPER.md`
