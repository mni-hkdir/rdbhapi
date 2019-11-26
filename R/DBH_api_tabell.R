
#' Create query for DBH-API
#'
#' @description Helper function to create queries to be converted to the DBH-API JSON format
#' for queries.
#'
#' @param table_id The code name for the dataset
#' @param filters A named list, where the names are the names of the variables
#'   in the dataset to be filtered, and the values contain the matching
#'   conditions.
#' @param group_by A list of variables to include in the aggregation for
#'   aggregating tables.
#' @param sort_by A list of variables that define the sorting order.
#' @param exclude A named list, where the names must also occur in
#'   \code{filters}, and the values specify values to be excluded from the
#'   filter.
#' @param variables A list of variables, do not combine with group_by
#' @return A list of length containing the DBH-API query that can be converted
#'   to the proper JSON
#' @keywords internal

.make_query <-
  function(
    table_id,
    filters,
    group_by = list(),
    sort_by = list(),
    exclude = NULL,
    variables=list()) {

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

      }
      else if (filters[[i]][1] %in% c("top",  "lessthan", "greaterthan")) {
        filter_query[[i]]$selection$filter <- filters[[i]][1]
        filter_query[[i]]$selection$values <- lapply(filters[[i]][2],
                                  function(s) enc2utf8(as.character(s)))

      } else if (filters[[i]][1] == "between") {
        filter_query[[i]]$selection$filter <- "between"
        filter_query[[i]]$selection$values <- c(lapply(filters[[i]][2], function(s) enc2utf8(as.character(s))),
                                       lapply(filters[[i]][3], function(s) enc2utf8(as.character(s))))

      }
      if (names(filters)[i] %in% names(exclude)) {
        filter_query[[i]]$selection$exclude <-lapply(exclude[[names(filters)[i]]],
                                         function(s) enc2utf8(as.character(s)))
      }
      else if (names(filters)[i] %in% names(exclude)) {
        exclude_warning <-
          paste0(ifelse(length(exclude_warning) == 0,
                        "Excluding filters cannot be combined with the item filter for the following variables: ",
                        paste0(exclude_warning, ", ")),
                 names(filters)[i])
      }

    }
    if (length(exclude_warning) != 0) warning(exclude_warning)



    return(list(
      tabell_id = table_id ,
      variabler=lapply(variables, function(s) enc2utf8(as.character(s))),
      groupBy = lapply(group_by, function(s) enc2utf8(as.character(s))),
      sortBy = lapply(sort_by, function(s) enc2utf8(as.character(s))),
      filter = filter_query))
  }



#'  Get data from API as R dataframe
#'
#' @description Send request from R to DBH-API and get data from DBH-API into R.
#'  Data are converted in right format using help function dbh_metadata \code{\link{dbh_metadata}}
#'  For token users it is possible to get token and use it further
#'
#' @param table_id The code name for the dataset
#' @param filters A named list, where the names are the names of the variables
#'   in the dataset to be filtered, and the values contain the matching
#'   conditions.
#' @param group_by A list of variables to include in the aggregation for
#'   aggregating tables.
#' @param sort_by A list of variables that define the sorting order.
#' @param exclude A named list, where the names must also occur in
#'   \code{filters}, and the values specify values to be excluded from the
#'   filter.
#' @param variables A list of variables to include in dataset
#' @param api_version DBH-API version
#' @importFrom httr add_headers
#' @importFrom httr http_error
#' @importFrom httr POST
#' @importFrom httr http_type
#' @importFrom httr http_status
#' @importFrom utils download.file
#' @return R dataframe
#' @export
#' @examples

#' dbh_data(60, filters=list( "Institusjonskode"="1120","Alder"=c("between",c("30","40")))
#' , group_by="Alder")

dbh_data <- function(
  table_id,
  filters = NULL,
  group_by = NULL,
  sort_by = NULL,
  exclude = NULL,
  variables=NULL,
  api_version = 1) {
  if (is.null(filters) & is.null(group_by) & is.null(sort_by) & is.null(variables))
  {
    content<-.dbh_content(table_id)
    if(isTRUE(content[["Bulk tabell"]] == "true")){
      url <- paste0("https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=", table_id)
      temp_file <- tempfile()
      on.exit(unlink(temp_file))
      utils::download.file(url,
                           destfile = temp_file,
                           headers = c(Authorization =
                                         paste("Bearer", .get_token(), sep = " ")))
      res <- temp_file
      delim_csv <- ","
    }
    else {stop("For selected table id", table_id, " there is no bulk data ")}
  }

  else {
    query <- .make_query(table_id = table_id, filters = filters,
                         group_by = group_by, sort_by = sort_by, exclude = exclude, variables = variables)
    post_body <-
      rjson::toJSON(c(list(
        api_versjon = api_version,
        statuslinje = "N",
        decimal_separator = "."),
        query))
    res <-
      httr::POST(url = "https://api.nsd.no/dbhapitjener/Tabeller/hentCSVTabellData",
                 httr::add_headers(`Content-Type` = "application/json",
                                   Authorization = paste("Bearer", .get_token(), sep =  " ")),
                 body = post_body,
                 encode = 'json')
    delim_csv <- ";"
    res_text_content <- httr::content(res, "text")
    if (httr::http_error(res)) {
      res_parsed <-
        jsonlite::fromJSON(res_text_content,
                           simplifyVector = FALSE)
      stop(sprintf("DBH-API request failed\n%s\n%s: %s",
                   res$url,
                   httr::http_status(res)$message,
                   res_parsed$message),
           call. = FALSE)
    }
    res_type <- httr::http_type(res)
    if (!identical(res_type, "text/csv")) {
      stop(sprintf("DBH-API request returned type '%s' and not 'text/csv' as expected",
                   res_type),
           call. = FALSE)
    }
    res <- res_text_content
  }
  data <-
    readr::read_delim(
      res,
      delim = delim_csv,
      col_types = readr::cols(.default = readr::col_character()),
      locale = readr::locale(decimal_mark = "."),
      na = "",
      trim_ws = TRUE,
      progress = readr::show_progress()
    )
  metadata <- dbh_metadata(table_id)
  for (n in names(data)) {
    if (isTRUE(n %in% metadata[metadata[["Datatype"]] %in%
                               c("int", "bigint", "smallint", "tinyint", "bit"), ][["Variabel navn"]])) {
      data[[n]] <- as.integer(data[[n]])
    } else {
      if (isTRUE(n %in% metadata[metadata[["Datatype"]] %in%
                                 c("decimal", "numeric", "float", "real"), ][["Variabel navn"]])) {
        data[[n]] <- as.double(data[[n]])
      }
    }
  }
  data
}
