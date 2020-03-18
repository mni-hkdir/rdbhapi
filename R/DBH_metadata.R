#' @title Get metadata for DBH datasets
#'
#' @description Gets information on variables included in DBH datasets (type of variable, data type).
#'
#' @param table_id A vector of code names for the datasets to get variable information for
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom readr read_delim
#' @importFrom readr col_character
#' @importFrom readr locale
#' @importFrom readr show_progress
#' @importFrom dplyr %>%
#' @importFrom tibble as_tibble
#' @return A tibble
#' @export
#' @examples
#' dbh_metadata(88)




dbh_metadata <- function(table_id){
  url_meta <- "https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=002"
  res <- httr::GET(url_meta)
  res <- httr::content(res, as = "text")
  metadata <-
    readr::read_delim(
      res,
      delim = ",",
      col_types = readr::cols(.default = readr::col_character()),
      locale = readr::locale(decimal_mark = "."),
      na = "",
      trim_ws = TRUE,
      progress = readr::show_progress()
    )
  metadata[as.integer(metadata[["Tabell id"]]) %in% as.integer(table_id), ]
}

#' @title Get content data from DBH-API
#'
#' @param table_id A vector of code names for the datasets to get variable information for
#'
#' @return A tibble
#' @keywords internal

.dbh_content<-function(table_id){
  url_content<-"https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=001"
  res <- httr::GET(url_content)
  res <- httr::content(res, as = "text")
  content <-
    readr::read_delim(
      res,
      delim = ",",
      col_types = readr::cols(.default = readr::col_character()),
      locale = readr::locale(decimal_mark = "."),
      na = "",
      trim_ws = TRUE,
      progress = readr::show_progress()
    )
  content[as.integer(content[["Tabell id"]]) %in% as.integer(table_id), ]
}

#' Title
#'
#' @param table_id A vector of code names for the datasets to get variable information for
#'
#' @return A list of group by variables

#'

.dbh_groupBy <- function(table_id){
  metadata <- dbh_metadata(table_id)
  group_by <- as_tibble(metadata  %>% filter(metadata[["Group by (forslag)"]] =="J"))


  if (is_empty(group_by[["Group by (forslag)"]]))
  {
    group_by=NULL
  }
  else
  {
    group_by=as.list(group_by[["Variabel navn"]])
  }
  group_by
}

