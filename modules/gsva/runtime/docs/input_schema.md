# Input Schema

## Parameters

Required inputs:

- `normalized_data`: Path to normalized expression data (TSV/CSV)
- `sample_metadata`: Path to sample metadata table (TSV/CSV)
- `pathways_database`: Path to pathways database (TSV/CSV)

Optional parameters with defaults:

- `gene_column`: Gene name column in normalized data (default: "Gene")
- `sample_name_column`: Column containing sample name in metadata (default: "Sample")
- `samples_to_include`: Comma-separated sample columns to include
- `species`: Species in normalized data (default: "Human")
- `database_species`: Species in pathways database (default: "Human")
- `collections_to_include`: Comma-separated MSigDB collections (default: "H: hallmark gene sets")
- `custom_pathways_database`: Use custom pathways database (default: "false")
- `custom_species`: Species for custom pathways database (default: "Mouse")
- `method`: GSVA method — gsva, ssgsea, zscore, plage (default: "gsva")
- `minimum_geneset_size`: Minimum geneset size (default: 15)
- `maximum_geneset_size`: Maximum geneset size (default: 1200)
- `update_genes`: Update gene symbols using l2psupp (default: "true")
- `input_delim`: Delimiter for input files (default: "\t")
- `image_width`: Plot width in inches (default: 12)
- `image_height`: Plot height in inches (default: 10)

## Normalized Expression Data

The normalized data TSV must contain:
- A gene identifier column (named per `gene_column`)
- One or more numeric sample columns matching the names in `samples_to_include`

See `data/example_inputs/normalized_data.tsv` for a minimal example.

## Sample Metadata

The metadata TSV must contain:
- A sample name column (named per `sample_name_column`) with values matching sample column names in the normalized data

See `data/example_inputs/sample_metadata.tsv` for a minimal example.

## Pathways Database

The pathways database TSV must contain columns for collection, gene set name, and gene symbol.
The shared r-pathway image includes MSigDB v2023.2 at `/data/msigdb_v2023_2.rds`.

See `data/example_inputs/pathways_database.tsv` for a minimal example.
