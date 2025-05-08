
[![R-CMD-check](https://github.com/mni-hkdir/rdbhapi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mni-hkdir/rdbhapi/actions)
[![Codecov test
coverage](https://codecov.io/gh/mni-hkdir/rdbhapi/branch/main/graph/badge.svg)](https://codecov.io/gh/mni-hkdir/rdbhapi)
[![CRAN
status](https://www.r-pkg.org/badges/version/rdbhapi)](https://CRAN.R-project.org/package=rdbhapi)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

## Overview

**rdbhapi** provides an R interface for accessing the open data
available through [DBH-API](https://dbh.hkdir.no/dbhapiklient/). It
allows users to query, filter, and retrieve data directly into R for
further analysis.

------------------------------------------------------------------------

## Installation

### Install remotes if you don’t have it

install.packages(“remotes”)

### Install rdbhapi from GitHub

remotes::install_github(“mni-hkdir/rdbhapi”)

## Authentication

To retrieve full (non-rounded) data from the DBH-API, you need to
authenticate using your SSO ID and SSO Secret credentials.

There are two options:

1.  **Using `.Renviron` file**

    The `.Renviron` file is a hidden file used by R to store environment
    variables.  
    You can create or edit this file in your home directory or in your R
    project folder.

    Open the `.Renviron` file in a text editor:

    ``` r
    file.edit("~/.Renviron")
    ```

    Add the following lines to `.Renviron`:

        dbhapi_sso_id = "your_sso_id"
        dbhapi_sso_secret = "your_sso_secret"

    After saving, **restart your R session** to load the updated
    `.Renviron` file.

    You can verify the environment variables are loaded using:

    ``` r
    Sys.getenv("dbhapi_sso_id")
    Sys.getenv("dbhapi_sso_secret")
    ```

2.  **Setting credentials dynamically**

    Alternatively, you can set the token during your R session using:

    ``` r
    Sys.setenv(dbhapi_sso_id = "your_sso_id")
    Sys.setenv(dbhapi_sso_secret = "your_sso_secret")
    ```

    ## Examples

``` r
# Load the package
library(rdbhapi)
```

### Get contents of a table

``` r
dbh_data(1)
```

### Get the whole table (ID 211)

``` r
institutions <- dbh_data(211)
head(institutions)
```

### Download the entire table with ID 142

``` r
students_abroad <- dbh_data(142)
head(students_abroad)
```

### Download filtered data for table ID 211

``` r
top5_institutions <- dbh_data(
  211,
  filters = list(
    "Institusjonskode" = c("top", "5")
  )
)
head(top5_institutions)
```
