# OMIX L2P Code Ocean Capsule Plan

## Summary

Build two real Code Ocean-ready examples inside `OMIX_Test`: `pathway_l2p_single` and `pathway_l2p_multi`. Keep every other module as a placeholder for now. The OMIX monorepo remains the source of truth, but each L2P capsule will be exportable as an isolated Code Ocean capsule using sparse checkout plus sync.

Current local state: `OMIX_Test` already has separate `modules/pathway_l2p_single` and `modules/pathway_l2p_multi` modules, both using `r-pathway`, and the repo is one local commit ahead of GitHub.

## Key Changes

- Add a Code Ocean capsule bundle under each runnable module:
  - `modules/pathway_l2p_single/capsule/`
  - `modules/pathway_l2p_multi/capsule/`

- Each capsule bundle will follow the selected Code Ocean-style root layout:
  - `README.md`
  - `run.sh`
  - `code/main.R`
  - `code/functions/`
  - `environment/postInstall.sh`
  - `environment/renv.lock` or dependency notes
  - `data/README.md`
  - `data/example_inputs/`
  - `results/README.md`
  - `docs/input_schema.md`
  - `docs/output_schema.md`
  - `docs/usage.md`
  - `tests/test_run_small.sh`

- Keep `module.yml` as the OMIX module contract, but update the two L2P manifests so their `entrypoint` points to the capsule entrypoint model and clearly records:
  - module name
  - Code Ocean capsule name
  - starter environment: `r-pathway`
  - source template/version lineage
  - expected input/output schemas

- Use `L2P_Single_v148.R` and `L2P_Multi_v93.R` as the practical source implementations for the first capsule examples.

- Keep production data out of GitHub. The repo will contain only docs, code, schemas, and tiny test/example inputs. Real inputs will be mounted as Code Ocean data assets.

## Sparse Checkout And Sync

- Outbound sync to Code Ocean will use sparse checkout of only the target module plus minimal shared files needed to build/run it:
  - `modules/pathway_l2p_single/**` or `modules/pathway_l2p_multi/**`
  - relevant `core/**` helpers only if required
  - relevant `starter-environments/r-pathway/**`
  - top-level docs/licenses only when useful for capsule metadata

- The sparse checkout output will be synced into the Code Ocean capsule root from the nested `capsule/` directory, so Code Ocean sees a normal capsule layout rather than the whole monorepo.

- Bidirectional sync is possible, but must be guarded:
  - L2P Single Code Ocean capsule root syncs back only to `modules/pathway_l2p_single/capsule/`
  - L2P Multi Code Ocean capsule root syncs back only to `modules/pathway_l2p_multi/capsule/`
  - reverse sync creates a branch/PR, not a direct update to `main`
  - reject changes outside the target module path
  - do not sync generated `results/**`, except `results/README.md`
  - do not sync production `data/**`, except `data/README.md` and intentional tiny examples
  - defer `.codeocean/**` tracking unless we later decide those metadata files should be versioned

## Test Plan

- Run existing OMIX contract validation:
  - `Rscript tests/test-module-contract.R`

- Add small capsule smoke tests:
  - `modules/pathway_l2p_single/capsule/tests/test_run_small.sh`
  - `modules/pathway_l2p_multi/capsule/tests/test_run_small.sh`

- Validate each capsule locally before Code Ocean publication:
  - `run.sh` executes from capsule root
  - outputs are written only under `results/`
  - missing data asset paths fail with clear messages
  - example inputs produce expected small output files

- Validate sync behavior with dry runs:
  - sparse checkout includes only the requested L2P module and required shared support
  - outbound sync produces a valid Code Ocean capsule root
  - reverse sync refuses files outside the selected L2P module

## Assumptions And Defaults

- `run.sh` is the primary Code Ocean entrypoint.
- `.codeocean/*.json` files are not hand-authored for the first pass.
- Other OMIX modules remain placeholders until L2P Single and L2P Multi are working in Code Ocean.
- `r-pathway` remains the shared starter/runtime environment for both L2P capsules.
- GitHub remains the source of truth; Code Ocean changes return through branch/PR review.
