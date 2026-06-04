# Code Ocean Capsule Sync

OMIX keeps the monorepo as the source of truth while allowing each Code Ocean capsule to be edited in isolation.

## Outbound Sync

Export one module runtime into a Code Ocean capsule root:

```bash
scripts/code_ocean_sync.sh outbound pathway_l2p_single /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh outbound pathway_l2p_multi /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh outbound volcano /path/to/code-ocean-capsule
```

The command defaults to dry-run. Add `--apply` to copy files.

## Module Export Boundary

Each exported Code Ocean root should contain only the runnable code, docs, tests, and tiny examples for one module.

For example, an L2P Multi export should include `code/main.R` and `code/functions/L2P_Multi_v93.R`, but it should not include L2P Single, GSVA, GSEA, visualization modules, or the full OMIX monorepo.

A Volcano export should include `code/main.R` and `code/functions/Volcano_Plot_Enhanced_v85.R`, but it should not include L2P, GSVA, GSEA, other visualization modules, or the full OMIX monorepo.

Shared runtime/container definitions are handled separately through `starter-environments/`, such as `starter-environments/r-pathway`. The module export should reference or build from that shared runtime rather than copying unrelated module code into the export.

## Reverse Sync

Pull isolated Code Ocean changes back into the matching OMIX module:

```bash
scripts/code_ocean_sync.sh reverse pathway_l2p_single /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh reverse pathway_l2p_multi /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh reverse volcano /path/to/code-ocean-capsule
```

Reverse sync is path-mapped to only one module's `runtime/` directory. It includes edits to the actual analysis code, such as `code/main.R` and `code/functions/L2P_Single_v148.R` or `code/functions/L2P_Multi_v93.R`.

## Code Ocean Bug-Fix Workflow

Use this when a bug is found and fixed directly in a Code Ocean capsule:

```bash
# 1. Start from a clean local OMIX worktree.
git status --short

# 2. Dry-run the reverse sync to inspect what would come back.
scripts/code_ocean_sync.sh reverse pathway_l2p_single /path/to/code-ocean-capsule

# 3. Apply the reverse sync on a review branch.
scripts/code_ocean_sync.sh reverse pathway_l2p_single /path/to/code-ocean-capsule --apply --branch

# 4. Review and test before committing.
git diff
Rscript tests/test-module-contract.R
modules/pathway_l2p_single/runtime/tests/test_run_small.sh
```

For L2P Multi, replace `pathway_l2p_single` with `pathway_l2p_multi` and run the matching smoke test.

The `--branch` option refuses to run if the worktree is dirty. This keeps a Code Ocean-side fix from mixing with unrelated local edits.

## Guardrails

- Each synced Code Ocean root maps to exactly one OMIX module.
- L2P Single syncs only to `modules/pathway_l2p_single/runtime/`.
- L2P Multi syncs only to `modules/pathway_l2p_multi/runtime/`.
- Volcano syncs only to `modules/volcano/runtime/`.
- Other modules are excluded from the export and reverse-sync path.
- `.codeocean/` is excluded for the first pass.
- Generated `results/**` files are excluded except `results/README.md`.
- Production `data/**` files are excluded except `data/README.md` and tiny `data/example_inputs/**` fixtures.
- Changes should return to `main` through a branch and pull request.
