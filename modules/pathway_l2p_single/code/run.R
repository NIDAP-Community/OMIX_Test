#!/usr/bin/env Rscript

file_arg <- commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))][1]
module_root <- normalizePath(file.path(dirname(normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)), ".."))
run_script <- file.path(module_root, "runtime", "run.sh")
status <- system2("bash", c(run_script, commandArgs(TRUE)))
quit(status = status)
