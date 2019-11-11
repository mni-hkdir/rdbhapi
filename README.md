
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/makinin/rdbhapi.svg?branch=master)](https://travis-ci.org/makinin/rdbhapi)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/makinin/rdbhapi?branch=master&svg=true)](https://ci.appveyor.com/project/makinin/rdbhapi)
[![Codecov test
coverage](https://codecov.io/gh/makinin/rdbhapi/branch/master/graph/badge.svg)](https://codecov.io/gh/makinin/rdbhapi?branch=master)

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
# install.packages("devtools")
devtools::install_github("makinin/rdbhapi")
```

Token users have to obtain token in R using function
`dbh_api_token(brukernavn, passord)` and after that they can use R with
all token benefits.

## Example

DBH-API contents are in table

``` r
library(rdbhapi)
dbh_tabell(1)
#> # A tibble: 98 x 4
#>    Emne      `Tabell id` Tabellnavn              Variabelliste             
#>    <chr>     <chr>       <chr>                   <chr>                     
#>  1 Ikke til~ 1           API innhold             Emne,Tabell id,Tabellnavn~
#>  2 Ikke til~ 2           API metadata            Tabell id,Tabellnavn,Vari~
#>  3 Studentd~ 60          Studenter fordelt på a~ Institusjonskode,Avdeling~
#>  4 Studentd~ 62          Utvekslingsavtaler      Utvekslingsavtale,beskriv~
#>  5 Studentd~ 66          Desentralisering og fj~ Årstall,Institusjonskode,~
#>  6 Studentd~ 88          Etterutdanning          Institusjonskode,Avdeling~
#>  7 Studentd~ 93          Finansieringskilder (d~ Finansieringskildekode,fi~
#>  8 Studentd~ 98          Kandidater som har ful~ Institusjonskode,Årstall,~
#>  9 Doktorgr~ 100         Samarbeid om doktorgra~ Årstall,Institusjonsnavn ~
#> 10 Doktorgr~ 101         Avlagte doktorgrader (~ Institusjonskode,Avdeling~
#> # ... with 88 more rows
```

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

For table with medata data

``` r
dbh_metadata(142)
#> # A tibble: 21 x 9
#>    `Tabell id` Tabellnavn `Variabel navn` Datatype Datalengde Sortering
#>    <chr>       <chr>      <chr>           <chr>    <chr>      <chr>    
#>  1 142         Utvekslin~ Andel av heltid decimal  3,2        34       
#>  2 142         Utvekslin~ Andel praksis   float    <NA>       39       
#>  3 142         Utvekslin~ Antall kvinner  int      <NA>       11       
#>  4 142         Utvekslin~ Antall menn     int      <NA>       11       
#>  5 142         Utvekslin~ Antall totalt   int      <NA>       10       
#>  6 142         Utvekslin~ Avdelingskode   char     6          2        
#>  7 142         Utvekslin~ Institusjonsko~ char     4          1        
#>  8 142         Utvekslin~ Landkode        char     2          7        
#>  9 142         Utvekslin~ Nivåkode        char     10         33       
#> 10 142         Utvekslin~ NUS-kode        char     10         37       
#> # ... with 11 more rows, and 3 more variables: Kodefelt <chr>,
#> #   Kommentar <chr>, Numeric_variable <lgl>
```
