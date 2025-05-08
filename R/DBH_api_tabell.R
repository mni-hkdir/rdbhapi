


#' Create a query object for the DBH-API
#'
#' @description
#' Constructs a query list in the format required by the DBH-API,
#' which can then be serialized to JSON.
#'
#' @param table_id Numeric. The unique ID of the dataset to query.
#' @param filters Optional. A named list where each name corresponds to a variable to filter,
#'   and each value specifies filter conditions.
#' @param group_by Optional. A character vector specifying variables to group by (used for aggregated tables).
#' @param sort_by Optional. A character vector specifying variables to sort the results by.
#' @param exclude Optional. A named list where each name corresponds to a variable,
#'   and each value lists values to exclude from that variable's filter.
#' @param variables Optional. A character vector specifying variables to retrieve (used for non-aggregated tables).
#'   Cannot be used together with \code{group_by}.
#'
#' @return A list representing the query structure ready to be converted to JSON format for the DBH-API.
#'
#' @keywords internal

.make_query <- function(table_id,
                        filters = list(),
                        group_by = list(),
                        sort_by = list(),
                        exclude = NULL,
                        variables = list()) {
  # Build a query object for the DBH-API.
  #
  # Inputs: table_id (numeric), filters (named list), group_by (character vector),
  #         sort_by (character vector), exclude (named list), variables (character vector).
  # Output: a named list representing the query structure, ready to be serialized to JSON.
  filter_query <- list()
  exclude_warning <- character(0)

  .as_character_utf8 <- function(x)
    enc2utf8(as.character(x))


  # Validation: 'group_by' and 'variables' cannot be used simultaneously
  if (length(group_by) > 0 && length(variables) > 0) {
    stop("You cannot use 'group_by' and 'variables' simultaneously in a query.")
  }

  # Process filters
  if (length(filters) > 0) {
    for (i in seq_along(filters)) {
      filter_name <- names(filters)[i]
      filter_values <- filters[[i]]
      first_value <- filter_values[1]

      selection <- list(filter = "item",
                        values = lapply(filter_values, .as_character_utf8))

      if (first_value == "*") {
        selection$filter <- "all"
      } else if (first_value %in% c("top", "lessthan", "greaterthan")) {
        selection$filter <- first_value
        selection$values <- list(.as_character_utf8(filter_values[2]))
      } else if (first_value == "between") {
        selection$filter <- "between"
        selection$values <- lapply(filter_values[2:3], .as_character_utf8)
      }

      # Handle exclusions if defined
      if (!is.null(exclude) && filter_name %in% names(exclude)) {
        if (selection$filter %in% c("all", "top", "lessthan", "greaterthan", "between")) {
          selection$exclude <- lapply(exclude[[filter_name]], .as_character_utf8)
        } else {
          exclude_warning <- c(exclude_warning, filter_name)
        }
      }

      filter_query[[i]] <- list(variabel = enc2utf8(filter_name),
                                selection = selection)
    }
  }

  # Add additional excludes not covered by filters
  if (!is.null(exclude)) {
    missing_excludes <- setdiff(names(exclude), names(filters))
    if (length(missing_excludes) > 0) {
      extra_excludes <- lapply(missing_excludes, function(var) {
        list(
          variabel = enc2utf8(var),
          selection = list(
            filter = "all",
            values = list("*"),
            exclude = lapply(exclude[[var]], .as_character_utf8)
          )
        )
      })
      filter_query <- c(filter_query, extra_excludes)
    }
  }

  # Warning for incompatible excludes
  if (length(exclude_warning) > 0) {
    warning(
      paste0(
        "Excluding filters cannot be combined with the 'item' filter. ",
        "The excluding filter has been ignored for these variables: ",
        paste0(exclude_warning, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  # Dynamically build query object: include only 'groupBy' or 'variabler'
  query <- list(
    tabell_id = table_id,
    sortBy = lapply(sort_by, .as_character_utf8),
    filter = filter_query
  )

  if (length(group_by) > 0) {
    query$groupBy <- lapply(group_by, .as_character_utf8)
  } else if (length(variables) > 0) {
    query$variabler <- lapply(variables, .as_character_utf8)
  }

  return(query)
}



#' Retrieve data from DBH-API as an R data frame
#'
#' @description
#' Sends a request to the DBH-API and returns the result as an R `data.frame`.
#' Data types are automatically converted based on the table metadata,
#' using the helper function \code{\link{dbh_metadata}}.
#'
#' Authentication with the DBH-API is optional:
#' - If no token is provided, the API still returns data, but numeric values will be rounded (typically to the nearest 3).
#' - If a valid token is provided, full and precise data values are returned.
#'
#' To authenticate, users must set their SSO ID and SSO Secret as environment variables
#' (\code{dbhapi_sso_id} and \code{dbhapi_sso_secret}) manually or in an `.Renviron` file.
#' If these environment variables are set, the package will automatically retrieve and use a token when sending requests.
#'
#' @param table_id Numeric. Required. The unique ID of the dataset to query.
#' @param filters Optional. A named list where names correspond to dataset variables, and values specify filter criteria.
#' @param group_by Optional. A character vector of variables to use for aggregating tables.
#' @param sort_by Optional. A character vector of variables to define sorting order.
#' @param exclude Optional. A named list specifying values to exclude from the filters.
#' @param variables Optional. A character vector of variables to include when retrieving non-aggregated data.
#' @param api_version Integer. Version of the DBH-API to use (default is 1).
#'
#' @return A `data.frame` containing the requested dataset, with variables properly typed.
#'
#' @seealso \code{\link{dbh_metadata}}
#'
#' @importFrom httr add_headers
#' @importFrom httr http_error
#' @importFrom httr POST
#' @importFrom utils download.file
#' @importFrom rjson toJSON
#' @importFrom readr read_delim
#'
#' @examples
#' \dontrun{
#' # Example 1: Query with filters and group_by
#' filter_example <- dbh_data(
#'   table_id = 142,
#'   filters = list(Institusjonskode = c("top", 3)),
#'   group_by = "Institusjonskode"
#' )
#'
#' # Example 2: Download bulk table
#' bulk_example <- dbh_data(table_id = 211)
#' }
#'
#' @export


dbh_data <- function(table_id,
                     filters = NULL,
                     group_by = NULL,
                     sort_by = NULL,
                     exclude = NULL,
                     variables = NULL,
                     api_version = 1) {
  metadata <- dbh_metadata(table_id)
  toc <- .get_toc(table_id)

  # Check for bulk download possibility
  if (isTRUE(toc[["Bulk tabell"]] == 1) &&
      all(vapply(
        list(filters, group_by, sort_by, variables, exclude),
        is.null,
        logical(1)
      ))) {
    url <- paste0("https://dbh-data.dataporten-api.no/Tabeller/bulk-csv?rptNr=",
                  table_id)
    temp_file <- tempfile()
    on.exit(unlink(temp_file))

    utils::download.file(url,
                         destfile = temp_file,
                         headers = c(Authorization = paste("Bearer", .get_token())))

    return(.read_dbh_file(temp_file, ",", metadata))
  }

  # Validate presence of 'Math' field
  math_flag <- toc[["Math"]]
  if (is.null(math_flag)) {
    stop("'Math' field not found in table metadata.")
  }


  # Handle 'Math' logic
  if (math_flag == 1) {
    # Aggregated table: use 'group_by', not 'variables'
    if (!is.null(variables)) {
      stop("This table uses 'group_by'. The 'variables' parameter must not be specified.")
    }

    if (is.null(group_by)) {
      group_by <- .default_group_by(table_id)$group_by
      group_by <- group_by[!is.na(group_by)]

      if (length(group_by) == 0) {
        stop("At least one 'group_by' variable must be provided.")
      }
    }

    # Ensure that all group_by variables have filter and exclude definitions
    filters <- filters %||% list()
    exclude <- .ensure_group_by_exclude(group_by, exclude)

    for (var in group_by) {
      if (!(var %in% names(filters))) {
        filters[[var]] <- c("*")
      }
    }

  } else if (math_flag == 0) {
    # Non-aggregated table: use 'variables', not 'group_by'
    if (!is.null(group_by)) {
      stop("This table uses 'variables'. The 'group_by' parameter must not be specified.")
    }

    if (is.null(variables)) {
      variables <- "*"
    }
  } else {
    stop("Unknown value in 'Math' field: expected 0 or 1.")
  }

  # Create query
  query <- .make_query(table_id, filters, group_by, sort_by, exclude, variables)
  message("Query sent to API:\n", rjson::toJSON(query))

  # Send API request
  post_body <- rjson::toJSON(c(
    list(
      api_versjon = api_version,
      statuslinje = "N",
      kodetekst = "J",
      decimal_separator = "."
    ),
    query
  ))

  res <- httr::POST(
    url = "https://dbh-data.dataporten-api.no/Tabeller/hentCSVTabellData",
    httr::add_headers(
      `Content-Type` = "application/json",
      Authorization = paste("Bearer", .get_token())
    ),
    body = post_body,
    encode = "json"
  )

  # Check for HTTP errors
  if (httr::http_error(res)) {
    stop(
      sprintf(
        "DBH-API request failed: %s\nURL: %s\nQuery: %s",
        httr::http_status(res)$message,
        res$url,
        post_body
      ),
      call. = FALSE
    )
  }

  # Read and parse the API response
  content <- httr::content(res, "text", encoding = "UTF-8")
  .read_dbh_file(content, ";", metadata)
}

.ensure_group_by_exclude <- function(group_by, exclude) {
  exclude <- exclude %||% list()
  for (var in group_by) {
    if (!(var %in% names(exclude))) {
      exclude[[var]] <- c("")
    }
  }
  return(exclude)
}

.read_dbh_file <- function(file_or_text, delim, metadata) {
  data <- readr::read_delim(
    file_or_text,
    delim = delim,
    col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(decimal_mark = "."),
    na = "",
    trim_ws = TRUE
  )

  # Automatically type cast based on metadata
  numeric_vars <- metadata[metadata[["Datatype"]] %in% c("int", "bigint", "smallint", "tinyint", "bit"), ][["Variabel navn"]]

  decimal_vars <- metadata[metadata[["Datatype"]] %in% c("decimal", "numeric", "float", "real"), ][["Variabel navn"]]

  for (n in names(data)) {
    if (n %in% numeric_vars) {
      data[[n]] <- as.integer(data[[n]])
    } else if (n %in% decimal_vars) {
      data[[n]] <- as.double(data[[n]])
    }
  }

  return(data)
}
