#' @title Get metadata for DBH datasets
#'
#' @description Gets information on variables
#' included in DBH datasets (type of variable, data type).
#'
#' @param table_id Numeric. Required. The unique ID of the dataset.
#' @return A tibble containing variable metadata.
#' @examples
#' \dontrun{
#' # Show metadata for table 88
#' meta_table <- dbh_metadata(88)
#' }

#' @export

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
  url_meta <- "https://dbh.hkdir.no/api/Tabeller/bulk-csv?rptNr=002"
  .fetch_data(url_meta)
}
#' Generic function to fetch data from DBH API
#' @keywords internal
#' @param url URL to fetch the data from
#' @return A tibble
.fetch_data <- function(url) {
  res <- httr::GET(url)
  res <- httr::content(res, as = "text", encoding = "UTF-8")
  readr::read_delim(
    res,
    delim = ",",
    col_types = readr::cols(.default = readr::col_character()),
    na = "",
    trim_ws = TRUE,
    progress = FALSE
  )
}



#' Download table of contents of the DBH API
#' @keywords internal
#' @return a tibble

.get_new_toc <- function() {
  url_toc <- "https://dbh.hkdir.no/api/Tabeller/bulk-csv?rptNr=001"
  .fetch_data(url_toc)
}

#' Default group_by for a table as suggested by DBH
#'
#' @param table_id A vector of code names for the
#' datasets to get variable information for
#' @return A list of group by variables
#' @keywords internal
#' @return a tibble


.default_group_by <- function(table_id) {

  excel_path <- system.file("extdata", "DBHAPI_Variabler.xlsx", package = "rdbhapi")

  if (excel_path == "") {
    stop("Excel file not found in extdata folder.")
  }

  metadata <- readxl::read_excel(excel_path)

  filtered_metadata <- metadata[metadata$`Tabell id` == table_id, ]

  if (nrow(filtered_metadata) == 0) {
    message("No group_by or variable_liste found for Tabell id: ", table_id)
    return(NULL)
  }

  group_by <- filtered_metadata$Group_by
  variable_liste <- filtered_metadata$Variabelliste

  group_by_list <- if (!is.null(group_by)) unlist(strsplit(group_by, ",")) else NULL
  variable_list <- if (!is.null(variable_liste)) unlist(strsplit(variable_liste, ",")) else NULL

  list(
    group_by = group_by_list,
    variable_liste = variable_list
  )
}

#' Get table with content for variables in the DBH-API
#' @keywords internal
#' @return a tibble
.get_toc <- function(table_id = NULL) {
  toc <- .get_new_toc()
  if (!is.null(table_id)) {
    toc <- toc[toc[["Tabell id"]] %in% as.character(table_id), ]
  }
  toc
}
