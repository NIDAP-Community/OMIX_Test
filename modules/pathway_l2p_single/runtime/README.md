# OMIX L2P Single

Runtime bundle for L2P pathway enrichment from one differential-expression comparison.

This runtime is sourced from `L2P_Single_v148.R` and runs the `l2p_single()` function. Production inputs should be mounted by the target execution platform. The repository includes only tiny example inputs for dry-run validation.

## Inputs

- Parameters JSON: `/data/params.json` or `--params PATH`
- DEG table CSV: `/data/deg_table.csv`, `--deg-table PATH`, or `inputs.deg_table_file` in the parameters JSON

The DEG table must include:

- gene name column
- one rank/statistic column
- one significance column
- one fold-change column

## Outputs

Files are written to `/results` in Code Ocean, or `results/` when run locally.

- `l2p_single_results.csv`
- up/down bar and bubble plot PNG files
- `run_manifest.json`

## Run

```bash
./run.sh --params /data/params.json --deg-table /data/deg_table.csv
```

For layout and parameter validation without running the full L2P dependency stack:

```bash
./run.sh --dry-run
```
