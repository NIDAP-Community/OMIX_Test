#!/usr/bin/env Rscript

# Galaxy wrapper for OMIX Volcano Plot
# This script is called by Galaxy's tool runner. It sources the shared
# volcano function and writes output to the Galaxy working directory.

suppressPackageStartupMessages({
  library(optparse)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(ggrepel)
  library(stringr)
})

# In Galaxy, __tool_directory__ is resolved by the runner; the script lives
# alongside the XML. The runtime code is at a known relative path.
tool_dir <- normalizePath(dirname(sys.frame(1)$ofile %||% "."), mustWork = FALSE)
runtime_functions <- file.path(tool_dir, "..", "runtime", "code", "functions")

# Source the volcano function
source(file.path(runtime_functions, "Volcano_Plot_Enhanced.R"))

# Define CLI options (mirrors runtime/code/main.R)
option_list <- list(
  make_option("--deg_table", type = "character"),
  make_option("--pvalue_type", type = "character", default = "nominal"),
  make_option("--column_with_feature_id", type = "character", default = NULL),
  make_option("--significance_column", type = "character", default = NULL),
  make_option("--log2_fold_change_column", type = "character", default = NULL),
  make_option("--p_value_threshold", type = "double", default = 0.05),
  make_option("--log2_fold_change_threshold", type = "double", default = 1.0),
  make_option("--choose_feature_to_label_by", type = "character", default = "p-value"),
  make_option("--number_of_features_to_label", type = "integer", default = 30),
  make_option("--label_only_my_feature_list", type = "character", default = "false"),
  make_option("--my_feature_list", type = "character", default = ""),
  make_option("--top_genes_labeled_only_if_passing_thresholds", type = "character", default = "true"),
  make_option("--label_size", type = "double", default = 4),
  make_option("--label_box_padding", type = "double", default = 1),
  make_option("--label_force", type = "double", default = 1),
  make_option("--label_max_overlaps", type = "double", default = 100),
  make_option("--use_custom_axis_label", type = "character", default = "false"),
  make_option("--custom_significance_label", type = "character", default = "p-value"),
  make_option("--custom_log_fold_change_label", type = "character", default = "log2FC"),
  make_option("--plot_title", type = "character", default = "Volcano Plot"),
  make_option("--plot_subtitle", type = "character", default = ""),
  make_option("--y_limit", type = "double", default = 0),
  make_option("--use_auto_axis_capping", type = "character", default = "true"),
  make_option("--auto_axis_capping_quantile", type = "double", default = 0.9999),
  make_option("--auto_axis_capping_symmetric_x", type = "character", default = "true"),
  make_option("--custom_x_axis_limits", type = "character", default = ""),
  make_option("--x_limit_padding", type = "double", default = 0),
  make_option("--y_limit_padding", type = "double", default = 0),
  make_option("--plot_title_size", type = "double", default = 16),
  make_option("--axis_title_size", type = "double", default = 14),
  make_option("--axis_text_size", type = "double", default = 12),
  make_option("--point_size", type = "double", default = 2),
  make_option("--image_width", type = "integer", default = 3000),
  make_option("--image_height", type = "integer", default = 3000),
  make_option("--resolution_dpi_", type = "integer", default = 300),
  make_option("--color_not_significant", type = "character", default = "gray"),
  make_option("--color_fold_change_only", type = "character", default = "orange"),
  make_option("--color_significant_only", type = "character", default = "green4"),
  make_option("--color_significant_and_fold_change", type = "character", default = "red3")
)

opt <- parse_args(OptionParser(option_list = option_list))

# Convert string booleans
opt$label_only_my_feature_list <- tolower(opt$label_only_my_feature_list) == "true"
opt$top_genes_labeled_only_if_passing_thresholds <- tolower(opt$top_genes_labeled_only_if_passing_thresholds) == "true"
opt$use_custom_axis_label <- tolower(opt$use_custom_axis_label) == "true"
opt$use_auto_axis_capping <- tolower(opt$use_auto_axis_capping) == "true"
opt$auto_axis_capping_symmetric_x <- tolower(opt$auto_axis_capping_symmetric_x) == "true"

# Read input
deg_table <- read.csv(opt$deg_table, check.names = FALSE, stringsAsFactors = FALSE)

# Ensure output directory
dir.create("results", showWarnings = FALSE)

# Run
volcano_plot_enhanced(
  deg_table = deg_table,
  pvalue_type = opt$pvalue_type,
  column_with_feature_id = opt$column_with_feature_id,
  significance_column = opt$significance_column,
  log2_fold_change_column = opt$log2_fold_change_column,
  p_value_threshold = opt$p_value_threshold,
  log2_fold_change_threshold = opt$log2_fold_change_threshold,
  choose_feature_to_label_by = opt$choose_feature_to_label_by,
  number_of_features_to_label = opt$number_of_features_to_label,
  label_only_my_feature_list = opt$label_only_my_feature_list,
  use_custom_axis_label = opt$use_custom_axis_label,
  my_feature_list = opt$my_feature_list,
  top_genes_labeled_only_if_passing_thresholds = opt$top_genes_labeled_only_if_passing_thresholds,
  label_size = opt$label_size,
  label_box_padding = opt$label_box_padding,
  label_force = opt$label_force,
  label_max_overlaps = opt$label_max_overlaps,
  custom_significance_label = opt$custom_significance_label,
  custom_log_fold_change_label = opt$custom_log_fold_change_label,
  plot_title = opt$plot_title,
  plot_subtitle = opt$plot_subtitle,
  y_limit = opt$y_limit,
  use_auto_axis_capping = opt$use_auto_axis_capping,
  auto_axis_capping_quantile = opt$auto_axis_capping_quantile,
  auto_axis_capping_min_y_limit = 0,
  auto_axis_capping_symmetric_x = opt$auto_axis_capping_symmetric_x,
  custom_x_axis_limits = opt$custom_x_axis_limits,
  x_limit_padding = opt$x_limit_padding,
  y_limit_padding = opt$y_limit_padding,
  plot_title_size = opt$plot_title_size,
  axis_title_size = opt$axis_title_size,
  axis_text_size = opt$axis_text_size,
  point_size = opt$point_size,
  image_width = opt$image_width,
  image_height = opt$image_height,
  resolution_dpi_ = opt$resolution_dpi_,
  output_file_path = "results/volcano_plot.png",
  color_not_significant = opt$color_not_significant,
  color_fold_change_only = opt$color_fold_change_only,
  color_significant_only = opt$color_significant_only,
  color_significant_and_fold_change = opt$color_significant_and_fold_change
)
