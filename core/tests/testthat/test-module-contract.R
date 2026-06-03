test_that("module contract validation reports scaffold modules as valid", {
  repo_root <- normalizePath(file.path("..", ".."), mustWork = TRUE)
  module_dir <- file.path(repo_root, "modules", "volcano")

  skip_if_not(dir.exists(module_dir))

  result <- validate_module_contract(module_dir)
  expect_true(result$ok, info = paste(result$issues, collapse = "\n"))
})

