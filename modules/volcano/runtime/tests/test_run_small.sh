#!/usr/bin/env bash
set -euo pipefail

runtime_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
results_dir="${runtime_root}/results"

cleanup() {
  find "${results_dir}" -maxdepth 1 -type f -name 'volcano_plot*.png' -delete
}
trap cleanup EXIT

mkdir -p "${results_dir}"

"${runtime_root}/run.sh" \
  --deg_table "${runtime_root}/data/example_inputs/deg_table.csv" \
  --pvalue_type nominal \
  --column_with_feature_id Gene \
  --significance_column A-B_pval \
  --log2_fold_change_column A-B_logFC \
  --image_width 600 \
  --image_height 600 \
  --resolution_dpi_ 150

test -s "${results_dir}/volcano_plot.png"
