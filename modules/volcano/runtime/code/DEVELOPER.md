# OMIX Volcano Plot - Developer Documentation

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
│       └── Volcano_Plot_Enhanced.R # Core scientific function
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

All visualization modules share a single container image:
`ghcr.io/nidap-community/omix-r-visualization:latest`

This image is:
- Built from `starter-environments/r-visualization/Dockerfile` (pinned package versions)
- Published to GHCR on merge to `main`
- Used by Code Ocean capsules as their runtime environment
- Pulled by HPC users via `apptainer pull`

**There is no per-module Dockerfile.** The shared image contains all packages for
all visualization modules. Module code is bind-mounted at runtime, not baked in.

### For HPC

```bash
# Pull the shared image (one time)
apptainer pull docker://ghcr.io/nidap-community/omix-r-visualization:latest

# Run volcano
cd modules/volcano/runtime
apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind "$PWD/results:/results" \
  /path/to/omix-r-visualization_latest.sif \
  bash /work/run.sh --deg_table /data/input.csv
```

### For Code Ocean

The `environment/Dockerfile` is a Code Ocean build artifact that installs the same
pinned packages into CO's base image. It exists for CO's build system but produces
an equivalent environment to the shared starter image.

## Running on HPC

### With the shared container

```bash
cd modules/volcano/runtime
mkdir -p results

apptainer exec --cleanenv \
  --bind "$PWD:/work" \
  --bind /path/to/deg_results.csv:/data/input.csv \
  --bind "$PWD/results:/results" \
  /path/to/omix-r-visualization_latest.sif \
  bash /work/run.sh \
    --deg_table /data/input.csv \
    --pvalue_type adjusted \
    --significance_column Treatment_vs_Control_adjpval \
    --log2_fold_change_column Treatment_vs_Control_logFC \
    --image_width 3000 \
    --image_height 3000 \
    --resolution_dpi_ 300
```

### Without a container (module installed locally)

```bash
cd modules/volcano/runtime
bash environment/postInstall.sh   # one-time setup
bash run.sh --deg_table /path/to/deg_results.csv
```

## Input Specification

### Data Inputs

Production inputs are mounted by the Code Ocean execution platform. The repository
includes only tiny example inputs for dry-run validation.

#### DEG Table CSV
- Location: `--deg_table PATH` (CLI) or mounted at `/data/` (container)
- Required columns:
  - Feature/gene identifier column
  - One or more significance columns (p-values)
  - Matching log2 fold-change columns

### Column Detection Logic

The function automatically infers significance and fold-change columns using regex patterns:
- **Adjusted p-values**: Column names containing "adj" (case-insensitive)
- **Nominal p-values**: Column names matching p-value patterns but excluding "adj"
- **Log2 fold-change**: Column names matching log2FC patterns

Selection logic (`infer_significance_columns()`):
- When `pvalue_type = "adjusted"`: Prefers adjusted columns, falls back to nominal
- When `pvalue_type = "nominal"`: Prefers nominal columns, falls back to adjusted

## Output Specification

Files are written to `/results` in container mode, or `runtime/results/` when run locally.

### Standard Outputs
- **Volcano plot PNG files**: Named `volcano_plot_{comparison}.png`

## CLI Interface

App Panel (Code Ocean) or the command line passes parameters as CLI flags:
```bash
bash run.sh --pvalue_type nominal --p_value_threshold 0.05 --log2_fold_change_threshold 1.0 ...
```

All parameters are documented in `schemas/inputs.schema.json`.
