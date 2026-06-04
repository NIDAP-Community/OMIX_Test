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

The sync script uses `rsync` when it is available. If a Code Ocean environment does not include `rsync`, the script falls back to a portable `find`/`cp` copy path with the same module-boundary filters.

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

## Worked Example: Volcano Code Ocean Edit Back To Main

This is the safe path for a change made in the Code Ocean Volcano capsule.

Do not open a pull request from `co/volcano` directly to `main`. The `co/volcano` branch has the Code Ocean capsule-root layout, while `main` has the OMIX monorepo layout.

Correct flow:

```text
co/volcano
  -> reverse sync
co-sync/volcano-demo
  -> pull request to main
```

### 1. Pull the Code Ocean export branch locally

Use the local export checkout for the capsule-shaped branch:

```bash
cd /private/tmp/omix-co-volcano
git pull origin co/volcano
```

This updates the local export checkout with edits that were committed and pushed from Code Ocean.

### 2. Create a monorepo-shaped sync branch

Return to the OMIX monorepo and start from `main`:

```bash
cd /Users/maggiec/GitHub/Maggie/NIDAP/Templates/OMIX_Test
git switch main
git pull origin main
git switch -c co-sync/volcano-demo
```

### 3. Reverse-sync the export into the Volcano module

Map the Code Ocean root back into the module runtime directory:

```bash
scripts/code_ocean_sync.sh reverse volcano /private/tmp/omix-co-volcano --apply
```

If Code Ocean reports `rsync: command not found`, update to a version of `scripts/code_ocean_sync.sh` that includes the portable fallback, or install `rsync` in the sync capsule before retrying:

```bash
apt-get update
apt-get install -y rsync
```

Example mapping:

```text
README.md
  -> modules/volcano/runtime/README.md

code/functions/Volcano_Plot_Enhanced_v85.R
  -> modules/volcano/runtime/code/functions/Volcano_Plot_Enhanced_v85.R

data/example_inputs/params.json
  -> modules/volcano/runtime/data/example_inputs/params.json
```

### 4. Confirm only the intended module changed

```bash
git diff --name-only
```

Expected paths should be under:

```text
modules/volcano/runtime/
```

For example:

```text
modules/volcano/runtime/README.md
modules/volcano/runtime/code/functions/Volcano_Plot_Enhanced_v85.R
modules/volcano/runtime/data/example_inputs/params.json
```

Do not continue if the diff shows top-level monorepo deletions or unrelated module changes.

### 5. Test the mapped changes

```bash
Rscript tests/test-module-contract.R
modules/volcano/runtime/tests/test_run_small.sh
```

Optionally run the full tiny example:

```bash
cd modules/volcano/runtime/code
Rscript main.R --params=../data/example_inputs/params.json --deg-table=../data/example_inputs/deg_table.csv
cd ../../../..
```

If the full run creates example outputs, remove generated result files before committing:

```bash
rm -f modules/volcano/runtime/results/run_manifest.json \
      modules/volcano/runtime/results/volcano_plot_volcano_A_B_adjpval.png \
      modules/volcano/runtime/results/volcano_plot_volcano_A_C_adjpval.png \
      modules/volcano/runtime/results/volcano_plot_volcano_B_C_adjpval.png
```

Generated `results/**` files should not be committed, except `results/README.md`.

### 6. Commit only the Volcano module changes

Stage the module path explicitly:

```bash
git add modules/volcano/runtime
git commit -m "Sync Volcano edits from Code Ocean"
git push origin co-sync/volcano-demo
```

Use `git add modules/volcano/runtime`, not `git add .`, so Code Ocean metadata or unrelated files are not included.

### 7. Open the safe pull request

Open a PR from:

```text
co-sync/volcano-demo -> main
```

Before merging, confirm the changed files are only under:

```text
modules/volcano/runtime/
```

Use squash-and-merge for a single logical sync commit.

After merge, update local `main`:

```bash
git switch main
git pull origin main
```

The persistent `co/volcano` branch should remain because Code Ocean uses it as the isolated export branch. Temporary `co-sync/*` branches can be deleted after merge.

## Diagram

See `docs/code-ocean-sync-flow.mmd` for a Mermaid diagram of the full process. The diagram is suitable for pasting into Lucidchart or any Mermaid renderer.

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
