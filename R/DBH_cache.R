#' @title  Clean DBH cache
#' @description Delete all .rds files from the DBH cache directory.
#'
#' @param cache_dir a path to cache directory.
#'
#' @return {No return value}
#' @export
#'
#'
dbh_clean_cache <- function(cache_dir = NULL){
  if (is.null(cache_dir)){
    cache_dir <- getOption("dbh_cache_dir", file.path(tempdir(), "dbh"))
    if (!file.exists(cache_dir)) {
      message("The cache does not exist")
      return(invisible(TRUE))
    }
  }
  if (!file.exists(cache_dir)) stop("The cache folder ", cache_dir, " does not exist")

  files <- list.files(cache_dir, pattern = "rds", full.names = TRUE)
  if (length(files) == 0) {
    message("The cache folder ", cache_dir, " is empty.")
  } else {
    unlink(files)
    message("Deleted .rds files from ", cache_dir)
  }
  invisible(TRUE)
}




#' Cache DBH tables
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
#' @param cache a logical value whether to cache
#' @param update_cache a logical value whether to update cache , default is without updating
#' @param cache_dir a path to cache directory. Default value create a cache directory
#' @param compress_file logical value whether to compress, default is to compress
#'
#' @return a tibble
#' @export
#'
dbh_cache <- function(table_id,
                      filters = NULL,
                      group_by = NULL,
                      sort_by = NULL,
                      exclude = NULL,
                      variables = NULL,
                      api_version = 1,
                      cache = TRUE, update_cache = FALSE, cache_dir = NULL,
                         compress_file = TRUE)
  {if (cache){

      # get cache directory
      if (is.null(cache_dir)){

        cache_dir <- getOption("dbh_cache_dir", NULL)

        if (is.null(cache_dir)){
          cache_dir <- file.path(tempdir(), "dbh")
          if (!file.exists(cache_dir)) dir.create(cache_dir)
        }

      } else {
        if (!file.exists(cache_dir)) {
          stop("The folder ", cache_dir, " does not exist")
        }
      }

      # cache filename
      cache_file <- file.path(cache_dir,
                              paste0(table_id,

                                     ".rds"))
    }

    # if cache = FALSE or update or new: dowload else read from cache
    if (!cache || update_cache || !file.exists(cache_file)){
       y <- dbh_data(table_id,
                      filters = NULL,
                      group_by = NULL,
                      sort_by = NULL,
                      exclude = NULL,
                      variables = NULL,
                      api_version = 1)


         }
  else {
      cf <- path.expand(cache_file)
      message(paste("Reading cache file", cf))
      y <- readRDS(cache_file)
      message(paste("Table ", table_id, " read from cache file: ", cf))
    }

    # if update or new: save
    if (cache && (update_cache || !file.exists(cache_file))){
      saveRDS(y, file = cache_file, compress = compress_file)
      message("Table ", table_id, " cached at ", path.expand(cache_file))
    }

    y

}

