# L2P Single

Independent OMIX module for L2P single-comparison pathway analysis.

Starter environment: `r-pathway`

The runnable Code Ocean payload lives in `runtime/`. The module-level files here (`module.yml`, schemas, changelog, and this README) describe the OMIX module boundary in the monorepo; `runtime/README.md` is the capsule-facing user README.

## Run This Module

OMIX supports multiple execution contexts, including Code Ocean GUI capsules. The instructions below focus on code-oriented use from the GitHub repo.

These commands assume you have cloned the repo and are starting from the repository root:

```bash
git clone https://github.com/NIDAP-Community/OMIX_Test.git
cd OMIX_Test
```

### Interactive R or Notebook

Open the repository in Positron or another R-capable editor. For notebook workflows, use an R Markdown or Quarto document and keep the working directory at `modules/pathway_l2p_single/runtime`.

Install or verify the R packages for the runtime once before running interactively:

```bash
cd modules/pathway_l2p_single/runtime
bash environment/postInstall.sh
```

Use the terminal for the same shell commands shown below. For function-level debugging in an interactive R session or notebook, the main scientific function lives in:

```text
runtime/code/functions/L2P_Single_v148.R
```

Set the working directory to `modules/pathway_l2p_single/runtime` before running or sourcing runtime files interactively.

There is not currently a module-specific `renv.lock` in `runtime/`. The shared starter-environment lockfiles live under `starter-environments/`; this module's immediate interactive setup is handled by `runtime/environment/postInstall.sh`.

### Bash or Shell

From the repository root, run the local smoke test:

```bash
cd modules/pathway_l2p_single/runtime
bash tests/test_run_small.sh
```

Run the example input directly:

```bash
cd modules/pathway_l2p_single/runtime
bash run.sh \
  --dry-run \
  --params data/example_inputs/params.json \
  --deg-table data/example_inputs/deg_table.csv \
  --results-dir /tmp/omix_l2p_single_results
```

See `runtime/docs/usage.md` for runtime details.

### Singularity or Apptainer on HPC

Use a module-specific image, or another image that contains the packages declared by `runtime/environment/`. Bind the checked-out runtime into the container and run the same `run.sh` entrypoint:

```bash
cd modules/pathway_l2p_single/runtime
mkdir -p /tmp/omix_l2p_single_results

IMAGE=/path/to/omix-pathway-l2p-single.sif

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind /tmp/omix_l2p_single_results:/results \
  "$IMAGE" \
  bash /work/run.sh \
    --dry-run \
    --params /work/data/example_inputs/params.json \
    --deg-table /work/data/example_inputs/deg_table.csv \
    --results-dir /results
```

If your HPC site uses the `singularity` command name instead of `apptainer`, replace `apptainer exec` with `singularity exec`.
