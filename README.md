
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rdbhapi

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/makinin/rdbhapi.svg?branch=master)](https://travis-ci.org/makinin/rdbhapi)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/makinin/rdbhapi?branch=master&svg=true)](https://ci.appveyor.com/project/makinin/rdbhapi)
[![Codecov test
coverage](https://codecov.io/gh/makinin/rdbhapi/branch/master/graph/badge.svg)](https://codecov.io/gh/makinin/rdbhapi?branch=master)
<!-- badges: end -->

R interface for NSD-Database for høgre utdanning
[DBH-API](https://dbh.nsd.uib.no/tjenester.action) open data access.

## Installation

You can install the released version of rdbhapi from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("rdbhapi")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("makinin/rdbhapi")
```

Token users have to obtain token in R using function
`dbh_api_token(brukernavn, passord)` and after that they can use R with
all token benefits.

## Example

Get the whole table in R format:

``` r
library(rdbhapi)
dbh_tabell(211)
#> # A tibble: 274 x 15
#>    Institusjonskode Institusjonsnavn Adresse Postnummer `Gyldig fra`
#>    <chr>            <chr>            <chr>   <chr>      <chr>       
#>  1 0211             Høgskolen i Bodø Høgsko~ 8049       19943       
#>  2 0212             Høgskolen i Fin~ Follum~ 9509       19943       
#>  3 0213             Høgskolen i Har~ Høgsko~ 9480       19943       
#>  4 0214             Høgskolen i Nar~ Postbo~ 8505       19943       
#>  5 0215             Høgskolen i Nes~ Høgsko~ 8700       19943       
#>  6 0216             Høgskolen i Tro~ Høgsko~ 9293       19943       
#>  7 0217             Samisk høgskole  Hánnol~ 9520       19943       
#>  8 0221             Høgskolen i Nor~ Servic~ 7729       19943       
#>  9 0222             Høgskolen i Sør~ Høgsko~ 7004       19943       
#> 10 0231             Høgskolen i Ber~ Postbo~ 5020       19943       
#> # ... with 264 more rows, and 10 more variables: `Gyldig til` <chr>,
#> #   Telefon <chr>, Telefax <chr>, Institusjonstypekode <chr>,
#> #   Typenavn <chr>, Kortnavn <chr>, Departementid <dbl>, Dep_navn <chr>,
#> #   `Institusjonskode (sammenslått)` <chr>, `Sammenslått navn` <chr>
```

Multiple choice query:

``` r
dbh_tabell(142, filters = list("Årstall" = c("top","5"),Utvekslingsavtale = "ERASMUS+", 
Type = "NORSK", "Nivåkode" = "*"),exclude = c("Nivåkode" = "FU"), group_by = "Årstall")
#> # A tibble: 5 x 4
#>   Årstall `Antall totalt` `Antall kvinner` `Antall menn`
#>     <dbl>           <dbl>            <dbl>         <dbl>
#> 1    2019            1547              895           652
#> 2    2018            2707             1640          1067
#> 3    2017            2368             1464           904
#> 4    2016            2206             1352           854
#> 5    2015            1692             1048           644
```
