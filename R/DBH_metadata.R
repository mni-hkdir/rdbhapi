#' Get metadata for DBH datasets
#'
#' Gets information on variables included in DBH datasets (type of variable, data type).
#'
#' @param table_id A vector of code names for the datasets to get variable information for
#' @return A \code{\link{tibble()}}
#' @export
#' @examples
#' dbh_metadata(88)




dbh_metadata <- function(table_id){
  url_meta = "https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=002"
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
