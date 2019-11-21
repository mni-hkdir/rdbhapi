get_dbh_raw <- function(table_id) {



  url <- paste0("https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=", table_id)

  tfile <- tempfile()
  on.exit(unlink(tfile))

  # download and read file
  utils::download.file(url, tfile)

  data <-
    readr::read_delim(
      tfile,
      delim = ",",
      col_types = readr::cols(.default = readr::col_character()),
      locale = readr::locale(decimal_mark = "."),
      na = "",
      trim_ws = TRUE,
      progress = readr::show_progress()
    )

  data
}
