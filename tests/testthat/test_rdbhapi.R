context("token test")



test_that("function dbh_data returns status when data set does not exist in bulk data",
  {expect_error(dbh_data(142))})


test_that("dbh_data returns data when data set exists in set of bulk data",
  {expect_equal(dbh_data(211)[[1]][1], "0211")})

test_that("dbh_data with fileter values",
  {expect_equal(dbh_data(211, filters = list("Kortnavn" = "UIB"))[[1]][1], "1120")})

test_that("dbh_data returns error in case of agregate tables without defined group_by",
  {expect_error(dbh_data(142, filters = list("Årstall" = c("top","5"))))})

