# Volcano

Independent OMIX module for volcano plots.

Starter environment: `r-visualization`

The runnable Code Ocean payload lives in `runtime/`. The module-level files here (`module.yml`, schemas, changelog, and this README) describe the OMIX module boundary in the monorepo; `runtime/README.md` is the capsule-facing user README.

## Run This Module

OMIX supports multiple execution contexts, including Code Ocean GUI capsules. The instructions below focus on code-oriented use from the GitHub repo.

These commands assume you have cloned the repo and are starting from the repository root:

```bash
git clone https://github.com/NIDAP-Community/OMIX_Test.git
cd OMIX_Test
```

### Interactive R or Notebook

Open the repository in Positron or another R-capable editor. For notebook workflows, use an R Markdown or Quarto document and keep the working directory at `modules/volcano/runtime`.

Install or verify the R packages for the runtime once before running interactively:

```bash
cd modules/volcano/runtime
bash environment/postInstall.sh
```

Use the terminal for the same shell commands shown below. For function-level debugging in an interactive R session or notebook, the main scientific function lives in:

```text
runtime/code/functions/Volcano_Plot_Enhanced.R
```

Set the working directory to `modules/volcano/runtime` before running or sourcing runtime files interactively.

There is not currently a module-specific `renv.lock` in `runtime/`. The shared starter-environment lockfiles live under `starter-environments/`; this module's immediate interactive setup is handled by `runtime/environment/postInstall.sh`.

### Bash or Shell

From the repository root, run the local smoke test:

```bash
cd modules/volcano/runtime
bash tests/test_run_small.sh
```

Run the example input directly:

```bash
cd modules/volcano/runtime
bash run.sh \
  --deg_table data/example_inputs/deg_table.csv \
  --pvalue_type nominal \
  --column_with_feature_id Gene \
  --significance_column A-B_pval \
  --log2_fold_change_column A-B_logFC \
  --image_width 600 \
  --image_height 600 \
  --resolution_dpi_ 150
```

Generated outputs are written to `runtime/results/` locally. See `runtime/docs/usage.md` for runtime details.

### Singularity or Apptainer on HPC

All visualization modules share the `r-visualization` runtime environment. Pull it once and reuse across modules:

```bash
# Pull the shared environment (one time)
apptainer pull docker://ghcr.io/nidap-community/omix-r-visualization:latest
```

Then bind-mount the module code and your data into the container:

```bash
cd modules/volcano/runtime
mkdir -p results

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind /path/to/your/deg_results.csv:/data/input.csv \
  --bind "$PWD/results:/results" \
  /path/to/omix-r-visualization_latest.sif \
  bash /work/run.sh \
    --deg_table /data/input.csv \
    --pvalue_type adjusted \
    --image_width 3000 \
    --image_height 3000 \
    --resolution_dpi_ 300
```

To run the included example data:

```bash
cd modules/volcano/runtime
mkdir -p results

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind "$PWD/results:/results" \
  /path/to/omix-r-visualization_latest.sif \
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

If your HPC site uses the `singularity` command name instead of `apptainer`, replace `apptainer exec` with `singularity exec`.

> **Note:** The same `omix-r-visualization` image is used by Code Ocean capsules, ensuring identical results between CO and HPC runs.
