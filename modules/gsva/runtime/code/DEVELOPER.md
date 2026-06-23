# OMIX GSVA - Developer Documentation

Technical implementation details for developers and maintainers.

## File Ownership Map

Each file in `runtime/` belongs to one of three ownership categories:

| Category | Description | Who uses it |
|----------|-------------|-------------|
| **Shared** | Scientific code and CLI interface used everywhere | All environments |
| **Code Ocean** | Platform-specific hooks and metadata | Code Ocean capsules only |
| **HPC / Local** | Standalone build and execution without Code Ocean | HPC clusters, laptops |

### Shared (used by all environments)

```
runtime/
├── run.sh                          # Canonical entrypoint (all environments)
├── code/
│   ├── main.R                      # CLI interface (optparse)
│   └── functions/
│       └── GSVA_v1.R               # Core scientific function
├── data/
│   └── example_inputs/             # Tiny validation data
├── docs/
│   └── usage.md                    # User-facing run instructions
└── results/                        # Output directory (gitignored except README)
```

### Code Ocean Only

```
runtime/
├── code/run                        # CO-specific entrypoint (assumes /code path)
├── environment/
│   ├── Dockerfile                  # CO image build (uses $REGISTRY_HOST base)
│   ├── postInstall.sh              # Dependency installer (also used in CI)
│   └── postinstall                 # Lowercase alias for CO platform hook
└── metadata/
    └── metadata.yml                # CO capsule metadata
```

### HPC / Local Only

```
runtime/
└── tests/
    └── test_run_small.sh           # Smoke test (runs postInstall.sh + pipeline)
```

## Runtime Environment

All pathway modules share a single container image:
`ghcr.io/nidap-community/omix-r-pathway:latest`

This image is:
- Built from `starter-environments/r-pathway/Dockerfile` (pinned package versions)
- Published to GHCR on merge to `main`
- Used by Code Ocean capsules as their runtime environment
- Pulled by HPC users via `apptainer pull`

**There is no per-module Dockerfile.** The shared image contains all packages for
all pathway modules. Module code is bind-mounted at runtime, not baked in.

### For HPC

```bash
# Pull the shared image (one time)
apptainer pull docker://ghcr.io/nidap-community/omix-r-pathway:latest

# Run GSVA
cd modules/gsva/runtime
apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind "$PWD/results:/results" \
  /path/to/omix-r-pathway_latest.sif \
  bash /work/run.sh \
    --normalized_data /data/normalized_data.tsv \
    --sample_metadata /data/sample_metadata.tsv \
    --pathways_database /data/pathways_database.tsv
```

### For Code Ocean

The `environment/Dockerfile` is a Code Ocean build artifact that installs the same
pinned packages into CO's base image. It exists for CO's build system but produces
an equivalent environment to the shared starter image.

## Running on HPC

### With the shared container

```bash
cd modules/gsva/runtime
mkdir -p results

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind /path/to/normalized_data.tsv:/data/normalized_data.tsv \
  --bind /path/to/sample_metadata.tsv:/data/sample_metadata.tsv \
  --bind /path/to/pathways_database.tsv:/data/pathways_database.tsv \
  --bind "$PWD/results:/results" \
  /path/to/omix-r-pathway_latest.sif \
  bash /work/run.sh \
    --normalized_data /data/normalized_data.tsv \
    --sample_metadata /data/sample_metadata.tsv \
    --pathways_database /data/pathways_database.tsv \
    --species Mouse \
    --method gsva \
    --minimum_geneset_size 5 \
    --maximum_geneset_size 500
```

### Without a container (module installed locally)

```bash
cd modules/gsva/runtime
bash environment/postInstall.sh   # one-time setup
bash run.sh \
  --normalized_data data/example_inputs/normalized_data.tsv \
  --sample_metadata data/example_inputs/sample_metadata.tsv \
  --pathways_database data/example_inputs/pathways_database.tsv
```

## Input Specification

### Data Inputs

Production inputs are mounted by the Code Ocean execution platform. The repository
includes only tiny example inputs for dry-run validation.

#### Normalized Expression Data (TSV)
- Location: `--normalized_data PATH` (CLI) or mounted at `/data/` (container)
- Required: A gene column and one or more numeric sample columns

#### Sample Metadata (TSV)
- Location: `--sample_metadata PATH`
- Required: A sample name column matching column names in the normalized data

#### Pathways Database (TSV)
- Location: `--pathways_database PATH`
- Required: Columns for collection, gene set name, and gene symbol
- The shared r-pathway image includes MSigDB v2023.2 at `/data/msigdb_v2023_2.rds`

## Output Specification

Files are written to `/results` in container mode, or `runtime/results/` when run locally.

### Standard Outputs
- **GSVA results CSV**: `gsva_results.csv` — enrichment scores per gene set per sample
- **Heatmap PNG**: `gsva_heatmap.png` — clustered heatmap of enrichment scores

## CLI Interface

App Panel (Code Ocean) or the command line passes parameters as CLI flags:
```bash
bash run.sh --species Mouse --method gsva --minimum_geneset_size 5 ...
```

All parameters are documented in `schemas/inputs.schema.json`.
