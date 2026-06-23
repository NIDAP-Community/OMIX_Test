# Data

Production inputs should be mounted by the target execution platform. Do not commit production expression data or pathways databases to this repository.

Expected mounted files:

- `/data/normalized_data.tsv` — Normalized expression matrix (genes × samples)
- `/data/sample_metadata.tsv` — Sample metadata table
- `/data/pathways_database.tsv` — Gene set membership table (collection, gene_set_name, gene_symbol, species)

The `example_inputs/` directory contains tiny files for dry-run validation only.
