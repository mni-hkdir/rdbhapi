## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## ----setup--------------------------------------------------------------------
library(rdbhapi)

## ----echo=FALSE,comment=NA----------------------------------------------------
cat(paste0(library(help = "rdbhapi")$info[[2]], collapse = "\n"))

## ----data_content, warning=FALSE, message=FALSE, results='asis', echo=TRUE, eval=TRUE----
library(knitr)
data_content <- dbh_data(1)
kable(head(data_content))

## ----metadata, warning=FALSE, message=FALSE, results='asis', echo=TRUE, eval=TRUE----
library(knitr)
metadata <- dbh_data(2)
kable(head(metadata))

## ----erasmus, warning=FALSE, message=FALSE, results='asis', echo=TRUE, eval=TRUE----
library(knitr)
erasmus <- dbh_data(211)
kable(head(erasmus))

## ----institusjoner_filter, warning=FALSE, message=FALSE, results='asis', echo=TRUE, eval=TRUE----
library(knitr)
institusjoner_filter <- dbh_data(
  211,
  filters = list(
    "Institusjonskode" = c("top", "5")
  )
)
kable(head(institusjoner_filter))


## ----Renvirion access---------------------------------------------------------
Sys.getenv("dbhapi_sso_id")
Sys.getenv("dbhapi_sso_secret")

## ----Sys.setenv---------------------------------------------------------------
Sys.setenv(dbhapi_sso_id = "your_sso_id")
Sys.setenv(dbhapi_sso_secret = "your_sso_secret")


## ----sessioninfo, message=FALSE, warning=FALSE--------------------------------
sessionInfo()

