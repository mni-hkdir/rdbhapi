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


test_that("Cache give error if cache dir does not exist", {
  skip_on_cran()
  expect_error(
    dbh_cache(1, cache_dir = file.path(tempdir(), "r_cache")))
})
