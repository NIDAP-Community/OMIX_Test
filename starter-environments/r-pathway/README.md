# r-pathway

Pathway starter environment for gene-set and pathway-focused OMIX modules.

Example modules:

- `pathway_gsva`
- `pathway_gsea`
- `pathway_l2p_single`
- `pathway_l2p_multi`

Intended image:

```text
ghcr.io/nidap-community/omix-r-pathway:latest
```

## Requirement

This environment is the shared runtime/container layer for pathway modules. It should hold dependencies that are common to pathway workflows, including modules such as:

- GSVA
- GSEA
- L2P Single
- L2P Multi

Individual modules should reference this runtime via `starter_environment: r-pathway` and keep only module-specific code or setup inside their own module directory.

For platform exports, the module bundle should reference or build from this shared image rather than copying the entire shared runtime definition into every module. A fully self-contained export is allowed only when a target platform requires it.
