#!/usr/bin/env Rscript

module_name <- "volcano"
display_name <- "OMIX Volcano"
source_template <- "Volcano_Plot_Enhanced_v85.R"
entry_function <- "volcano_plot_enhanced"

get_script_dir <- function() {
  file_arg <- commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))]
  if (length(file_arg) == 0) {
    return(getwd())
  }
  dirname(normalizePath(sub("^--file=", "", file_arg[1]), mustWork = TRUE))
}

runtime_root <- normalizePath(file.path(get_script_dir(), ".."), mustWork = TRUE)

usage <- function() {
  cat(paste0(
    display_name, "\n\n",
    "Usage: run.sh [--params PATH] [--deg-table PATH] [--results-dir PATH] [--dry-run]\n\n",
    "Defaults use Code Ocean-style mounted data when present:\n",
    "  --params      /data/params.json, otherwise data/example_inputs/params.json\n",
    "  --deg-table   /data/deg_table.csv, otherwise value in params JSON\n",
    "  --results-dir /results, otherwise results/\n"
  ))
}

parse_args <- function(args) {
  opts <- list(help = FALSE, dry_run = FALSE)
  i <- 1
  while (i <= length(args)) {
    arg <- args[i]
    if (arg %in% c("-h", "--help")) {
      opts$help <- TRUE
    } else if (arg == "--dry-run") {
      opts$dry_run <- TRUE
    } else if (arg %in% c("--params", "--deg-table", "--deg_table", "--results-dir", "--results_dir")) {
      if (i == length(args)) {
        stop("Missing value for ", arg, call. = FALSE)
      }
      opts[[gsub("-", "_", sub("^--", "", arg))]] <- args[i + 1]
      i <- i + 1
    } else if (grepl("^--params=", arg)) {
      opts$params <- sub("^--params=", "", arg)
    } else if (grepl("^--deg-table=", arg)) {
      opts$deg_table <- sub("^--deg-table=", "", arg)
    } else if (grepl("^--deg_table=", arg)) {
      opts$deg_table <- sub("^--deg_table=", "", arg)
    } else if (grepl("^--results-dir=", arg)) {
      opts$results_dir <- sub("^--results-dir=", "", arg)
    } else if (grepl("^--results_dir=", arg)) {
      opts$results_dir <- sub("^--results_dir=", "", arg)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
    i <- i + 1
  }
  opts
}

is_absolute_path <- function(path) {
  grepl("^/", path) || grepl("^[A-Za-z]:[\\\\/]", path)
}

resolve_path <- function(path) {
  if (is.null(path) || !nzchar(path)) {
    return(path)
  }
  if (is_absolute_path(path)) {
    return(path)
  }
  if (file.exists(path)) {
    return(normalizePath(path, mustWork = TRUE))
  }
  file.path(runtime_root, path)
}

default_existing_path <- function(paths) {
  for (path in paths) {
    if (file.exists(path)) {
      return(path)
    }
  }
  paths[length(paths)]
}

require_jsonlite <- function() {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("The jsonlite R package is required.", call. = FALSE)
  }
}

require_runtime_packages <- function() {
  packages <- c("dplyr", "tidyr", "ggplot2", "ggrepel", "stringr")
  missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing_packages) > 0) {
    stop(
      "Missing required R package(s): ",
      paste(missing_packages, collapse = ", "),
      ". Run environment/postInstall.sh or rebuild the Code Ocean environment.",
      call. = FALSE
    )
  }
}

remove_default_rplots <- function() {
  default_rplots <- unique(c(
    file.path(getwd(), "Rplots.pdf"),
    file.path(runtime_root, "Rplots.pdf"),
    file.path(runtime_root, "code", "Rplots.pdf")
  ))
  for (path in default_rplots[file.exists(default_rplots)]) {
    file.remove(path)
  }
}

opts <- parse_args(commandArgs(TRUE))
if (opts$help) {
  usage()
  quit(status = 0)
}

require_jsonlite()
require_runtime_packages()

params_path <- opts$params
if (is.null(params_path)) {
  params_path <- default_existing_path(c("/data/params.json", file.path(runtime_root, "data", "example_inputs", "params.json")))
}
params_path <- resolve_path(params_path)
if (!file.exists(params_path)) {
  stop("Missing params JSON: ", params_path, call. = FALSE)
}

params <- jsonlite::fromJSON(params_path)
deg_table_path <- opts$deg_table
if (is.null(deg_table_path)) {
  deg_table_path <- Sys.getenv("OMIX_DEG_TABLE", unset = "")
}
if (!nzchar(deg_table_path) && !is.null(params$inputs$deg_table_file)) {
  deg_table_path <- params$inputs$deg_table_file
}
if (!nzchar(deg_table_path)) {
  deg_table_path <- default_existing_path(c("/data/deg_table.csv", file.path(runtime_root, "data", "example_inputs", "deg_table.csv")))
}
deg_table_path <- resolve_path(deg_table_path)
if (!file.exists(deg_table_path)) {
  stop("Missing DEG table CSV: ", deg_table_path, call. = FALSE)
}

results_dir <- opts$results_dir
if (is.null(results_dir)) {
  results_dir <- Sys.getenv("RESULTS_DIR", unset = "")
}
if (!nzchar(results_dir)) {
  results_dir <- if (dir.exists("/results")) "/results" else file.path(runtime_root, "results")
}
results_dir <- resolve_path(results_dir)
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

deg_table <- utils::read.csv(deg_table_path, check.names = FALSE)
function_args <- params$function_args
function_args$function_name <- NULL
function_args$deg_table <- deg_table
function_args$output_file_path <- file.path(results_dir, "volcano_plot.png")

required_columns <- unique(c(function_args$column_with_feature_id, unlist(function_args$significance_column), unlist(function_args$log2_fold_change_column)))
missing_columns <- setdiff(required_columns, names(deg_table))
if (length(missing_columns) > 0) {
  stop("DEG table is missing required column(s): ", paste(missing_columns, collapse = ", "), call. = FALSE)
}

source_path <- file.path(runtime_root, "code", "functions", source_template)
source(source_path)
if (!exists(entry_function)) {
  stop("Missing entry function after sourcing ", source_template, ": ", entry_function, call. = FALSE)
}

if (opts$dry_run) {
  jsonlite::write_json(
    list(
      module = module_name,
      display_name = display_name,
      source_template = source_template,
      entry_function = entry_function,
      params_path = params_path,
      deg_table_path = deg_table_path,
      results_dir = results_dir,
      rows = nrow(deg_table),
      columns = names(deg_table),
      dry_run = TRUE
    ),
    file.path(results_dir, "volcano_dry_run.json"),
    pretty = TRUE,
    auto_unbox = TRUE
  )
  message("Dry-run validation complete: ", display_name)
  quit(status = 0)
}

result <- do.call(entry_function, function_args)
remove_default_rplots()
jsonlite::write_json(
  list(
    module = module_name,
    display_name = display_name,
    source_template = source_template,
    entry_function = entry_function,
    params_path = params_path,
    deg_table_path = deg_table_path,
    results_dir = results_dir,
    output_files = list.files(results_dir, full.names = FALSE),
    completed_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
  ),
  file.path(results_dir, "run_manifest.json"),
  pretty = TRUE,
  auto_unbox = TRUE
)

invisible(result)
