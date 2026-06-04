# Environment

This module expects the shared OMIX `r-visualization` runtime.

`postInstall.sh` installs or verifies the R packages needed by the wrapper and Volcano implementation.
`postinstall` is included as a compatibility wrapper for platforms that expect a lowercase post-install hook.
`Dockerfile` makes the CRAN dependency installation explicit for Code Ocean image builds.
