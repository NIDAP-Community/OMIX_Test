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
  required_dirs <- c("R", "tests", "schemas")
  required_files <- c("module.yml", "README.md", "CHANGELOG.md")
  required_fields <- c(
    "name",
    "display_name",
    "version",
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

  version <- manifest[["version"]]
  invalid_version <- character()
  if (!is.null(version) && nzchar(version) &&
      !grepl("^[0-9]+\\.[0-9]+\\.[0-9]+([-.][A-Za-z0-9][A-Za-z0-9.-]*)?$", version)) {
    invalid_version <- version
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
    issue_lines("missing entrypoint: ", missing_entrypoint),
    issue_lines("invalid semver version: ", invalid_version)
  )

  issues <- issues[nzchar(issues)]

  list(
    ok = length(issues) == 0,
    module_dir = module_dir,
    issues = issues,
    manifest = manifest
  )
}

read_manifest_version <- function(text) {
  version_line <- grep("^version:[[:space:]]*", text, value = TRUE)
  if (length(version_line) == 0) {
    return(NA_character_)
  }
  sub("^version:[[:space:]]*", "", version_line[[1]])
}

changed_module_files <- function(base_ref) {
  files <- system2(
    "git",
    c("diff", "--name-only", base_ref, "HEAD", "--", "modules"),
    stdout = TRUE,
    stderr = TRUE
  )
  files[nzchar(files)]
}

read_file_at_ref <- function(ref, path) {
  output <- system2(
    "git",
    c("show", paste0(ref, ":", path)),
    stdout = TRUE,
    stderr = FALSE
  )
  status <- attr(output, "status")
  if (!is.null(status) && status != 0) {
    return(character())
  }
  output
}

release_impacting <- function(paths, module) {
  prefix <- paste0("modules/", module, "/")
  rel <- sub(paste0("^", prefix), "", paths)
  any(grepl("^(R|code|runtime|schemas)/", rel) | rel == "module.yml")
}

check_module_versioning <- function(base_ref) {
  files <- changed_module_files(base_ref)
  module_files <- grep("^modules/[^/]+/", files, value = TRUE)

  if (length(module_files) == 0) {
    return(character())
  }

  modules <- sort(unique(sub("^modules/([^/]+)/.*$", "\\1", module_files)))
  issues <- character()

  for (module in modules) {
    paths <- grep(paste0("^modules/", module, "/"), module_files, value = TRUE)
    if (!release_impacting(paths, module)) {
      next
    }

    manifest_path <- file.path("modules", module, "module.yml")
    changelog_path <- file.path("modules", module, "CHANGELOG.md")

    current_manifest <- readLines(manifest_path, warn = FALSE)
    base_manifest <- read_file_at_ref(base_ref, manifest_path)
    current_version <- read_manifest_version(current_manifest)
    base_version <- read_manifest_version(base_manifest)

    version_changed <- !identical(current_version, base_version)
    changelog_changed <- changelog_path %in% files

    if (is.na(current_version) || !nzchar(current_version)) {
      issues <- c(issues, paste0(module, ": missing version in module.yml"))
    } else if (!grepl("^[0-9]+\\.[0-9]+\\.[0-9]+([-.][A-Za-z0-9][A-Za-z0-9.-]*)?$", current_version)) {
      issues <- c(issues, paste0(module, ": version is not SemVer: ", current_version))
    }

    if (!version_changed) {
      issues <- c(issues, paste0(module, ": release-impacting changes require a module.yml version update"))
    }

    if (!changelog_changed) {
      issues <- c(issues, paste0(module, ": release-impacting changes require a CHANGELOG.md entry"))
    }
  }

  issues
}
