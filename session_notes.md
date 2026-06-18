# Session Notes: OMIX L2P Runtime Setup

Date: 2026-06-03

## Goal

Set up `OMIX_Test` as a modular OMIX monorepo with the first two real platform-ready runtime examples:

- `pathway_l2p_single`
- `pathway_l2p_multi`

All other modules remain placeholders until these two L2P examples are validated in Code Ocean.

## Architecture Decisions

- Keep `OMIX_Test` as the GitHub source of truth.
- Treat each module as independently runnable and independently syncable.
- Put the platform-ready runtime layout inside each module under `runtime/`.
- Use external execution platform mounts or data assets for production inputs.
- Keep only documentation and tiny example inputs in GitHub.
- Do not hand-author `.codeocean/*.json` files for the first pass.
- Use `run.sh` as the primary Code Ocean entrypoint.
- Keep `r-pathway` as the shared runtime/starter environment for both L2P modules.

## Shared Pathway Runtime Requirement

The shared container/runtime for pathway analyses belongs under:

```text
starter-environments/r-pathway/
```

This runtime should be shared by pathway modules such as:

- GSVA
- GSEA
- L2P Single
- L2P Multi

Each module should reference it with:

```yaml
starter_environment: r-pathway
```

The shared runtime should be built once and published as a reusable image, for example:

```text
ghcr.io/nidap-community/omix-r-pathway:latest
```

Module exports to Code Ocean, Shiny, HPC, Galaxy, or another execution platform should include the module's runnable code and only module-specific environment additions. They should not duplicate the full shared pathway runtime unless a target platform requires a fully self-contained bundle.

## Module Export Boundary Requirement

Each exported execution bundle should contain only one module's runnable code, documentation, tests, and tiny examples.

For example:

- L2P Single exports include `L2P_Single_v148.R`, not `L2P_Multi_v93.R`.
- L2P Multi exports include `L2P_Multi_v93.R`, not `L2P_Single_v148.R`.
- Neither L2P export should include GSVA, GSEA, visualization modules, or the full OMIX monorepo.

Shared runtime/container definitions stay in `starter-environments/` and are referenced separately.

## L2P Runtime Bundles Added

Each L2P module now has a nested platform-ready runtime bundle:

```text
modules/pathway_l2p_single/runtime/
modules/pathway_l2p_multi/runtime/
```

Each bundle includes:

```text
README.md
run.sh
code/main.R
code/functions/
environment/postInstall.sh
environment/README.md
data/README.md
data/example_inputs/
results/README.md
docs/input_schema.md
docs/output_schema.md
docs/usage.md
tests/test_run_small.sh
```

## L2P Source Code

The practical L2P source implementations were copied into the runtime bundles:

- `modules/pathway_l2p_single/runtime/code/functions/L2P_Single_v148.R`
- `modules/pathway_l2p_multi/runtime/code/functions/L2P_Multi_v93.R`

The runtime runners source these files and call:

- `l2p_single()`
- `l2p_multi()`

The runners support:

- `--params PATH`
- `--deg-table PATH`
- `--results-dir PATH`
- `--dry-run`

Dry-run mode validates layout, parameters, input columns, and result-writing behavior without running the full L2P pathway analysis.

## Module Contract Updates

The two L2P module manifests were updated so their OMIX entrypoint is the runtime entrypoint:

```yaml
entrypoint: runtime/run.sh
```

They also record:

- runtime root
- source template
- template version
- data policy
- sync policy

The legacy module-level `code/run.R` wrappers were removed for modules whose manifest entrypoint now points directly to `runtime/run.sh`.

## Git Ignore Updates

The top-level `.gitignore` still ignores production data, generated results, and large outputs. Narrow exceptions were added so runtime documentation and tiny example inputs can be tracked:

- `modules/*/runtime/data/README.md`
- `modules/*/runtime/data/example_inputs/**`
- `modules/*/runtime/results/README.md`

## Code Ocean Sync Workflow

Added:

- `scripts/code_ocean_sync.sh`
- `docs/code-ocean-sync.md`

The sync helper supports:

```bash
scripts/code_ocean_sync.sh outbound pathway_l2p_single /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh outbound pathway_l2p_multi /path/to/code-ocean-capsule

scripts/code_ocean_sync.sh reverse pathway_l2p_single /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh reverse pathway_l2p_multi /path/to/code-ocean-capsule
```

Default behavior is dry-run. Add `--apply` to copy files.

Reverse sync can bring Code Ocean edits back into GitHub, including fixes to actual L2P source files under `code/functions/`.

For a safer Code Ocean bug-fix workflow:

```bash
scripts/code_ocean_sync.sh reverse pathway_l2p_single /path/to/code-ocean-capsule --apply --branch
```

The `--branch` option creates a review branch before applying reverse-sync changes and refuses to run if the local worktree is dirty.

## Reverse Sync Guardrails

Reverse sync is intentionally scoped:

- L2P Single syncs only to `modules/pathway_l2p_single/runtime/`.
- L2P Multi syncs only to `modules/pathway_l2p_multi/runtime/`.
- `.codeocean/` is excluded for now.
- Generated `results/**` files are excluded except `results/README.md`.
- Production `data/**` files are excluded except `data/README.md` and tiny examples under `data/example_inputs/**`.
- Changes should return to `main` through a branch and pull request.

## Verification Completed

The following checks passed:

```bash
bash -n OMIX_Test/scripts/code_ocean_sync.sh
Rscript tests/test-module-contract.R
modules/pathway_l2p_single/runtime/tests/test_run_small.sh
modules/pathway_l2p_multi/runtime/tests/test_run_small.sh
```

Outbound sync dry-runs for both L2P modules showed the expected Code Ocean root layout.

Reverse sync dry-runs showed that code and intentional docs/examples would sync back, while production data and generated results would remain excluded.

## Current Git State Notes

At the end of the implementation, `OMIX_Test` was still on `main` and ahead of `origin/main` by one existing local commit.

There were uncommitted changes for the runtime implementation and an existing untracked `PLAN.md` file. `PLAN.md` was not changed during this runtime implementation.

## Suggested Next Steps

1. Review the new runtime files locally.
2. Commit the OMIX runtime changes.
3. Push to `NIDAP-Community/OMIX_Test`.
4. Sparse-sync `pathway_l2p_single` into a Code Ocean capsule and validate it there.
5. Repeat for `pathway_l2p_multi`.
6. After Code Ocean validation, use the reverse-sync workflow for any fixes made inside Code Ocean.
