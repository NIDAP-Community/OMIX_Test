# Changelog

## 0.2.0

- Fill out `inputs.schema.json` with all parameters, types, defaults, and enums.
- Add `outputs.schema.json` declaring the volcano plot PNG artifact.
- Remove redundant `library()` calls from `volcano_plot_enhanced()` function body.
- Remove `print(plot_obj)` side effect that created spurious `Rplots.pdf`.
- Fix bug: use `read.csv()` instead of `read.delim()` for CSV file-path inputs.
- Pin package versions in `postInstall.sh` to match the Dockerfile.
- Add testthat unit tests (14 tests).
- Fix inaccurate `docs/usage.md` description of the dry-run test.

## 0.1.1

- Removed obsolete module-level `code/run.R` wrapper; the module entrypoint is now only `runtime/run.sh`.
- Clarified local runtime instructions in the module README and runtime usage docs.

## 0.1.0

- Added explicit module version metadata for release tracking.

## 0.0.1

- Created module scaffold.
