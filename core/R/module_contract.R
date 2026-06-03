read_module_manifest <- function(path) {
  if (dir.exists(path)) {
    path <- file.path(path, "module.yml")
  }

  if (!file.exists(path)) {
    stop("Missing module manifest: ", path, call. = FALSE)
  }

  lines <- readLines(path, warn = FALSE)
  fields <- list()

  for (line in lines) {
    match <- regexec("^([A-Za-z0-9_ -]+):[[:space:]]*(.*)$", line)
    parts <- regmatches(line, match)[[1]]
    if (length(parts) == 3) {
      key <- trimws(parts[[2]])
      value <- trimws(parts[[3]])
      if (nzchar(key)) {
        fields[[key]] <- value
      }
    }
  }

  fields
}

validate_module_contract <- function(module_dir) {
  required_dirs <- c("R", "tests", "schemas", "app-panel", "code")
  required_files <- c("module.yml", "README.md", "CHANGELOG.md")
  required_fields <- c(
    "name",
    "display_name",
    "module_type",
    "starter_environment",
    "entrypoint"
  )

  missing_dirs <- required_dirs[!dir.exists(file.path(module_dir, required_dirs))]
  missing_files <- required_files[!file.exists(file.path(module_dir, required_files))]
  manifest <- read_module_manifest(module_dir)
  missing_fields <- required_fields[!required_fields %in% names(manifest)]

  entrypoint <- manifest[["entrypoint"]]
  missing_entrypoint <- character()
  if (!is.null(entrypoint) && nzchar(entrypoint)) {
    entrypoint_path <- file.path(module_dir, entrypoint)
    if (!file.exists(entrypoint_path)) {
      missing_entrypoint <- entrypoint
    }
  }

  issue_lines <- function(prefix, values) {
    if (length(values) == 0) {
      return(character())
    }
    paste0(prefix, values)
  }

  issues <- c(
    issue_lines("missing directory: ", missing_dirs),
    issue_lines("missing file: ", missing_files),
    issue_lines("missing manifest field: ", missing_fields),
    issue_lines("missing entrypoint: ", missing_entrypoint)
  )

  issues <- issues[nzchar(issues)]

  list(
    ok = length(issues) == 0,
    module_dir = module_dir,
    issues = issues,
    manifest = manifest
  )
}
