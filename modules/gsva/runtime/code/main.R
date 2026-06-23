#!/usr/bin/env Rscript

# OMIX GSVA - CLI-first Gene Set Variation Analysis
# Accepts parameters via command-line arguments from App Panel

suppressPackageStartupMessages({
  library(optparse)
  library(dplyr)
  library(GSVA)
  library(l2psupp)
  library(stringr)
  library(tibble)
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
  make_option("--normalized_data", type = "character", help = "Path to normalized expression data (TSV/CSV)"),
  make_option("--sample_metadata", type = "character", help = "Path to sample metadata table (TSV/CSV)"),
  make_option("--pathways_database", type = "character", help = "Path to pathways database (TSV/CSV). Optional when built-in MSigDB is available."),
  make_option("--gene_column", type = "character", default = "Gene", help = "Gene name column in normalized data"),
  make_option("--sample_name_column", type = "character", default = "Sample", help = "Column containing sample name in metadata"),
  make_option("--samples_to_include", type = "character", default = "", help = "Comma-separated sample columns to include"),
  make_option("--species", type = "character", default = "Human", help = "Species in normalized data"),
  make_option("--database_species", type = "character", default = "Human", help = "Species in pathways database"),
  make_option("--collections_to_include", type = "character", default = "H: hallmark gene sets", help = "Comma-separated collections to include"),
  make_option("--custom_pathways_database", type = "character", default = "false", help = "Use custom species for pathways database"),

  make_option("--custom_species", type = "character", default = "Mouse", help = "Species for custom pathways database"),
  make_option("--method", type = "character", default = "gsva", help = "Method: gsva, ssgsea, zscore, plage"),
  make_option("--minimum_geneset_size", type = "integer", default = 15L, help = "Minimum geneset size"),
  make_option("--maximum_geneset_size", type = "integer", default = 1200L, help = "Maximum geneset size"),
  make_option("--update_genes", type = "character", default = "true", help = "Update gene symbols using l2psupp"),
  make_option("--input_delim", type = "character", default = "\t", help = "Delimiter for input files"),
  make_option("--image_width", type = "integer", default = 12L, help = "Plot width in inches"),
  make_option("--image_height", type = "integer", default = 10L, help = "Plot height in inches")
)

parser <- OptionParser(
  usage = "Usage: %prog --normalized_data PATH --sample_metadata PATH [options]\n\nThe built-in MSigDB v2023.2 database is used by default. Override with --pathways_database.",
  option_list = option_list,
  description = "Run Gene Set Variation Analysis (GSVA) on expression data"
)

opt <- parse_args(parser, args = commandArgs(trailingOnly = TRUE))

# Resolve input file paths
resolve_path <- function(path, fallbacks) {
  if (!is.null(path) && nzchar(path)) {
    if (file.exists(path)) return(path)
    # Try relative to runtime_root
    rel <- file.path(runtime_root, path)
    if (file.exists(rel)) return(rel)
    stop("File not found: ", path, call. = FALSE)
  }
  for (fb in fallbacks) {
    if (file.exists(fb)) return(fb)
  }
  NULL
}

norm_path <- resolve_path(opt$normalized_data, c(
  "/data/normalized_data.tsv",
  file.path(runtime_root, "data", "example_inputs", "normalized_data.tsv")
))
meta_path <- resolve_path(opt$sample_metadata, c(
  "/data/sample_metadata.tsv",
  file.path(runtime_root, "data", "example_inputs", "sample_metadata.tsv")
))
# Pathways database: check user-supplied file, then built-in MSigDB RDS
builtin_msigdb <- "/data/msigdb_v2023_2.rds"
pathways_path <- resolve_path(opt$pathways_database, c(
  "/data/pathways_database.tsv",
  file.path(runtime_root, "data", "example_inputs", "pathways_database.tsv")
))

pathways_df <- NULL
if (!is.null(pathways_path)) {
  # User provided a file — it will be read by run_gsva via pathways_database_file
} else if (file.exists(builtin_msigdb)) {
  message("Using built-in MSigDB v2023.2 database")
  pathways_df <- readRDS(builtin_msigdb)
  pathways_path <- NULL
} else {
  stop("ERROR: --pathways_database is required (no built-in MSigDB found).", call. = FALSE)
}

if (is.null(norm_path)) stop("ERROR: --normalized_data is required.", call. = FALSE)
if (is.null(meta_path)) stop("ERROR: --sample_metadata is required.", call. = FALSE)

# Results directory
results_dir <- if (dir.exists("/results")) "/results" else file.path(runtime_root, "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

# Source GSVA function
source(file.path(runtime_root, "code", "functions", "GSVA_v1.R"))

# Convert string booleans
opt$custom_pathways_database <- tolower(opt$custom_pathways_database) == "true"
opt$update_genes <- tolower(opt$update_genes) == "true"

# Parse comma-separated collections
collections <- trimws(unlist(strsplit(opt$collections_to_include, ",")))

# Parse samples_to_include — if empty, will be derived from data
samples_to_include <- if (nzchar(opt$samples_to_include)) {
  trimws(unlist(strsplit(opt$samples_to_include, ",")))
} else {
  NULL
}

# Read normalized data to auto-detect sample columns if needed
norm_data <- utils::read.delim(norm_path, sep = opt$input_delim, check.names = FALSE, stringsAsFactors = FALSE)
if (is.null(samples_to_include)) {
  samples_to_include <- setdiff(colnames(norm_data), opt$gene_column)
}

# Call the GSVA function
result <- run_gsva(
  normalized_data = NULL,
  sample_metadata_table = NULL,
  pathways_database = pathways_df,
  gene_column = opt$gene_column,
  sample_name_column = opt$sample_name_column,
  samples_to_include = samples_to_include,
  species = opt$species,
  database_species = opt$database_species,
  collections_to_include = collections,
  custom_pathways_database = opt$custom_pathways_database,
  custom_species = opt$custom_species,
  method = opt$method,
  minimum_geneset_size = opt$minimum_geneset_size,
  maximum_geneset_size = opt$maximum_geneset_size,
  update_genes = opt$update_genes,
  display_warnings = -1,
  normalized_data_file = norm_path,
  sample_metadata_file = meta_path,
  pathways_database_file = pathways_path,
  input_delim = opt$input_delim,
  export_results_file = file.path(results_dir, "gsva_results.csv"),
  export_plot_file = file.path(results_dir, "gsva_heatmap.png"),
  export_plot_width = opt$image_width,
  export_plot_height = opt$image_height
)

message("GSVA analysis complete. Results written to ", results_dir)
invisible(result)
