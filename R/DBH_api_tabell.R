
#' Send query to DBH-API in JSON format

#' @description Help function which send query form r to DBH-API, it is designs in the way that it looks like api query and allows
#' the same functionality as in DBH-API
#'
#' @param tabell_id a code name for dataset
#' @param filters is the same as filters in DBH-API: item, all, top, between, greater than
#' @param group_by group by variables in the same way as in DBH-API
#' @param sort_by sort variables
#' @param exclude variable values we do not want



#' @return query
#' @export

dbh_json_query <-
  function(tabell_id,
    filters = list(),
    group_by = list(),
    sort_by = list(),
    exclude = NULL) {

    filter_query <- list()
    exclude_warning <- character(0)

    for (i in seq_along(filters)) {
      filter_query[[i]] <-
        list(variabel = enc2utf8(names(filters)[i]),
          selection = list(filter = "item",
            values = lapply(filters[[i]],
              function(s) enc2utf8(as.character(s)))))
      if (filters[[i]][1] == "*") {
        filter_query[[i]]$selection$filter <- "all"
        if (names(filters)[i] %in% names(exclude)) {
          filter_query[[i]]$selection$exclude = lapply(exclude[[names(filters)[i]]],
            function(s) enc2utf8(as.character(s)))
        }
      } else if (filters[[i]][1] %in% c("top",  "lessthan", "greaterhan")) {
        filter_query[[i]]$selection$filter <- filters[[i]][1]
        filter_query[[i]]$selection$values <- lapply(filters[[i]][2],
          function(s) enc2utf8(as.character(s)))
        if (names(filters)[i] %in% names(exclude)) {
          filter_query[[i]]$selection$exclude = lapply(exclude[[names(filters)[i]]],
            function(s) enc2utf8(as.character(s)))
        }
      } else if (filters[[i]][1] == "between") {
        filter_query[[i]]$selection$filter <- "between"
        filter_query[[i]]$selection$values <- c(lapply(filters[[i]][2],
          function(s) enc2utf8(as.character(s))),lapply(filters[[i]][3],
            function(s) enc2utf8(as.character(s))))
        if (names(filters)[i] %in% names(exclude)) {
          filter_query[[i]]$selection$exclude = lapply(exclude[[names(filters)[i]]],
            function(s) enc2utf8(as.character(s)))
        }
      } else if (names(filters)[i] %in% names(exclude)) {
        exclude_warning <-
          paste0(ifelse(length(exclude_warning) == 0,
            "Excluding filters cannot be combined with the item filter for the following variables: ",
            paste0(exclude_warning, ", ")),
            names(filters)[i])
      }
    }

    if (length(exclude_warning) != 0) warning(exclude_warning)

    return(list(tabell_id = tabell_id ,
      groupBy = lapply(group_by, function(s) enc2utf8(as.character(s))),
      sortBy = lapply(sort_by, function(s) enc2utf8(as.character(s))),
      filter = filter_query))
  }



#'  Get data from API as R dataframe
#'
#' @description Send request from R to DBH-API and get data from DBH-API into R.
#'  Data are converted in right format using help function dbh_metadata \code{\link{dbh_metadata}}
#'  For token users it is possible to get token using function \code{\link{dbh_api_token}} and use it further
#'
#' @param tabell_id a code name for dataset
#' @param filters is the same as filters in DBH-API: item, all, top, between, greaterthan, lessthan
#' @param group_by group by variables in the same way as in DBH-API
#' @param sort_by sort variables in the same way as in DBH-API
#' @param exclude variable values we do not want to include in filtering
#' @param api_versjon defined DBH-API constant value 1
#' @param statuslinje defined DBH-API constant value N
#' @param decimal_separator defined DBH-API value
#' @param meta is set to FALSE and does not return metadata, set meta=TRUE and you will get metadata
#'
#' @importFrom httr GET
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom httr POST
#' @importFrom readr locale
#' @importFrom readr read_delim
#' @importFrom readr cols
#' @importFrom readr col_character
#' @importFrom readr show_progress

#' @return R dataframe
#' @export
#' @examples

#' dbh_tabell(60, filters=list( "Institusjonskode"="1120","Alder"=c("between",c("30","40")))
#' , group_by="Alder")

dbh_tabell <- function(tabell_id,
  filters=NULL,
  group_by = NULL,
  sort_by = NULL, exclude =NULL,
  api_versjon=1,
  statuslinje="N",
  decimal_separator = readr::locale()$decimal_mark,
  meta=FALSE) {
  if (is.null(filters)) {
    url <- paste("https://api-stage.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=", tabell_id, sep = "")

    res <- httr::GET(url, httr::add_headers(Authorization = paste("Bearer", dbh_api_token(), sep = " ")))
    status <- res$status_code
    res <- httr::content(res, as = "text")

    if (status == 200) {
      data = readr::read_delim(res,
        delim = ",",
        col_types = readr::cols(.default = readr::col_character()),
        locale = readr::locale(decimal_mark = "."),
        na = "",
        trim_ws = TRUE, progress = readr::show_progress()
      )
    }
    else {return(status)}
  }
  else {
    query <- dbh_json_query(tabell_id = tabell_id, filters = filters, group_by = group_by, sort_by = sort_by, exclude = exclude)
    post_body = rjson::toJSON(c(list(
      api_versjon = api_versjon,
      statuslinje = statuslinje,
      decimal_separator = decimal_separator),
      query))


    resultat <- httr::POST(url = "https://api.nsd.no/dbhapitjener/Tabeller/hentCSVTabellData",
      httr::add_headers(`Content-Type` = "application/json", Authorization = paste("Bearer", dbh_api_token(), sep =  " ")),
      body = post_body,
      encode = 'json' )
    status <- resultat$status_code
    resultat <- httr::content(resultat, as = "text")
    if (status == 200) {
      data = readr::read_delim(resultat,
        delim = ";",
        col_types = readr::cols(.default = readr::col_character()),
        locale = readr::locale(decimal_mark = decimal_separator),
        na = "",
        trim_ws = TRUE, progress = readr::show_progress()
      )
    }
    else{
      return(status)
    }

  }
  metadata <- dbh_metadata(tabell_id = tabell_id)
  for (i in seq_along(names(data))) {
    if (isTRUE(metadata[["Numeric_variable"]][match(names(data)[i], metadata[["Variabel navn"]])]))
    {

      data[[i]] <- as.numeric(data[[i]])
    }
  }
  if (meta == TRUE) {
    return(list(data, metadata))}
  else {
    return(data)
  }

}


