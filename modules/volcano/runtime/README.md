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
