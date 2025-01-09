

#' Create query for DBH-API
#'
#' @description Create queries to be converted to the DBH-API JSON format
#'
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

.make_query <- function(
    table_id,
    filters = list(),
    group_by = list(),
    sort_by = list(),
    exclude = NULL,
    variables = list()
) {
  filter_query <- list()
  exclude_warning <- character(0)


  .as_character_utf8 <- function(s) enc2utf8(as.character(s))


  if (!is.null(filters) && length(filters) > 0) {
    for (i in seq_along(filters)) {
      filter_query[[i]] <- list(
        variabel = enc2utf8(names(filters)[i]),
        selection = list(
          filter = "item",
          values = lapply(filters[[i]], .as_character_utf8)
        )
      )

      if (filters[[i]][1] == "*") {
        filter_query[[i]]$selection$filter <- "all"
      } else if (filters[[i]][1] %in% c("top", "lessthan", "greaterthan")) {
        filter_query[[i]]$selection$filter <- filters[[i]][1]
        filter_query[[i]]$selection$values <- lapply(filters[[i]][2], .as_character_utf8)
      } else if (filters[[i]][1] == "between") {
        filter_query[[i]]$selection$filter <- "between"
        filter_query[[i]]$selection$values <- lapply(filters[[i]][2:3], .as_character_utf8)
      }

      if (!is.null(exclude) && names(filters)[i] %in% names(exclude)) {
        if (filter_query[[i]]$selection$filter %in% c("all", "top", "lessthan", "greaterthan", "between")) {
          filter_query[[i]]$selection$exclude <- lapply(exclude[[names(filters)[i]]], .as_character_utf8)
        } else {
          exclude_warning <- c(exclude_warning, names(filters)[i])
        }
      }
    }
  }


  if (!is.null(exclude)) {
    filter_query <- c(
      filter_query,
      lapply(setdiff(names(exclude), names(filters)), function(var) {
        list(
          variabel = var,
          selection = list(
            filter = "all",
            values = list("*"),
            exclude = lapply(exclude[[var]], .as_character_utf8)
          )
        )
      })
    )
  }


  if (length(exclude_warning) > 0) {
    warning(
      paste0(
        "Excluding filters cannot be combined with the item filter. ",
        "The excluding filter has been disregarded for these variables: ",
        paste0(exclude_warning, collapse = ", ")
      ),
      call. = FALSE
    )
  }


  return(list(
    tabell_id = table_id,
    variabler = lapply(variables, .as_character_utf8),
    groupBy = lapply(group_by, .as_character_utf8),
    sortBy = lapply(sort_by, .as_character_utf8),
    filter = filter_query
  ))
}


#'  Get data from API as R dataframe
#'
#' @description Send request from R to DBH-API and get data from DBH-API into R.
#'  Data are converted in right format using help
#'  function dbh_metadata \code{\link{dbh_metadata}}
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
#' @importFrom stats setNames
#' @return R dataframe
#' @export
#' @examples
#'
#' # Table with usage of filter and group by variables
#'
#' filter_example <- dbh_data (142, filters =
#' list(Institusjonskode=c("top",3)), group_by = "Institusjonskode")
#' # Table using bulk data
#'
#' bulk_example <- dbh_data(211)



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
  query <- NULL

  if (all(vapply(list(filters, group_by, sort_by, variables, exclude),
                 is.null, logical(1)))) {
    toc <- .get_toc(table_id)
    if (isTRUE(toc[["Bulk tabell"]] == 1)) {
      url <-
        paste0("https://dbh-data.dataporten-api.no/Tabeller/bulk-csv?rptNr=", table_id)
      temp_file <- tempfile()
      on.exit(unlink(temp_file))
      utils::download.file(url,
                           destfile = temp_file,
                           headers = c(Authorization =
                                         paste("Bearer", .get_token(), sep = " ")))
      res <- temp_file
      delim_csv <- ","
    } else {

      default_values <- .default_group_by(table_id)
      variable_liste <- default_values$variable_liste
      group_by <- default_values$group_by
      group_by <- group_by[!is.na(group_by)]
      if (length(group_by) == 0) {
        group_by <- list()
      }
      filters <- setNames(lapply(variable_liste, function(x) c("*")), variable_liste)

      query <- .make_query(
        table_id,
        filters = filters,
        group_by = group_by,
        exclude = exclude,
        variables = "*",
        sort_by = sort_by
      )
    }
  }

  if (is.null(res)) {

    if (is.null(query)) {
      query <- .make_query(table_id, filters, group_by, sort_by, exclude, variables)
    }
    post_body <- rjson::toJSON(c(list(
      api_versjon = api_version,
      statuslinje = "N",
      kodetekst = "J",
      decimal_separator = "."),
      query))

    res <- httr::POST(
      url = "https://dbh-data.dataporten-api.no/Tabeller/hentCSVTabellData",
      httr::add_headers(`Content-Type` = "application/json",
                        Authorization = paste("Bearer", .get_token(), sep = " ")),
      body = post_body,
      encode = "json"
    )
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

  data <- readr::read_delim(
    res,
    delim = delim_csv,
    col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(decimal_mark = "."),
    na = "",
    trim_ws = TRUE
  )
  for (n in names(data)) {
    if (isTRUE(n %in% metadata[metadata[["Datatype"]] %in%
                               c("int", "bigint", "smallint", "tinyint", "bit"), ]
               [["Variabel navn"]])) {
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
