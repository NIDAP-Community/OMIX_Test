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

Your CSV file should include:

- **Gene names** (e.g., GENE_SYMBOL, ENSEMBL_ID)
- **P-values** (nominal and/or adjusted)
- **Log2 fold changes** (e.g., log2FC)

The tool will automatically detect your column names!

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
