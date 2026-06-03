# OMIX_Test

Prototype OMIX monorepo for modular analysis capsules with shared starter environments.

This repo is organized so each analysis module can be developed, tested, and released independently while sharing a small set of cached starter environments.

## Repository Layout

```text
OMIX_Test/
├── core/                     # Shared R utilities used by modules
├── starter-environments/     # Shared Docker/renv environments
├── modules/                  # Independent module capsules
├── tests/                    # Repo-level contract tests
└── .github/workflows/        # CI for module checks and starter environments
```

## Starter Environments

| Environment | Purpose | Example modules |
| --- | --- | --- |
| `r-base` | Base R, renv, common system libraries | shared utility modules |
| `r-visualization` | Plotting and visualization packages | volcano, heatmap, PCA, Venn, tSNE/UMAP, limma stats |
| `r-pathway` | Pathway and gene-set packages | GSVA, GSEA, L2P |
| `r-singlecell` | Single-cell packages | future single-cell modules |

Starter environments are intended to be built once, cached in GHCR, and referenced by module capsule builds.

## Modules

Each module owns its own code, tests, schemas, app-panel config, and capsule entrypoint. The starter environment is declared in `module.yml`.

Current starter modules:

- `volcano`
- `heatmap`
- `pca`
- `pca3d`
- `venn_diagram`
- `tsne_umap`
- `stats_limma`
- `pathway_gsva`
- `pathway_gsea`
- `pathway_l2p`

## Module Contract

Every module should contain:

```text
modules/<module>/
├── R/
├── tests/
├── schemas/
├── app-panel/
├── code/
├── module.yml
├── README.md
└── CHANGELOG.md
```

See `docs/module-contract.md` for the expected manifest fields.

## Local Checks

Validate the current scaffold with:

```bash
Rscript tests/test-module-contract.R
```

## Development Flow

1. Edit one module under `modules/<module>/`.
2. Commit and push.
3. CI validates the module contract and reports changed modules.
4. Module-specific build/test jobs can build only the changed capsule.
5. Starter environments rebuild only when files under `starter-environments/` change.

