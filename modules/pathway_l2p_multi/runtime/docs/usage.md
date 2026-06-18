# Usage

## Code Ocean

Mount production inputs as Code Ocean data assets and run:

```bash
./run.sh --params /data/params.json --deg-table /data/deg_table.csv
```

Outputs are written to `/results`.

Code Ocean users typically launch this through the platform GUI; this command is the underlying runtime entrypoint.

## Local Dry Run

```bash
./tests/test_run_small.sh
```

The dry run validates the runtime layout, parameter JSON, DEG table columns, and result-writing behavior without calling `l2p_multi()`.

To run the example input directly:

```bash
./run.sh \
  --dry-run \
  --params data/example_inputs/params.json \
  --deg-table data/example_inputs/deg_table.csv \
  --results-dir /tmp/omix_l2p_multi_results
```

## HPC Container Run

Use a module-specific Singularity/Apptainer image, or another image that contains the packages declared by `environment/`. Bind the runtime folder into the container and run the same entrypoint:

```bash
mkdir -p /tmp/omix_l2p_multi_results
IMAGE=/path/to/omix-pathway-l2p-multi.sif

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind /tmp/omix_l2p_multi_results:/results \
  "$IMAGE" \
  bash /work/run.sh \
    --dry-run \
    --params /work/data/example_inputs/params.json \
    --deg-table /work/data/example_inputs/deg_table.csv \
    --results-dir /results
```

Use `singularity exec` instead of `apptainer exec` on systems that still use the Singularity command name.

## Sync

This runtime should sync back only to `modules/pathway_l2p_multi/runtime/` in the OMIX monorepo.
