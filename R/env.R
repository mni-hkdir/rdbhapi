# Package environment
#' @importFrom rlang env
.env <- new.env(parent = emptyenv())

# Variables for current token and expiration time

.env$token <- ""

# Variables for cached metadata for variables
# and table of contents of the DBH API

.env$metadata <- NULL


.env$toc <- NULL
