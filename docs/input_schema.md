# Input Schema

## Parameters JSON

Required top-level fields:

- `inputs.deg_table_file`: optional relative or absolute path to a DEG CSV
- `function_args`: arguments passed to `l2p_multi()`

Required `function_args` fields:

- `gene_names_column`
- `t_statistic_columns`
- `significance_columns`
- `fold_change_columns`
- `species`
- `collections_to_include`

The runner replaces `function_args.deg_table` with the loaded CSV data frame and writes output paths under `/results`.

## DEG Table

The DEG CSV must contain the columns named in the parameter JSON. See `data/example_inputs/deg_table.csv` for a minimal dry-run example.
