# Package environment
#' @importFrom rlang env
.env <- new.env(parent = emptyenv())

# Variables for current token and expiration time
.env$token_expiration <- 0
.env$token <- ""

# Variables for cached metadata for variables
# and table of contents of the DBH API
.env$metadata_expiration <- 0
.env$metadata <- NULL

.env$toc_expiration <- 0
.env$toc <- NULL
