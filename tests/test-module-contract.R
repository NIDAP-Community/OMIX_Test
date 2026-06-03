source(file.path("core", "R", "module_contract.R"))

module_dirs <- list.dirs("modules", recursive = FALSE, full.names = TRUE)

if (length(module_dirs) == 0) {
  stop("No module directories found under modules/", call. = FALSE)
}

results <- lapply(module_dirs, validate_module_contract)
failed <- vapply(results, function(result) !result$ok, logical(1))

if (any(failed)) {
  for (result in results[failed]) {
    message("\n", result$module_dir)
    message(paste0(" - ", result$issues, collapse = "\n"))
  }
  stop("One or more modules failed the OMIX module contract.", call. = FALSE)
}

message("Validated ", length(module_dirs), " OMIX module contract(s).")

