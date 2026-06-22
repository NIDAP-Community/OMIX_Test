# Usage

## Overview

This document describes how to run the **OMIX Volcano Plot** capsule in different environments:

- **Code Ocean Platform (GUI or API)**: The primary execution environment where users run this capsule through the App Panel interface or programmatically via the API. This is the recommended way for most users.
- **Local Development/Testing**: Running the capsule code locally on your machine for testing and development.
- **HPC/Container Systems**: Running the capsule as a containerized workflow on high-performance computing clusters using Singularity/Apptainer.

The capsule's entrypoint is `/code/run` (or `./run.sh`), which accepts command-line parameters, processes differential expression data, and generates volcano plot images in `/results`.

---

## Code Ocean

**Where**: Code Ocean platform (https://poc-nci.codeocean.io or your deployment URL)  
**Who**: End users running analysis through the web interface or API  
**How**: Via the App Panel GUI (click "Reproducible Run" button) or programmatically via Code Ocean API

### GUI Execution (Recommended)

1. Open the capsule in Code Ocean
2. Click **"Reproducible Run"** 
3. Configure parameters in the App Panel (DEG table, thresholds, colors, etc.)
4. Click **Run** to execute
5. View results in the **Timeline** tab when complete

### Command-Line (Advanced)

If running directly via CLI or API, the underlying command executed is:

```bash
./run.sh --deg_table /data/deg_table.csv
```

---

## Local Dry Run

**Where**: Your local machine or development workstation  
**Who**: Developers testing changes before committing  
**How**: Clone the capsule repository and run test scripts locally

### Quick Test

```bash
./tests/test_run_small.sh
```

The dry run executes the full pipeline on example data at reduced resolution and verifies the output PNG is produced.

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

---

## HPC Container Run

**Where**: High-performance computing (HPC) clusters or container orchestration systems  
**Who**: Advanced users running batch analyses outside Code Ocean  
**How**: Execute the capsule via Singularity/Apptainer container with mounted data

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
