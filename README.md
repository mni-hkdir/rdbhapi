
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/makinin/rdbhapi?branch=master&svg=true)](https://ci.appveyor.com/project/makinin/rdbhapi)
[![Codecov test
coverage](https://codecov.io/gh/makinin/rdbhapi/branch/master/graph/badge.svg)](https://codecov.io/gh/makinin/rdbhapi?branch=master)

[![R-CMD-check](https://github.com/makinin/rdbhapi/workflows/R-CMD-check/badge.svg)](https://github.com/makinin/rdbhapi/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/rdbhapi)](https://CRAN.R-project.org/package=rdbhapi)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

R interface for [DBH-API](https://dbh.nsd.uib.no/tjenester.action) open
data access.

## Installation

You can install the released version of rdbhapi from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("rdbhapi")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("makinin/rdbhapi")
```

Token can be defined by placing login credentials in the environment
variables `dbhapi_sso_id` and `dbhapi_sso_secret` in the `.Renviron`
file before starting R or by using `Sys.setenv`.

## Example

DBH-API contents are in table

``` r
library(rdbhapi)
dbh_data(1)
#> # A tibble: 109 x 6
#>    Emne    `Tabell id` Tabellnavn        Gdpr  `Bulk tabell` Variabelliste      
#>    <chr>   <chr>       <chr>             <chr> <chr>         <chr>              
#>  1 Ikke t~ 1           API innhold       false true          Emne,Tabell id,Tab~
#>  2 Ikke t~ 2           API metadata      false true          Tabell id,Tabellna~
#>  3 Studen~ 60          Studenter fordel~ true  false         Institusjonskode,A~
#>  4 Studen~ 62          Utvekslingsavtal~ false false         Utvekslingsavtale,~
#>  5 Studen~ 66          Desentralisering~ true  false         Årstall,Institusjo~
#>  6 Studen~ 88          Etterutdanning    true  false         Institusjonskode,A~
#>  7 Studen~ 93          Finansieringskil~ false false         Finansieringskilde~
#>  8 Studen~ 98          Kandidater med f~ false true          Institusjonskode,Å~
#>  9 Doktor~ 100         Samarbeid om dok~ false true          Årstall,Institusjo~
#> 10 Doktor~ 101         Avlagte doktorgr~ false true          Institusjonskode,A~
#> # ... with 99 more rows
```

Get the whole table in R format:

``` r
library(rdbhapi)
dbh_data(211)
#> # A tibble: 282 x 15
#>    Institusjonskode Institusjonsnavn      Adresse        Postnummer `Gyldig fra`
#>    <chr>            <chr>                 <chr>          <chr>      <chr>       
#>  1 0211             Høgskolen i Bodø      Høgskolen i B~ 8049       19943       
#>  2 0212             Høgskolen i Finnmark  Follumsvei 31  9509       19943       
#>  3 0213             Høgskolen i Harstad   Høgskolen i H~ 9480       19943       
#>  4 0214             Høgskolen i Narvik    Postboks 385   8505       19943       
#>  5 0215             Høgskolen i Nesna     Høgskolen i N~ 8700       19943       
#>  6 0216             Høgskolen i Tromsø    Høgskolen i T~ 9293       19943       
#>  7 0217             Samisk høgskole       Hánnoluohkká ~ 9520       19943       
#>  8 0221             Høgskolen i Nord-Trø~ Serviceboks 2~ 7729       19943       
#>  9 0222             Høgskolen i Sør-Trøn~ Høgskolen i S~ 7004       19943       
#> 10 0231             Høgskolen i Bergen    Postboks 7030  5020       19943       
#> # ... with 272 more rows, and 10 more variables: Gyldig til <chr>,
#> #   Telefon <chr>, Telefax <chr>, Institusjonstypekode <chr>, Typenavn <chr>,
#> #   Kortnavn <chr>, Departementid <int>, Dep_navn <chr>,
#> #   Institusjonskode (sammenslått) <chr>, Sammenslått navn <chr>
```

Multiple choice query:

``` r
dbh_data(142, filters = list("Årstall" = c("top","5"),Utvekslingsavtale = "ERASMUS+", 
Type = "NORSK", "Nivåkode" = "*"),exclude = c("Nivåkode" = "FU"), group_by = "Årstall")
#> # A tibble: 5 x 4
#>   Årstall `Antall totalt` `Antall kvinner` `Antall menn`
#>     <int>           <int>            <int>         <int>
#> 1    2020            1775             1057           718
#> 2    2019            2902             1716          1186
#> 3    2018            2707             1640          1067
#> 4    2017            2368             1464           904
#> 5    2016            2206             1352           854
```

Meta data for data table

``` r
dbh_metadata(142)
#> # A tibble: 21 x 10
#>    `Tabell id` Tabellnavn `Variabel navn` Datatype Datalengde Sortering Kodefelt
#>    <chr>       <chr>      <chr>           <chr>    <chr>      <chr>     <chr>   
#>  1 142         Utvekslin~ Andel av heltid decimal  3,2        34        <NA>    
#>  2 142         Utvekslin~ Andel praksis   float    <NA>       39        <NA>    
#>  3 142         Utvekslin~ Antall kvinner  int      <NA>       11        <NA>    
#>  4 142         Utvekslin~ Antall menn     int      <NA>       11        <NA>    
#>  5 142         Utvekslin~ Antall totalt   int      <NA>       10        <NA>    
#>  6 142         Utvekslin~ Avdelingskode   char     6          2         J       
#>  7 142         Utvekslin~ Institusjonsko~ char     4          1         J       
#>  8 142         Utvekslin~ Landkode        char     2          7         J       
#>  9 142         Utvekslin~ Nivåkode        char     10         33        J       
#> 10 142         Utvekslin~ NUS-kode        char     10         37        <NA>    
#> # ... with 11 more rows, and 3 more variables: Group by (forslag) <chr>,
#> #   Kommentar <chr>, GDPR <chr>
```
