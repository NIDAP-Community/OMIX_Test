#!/usr/bin/env Rscript

# OMIX Volcano - CLI-first volcano plot generator
# Accepts parameters via command-line arguments from App Panel

suppressPackageStartupMessages({
  library(optparse)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(ggrepel)
  library(stringr)
})

get_script_dir <- function() {
  file_arg <- commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))]
  if (length(file_arg) == 0) {
    return(getwd())
  }
  dirname(normalizePath(sub("^--file=", "", file_arg[1]), mustWork = TRUE))
}

runtime_root <- normalizePath(file.path(get_script_dir(), ".."), mustWork = TRUE)

# Define CLI options
option_list <- list(
  make_option("--deg_table", type = "character", help = "Path to DEG table CSV"),
  make_option("--pvalue_type", type = "character", default = "adjusted"),
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
  make_option("--use_custom_axis_label", type = "character", default = "false"),
  make_option("--custom_significance_label", type = "character", default = "p-value"),
  make_option("--custom_log_fold_change_label", type = "character", default = "log2FC"),
  make_option("--plot_title", type = "character", default = "Volcano Plots"),
  make_option("--y_limit", type = "double", default = 0),
  make_option("--use_auto_axis_capping", type = "character", default = "true"),
  make_option("--auto_axis_capping_quantile", type = "double", default = 0.9999),
  make_option("--auto_axis_capping_symmetric_x", type = "character", default = "true"),
  make_option("--custom_x_axis_limits", type = "character", default = ""),
  make_option("--x_limit_padding", type = "double", default = 0),
  make_option("--y_limit_padding", type = "double", default = 0),
  make_option("--axis_label_size", type = "double", default = 24),
  make_option("--point_size", type = "double", default = 2),
  make_option("--image_width", type = "integer", default = 3000),
  make_option("--image_height", type = "integer", default = 3000),
  make_option("--resolution_dpi_", type = "integer", default = 300),
  make_option("--color_not_significant", type = "character", default = "gray"),
  make_option("--color_fold_change_only", type = "character", default = "orange"),
  make_option("--color_significant_only", type = "character", default = "green4"),
  make_option("--color_significant_and_fold_change", type = "character", default = "red3")
)

parser <- OptionParser(
  usage = "Usage: %prog --deg_table PATH [options]",
  option_list = option_list,
  description = "Generate enhanced volcano plots from differential expression analysis"
)

opt <- parse_args(parser, args = commandArgs(trailingOnly = TRUE))

# Validate required arguments
if (is.null(opt$deg_table) || !nzchar(opt$deg_table)) {
  # Try attached data asset first (check /data/example_deg/ for CSV files)
  attached_data_path <- "/data/example_deg/DEG-Results.csv"
  example_path <- file.path(runtime_root, "data", "example_inputs", "deg_table.csv")
  
  if (file.exists(attached_data_path)) {
    message("Note: No DEG table provided, using attached data asset: ", attached_data_path)
    opt$deg_table <- attached_data_path
  } else if (file.exists(example_path)) {
    message("Note: No DEG table provided, using example data from data/example_inputs/deg_table.csv")
    opt$deg_table <- example_path
  } else {
    stop("ERROR: --deg_table is required. Please upload a DEG table CSV file.", call. = FALSE)
  }
}

if (!file.exists(opt$deg_table)) {
  stop("ERROR: DEG table file not found: ", opt$deg_table, call. = FALSE)
}

# Convert string booleans to logical
opt$label_only_my_feature_list <- tolower(opt$label_only_my_feature_list) == "true"
opt$top_genes_labeled_only_if_passing_thresholds <- tolower(opt$top_genes_labeled_only_if_passing_thresholds) == "true"
opt$use_custom_axis_label <- tolower(opt$use_custom_axis_label) == "true"
opt$use_auto_axis_capping <- tolower(opt$use_auto_axis_capping) == "true"
opt$auto_axis_capping_symmetric_x <- tolower(opt$auto_axis_capping_symmetric_x) == "true"

# Read DEG table
deg_table <- read.csv(opt$deg_table, check.names = FALSE, stringsAsFactors = FALSE)

# Results directory
results_dir <- if (dir.exists("/results")) "/results" else file.path(runtime_root, "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

# Source volcano plot function
source(file.path(runtime_root, "code", "functions", "Volcano_Plot_Enhanced_v85.R"))

# Call volcano plot function
result <- volcano_plot_enhanced(
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
  custom_significance_label = opt$custom_significance_label,
  custom_log_fold_change_label = opt$custom_log_fold_change_label,
  plot_title = opt$plot_title,
  y_limit = opt$y_limit,
  use_auto_axis_capping = opt$use_auto_axis_capping,
  auto_axis_capping_quantile = opt$auto_axis_capping_quantile,
  auto_axis_capping_min_y_limit = 0,
  auto_axis_capping_symmetric_x = opt$auto_axis_capping_symmetric_x,
  custom_x_axis_limits = opt$custom_x_axis_limits,
  x_limit_padding = opt$x_limit_padding,
  y_limit_padding = opt$y_limit_padding,
  axis_label_size = opt$axis_label_size,
  point_size = opt$point_size,
  image_width = opt$image_width,
  image_height = opt$image_height,
  resolution_dpi_ = opt$resolution_dpi_,
  output_file_path = file.path(results_dir, "volcano_plot.png"),
  color_not_significant = opt$color_not_significant,
  color_fold_change_only = opt$color_fold_change_only,
  color_significant_only = opt$color_significant_only,
  color_significant_and_fold_change = opt$color_significant_and_fold_change
)

# Clean up default Rplots.pdf if created
default_rplots <- c(
  file.path(getwd(), "Rplots.pdf"),
  file.path(runtime_root, "Rplots.pdf"),
  file.path(runtime_root, "code", "Rplots.pdf")
)
for (path in unique(default_rplots[file.exists(default_rplots)])) {
  file.remove(path)
}

message("Volcano plots generated successfully in ", results_dir)
invisible(result)
