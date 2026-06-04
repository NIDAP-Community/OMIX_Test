#!/usr/bin/env bash
set -euo pipefail

runtime_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
results_dir="${TMPDIR:-/tmp}/omix_l2p_multi_smoke_$$"

cleanup() {
  rm -rf "${results_dir}"
}
trap cleanup EXIT

mkdir -p "${results_dir}"

"${runtime_root}/run.sh" \
  --dry-run \
  --params "${runtime_root}/data/example_inputs/params.json" \
  --deg-table "${runtime_root}/data/example_inputs/deg_table.csv" \
  --results-dir "${results_dir}"

test -s "${results_dir}/pathway_l2p_multi_dry_run.json"
