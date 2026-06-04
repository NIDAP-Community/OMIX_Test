# OMIX_Test

Prototype OMIX monorepo for modular analysis modules with shared starter environments.

This repo is organized so each analysis module can be developed, tested, and released independently while sharing a small set of cached starter environments.

## Repository Layout

```text
OMIX_Test/
├── core/                     # Shared R utilities used by modules
├── starter-environments/     # Shared Docker/renv environments
├── modules/                  # Independent analysis modules
├── tests/                    # Repo-level contract tests
└── .github/workflows/        # CI for module checks and starter environments
```

## Starter Environments

| Environment | Purpose | Example modules |
| --- | --- | --- |
| `r-base` | Base R, renv, common system libraries | shared utility modules |
| `r-visualization` | Plotting and visualization packages | volcano, heatmap, PCA, Venn, tSNE/UMAP, limma stats |
| `r-pathway` | Pathway and gene-set packages | GSVA, GSEA, L2P single, L2P multi |
| `r-singlecell` | Single-cell packages | future single-cell modules |

Starter environments are intended to be built once, cached in GHCR, and referenced by module runtime builds.

## Modules

Each module owns its own code, tests, schemas, app-panel config, and runtime entrypoint. The starter environment is declared in `module.yml`.

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
- `pathway_l2p_single`
- `pathway_l2p_multi`

The first platform-ready runtime examples are:

- `modules/pathway_l2p_single/runtime/`
- `modules/pathway_l2p_multi/runtime/`

All other modules are placeholders until these L2P examples are validated in Code Ocean.

## Code Ocean Sync

Each L2P runtime bundle can be sparse-synced into a standalone Code Ocean root. The OMIX monorepo remains the source of truth, and reverse sync is guarded so Code Ocean-side edits return only to the matching module runtime directory.

See `docs/code-ocean-sync.md`.

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
4. Module-specific build/test jobs can build only the changed runtime.
5. Starter environments rebuild only when files under `starter-environments/` change.
