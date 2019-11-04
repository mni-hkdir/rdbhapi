
# Global variables for current token and expiration time
dbh_api_token_expiration <- Sys.time()
dbh_api_token_contents <- ""


#' Retrieving new token
#' @param brukernavn username
#' @param passord password

#' @return returnnew dbh api token
#' @export

dbh_api_token_get_new <- function(brukernavn, passord) {
  res <-
    httr::POST(url = "https://sso.nsd.no/oauth/token",
      httr::authenticate(user = brukernavn,
        password = passord),
      body = list(grant_type = "client_credentials"),
      encode = "form")
  res <- httr::content(res, as = "text")
  res <- rjson::fromJSON(res)
  return(res$access_token)
}



#' Returns current token using golobal variable variable, or retrieves new token if expired
#' @param brukernavn username
#' @param passord password
#'
#' @return dbh api token
#' @export

 dbh_api_token <- function(brukernavn="", passord="" ){
  t <- Sys.time()
  if (t >= dbh_api_token_expiration) {
    purrr::walk2(
      stringr::str_c("dbh_api_token_",
        c("expiration", "contents")),
      list(t + 3600,
        dbh_api_token_get_new(brukernavn, passord)),
      assign,
      env = .GlobalEnv
    )
  }
  return(dbh_api_token_contents)
}
