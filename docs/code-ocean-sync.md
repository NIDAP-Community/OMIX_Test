# Code Ocean Capsule Sync

> Current implementation note: this page describes the intended `mod/<module>` staging-branch design. The checked-in GitHub Actions workflows currently open `co-sync/*` reverse-sync PRs directly to `main`, and no `promote-mod-to-main.yml` workflow is currently present. See `docs/ci-workflows.md` for the workflow-by-workflow current state.

OMIX keeps the monorepo as the source of truth while allowing each Code Ocean capsule to be edited in isolation. A per-module integration branch (`mod/<module>`) decouples fast Code Ocean iteration from the protected `main` branch.

## Architecture Overview

```
main (protected, monorepo source of truth)
  └── mod/<module> (per-module integration branch, tracks main)
       ← co-sync/<module>-* PRs land here (auto-merged when CI passes)
       → promotion PRs batch changes to main

co/<module> (persistent, capsule-root layout for Code Ocean)
  → [sync] commits trigger reverse sync into mod/<module>
  ← auto-refresh from main keeps capsule current
```

Key benefits:
- **Parallel development**: Multiple modules sync simultaneously (no global lock).
- **Fast CO iteration**: co-sync PRs auto-merge into `mod/<module>` when CI passes.
- **Batched review**: Promotion PRs from `mod/<module>` → `main` bundle multiple syncs.
- **Auto-refresh**: When `main` changes, `co/<module>` branches stay current automatically.

## Outbound Sync

Export one module runtime into a Code Ocean capsule root:

```bash
scripts/code_ocean_sync.sh outbound pathway_l2p_single /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh outbound pathway_l2p_multi /path/to/code-ocean-capsule
scripts/code_ocean_sync.sh outbound volcano /path/to/code-ocean-capsule
```

The command defaults to dry-run. Add `--apply` to copy files.

Outbound sync also copies `.github/workflows/auto-cosync-pr.yml` into the `co/<module>` branch root. This allows `[sync]` commits pushed from Code Ocean to trigger the automated reverse-sync workflow. Reverse sync excludes `.github/`, so workflow files are not copied into `modules/<module>/runtime/`.

## What Copies vs. What Stays Branch-Local

The normal capsule payload is copied from:

```text
modules/<module>/runtime/
```

to the root of:

```text
co/<module>
```

For example, `modules/volcano/runtime/code/main.R` becomes `code/main.R` on `co/volcano`.

The `co/<module>` branch may also contain Code Ocean platform files that are not copied back into `main`:

| Branch path | Role | Reverse-synced to `main`? |
| --- | --- | --- |
| `.codeocean/app-panel.json` | Code Ocean app panel / UI configuration | No |
| `.codeocean/datasets.json` | Code Ocean dataset attachment metadata | No |
| `.codeocean/resources.json` | Code Ocean resource metadata | No |
| `.github/workflows/auto-cosync-pr.yml` | GitHub automation used by `[sync]` commits from the capsule branch | No |

These files are intentionally branch-local platform metadata. They are excluded by `scripts/code_ocean_sync.sh` so the source-of-truth module code in `main` stays focused on portable runtime files, module contracts, tests, docs, and tiny examples.

At present, the live Volcano app-panel configuration is represented by `.codeocean/app-panel.json` on `co/volcano`. `main` does not track placeholder app-panel folders. If the team later decides to source-manage app-panel configuration from the monorepo, that should be added deliberately rather than kept as empty scaffolding.

## Module Export Boundary

Each exported Code Ocean root should contain only the runnable code, docs, tests, and tiny examples for one module.

For example, an L2P Multi export should include `code/main.R` and `code/functions/L2P_Multi_v93.R`, but it should not include L2P Single, GSVA, GSEA, visualization modules, or the full OMIX monorepo.

A Volcano export should include `code/main.R` and `code/functions/Volcano_Plot_Enhanced.R`, but it should not include L2P, GSVA, GSEA, other visualization modules, or the full OMIX monorepo.

Shared runtime/container definitions are handled separately through `starter-environments/`, such as `starter-environments/r-pathway`. The module export should reference or build from that shared runtime rather than copying unrelated module code into the export.

## Reverse Sync: Automated

Reverse sync from a Code Ocean capsule back to the monorepo is handled by CI/CD. Changes land on `mod/<module>` first, then get promoted to `main`.

The developer action is to include `[sync]` in the commit message when changes in a `co/<module>` branch are ready to be reviewed.

Example from the Volcano Code Ocean capsule:

```bash
git add code/functions/Volcano_Plot_Enhanced.R data/example_inputs/params.json README.md
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
3. Ensures `mod/<module>` exists (creates it from `main` if not).
4. Checks that no other `co-sync/*` PR for the **same module** is already open (different modules can sync in parallel).
5. Creates a timestamped branch such as `co-sync/volcano-20260605-104500` from `mod/<module>`.
6. Checks out the `co/<module>` export branch into a scratch worktree.
7. Runs `scripts/code_ocean_sync.sh reverse <module> /tmp/co-export`.
8. Applies the reverse sync into `modules/<module>/runtime/`.
9. Aborts if any changed path falls outside `modules/<module>/runtime/`.
10. Stages only `modules/<module>/runtime/`.
11. Commits the mapped changes.
12. Opens a PR from `co-sync/<module>-*` to `mod/<module>` (not `main`).
13. Enables auto-merge so the PR merges as soon as CI passes.

The generated PR includes a review checklist and metadata about the triggering Code Ocean commit.

## Promotion to Main

Changes accumulate on `mod/<module>` and are promoted to `main` in batches.

`.github/workflows/promote-mod-to-main.yml` handles this:

- **Daily schedule** (06:00 UTC): Finds all `mod/*` branches ahead of `main` and creates promotion PRs.
- **Manual dispatch**: Target a specific module for immediate promotion.
- **Post-merge rebase**: After a promotion merges, `mod/*` branches are automatically rebased onto the new `main`.

Promotion PRs include a commit log and full review checklist. Use squash-and-merge for clean history.

## Auto-Refresh Export

`.github/workflows/auto-refresh-export.yml` keeps Code Ocean capsules current:

- Triggered when a push to `main` touches `modules/<module>/runtime/**`.
- Detects which modules changed and runs outbound sync for each.
- Commits the refresh to `co/<module>` **without** a `[sync]` tag (no reverse-sync loop).

This eliminates manual re-export after merging changes through the local route.

## Duplicate PR Guard (Per-Module)

Only one `co-sync/*` PR per module may be open at a time. Different modules can sync in parallel.

The repository enforces this in two places:

- `.github/workflows/auto-cosync-pr.yml` refuses to create a new automated PR if another `co-sync/*` PR for the same module is already open against `mod/<module>`.
- `.github/workflows/block-duplicate-cosync-pr.yml` checks newly opened `co-sync/*` PRs and posts a warning if another co-sync PR for the same module already exists.

This per-module scoping allows multiple developers to work on different modules simultaneously without blocking each other.

## Commit Message Convention

| Commit message | Effect |
| --- | --- |
| `Fix threshold calculation` | No automation. The commit remains on the `co/<module>` branch only. |
| `Fix threshold calculation [sync]` | Triggers reverse sync → PR to `mod/<module>` → auto-merge if CI passes. |

## Branch Hierarchy

| Branch | Type | Purpose |
| --- | --- | --- |
| `main` | Persistent, protected | OMIX monorepo source of truth. |
| `mod/volcano` | Persistent | Volcano integration branch. Tracks main. CO syncs land here. |
| `mod/pathway_l2p_single` | Persistent | L2P Single integration branch. |
| `mod/pathway_l2p_multi` | Persistent | L2P Multi integration branch. |
| `co/volcano` | Persistent | Code Ocean Volcano export. Capsule-root layout. Never merge directly into `main` or `mod/*`. |
| `co/pathway_l2p_single` | Persistent | Code Ocean L2P Single export. |
| `co/pathway_l2p_multi` | Persistent | Code Ocean L2P Multi export. |
| `co-sync/<module>-*` | Temporary | Monorepo-shaped review branch. Targets `mod/<module>`. Delete after merge. |
| `feature/*`, `fix/*` | Temporary | Local development branches targeting `main`. |

Do not open a pull request from `co/<module>` directly to `main` or `mod/<module>`. The `co/<module>` branch has a Code Ocean capsule-root layout, while `main` and `mod/*` have the OMIX monorepo layout. Use `[sync]` to trigger the layout-aware reverse sync.

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

# 3. Create a monorepo-shaped sync branch from mod/<module>.
git fetch origin mod/volcano
SYNC_BRANCH="co-sync/volcano-$(date +%Y%m%d-%H%M%S)"
git switch -c "$SYNC_BRANCH" origin/mod/volcano

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

# 7. Open PR targeting mod/volcano (not main).
gh pr create --base mod/volcano --head "$SYNC_BRANCH" --title "Manual sync volcano"
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

See `docs/github-sync-flow.mmd` for a high-level local-machine vs Code Ocean synchronization flow.

See `docs/code-ocean-sync-flow.mmd` for a more detailed Mermaid diagram of the Code Ocean reverse-sync process. Both diagrams are suitable for pasting into Lucidchart or any Mermaid renderer.

## Guardrails

- Each synced Code Ocean root maps to exactly one OMIX module.
- `main` is protected; only promotion PRs and local-route PRs merge into it.
- `mod/<module>` is the fast sync target; co-sync PRs auto-merge here when CI passes.
- Per-module parallelism: different modules sync independently without blocking.
- L2P Single syncs only to `modules/pathway_l2p_single/runtime/`.
- L2P Multi syncs only to `modules/pathway_l2p_multi/runtime/`.
- Volcano syncs only to `modules/volcano/runtime/`.
- Other modules are excluded from the export and reverse-sync path.
- `.github/` is included in outbound export only for the auto-sync workflow, and is excluded from reverse sync.
- `.codeocean/` is excluded.
- Generated `results/**` files are excluded except `results/README.md`.
- Production `data/**` files are excluded except `data/README.md` and tiny `data/example_inputs/**` fixtures.
- Changes return to `main` through promotion PRs from `mod/<module>`, never directly from `co/*` or `co-sync/*`.
- Auto-refresh keeps `co/<module>` branches fresh after `main` merges.
- `mod/*` branches are automatically rebased onto `main` after promotions.
