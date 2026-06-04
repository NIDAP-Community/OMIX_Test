# Input Schema

## Parameters JSON

Required top-level fields:

- `inputs.deg_table_file`: optional relative or absolute path to a DEG CSV
- `function_args`: arguments passed to `volcano_plot_enhanced()`

Required `function_args` fields:

- `column_with_feature_id`
- `significance_column`
- `log2_fold_change_column`

The runner replaces `function_args.deg_table` with the loaded CSV data frame and writes output paths under `/results`.

## DEG Table

The DEG CSV must contain the columns named in the parameter JSON. See `data/example_inputs/deg_table.csv` for a minimal dry-run example.
