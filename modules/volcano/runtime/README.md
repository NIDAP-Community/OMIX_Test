# OMIX Volcano

Runtime bundle for enhanced volcano plots from a differential-expression table.

This runtime is sourced from `Volcano_Plot_Enhanced_v85.R` and runs the `volcano_plot_enhanced()` function. Production inputs should be mounted by the target execution platform. The repository includes only tiny example inputs for dry-run validation.

## Inputs

- Parameters JSON: `/data/params.json` or `--params PATH`
- DEG table CSV: `/data/deg_table.csv`, `--deg-table PATH`, or `inputs.deg_table_file` in the parameters JSON

The DEG table must include:

- feature/gene column
- one or more significance columns
- matching log2 fold-change columns

## Outputs

Files are written to `/results` in Code Ocean, or `results/` when run locally.

- one or more volcano plot files
- `run_manifest.json`

Dry-run mode writes `volcano_dry_run.json`.

## Customizing Colors

You can now customize the color of each quadrant in the volcano plot by adding these parameters to the `function_args` section of your `params.json`:

- `color_not_significant`: Color for non-significant points (default: `"gray"`)
- `color_fold_change_only`: Color for points with fold change only (default: `"orange"`)
- `color_significant_only`: Color for points with significance only (default: `"green4"`)
- `color_significant_and_fold_change`: Color for points with both significance and fold change (default: `"red3"`)

### Example

```json
"function_args": {
  ...
  "color_not_significant": "gray",
  "color_fold_change_only": "orange",
  "color_significant_only": "green4",
  "color_significant_and_fold_change": "red3"
}
```

Colors can be specified as:
- Named colors: `"red"`, `"blue"`, `"gray"`, `"green4"`, `"orange"`, etc.
- Hex codes: `"#D62828"`, `"#2A9D8F"`, etc.
- RGB: `"rgb(214, 40, 40)"`, etc.
