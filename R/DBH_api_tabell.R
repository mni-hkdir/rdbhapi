

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
    group_by,
    sort_by,
    exclude,
    variables) {

    filter_query <- list()
    exclude_warning <- character(0)
    .as_character_utf8 <- function(s) enc2utf8(as.character(s))

    if (is.null(filters)) {
      metadata <- .get_metadata(table_id)
      char_variabel <- metadata[metadata$Datatype %in% "char", ][["Variabel navn"]][1]
      filters <- setNames(list("*"), char_variabel)
    }

    for (i in seq_along(filters)) {
      filter_query[[i]] <-
        list(variabel = enc2utf8(names(filters)[i]),
             selection = list(filter = "item",
                              values = lapply(filters[[i]],
                                              .as_character_utf8)))
      if (filters[[i]][1] == "*") {
        filter_query[[i]]$selection$filter <- "all"
      } else if (filters[[i]][1] %in% c("top",  "lessthan", "greaterthan")) {
        filter_query[[i]]$selection$filter <- filters[[i]][1]
        filter_query[[i]]$selection$values <- lapply(filters[[i]][2],
                                                     .as_character_utf8)
      } else if (filters[[i]][1] == "between") {
        filter_query[[i]]$selection$filter <- "between"
        filter_query[[i]]$selection$values <- lapply(filters[[i]][2:3], .as_character_utf8)
      }
      if (names(filters)[i] %in% names(exclude)) {
        if (filter_query[[i]]$selection$filter %in% c("all", "top", "lessthan", "greaterthan", "between")) {
          filter_query[[i]]$selection$exclude <- lapply(exclude[[names(filters)[i]]],
                                                        .as_character_utf8)
        } else {
          exclude_warning <- c(exclude_warning, names(filters)[i])
        }
      }
    }

    filter_query <-
      c(filter_query,
        lapply(setdiff(names(exclude), names(filters)),
               function(var) {
                 list(variabel = var,
                      selection = list(filter = "all",
                                       values = list("*"),
                                       exclude = lapply(exclude[[var]],
                                                        .as_character_utf8)))
               }))

    if (is.null(group_by)) {
      group_by <- .default_group_by(table_id)
    }

    if (length(exclude_warning) != 0) {
      warning(paste0("Excluding filters cannot be combined with the item filter.\nThe excluding filter has been disregarded for these variables: ",
                     paste0(exclude_warning, collapse = ", ")),
              call. = FALSE)
    }

    return(list(
      tabell_id = table_id ,
      variabler = lapply(variables, .as_character_utf8),
      groupBy = lapply(group_by, .as_character_utf8),
      sortBy = lapply(sort_by, .as_character_utf8),
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




dbh_data <- function(
  table_id,
  filters = NULL,
  group_by = NULL,
  sort_by = NULL,
  exclude = NULL,
  variables = NULL,
  api_version = 1) {

  metadata <- .get_metadata(table_id)
  res <- NULL

  if (all(vapply(list(filters, group_by, sort_by, variables, exclude),
                 is.null, logical(1)))) {
    toc <- .get_toc(table_id)
    if (isTRUE(toc[["Bulk tabell"]] == "true")) {
      url <- paste0("https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=", table_id)
      temp_file <- tempfile()
      on.exit(unlink(temp_file))
      utils::download.file(url,
                           destfile = temp_file,
                           headers = c(Authorization =
                                         paste("Bearer", .get_token(), sep = " ")))
      res <- temp_file
      delim_csv <- ","
    } else {
      char_variabel <- metadata[metadata$Datatype %in% "char", ][["Variabel navn"]][1]
      filters <- setNames(list("*"), char_variabel)
    }
  }
  if (is.null(res)) {
    query <- .make_query(table_id, filters, group_by, sort_by, exclude, variables)
    post_body <-
      rjson::toJSON(c(list(
        api_versjon = api_version,
        statuslinje = "N",
        decimal_separator = "."),
        query))
    res <-
      httr::POST(url = "https://api.nsd.no/dbhapitjener/Tabeller/streamCsvData",
                 httr::add_headers(`Content-Type` = "application/json",
                                   Authorization = paste("Bearer", .get_token(), sep =  " ")),
                 body = post_body,
                 encode = 'json')
    delim_csv <- ";"
    if (httr::http_error(res)) {
      stop(sprintf("DBH-API request failed\n%s\nURL: %s\nQuery: %s",
                   httr::http_status(res)$message,
                   res$url,
                   post_body),
           call. = FALSE)
    }
    res <- httr::content(res, "text", encoding = "UTF-8")
  }

  data <-
    readr::read_delim(
      res,
      delim = delim_csv,
      col_types = readr::cols(.default = readr::col_character()),
      locale = readr::locale(decimal_mark = "."),
      na = "",
      trim_ws = TRUE
    )
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
