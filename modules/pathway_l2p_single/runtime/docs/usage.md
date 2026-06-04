# Usage

## Code Ocean

Mount production inputs as Code Ocean data assets and run:

```bash
./run.sh --params /data/params.json --deg-table /data/deg_table.csv
```

Outputs are written to `/results`.

## Local Dry Run

```bash
./tests/test_run_small.sh
```

The dry run validates the runtime layout, parameter JSON, DEG table columns, and result-writing behavior without calling `l2p_single()`.

## Sync

This runtime should sync back only to `modules/pathway_l2p_single/runtime/` in the OMIX monorepo.
