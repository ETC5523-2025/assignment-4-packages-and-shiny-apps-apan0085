
# SurNamExp

<!-- badges: start -->
<!-- badges: end -->

The goal of SurNamExp is to make surname frequency data easy to explore and communicate. 
It packages a clean dataset (last_names), a Shiny app you can launch with launch_app(), and a reproducible data pipeline in data-raw/. 
Clear roxygen2 docs and a vignette guide you to run the app, interpret outputs, and regenerate the data.

## Overview

- Shiny app in inst/app/ with a simple filter → plot/table workflow.
- Packaged data: last_names (columns: Surname, Per_1000_Americans).
- Reproducibility: data prep script in data-raw/ (e.g., make_last_names.R).
- Docs: roxygen reference, a vignette, and (optionally) a pkgdown site.

## Installation

You can install the development version of SurNamExp from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ETC5523-2025/assignment-4-packages-and-shiny-apps-apan0085")
```

## Documentation

For detailed documentation and examples, visit the pkgdown site [here](https://etc5523-2025.github.io/assignment-4-packages-and-shiny-apps-apan0085/).


## Data Description

last_names is a tidy dataset of common surnames and their approximate frequency per 1,000 people.

Columns:

1. Surname — character; the family name (e.g., “Smith”, “Johnson”).
2. Per_1000_Americans — numeric; estimated count per 1,000 people.

> Use the below for more details :
```r
?SurNamExp::last_names 
```

### What you can do ?

- Launch the app and interactively browse name frequencies.
- Visualise rankings and view summary statistics that update with your selections.
- Recreate the dataset via the script in data-raw/ for full reproducibility.

## Example

Launch the dashboard:
```r
SurNamExp::launch_app()
```
Inspect the packaged data:
```r
str(SurNamExp::last_names)
head(SurNamExp::last_names)
```

Reproducibility:

Regenerate the packaged dataset and reinstall:
```r 
# from the project root
source("data-raw/make_last_names.R")

devtools::document()
devtools::install(upgrade = "never")
```

## Want to help develop ?
You can contribute by reporting issues, refining code or suggesting new ideas for the Shiny app and data-set. The source code is available by clicking the Github icon on the website or you can use [this link](https://github.com/ETC5523-2025/assignment-4-packages-and-shiny-apps-apan0085/issues)
