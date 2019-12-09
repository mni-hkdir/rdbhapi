
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/makinin/rdbhapi.svg?branch=master)](https://travis-ci.org/makinin/rdbhapi)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/makinin/rdbhapi?branch=master&svg=true)](https://ci.appveyor.com/project/makinin/rdbhapi)
[![Codecov test
coverage](https://codecov.io/gh/makinin/rdbhapi/branch/master/graph/badge.svg)](https://codecov.io/gh/makinin/rdbhapi?branch=master)

<!-- badges: end -->
An R package to simplify API access to data on higher education in Norway, as provided by NSD - Norwegian Centre for Research Data.

For more information:
* DBH - Norwegian Database for Statistics on Higher Education [DBH](https://dbh.nsd.uib.no/)
* NSD - Norwegian Centre for Research Data [NSD](https://nsd.no/)

## Installation

Development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("makinin/rdbhapi")
```

Token can be defined by placing login credentials in the environment
variables `dbhapi_sso_id` and `dbhapi_sso_secret` in the `.Renviron`
file before starting R or by using `Sys.setenv`.

## Example

DBH-API contents are in table

``` r
library(rdbhapi)
dbh_data(1)
#> # A tibble: 98 x 4
#>    Emne      `Tabell id` Tabellnavn                Variabelliste                
#>    <chr>     <chr>       <chr>                     <chr>                        
#>  1 Ikke til~ 1           API innhold               Emne,Tabell id,Tabellnavn,Va~
#>  2 Ikke til~ 2           API metadata              Tabell id,Tabellnavn,Variabe~
#>  3 Studentd~ 60          Studenter fordelt på ald~ Institusjonskode,Avdelingsko~
#>  4 Studentd~ 62          Utvekslingsavtaler        Utvekslingsavtale,beskrivels~
#>  5 Studentd~ 66          Desentralisering og fjer~ Årstall,Institusjonskode,Avd~
#>  6 Studentd~ 88          Etterutdanning            Institusjonskode,Avdelingsko~
#>  7 Studentd~ 93          Finansieringskilder (dok~ Finansieringskildekode,finki~
#>  8 Studentd~ 98          Kandidater med fullført ~ Institusjonskode,Årstall,Ins~
#>  9 Doktorgr~ 100         Samarbeid om doktorgrads~ Årstall,Institusjonskode (ar~
#> 10 Doktorgr~ 101         Avlagte doktorgrader (ag~ Institusjonskode,Avdelingsko~
#> # ... with 88 more rows
```

Get the whole table in R format:

``` r
library(rdbhapi)
dbh_data(211)
#> # A tibble: 276 x 15
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
#> # ... with 266 more rows, and 10 more variables: `Gyldig til` <chr>,
#> #   Telefon <chr>, Telefax <chr>, Institusjonstypekode <chr>, Typenavn <chr>,
#> #   Kortnavn <chr>, Departementid <int>, Dep_navn <chr>, `Institusjonskode
#> #   (sammenslått)` <chr>, `Sammenslått navn` <chr>
```

Multiple choice query:

``` r
dbh_data(142, filters = list("Årstall" = c("top","5"),Utvekslingsavtale = "ERASMUS+", 
Type = "NORSK", "Nivåkode" = "*"),exclude = c("Nivåkode" = "FU"), group_by = "Årstall")
#> # A tibble: 5 x 4
#>   Årstall `Antall totalt` `Antall kvinner` `Antall menn`
#>     <int>           <int>            <int>         <int>
#> 1    2019            1547              895           652
#> 2    2018            2707             1640          1067
#> 3    2017            2368             1464           904
#> 4    2016            2206             1352           854
#> 5    2015            1692             1048           644
```

Meta data for data table

``` r
dbh_metadata(142)
#> # A tibble: 21 x 8
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
#> # ... with 11 more rows, and 1 more variable: Kommentar <chr>
```
