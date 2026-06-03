# Starter Environments

Starter environments are shared, cached base layers used by module capsules.

They should contain packages that are common across a group of modules, but not module-specific scripts. Module-specific code stays in `modules/<module>/`.

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

