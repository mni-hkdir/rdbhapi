#' @title Get metadata for DBH datasets
#'
#' @description Gets information on variables included in DBH datasets (type of variable, data type).
#'
#' @param table_id A vector of code names for the datasets to get variable information for, or NULL to get info for all variables.
#' @return A tibble
#' @export
#' @examples
#' dbh_metadata(88)

dbh_metadata <- function(table_id = NULL) {
  metadata <- .get_new_metadata()
  if (!is.null(table_id)) {
    metadata <- metadata[metadata[["Tabell id"]] %in% as.character(table_id), ]
  }
  metadata
}

#' Download table with metadata for variables in DBH-API
#' @keywords internal
#' @return a tibble

.get_new_metadata <- function() {
  url_meta <- "https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=002"
  res <- httr::GET(url_meta)
  res <- httr::content(res, as = "text", encoding = "UTF-8")
  res <-
    readr::read_delim(
      res,
      delim = ",",
      col_types = readr::cols(.default = readr::col_character()),
      na = "",
      trim_ws = TRUE,
      progress = FALSE
    )
  res
}


#' Get table with metadata for variables in the DBH API
#' @keywords internal
#' @return a tibble


.get_metadata <- function(table_id = NULL) {
  t <- Sys.time()
  if (t >= .env$metadata_expiration) {
    .env$metadata <- .get_new_metadata()
    .env$metadata_expiration <- t + 86400
  }
  metadata <- .env$metadata
  if (!is.null(table_id)) {
    metadata <- metadata[metadata[["Tabell id"]] %in% as.character(table_id), ]
  }
  metadata
}


#' @title Table of contents for DBH-API
#'
#' @param table_id A vector of code names for the datasets retrieve information for, or NULL to get the whole table of contents
#'
#' @return a tibble

dbh_toc <- function(table_id = NULL) {
  toc <- .get_new_toc()
  if (!is.null(table_id)) {
    toc <- toc[toc[["Tabell id"]] %in% as.character(table_id), ]
  }
  toc
}


#' Download table of contents of the DBH API
#' @keywords internal
#' @return a tibble

.get_new_toc <- function() {
  url_meta <- "https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=001"
  res <- httr::GET(url_meta)
  res <- httr::content(res, as = "text", encoding = "UTF-8")
  res <-
    readr::read_delim(
      res,
      delim = ",",
      col_types = readr::cols(.default = readr::col_character()),
      na = "",
      trim_ws = TRUE,
      progress = FALSE
    )
  res
}

#' Get table with content for variables in the DBH-API
#' @keywords internal
#' @return a tibble

.get_toc <- function(table_id = NULL) {
  t <- Sys.time()
  if (t >= .env$toc_expiration) {
    .env$toc <- .get_new_toc()
    .env$toc_expiration <- t + 86400
  }
  toc <- .env$toc
  if (!is.null(table_id)) {
    toc <- toc[toc[["Tabell id"]] %in% as.character(table_id), ]
  }
  toc
}

#' Default group_by for a table as suggested by DBH
#'
#' @param table_id A vector of code names for the datasets to get variable information for
#' @return A list of group by variables
#' @keywords internal
#' @return a tibble


.default_group_by <- function(table_id){
  metadata <- .get_metadata()
  metadata <- metadata[(metadata$`Tabell id` %in% table_id) &
                         (metadata$`Group by (forslag)` %in% "J"), ]
  group_by <- metadata[["Variabel navn"]]
  group_by <- if (length(group_by) == 0) NULL else as.list(group_by)
  if(length(group_by)!=0){
    message("Default group by :", as.list(group_by))
    group_by
  }

}

