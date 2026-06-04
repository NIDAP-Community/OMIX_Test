# Starter Environments

Starter environments are shared, cached base layers used by module runtimes.

They should contain packages that are common across a group of modules, but not module-specific scripts. Module-specific code stays in `modules/<module>/`.

## Shared Runtime Requirement

Starter environments are the repo home for shared runtime/container definitions. For example, pathway modules such as GSVA, GSEA, L2P Single, and L2P Multi should share `starter-environments/r-pathway` instead of duplicating container setup inside each module.

The shared runtime definition should be built once and published as a reusable image, such as:

```text
ghcr.io/nidap-community/omix-r-pathway:latest
```

Modules should reference the shared runtime in `module.yml`:

```yaml
starter_environment: r-pathway
```

When a module is exported or synced to a platform such as Code Ocean, Shiny, HPC, or Galaxy, the module should bring its runnable code and only module-specific environment additions. The full shared runtime source should not be duplicated into every module export unless a platform explicitly requires a fully self-contained bundle.

Module-specific packages or setup can live in the module runtime environment files when they are not broadly useful across the pathway family. Packages shared by multiple pathway modules belong in `starter-environments/r-pathway`.

## Current Environments

- `r-base`: base R, `renv`, `jsonlite`, `yaml`, and common system libraries.
- `r-visualization`: plotting and visualization packages.
- `r-pathway`: pathway and gene-set analysis packages.
- `r-singlecell`: single-cell analysis packages.

## Image Naming Convention

The CI templates assume this image naming pattern:

```text
ghcr.io/nidap-community/omix-<starter-environment>:latest
```

This scaffold is configured for the `nidap-community` GHCR namespace.
