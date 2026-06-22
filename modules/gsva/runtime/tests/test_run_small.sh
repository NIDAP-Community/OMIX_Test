#!/usr/bin/env bash
set -euo pipefail

runtime_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
results_dir="${runtime_root}/results"

# Ensure dependencies are installed
bash "${runtime_root}/environment/postInstall.sh"

cleanup() {
  rm -f "${results_dir}/gsva_results.csv" "${results_dir}/gsva_heatmap.png"
}
trap cleanup EXIT

mkdir -p "${results_dir}"

"${runtime_root}/run.sh" \
  --normalized_data "${runtime_root}/data/example_inputs/normalized_data.tsv" \
  --sample_metadata "${runtime_root}/data/example_inputs/sample_metadata.tsv" \
  --pathways_database "${runtime_root}/data/example_inputs/pathways_database.tsv" \
  --gene_column Gene \
  --sample_name_column Sample \
  --collections_to_include "H: hallmark gene sets" \
  --method gsva \
  --minimum_geneset_size 5 \
  --maximum_geneset_size 500

test -s "${results_dir}/gsva_results.csv"
echo "PASS: GSVA test completed successfully"
