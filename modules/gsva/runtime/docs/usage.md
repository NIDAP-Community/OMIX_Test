# Usage

## Overview

This document describes how to run the **OMIX GSVA** capsule in different environments:

- **Code Ocean Platform (GUI or API)**: The primary execution environment where users run this capsule through the App Panel interface or programmatically via the API. This is the recommended way for most users.
- **Local Development/Testing**: Running the capsule code locally on your machine for testing and development.
- **HPC/Container Systems**: Running the capsule as a containerized workflow on high-performance computing clusters using Singularity/Apptainer.

The capsule's entrypoint is `/code/run` (or `./run.sh`), which accepts command-line parameters, runs Gene Set Variation Analysis on expression data, and writes enrichment scores and a heatmap to `/results`.

---

## Code Ocean

**Where**: Code Ocean platform (https://poc-nci.codeocean.io or your deployment URL)
**Who**: End users running analysis through the web interface or API
**How**: Via the App Panel GUI (click "Reproducible Run" button) or programmatically via Code Ocean API

### GUI Execution (Recommended)

1. Open the capsule in Code Ocean
2. Click **"Reproducible Run"**
3. Configure parameters in the App Panel (input files, species, method, thresholds, etc.)
4. Click **Run** to execute
5. View results in the **Timeline** tab when complete

### Command-Line (Advanced)

If running directly via CLI or API, the underlying command executed is:

```bash
./run.sh \
  --normalized_data /data/normalized_data.tsv \
  --sample_metadata /data/sample_metadata.tsv \
  --pathways_database /data/pathways_database.tsv
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

The dry run executes the full pipeline on example data and verifies outputs are produced.

To run the example input directly:

```bash
./run.sh \
  --normalized_data data/example_inputs/normalized_data.tsv \
  --sample_metadata data/example_inputs/sample_metadata.tsv \
  --pathways_database data/example_inputs/pathways_database.tsv \
  --gene_column Gene \
  --sample_name_column Sample \
  --samples_to_include "A1,A2,A3,B1,B2,B3,C1,C2,C3" \
  --species Mouse \
  --database_species Mouse \
  --collections_to_include "H: hallmark gene sets" \
  --custom_pathways_database TRUE \
  --custom_species Mouse \
  --method gsva \
  --minimum_geneset_size 5 \
  --maximum_geneset_size 500
```

---

## HPC Container Run

**Where**: High-performance computing (HPC) clusters or container orchestration systems
**Who**: Advanced users running batch analyses outside Code Ocean
**How**: Execute the capsule via Singularity/Apptainer container with mounted data

Use the shared pathway image or another image that contains the packages declared by `environment/`. Bind the runtime folder into the container and run the same entrypoint:

```bash
mkdir -p results
IMAGE=/path/to/omix-r-pathway_latest.sif

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind "$PWD/results:/results" \
  "$IMAGE" \
  bash /work/run.sh \
    --normalized_data /work/data/example_inputs/normalized_data.tsv \
    --sample_metadata /work/data/example_inputs/sample_metadata.tsv \
    --pathways_database /work/data/example_inputs/pathways_database.tsv \
    --species Mouse \
    --method gsva \
    --minimum_geneset_size 5 \
    --maximum_geneset_size 500
```

Use `singularity exec` instead of `apptainer exec` on systems that still use the Singularity command name.

## Sync

This runtime should sync back only to `modules/gsva/runtime/` in the OMIX monorepo.
