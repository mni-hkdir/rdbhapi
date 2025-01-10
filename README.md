
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/mni-hkdir/rdbhapi/branch/master/graph/badge.svg)](https://codecov.io/gh/makinin/rdbhapi?branch=master)

[![R-CMD-check](https://github.com/mni-hkdir/rdbhapi/workflows/R-CMD-check/badge.svg)](https://github.com/makinin/rdbhapi/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/rdbhapi)](https://CRAN.R-project.org/package=rdbhapi)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

R interface for [DBH-API](https://dbh.hkdir.no/dbhapiklient/) open data
access.

## Installation

You can install development version from [GitHub](https://github.com/)
with:

``` r
# install.packages("remotes")
remotes::install_github("mni-hkdir/rdbhapi")
```

To authenticate with the DBH-API, you need to provide a valid token
using your SSO ID and SSO Secret. These credentials can be securely
defined as environment variables in one of the following ways: Option 1:
Using `.Renviron` File

The `.Renviron` file is a hidden file used by R to store environment
variables. You can create or edit this file in your home directory or in
your R project folder. Open the `.Renviron` file in a text editor or
within R using:

`{r file.edit("~/.Renviron")` Add `dbhapi_sso_id` = “your_sso_id” and
`dbhapi_sso_secret` = “your_sso_secret” in `.Renviron` file and save the
file.

After saving, restart your R session to load the updated `.Renviron`
file.

Once defined, these variables can be accessed in R using `Sys.setenv`:

`{r Sys.getenv("dbhapi_sso_id") Sys.getenv("dbhapi_sso_secret")` Option
2: Using `Sys.setenv` Alternatively, you can define the token
dynamically during your R session using the `Sys.setenv` function:

\`\`\`{r Sys.setenv(dbhapi_sso_id = “your_sso_id”)
Sys.setenv(dbhapi_sso_secret = “your_sso_secret”)


    ## Example

    DBH-API contents are in table


    ``` r
    library(rdbhapi) 
    dbh_data(1)
    #> # A tibble: 110 × 6
    #>    Emne                `Tabell id` Tabellnavn  Gdpr  `Bulk tabell` Variabelliste
    #>    <chr>               <chr>       <chr>       <chr> <chr>         <chr>        
    #>  1 Ikke tilordnet emne 1           API innhold 0     1             Emne,Tabell …
    #>  2 Ikke tilordnet emne 2           API metada… 0     1             Tabell id,Ta…
    #>  3 Studentdata         60          Studenter … 1     0             Institusjons…
    #>  4 Studentdata         62          Utveksling… 0     0             Utvekslingsa…
    #>  5 Studentdata         93          Finansieri… 0     0             Finansiering…
    #>  6 Studentdata         98          Kandidater… 0     1             Institusjons…
    #>  7 Doktorgradsdata     100         Samarbeid … 0     1             Årstall,Inst…
    #>  8 Doktorgradsdata     101         Avlagte do… 0     1             Institusjons…
    #>  9 Studentdata         104         Ferdige ka… 1     0             Institusjons…
    #> 10 Studentdata         112         Opptak      1     0             Institusjons…
    #> # ℹ 100 more rows

\##Get the whole table in R format:

``` r
library(knitr)
library(rdbhapi)
institusjoner <- dbh_data(211)
kable(head(institusjoner))
```

| Institusjonskode | Institusjonsnavn | Adresse | Postnummer | Gyldig fra | Gyldig til | Telefon | Telefax | Institusjonstypekode | Typenavn | Kortnavn | Departementid | Dep_navn | Institusjonskode (sammenslått) | Sammenslått navn |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|---:|:---|:---|:---|
| 0211 | Høgskolen i Bodø | Høgskolen i Bodø | 8049 | 19943 | 20103 | 75517200 | 75517457 | 02 | Statlige høyskoler | HiBo | 1 | Kunnskapsdepartementet | 1174 | Nord universitet |
| 0212 | Høgskolen i Finnmark | Follumsvei 31 | 9509 | 19943 | 20133 | 78450500 | 78434438 | 02 | Statlige høyskoler | HiFm | 1 | Kunnskapsdepartementet | 1130 | Universitetet i Tromsø - Norges arktiske universitet |
| 0213 | Høgskolen i Harstad | Høgskolen i Harstad | 9480 | 19943 | 20153 | 77058100 | 77058101 | 02 | Statlige høyskoler | HiH | 1 | Kunnskapsdepartementet | 1130 | Universitetet i Tromsø - Norges arktiske universitet |
| 0214 | Høgskolen i Narvik | Postboks 385 | 8505 | 19943 | 20153 | 76966000 | 76966810 | 02 | Statlige høyskoler | HiN | 1 | Kunnskapsdepartementet | 1130 | Universitetet i Tromsø - Norges arktiske universitet |
| 0215 | Høgskolen i Nesna | Høgskolen i Nesna | 8700 | 19943 | 20153 | 75052000 | 75057900 | 02 | Statlige høyskoler | HiNe | 1 | Kunnskapsdepartementet | 1174 | Nord universitet |
| 0216 | Høgskolen i Tromsø | Høgskolen i Tromsø | 9293 | 19943 | 20083 | 77660300 | 77689956 | 02 | Statlige høyskoler | HiTø | 1 | Kunnskapsdepartementet | 1130 | Universitetet i Tromsø - Norges arktiske universitet |

\##Download the entire table with ID 142:

``` r
library(knitr)
library(rdbhapi)
utvekslingstudenter <- dbh_data(142)
kable(head(utvekslingstudenter))
```

| Institusjonskode | Institusjonsnavn | Avdelingskode | Avdelingsnavn | Årstall | Semester | Semesternavn | Studieprogramkode | Studieprogramnavn | Antall totalt | Antall kvinner | Antall menn |
|:---|:---|:---|:---|---:|---:|:---|:---|:---|---:|---:|---:|
| 0236 | Høgskulen i Volda | 000000 | HiVo (uspesifisert underenhet) | 2009 | 1 | Vår | SPLBV | Bachelorgradsstudium i språk og litteratur | 3 | 0 | 0 |
| 0237 | Høgskolen i Ålesund | 310000 | Institutt for teknologi og nautikkfag | 2011 | 1 | Vår | 004DA | Bachelor i ingeniørfag - Data | 0 | 0 | 0 |
| 0236 | Høgskulen i Volda | 000000 | HiVo (uspesifisert underenhet) | 2011 | 1 | Vår | NUS | Norsk språk og samfunnskunnskap for utanlandske studentar | 8 | 5 | 3 |
| 0236 | Høgskulen i Volda | 000000 | HiVo (uspesifisert underenhet) | 2018 | 1 | Vår | OFFBV | Bachelorgradsstudium i planlegging og administrasjon | 3 | 0 | 0 |
| 0237 | Høgskolen i Ålesund | 340000 | Avdeling for internasjonal business | 2008 | 1 | Vår | 473EK | Bachelor i eksportmarkedsføring | 17 | 8 | 9 |
| 0237 | Høgskolen i Ålesund | 340000 | Avdeling for internasjonal business | 2011 | 1 | Vår | 473EK | Bachelor i eksportmarkedsføring | 9 | 5 | 4 |

## Download filtered data for table with ID 211:

``` r
library(knitr)
library(rdbhapi)
institusjoner_filter <- dbh_data(
  211,
  filters = list(
    "Institusjonskode" = c("top", "5")
  )
)
kable(head(institusjoner_filter))
```

| Institusjonskode | Institusjonsnavn | Adresse | Postnummer | Gyldig fra | Gyldig til | Telefon | Telefax | Institusjonstypekode | Typenavn | Kortnavn | Departementid | Dep_navn | Institusjonskode (sammenslått) | Sammenslått navn |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|---:|:---|:---|:---|
| 2201 | Møre og Romsdal distriktshøgskole - Molde | Postboks 308 | 6401 | 19691 | 19943 | NA | NA | 22 | Distriktshøgskoler | MRDHM | 1 | Kunnskapsdepartementet | 2201 | Møre og Romsdal distriktshøgskole - Molde |
| 2202 | Agder distriktshøgskole | Tordenskjoldsgate 65 | 4604 | 19691 | 19943 | NA | NA | 22 | Distriktshøgskoler | ADH | 1 | Kunnskapsdepartementet | 2202 | Agder distriktshøgskole |
| 2203 | Finnmark distriktshøgskole | Follumsvei | 9510 | 19811 | 19943 | NA | NA | 22 | Distriktshøgskoler | FDH | 1 | Kunnskapsdepartementet | 2203 | Finnmark distriktshøgskole |
| 2204 | Hedmark distriktshøgskole | Postboks 104 | 2451 | 19771 | 19943 | NA | NA | 22 | Distriktshøgskoler | HDH | 1 | Kunnskapsdepartementet | 2204 | Hedmark distriktshøgskole |
| 2205 | Møre og Romsdal distriktshøgskule - Volda | Postboks 188 | 6101 | 19701 | 19943 | NA | NA | 22 | Distriktshøgskoler | MRDHV | 1 | Kunnskapsdepartementet | 2205 | Møre og Romsdal distriktshøgskule - Volda |
| 2206 | Nord-Trøndelag distriktshøgskole | Skolegata 22, Postboks 145 | 7701 | 19801 | 19943 | NA | NA | 22 | Distriktshøgskoler | NTDH | 1 | Kunnskapsdepartementet | 2206 | Nord-Trøndelag distriktshøgskole |
