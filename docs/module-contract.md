# Module Folder Contract

Each module is a self-contained unit that can be built, tested, and released independently.

Required folders:

- `R/` for reusable R functions.
- `tests/` for module-local tests.
- `schemas/` for input and output schemas.
- `app-panel/` for Code Ocean app-panel configuration.
- `code/` for module entrypoints and execution scripts.

Required files:

- `module.yml`
- `README.md`
- `CHANGELOG.md`

Required `module.yml` fields:

- `name`
- `display_name`
- `module_type`
- `starter_environment`
- `entrypoint`

Optional but recommended fields:

- `owner`
- `description`
- `inputs_schema`
- `outputs_schema`
- `runtime_root`
- `deployment.image`
- `deployment.base_image`

Supported starter environments in this scaffold:

- `r-base`
- `r-visualization`
- `r-pathway`
- `r-singlecell`
