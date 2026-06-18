library(testthat)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(stringr)
library(tidyr)

# Locate the module root by finding this file's directory.
# Works with test_file(), test_dir(), and source().
this_file <- (function() {
  # When run via testthat
  if (nzchar(Sys.getenv("TESTTHAT_PKG", ""))) {
    return(testthat::test_path("."))
  }
  # When called via Rscript / source
  for (i in rev(seq_len(sys.nframe()))) {
    f <- sys.frame(i)$ofile
    if (!is.null(f)) return(dirname(normalizePath(f, mustWork = TRUE)))
  }
  # Fallback: assume cwd is the tests/ dir
  getwd()
})()

runtime_root <- normalizePath(file.path(this_file, "..", "runtime"), mustWork = TRUE)
source(file.path(runtime_root, "code", "functions", "Volcano_Plot_Enhanced.R"))

example_csv <- file.path(runtime_root, "data", "example_inputs", "deg_table.csv")
deg_table <- read.csv(example_csv, check.names = FALSE, stringsAsFactors = FALSE)

test_that("basic volcano plot returns a data frame with rank columns", {
  result <- volcano_plot_enhanced(
    deg_table = deg_table,
    pvalue_type = "nominal",
    column_with_feature_id = "Gene",
    significance_column = "A-B_pval",
    log2_fold_change_column = "A-B_logFC",
    output_file_path = NULL
  )
  expect_s3_class(result, "data.frame")
  expect_true(any(grepl("_rank$", colnames(result))))
  expect_equal(nrow(result), nrow(deg_table))
})

test_that("column inference works when columns are not specified", {
  result <- volcano_plot_enhanced(
    deg_table = deg_table,
    pvalue_type = "nominal",
    column_with_feature_id = NULL,
    significance_column = NULL,
    log2_fold_change_column = NULL,
    output_file_path = NULL
  )
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(deg_table))
})

test_that("adjusted pvalue_type prefers adjusted columns", {
  result <- volcano_plot_enhanced(
    deg_table = deg_table,
    pvalue_type = "adjusted",
    column_with_feature_id = "Gene",
    significance_column = NULL,
    log2_fold_change_column = NULL,
    output_file_path = NULL
  )
  expect_s3_class(result, "data.frame")
})

test_that("custom feature list labels only specified genes", {
  result <- volcano_plot_enhanced(
    deg_table = deg_table,
    pvalue_type = "nominal",
    column_with_feature_id = "Gene",
    significance_column = "A-B_pval",
    log2_fold_change_column = "A-B_logFC",
    label_only_my_feature_list = TRUE,
    my_feature_list = "STAT1,IRF7",
    output_file_path = NULL
  )
  expect_s3_class(result, "data.frame")
})

test_that("multi-contrast mode produces wider output", {
  result <- volcano_plot_enhanced(
    deg_table = deg_table,
    pvalue_type = "nominal",
    column_with_feature_id = "Gene",
    significance_column = c("A-B_pval", "A-C_pval"),
    log2_fold_change_column = c("A-B_logFC", "A-C_logFC"),
    output_file_path = NULL
  )
  expect_s3_class(result, "data.frame")
  rank_cols <- grep("_rank$", colnames(result), value = TRUE)
  expect_equal(length(rank_cols), 2)
})

test_that("file path input works", {
  result <- volcano_plot_enhanced(
    deg_table = example_csv,
    pvalue_type = "nominal",
    column_with_feature_id = "Gene",
    significance_column = "A-B_pval",
    log2_fold_change_column = "A-B_logFC",
    output_file_path = NULL
  )
  expect_s3_class(result, "data.frame")
})

test_that("invalid file path errors informatively", {

  expect_error(
    volcano_plot_enhanced(
      deg_table = "/nonexistent/path.csv",
      pvalue_type = "nominal",
      column_with_feature_id = "Gene",
      significance_column = "A-B_pval",
      log2_fold_change_column = "A-B_logFC",
      output_file_path = NULL
    ),
    "does not exist"
  )
})

test_that("missing required columns errors informatively", {
  expect_error(
    volcano_plot_enhanced(
      deg_table = deg_table,
      pvalue_type = "nominal",
      column_with_feature_id = "Gene",
      significance_column = "nonexistent_col",
      log2_fold_change_column = "A-B_logFC",
      output_file_path = NULL
    ),
    "not present"
  )
})

test_that("output file is written when path is provided", {
  tmp_png <- tempfile(fileext = ".png")
  on.exit(unlink(tmp_png), add = TRUE)

  volcano_plot_enhanced(
    deg_table = deg_table,
    pvalue_type = "nominal",
    column_with_feature_id = "Gene",
    significance_column = "A-B_pval",
    log2_fold_change_column = "A-B_logFC",
    image_width = 600,
    image_height = 600,
    resolution_dpi_ = 72,
    output_file_path = tmp_png
  )
  expect_true(file.exists(tmp_png))
  expect_gt(file.size(tmp_png), 0)
})
