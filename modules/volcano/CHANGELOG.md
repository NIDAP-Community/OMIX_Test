# Changelog

## 0.2.4

- Sync detailed runtime README column naming requirements from Code Ocean.

## 0.2.3

- Sync expanded runtime usage documentation from Code Ocean.

## 0.2.2

- Sync Code Ocean runtime metadata name and runtime `.gitignore` output filters.

## 0.2.1

- Add Galaxy tool wrapper (`galaxy/omix_volcano.xml` + `galaxy/main.R`).
- Cross-reference capsule README and DEVELOPER.md from module README.
- Rewrite DEVELOPER.md with file-ownership map (Shared / CO Only / HPC Only).
- Align with shared runtime environment architecture.

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
