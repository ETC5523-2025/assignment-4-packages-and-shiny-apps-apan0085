#' last_names
#'
#' Common surnames and their approximate frequency per 1,000 people.
#'
#' @format A data frame with 21 rows and 2 variables:
#' \describe{
#'   \item{Surname}{Character. Family name (e.g., "Smith", "Johnson").}
#'   \item{Per_1000_Americans}{Numeric. Estimated count per 1,000 people.}
#' }
#'
#' @details
#' The dataset is stored as \code{last_names}. It is created by a reproducible
#' script in \code{data-raw/} (e.g., \code{make_last_names.R}) and saved with
#' \code{usethis::use_data(last_names)}.
#'
#' @source Recreated for demonstration; see \code{data-raw/make_last_names.R}.
#'
#' @examples
#' # Inspect structure
#' str(last_names)
#'
#' # Top 5 by frequency
#' head(last_names[order(-last_names$Per_1000_Americans), ], 5)
"last_names"
