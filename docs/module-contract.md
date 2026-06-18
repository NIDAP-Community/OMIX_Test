# Module Folder Contract

Each module is a self-contained unit that can be built, tested, and released independently.

The validation helpers for this contract live in `scripts/lib/module_governance.R`, not in `core/`. `core/` is reserved for scientific/runtime package code used by OMIX modules.

Required folders:

- `R/` for reusable R functions.
- `tests/` for module-local tests.
- `schemas/` for input and output schemas.

Required files:

- `module.yml`
- `README.md`
- `CHANGELOG.md`

Required `module.yml` fields:

- `name`
- `display_name`
- `version`
- `module_type`
- `starter_environment`
- `entrypoint`

The entrypoint path is declared in `module.yml`. It may point to a module-level script such as `code/run.R` for early scaffold modules, or to a platform-ready runtime wrapper such as `runtime/run.sh` once a module has a capsule-root payload.

Optional but recommended fields:

- `owner`
- `description`
- `inputs_schema`
- `outputs_schema`
- `runtime_root`
- `deployment.image`
- `deployment.base_image`

## Versioning Rules

`version` must use semantic versioning, for example `0.1.0` or `1.2.0-rc.1`.

CI enforces version discipline for release-impacting module changes:

- Changes under `R/`, `code/`, `runtime/`, `schemas/`, or `module.yml` require a `module.yml` version update.
- The same changes require an entry in the module's `CHANGELOG.md`.
- Docs-only and tests-only changes do not require a module version bump.

Use namespaced Git tags for releases from the monorepo, for example `volcano/v0.1.0` or `pathway_gsea/v1.2.0`.

Supported starter environments in this scaffold:

- `r-base`
- `r-visualization`
- `r-pathway`
- `r-singlecell`
