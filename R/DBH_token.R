# Package environment
.env <- new.env(parent = emptyenv())


# Variables for current token and expiration time
.env$token_expiration <- 0
.env$token <- ""


#' Retrieve new JWT token for DBH-API
#'
#' @param sso_id Client ID for DBH-API authentication
#' @param sso_secret Secret ID for DBH-API authentication
#' @importFrom httr authenticate
#' @importFrom rjson fromJSON
#' @importFrom httr POST
#' @importFrom httr content
#' @return A new JWT token for DBH-API
#' @keywords internal

.get_new_token <- function(sso_id, sso_secret) {
  res <-
    httr::POST(url = "https://sso.nsd.no/oauth/token",
               httr::authenticate(user = sso_id,
                                  password = sso_secret),
               body = list(grant_type = "client_credentials"),
               encode = "form")
  res <- httr::content(res, as = "text")
  res <- rjson::fromJSON(res)
  res <- res$access_token
  if (is.null(res)) {
    return("")
  } else {
    return(res)
  }
}



#' Return JWT token for DBH-API
#'
#' @description Return current token or new token if expired.
#' Retrieves credientials for
#' fetching tokens from environment variables.
#' Place login credentials in the environment variables \code{dbhapi_sso_id} and
#' \code{dbhapi_sso_secret}. They can be defined in the .Renviron file before
#' starting R or by using \code{\link{Sys.setenv}}
#' @return A character string containing the JWT token, or the empty string if
#'  fetching the token fails.
#' @keywords internal
.get_token <-
  function() {
    sso_id <- Sys.getenv("dbhapi_sso_id")
    sso_secret <- Sys.getenv("dbhapi_sso_secret")
    if (identical(sso_id, "") | identical(sso_secret, "")) {
      return("")
    } else {
      t <- Sys.time()
      if (t >= .env$token_expiration) {
        .env$token <- .get_new_token(sso_id,
                                     sso_secret)
        .env$token_expiration <- t + 3600
      }
      return(.env$token)}
  }

