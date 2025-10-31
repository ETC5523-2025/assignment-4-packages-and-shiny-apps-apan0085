#' Launch the Shiny App
#' @export
run_app <- function() {
  app_dir <- system.file("eda-app", package = "SurNamExp")
  shiny::runApp(app_dir, display.mode = "normal")
}
