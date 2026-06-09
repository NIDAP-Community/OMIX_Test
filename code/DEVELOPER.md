# OMIX Volcano Plot - Developer Documentation

Technical implementation details for developers and maintainers.

## Architecture

This capsule is a runtime bundle for enhanced volcano plots from differential-expression tables. It is sourced from `Volcano_Plot_Enhanced_v85.R` and runs the `volcano_plot_enhanced()` function.

### Core Components

- **Main entry point**: `/code/main.R` - CLI interface with optparse
- **Plotting function**: `/code/functions/Volcano_Plot_Enhanced_v85.R` - Core visualization logic
- **Execution script**: `/code/run` - Bash driver for reproducible runs

## Input Specification

### Data Inputs

Production inputs are mounted by the Code Ocean execution platform. The repository includes only tiny example inputs for dry-run validation.

#### Parameters JSON
- Location: `/data/params.json` or `--params PATH`
- Format: JSON with `function_args` and `inputs` sections

#### DEG Table CSV
- Location: `/data/deg_table.csv`, `--deg-table PATH`, or `inputs.deg_table_file` in params.json
- Required columns:
  - Feature/gene identifier column
  - One or more significance columns (p-values)
  - Matching log2 fold-change columns

### Column Detection Logic

The function automatically infers significance and fold-change columns using regex patterns:
- **Adjusted p-values**: Column names containing "adj" (case-insensitive)
- **Nominal p-values**: Column names matching p-value patterns but excluding "adj"
- **Log2 fold-change**: Column names matching log2FC patterns

Selection logic (`infer_significance_columns()`):
- When `pvalue_type = "adjusted"`: Prefers adjusted columns, falls back to nominal
- When `pvalue_type = "nominal"`: Prefers nominal columns, falls back to adjusted

## Output Specification

Files are written to `/results` in Code Ocean, or `results/` when run locally.

### Standard Outputs
- **Volcano plot PNG files**: Named `volcano_plot_{comparison}_{pvalue_type}.png`
- **Run manifest**: `run_manifest.json` with execution metadata

### Dry-Run Mode
- When enabled, writes `volcano_dry_run.json` instead of generating plots

## CLI Interface

### Named Parameters Mode (Current)

App Panel passes parameters as CLI flags:
```bash
/code/run --pvalue_type nominal --p_value_threshold 0.05 --log2_fold_change_threshold 1.0 ...
```

Main.R uses optparse to parse named arguments and forwards them to the plotting function.

### Available Parameters

See `option_list` in `/code/main.R` for the complete list. Key parameters:

- `--pvalue_type`: "adjusted" or "nominal" (default: "nominal")
- `--p_value_threshold`: Numeric threshold for significance
- `--log2_fold_change_threshold`: Numeric threshold for fold change
- `--use_auto_axis_capping`: "true" or "false" (default: "true")
- `--auto_axis_capping_quantile`: 0-1 (default: 0.9999)
- Font size parameters: `--plot_title_size`, `--axis_title_size`, `--axis_text_size`
- Label repel parameters: `--label_box_padding`, `--label_force`, `--label_max_overlaps`

## Color Customization

Quadrant colors are configurable via parameters:

```r
color_not_significant          # Default: "gray"
color_fold_change_only         # Default: "orange"
color_significant_only         # Default: "green4"
color_significant_and_fold_change  # Default: "red3"
```

Color formats supported:
- Named colors: `"red"`, `"blue"`, `"gray"`, `"green4"`, `"orange"`
- Hex codes: `"#D62828"`, `"#2A9D8F"`
- RGB: `"rgb(214, 40, 40)"`

## Advanced Features

### Auto Axis Capping

Controlled by `use_auto_axis_capping` and `auto_axis_capping_quantile`.

When enabled:
1. Calculates quantile-based limits for x and y axes
2. Clips extreme outliers to improve visualization
3. Optionally enforces symmetric x-axis limits

**Quantile interpretation**:
- 0.9999 = only top 0.01% outliers removed (less aggressive)
- 0.995 = top 0.5% outliers removed (more aggressive)

### Label Repulsion (ggrepel)

Controlled by three parameters:
- `label_box_padding`: Space around label boxes (default: 0.5)
- `label_force`: Repulsion strength between labels (default: 1)
- `label_max_overlaps`: Maximum overlapping labels allowed (default: 999)

Uses `ggrepel::geom_text_repel()` to prevent label overlap.

## File Structure

```
/code/
├── main.R                        # CLI entry point
├── run                           # Bash execution script
├── functions/
│   └── Volcano_Plot_Enhanced_v85.R  # Core plotting function
└── DEVELOPER.md                  # This file

/data/
└── example_deg/                  # Example input data

/results/                         # Output directory (created at runtime)
```

## Dependencies

### R Packages (CRAN)
- ggplot2
- ggrepel
- dplyr
- readr
- optparse
- stringr

### Environment
- Starter environment: R-based Code Ocean starter
- See `/environment` for full package list

## Reproducibility

### Reproducible Run Requirements
1. Use Released capsule version
2. Execute via Code Ocean reproducible run
3. Capture results as data assets

### Non-deterministic Elements
- ggrepel label placement (can vary slightly between runs)
- R random number generation (set seed if needed)

## Testing

### Quick Test
```bash
cd /code
Rscript main.R  # Uses example data by default
```

### With Custom Data
```bash
cd /code
Rscript main.R --deg_table /data/my_data.csv \
  --pvalue_type nominal \
  --p_value_threshold 0.05
```

## Maintenance Notes

### Version History
- v85: Current version with label repel controls
- Previous versions: See git history

### Known Issues
- Label placement can overlap with very high gene counts
- Auto-capping may be too aggressive for some datasets (adjust quantile)

### Future Enhancements
- Interactive plots (plotly)
- Batch processing mode
- Additional plot types (MA plots, heatmaps)

## Support

For technical issues or feature requests, contact the capsule maintainer or Code Ocean support.
