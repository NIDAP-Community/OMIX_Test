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

Outbound sync also copies `.github/workflows/auto-cosync-pr.yml` into the `co/<module>` branch root. This allows `[sync]` commits pushed from Code Ocean to trigger the automated reverse-sync workflow. Reverse sync excludes `.github/`, so workflow files are not copied into `modules/<module>/runtime/`.

## Module Export Boundary

Each exported Code Ocean root should contain only the runnable code, docs, tests, and tiny examples for one module.

For example, an L2P Multi export should include `code/main.R` and `code/functions/L2P_Multi_v93.R`, but it should not include L2P Single, GSVA, GSEA, visualization modules, or the full OMIX monorepo.

A Volcano export should include `code/main.R` and `code/functions/Volcano_Plot_Enhanced_v85.R`, but it should not include L2P, GSVA, GSEA, other visualization modules, or the full OMIX monorepo.

Shared runtime/container definitions are handled separately through `starter-environments/`, such as `starter-environments/r-pathway`. The module export should reference or build from that shared runtime rather than copying unrelated module code into the export.

## Reverse Sync: Automated

Reverse sync from a Code Ocean capsule back to `main` is handled by CI/CD.

The developer action is to include `[sync]` in the commit message when changes in a `co/<module>` branch are ready to be reviewed and merged into the monorepo.

Example from the Volcano Code Ocean capsule:

```bash
git add code/functions/Volcano_Plot_Enhanced_v85.R data/example_inputs/params.json README.md
git commit -m "Fix fold-change threshold [sync]"
git push origin co/volcano
```

WIP commits without `[sync]` are ignored by the automated reverse-sync workflow:

```bash
git commit -m "Experiment with volcano labels"
```

## Automated PR Flow

When a `[sync]` commit is pushed to `co/<module>`, `.github/workflows/auto-cosync-pr.yml` runs automatically.

The workflow:

1. Confirms the commit message contains `[sync]`.
2. Extracts the module name from the branch name, for example `co/volcano` becomes `volcano`.
3. Checks that no other `co-sync/*` PR is already open against `main`.
4. Checks out a fresh copy of `main`.
5. Creates a timestamped branch such as `co-sync/volcano-20260605-104500`.
6. Checks out the `co/<module>` export branch into a scratch worktree.
7. Runs `scripts/code_ocean_sync.sh reverse <module> /tmp/co-export`.
8. Applies the reverse sync into `modules/<module>/runtime/`.
9. Aborts if any changed path falls outside `modules/<module>/runtime/`.
10. Stages only `modules/<module>/runtime/`.
11. Commits the mapped changes.
12. Opens a draft PR from `co-sync/<module>-*` to `main`.

The generated PR includes a review checklist and metadata about the triggering Code Ocean commit.

## Duplicate PR Guard

Only one `co-sync/*` PR should be open against `main` at a time.

The repository enforces this in two places:

- `.github/workflows/auto-cosync-pr.yml` refuses to create a new automated PR if any `co-sync/*` PR is already open.
- `.github/workflows/block-duplicate-cosync-pr.yml` checks newly opened `co-sync/*` PRs and posts a warning if another co-sync PR already exists.

This guard applies across modules. Even if two PRs touch different modules, they may have branched from a stale copy of `main`, and shared files or module-contract behavior may have changed between them.

## Commit Message Convention

| Commit message | Effect |
| --- | --- |
| `Fix threshold calculation` | No automation. The commit remains on the `co/<module>` branch only. |
| `Fix threshold calculation [sync]` | Triggers automated reverse sync and opens a draft PR. |

## Persistent And Temporary Branches

| Branch | Type | Purpose |
| --- | --- | --- |
| `main` | Persistent | OMIX monorepo source of truth. |
| `co/volcano` | Persistent | Code Ocean Volcano export branch. Never merge directly into `main`. |
| `co/pathway_l2p_single` | Persistent | Code Ocean L2P Single export branch. Never merge directly into `main`. |
| `co/pathway_l2p_multi` | Persistent | Code Ocean L2P Multi export branch. Never merge directly into `main`. |
| `co-sync/<module>-*` | Temporary | Monorepo-shaped review branch created by automation. Delete after PR merge. |

Do not open a pull request from `co/<module>` directly to `main`. The `co/<module>` branch has a Code Ocean capsule-root layout, while `main` has the OMIX monorepo layout.

## Manual Reverse Sync Fallback

The automated `[sync]` flow is preferred. Use the manual path only for debugging or local recovery.

```bash
# 1. Start from a clean local OMIX worktree.
git status --short

# 2. Pull the latest export branch into a scratch checkout.
rm -rf /scratch/omix-co-volcano
git clone --branch co/volcano --single-branch \
  https://github.com/NIDAP-Community/OMIX_Test.git \
  /scratch/omix-co-volcano

# 3. Create a monorepo-shaped sync branch from main.
git switch main
git pull origin main
SYNC_BRANCH="co-sync/volcano-$(date +%Y%m%d-%H%M%S)"
git switch -c "$SYNC_BRANCH"

# 4. Reverse-sync into the module runtime path.
scripts/code_ocean_sync.sh reverse volcano /scratch/omix-co-volcano --apply

# 5. Review and test before committing.
git diff --name-only
Rscript tests/test-module-contract.R
modules/volcano/runtime/tests/test_run_small.sh

# 6. Commit only the module runtime path.
git add modules/volcano/runtime
git commit -m "Sync Volcano edits from Code Ocean"
git push origin "$SYNC_BRANCH"
```

Before opening or merging the PR, confirm all changed files live under:

```text
modules/volcano/runtime/
```

For L2P Single or L2P Multi, replace `volcano` with `pathway_l2p_single` or `pathway_l2p_multi`, and use the matching `modules/<module>/runtime/tests/test_run_small.sh` smoke test.

## Sync Script Notes

The sync script uses `rsync` when it is available. If a Code Ocean environment does not include `rsync`, the script falls back to a portable `find`/`cp` copy path with the same module-boundary filters.

This fallback message is expected in minimal Code Ocean environments:

```text
rsync not found; using portable copy fallback.
```

`scripts/code_ocean_sync.sh` supports any module with a `modules/<module>/runtime/` directory. It is no longer limited to a hardcoded module list.

## Diagram

See `docs/code-ocean-sync-flow.mmd` for a Mermaid diagram of the full process. The diagram is suitable for pasting into Lucidchart or any Mermaid renderer.

## Guardrails

- Each synced Code Ocean root maps to exactly one OMIX module.
- L2P Single syncs only to `modules/pathway_l2p_single/runtime/`.
- L2P Multi syncs only to `modules/pathway_l2p_multi/runtime/`.
- Volcano syncs only to `modules/volcano/runtime/`.
- Other modules are excluded from the export and reverse-sync path.
- `.github/` is included in outbound export only for the auto-sync workflow, and is excluded from reverse sync.
- `.codeocean/` is excluded.
- Generated `results/**` files are excluded except `results/README.md`.
- Production `data/**` files are excluded except `data/README.md` and tiny `data/example_inputs/**` fixtures.
- Changes return to `main` through a `co-sync/*` branch and pull request, never directly from a `co/*` branch.
- Only one `co-sync/*` PR may be open against `main` at a time.
