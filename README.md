# OMIX_Test

Prototype OMIX monorepo for modular analysis modules with shared starter environments.

This repo is organized so each analysis module can be developed, tested, and released independently while sharing a small set of cached starter environments.

## Repository Layout

```text
OMIX_Test/
├── core/                     # Shared scientific R utilities used by modules
├── starter-environments/     # Shared Docker/renv environments
├── modules/                  # Independent analysis modules
├── scripts/                  # Repo sync and governance automation
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

Each module owns its own scientific code, tests, schemas, and runtime entrypoint. The starter environment is declared in `module.yml`.

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

- `modules/volcano/runtime/`
- `modules/pathway_l2p_single/runtime/`
- `modules/pathway_l2p_multi/runtime/`

All other modules are placeholders until these first examples are validated in Code Ocean.

## Running Platform-Ready Modules

Platform-ready modules keep their runnable payload under `runtime/`. OMIX is intended to support multiple execution contexts, including Code Ocean GUI capsules, interactive R work, shell execution, and HPC containers. For code-oriented runs, start from the module README:

- `modules/volcano/README.md`
- `modules/pathway_l2p_single/README.md`
- `modules/pathway_l2p_multi/README.md`

If you do not already have the repository locally, clone it first:

```bash
git clone https://github.com/NIDAP-Community/OMIX_Test.git
cd OMIX_Test
```

Each module README documents three non-CO run modes:

- Interactive R or notebook work, such as Positron, R Markdown, or Quarto.
- Shell execution with `bash run.sh`.
- HPC/container execution with Singularity or Apptainer.

For bare R or notebook use, install the module's R dependencies before running examples. Platform-ready modules currently declare this setup in `modules/<module>/runtime/environment/postInstall.sh`. Shared `renv.lock` files live under `starter-environments/`, but there is not yet a populated per-module `renv.lock` inside each `runtime/` folder.

The common shell smoke-test pattern is:

```bash
cd modules/<module>/runtime
bash tests/test_run_small.sh
```

The module README gives exact commands for example inputs and points to `runtime/docs/usage.md` for fuller runtime details.

## Code Ocean Sync

Each runtime bundle can be layout-projected into a standalone Code Ocean root. The OMIX monorepo remains the source of truth, and reverse sync is guarded so Code Ocean-side edits return only to the matching module runtime directory.

See:

- `docs/code-ocean-sync.md` for the step-by-step sync workflow
- `docs/ci-workflows.md` for the current GitHub Actions workflow reference
- `docs/github-sync-flow.mmd` for the high-level local-machine vs Code Ocean GitHub sync flow
- `docs/code-ocean-sync-flow.mmd` for the Mermaid/Lucidchart diagram

## Module Contract

Every module should contain:

```text
modules/<module>/
├── R/
├── tests/
├── schemas/
├── module.yml
├── README.md
└── CHANGELOG.md
```

See `docs/module-contract.md` for the expected manifest fields. The executable entrypoint is declared in `module.yml`; platform-ready modules usually point to `runtime/run.sh`.

## Module Versioning

Each module declares a SemVer `version:` in `module.yml`. CI validates the version format and checks that release-impacting module changes update both `module.yml` and the module's `CHANGELOG.md`.

Release-impacting changes include files under `R/`, `code/`, `runtime/`, `schemas/`, and `module.yml`. Docs-only and tests-only changes do not require a version bump.

Use namespaced tags for monorepo module releases, for example `volcano/v0.1.0`.

## Local Checks

Validate the current scaffold with:

```bash
Rscript tests/test-module-contract.R
```

Repo governance helpers live under `scripts/lib/`, keeping `core/` reserved for scientific/runtime package code.

For PR-style versioning checks, compare the current branch against the intended base ref:

```bash
Rscript scripts/check_module_versioning.R origin/main
```

## Development Flow

1. Edit one module under `modules/<module>/`.
2. Commit and push.
3. CI validates the module contract and reports changed modules.
4. Module-specific build/test jobs can build only the changed runtime.
5. Starter environments rebuild only when files under `starter-environments/` change.
