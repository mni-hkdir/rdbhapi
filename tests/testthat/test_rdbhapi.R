context("token test")

test_that("function dbh_api_token returns token",
  {expect_equal(dbh_api_token(), "") })

test_that("function dbh_tabell returns status when data set does not exist in bulk data",
  {expect_equal(dbh_tabell(142),404)})


test_that("dbh_tabell returns data when data set exists in set of bulk data",
  {expect_equal(dbh_tabell(211)[[1]][1], "0211")})

test_that("dbh_tabell with fileter values",
  {expect_equal(dbh_tabell(211, filters = list("Kortnavn" = "UIB"))[[1]][1], "1120")})

test_that("dbh_tabell returns error in case of agregate tables without defined group_by",
  {expect_error(dbh_tabell(142, filters = list("Årstall" = c("top","5"))))})

