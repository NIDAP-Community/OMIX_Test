source(file.path("scripts", "lib", "module_governance.R"))

base_ref <- commandArgs(trailingOnly = TRUE)
if (length(base_ref) != 1 || !nzchar(base_ref)) {
  stop("Usage: Rscript scripts/check_module_versioning.R <base-ref>", call. = FALSE)
}
base_ref <- base_ref[[1]]

files <- changed_module_files(base_ref)
module_files <- grep("^modules/[^/]+/", files, value = TRUE)
if (length(module_files) == 0) {
  message("No module changes detected for versioning check.")
  quit(status = 0)
}

issues <- check_module_versioning(base_ref)
if (length(issues) == 0) {
  message("Module versioning check passed.")
  quit(status = 0)
}

writeLines(paste0(" - ", issues))
stop("Module versioning check failed.", call. = FALSE)
