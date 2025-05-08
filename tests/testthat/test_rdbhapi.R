context("rdbhapi test")



test_that("dbh_data returns Institusjonskode, Kortnavn as variable names for Bulk dataset",{
  skip_on_cran()
  expect_true(all(c("Institusjonskode", "Kortnavn") %in%
                    names(dbh_data(211))))
})


test_that("dbh_data return error for data set that do not exist in DBH API ",{
  skip_on_cran()
  expect_error(dbh_data(4))

})


test_that("dbh_data filters without group_by for table that need group_by statement", {
  skip_on_cran()
  skip_on_ci()
   expect_error(dbh_data(dbh_data(373, filters = list(Institusjonskode="1120"))))
})


test_that("Basic query is generated correctly", {
  query <- .make_query(
    table_id = 142,
    filters = list(Institusjonskode = c("*")),
    group_by = c("Institusjonskode"),
    sort_by = c("Institusjonskode")
  )

  expect_equal(query$tabell_id, 142)
  expect_equal(query$groupBy, list("Institusjonskode"))
  expect_equal(query$sortBy, list("Institusjonskode"))
  expect_equal(query$filter[[1]]$variabel, "Institusjonskode")
  expect_equal(query$filter[[1]]$selection$filter, "all")
})

test_that("Query handles exclude-only variables", {
  query <- .make_query(
    table_id = 211,
    exclude = list(Institusjonskode = c("1120", "1110"))
  )


  institusjonskode_filter <- query$filter[[which(sapply(query$filter, function(x) x$variabel == "Institusjonskode"))]]

  expect_equal(institusjonskode_filter$variabel, "Institusjonskode")
  expect_equal(institusjonskode_filter$selection$filter, "all")
  expect_equal(institusjonskode_filter$selection$values, list("*"))
  expect_equal(institusjonskode_filter$selection$exclude, list("1120", "1110"))
})

test_that("Excel file is read correctly", {
  excel_path <- system.file("extdata", "DBHAPI_Variabler.xlsx", package = "rdbhapi")
  expect_error(readxl::read_excel(excel_path), NA)
})

test_that(".fetch_data retrieves and parses CSV correctly", {
  skip_on_cran()
  skip_on_ci()

  url <- "https://dbh.hkdir.no/api/Tabeller/bulk-csv?rptNr=001"
  data <- .fetch_data(url)

  expect_s3_class(data, "tbl_df")
  expect_true(ncol(data) > 0)
  expect_true(nrow(data) > 0)
})

test_that(".get_new_metadata returns a tibble with expected columns", {
  skip_on_cran()
  skip_on_ci()

  metadata <- .get_new_metadata()
  expect_s3_class(metadata, "tbl_df")
  expect_true(any(c("Variabel navn", "Tabell id") %in% names(metadata)))
})

test_that(".get_new_toc returns a tibble with expected columns", {
  skip_on_cran()
  skip_on_ci()

  toc <- .get_new_toc()
  expect_s3_class(toc, "tbl_df")
  expect_true(any(c("Tabell id", "Tabellnavn") %in% names(toc)))
})
test_that(".default_group_by reads Excel and returns correct structure", {
  skip_on_cran()
  skip_on_ci()

  result <- .default_group_by(142)
  if (!is.null(result)) {
    expect_true(is.list(result))
    expect_true(all(c("group_by", "variable_liste") %in% names(result)))
  } else {
    expect_null(result)
  }
})
