# Output Schema

## `l2p_single_results.csv`

CSV table returned by `l2p_single()`, filtered according to the supplied pathway and p-value parameters.

## Plot Files

The single-comparison L2P function writes separate up/down bar and bubble plot files using the configured plot path prefix.

## `run_manifest.json`

Run metadata written by the runtime wrapper:

- module name
- source template
- entry function
- parameter file path
- DEG table path
- results directory
- list of files present in results at completion
- completion timestamp
