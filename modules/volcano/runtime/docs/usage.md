# Usage

## Code Ocean

Mount production inputs as Code Ocean data assets and run:

```bash
./run.sh --deg_table /data/deg_table.csv
```

Outputs are written to `/results`.

Code Ocean users typically launch this through the platform GUI; this command is the underlying runtime entrypoint.

## Local Dry Run

```bash
./tests/test_run_small.sh
```

The dry run validates the runtime layout, parameter JSON, DEG table columns, and result-writing behavior without calling `volcano_plot_enhanced()`.

To run the example input directly:

```bash
./run.sh \
  --deg_table data/example_inputs/deg_table.csv \
  --pvalue_type nominal \
  --column_with_feature_id Gene \
  --significance_column A-B_pval \
  --log2_fold_change_column A-B_logFC \
  --image_width 600 \
  --image_height 600 \
  --resolution_dpi_ 150
```

## HPC Container Run

Use a module-specific Singularity/Apptainer image, or another image that contains the packages declared by `environment/`. Bind the runtime folder into the container and run the same entrypoint:

```bash
mkdir -p results
IMAGE=/path/to/omix-volcano.sif

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind "$PWD/results:/results" \
  "$IMAGE" \
  bash /work/run.sh \
    --deg_table /work/data/example_inputs/deg_table.csv \
    --pvalue_type nominal \
    --column_with_feature_id Gene \
    --significance_column A-B_pval \
    --log2_fold_change_column A-B_logFC \
    --image_width 600 \
    --image_height 600 \
    --resolution_dpi_ 150
```

Use `singularity exec` instead of `apptainer exec` on systems that still use the Singularity command name.

## Sync

This runtime should sync back only to `modules/volcano/runtime/` in the OMIX monorepo.
