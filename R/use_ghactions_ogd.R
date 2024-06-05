#' Workflow automation with GitHub Actions (specialised)
#'
#' See [`use_ghactions()`][ghactions::use_ghactions()] from the [ghactions] package
#'
#' @param workflow see [ghactions::use_ghactions()]
#'
#' @export
#'
use_ghactions_ogd <- function(workflow){

  checkmate::assert_list(x = workflow, any.missing = FALSE,
                         names = "named", null.ok = FALSE)

  workflow$on = list(schedule = workflow$on$schedule,
                     workflow_dispatch = NULL)
  workflow$jobs$run_script$steps[[1]]$run <- NULL


  # Manual correction
  yaml_file <- ghactions:::r2yaml(workflow)
  yaml_file_new <- gsub("    cron:","    - cron:",yaml_file)

  tryCatch(expr = gh::gh_tree_remote(), error = function(cnd) {
    usethis::ui_stop(c("This project does not have a GitHub remote configured as {usethis::ui_value('origin')}.",
                       "Do you need to run {usethis::ui_code('usethis::use_github()')}?"))
  })
  usethis::use_directory(path = ".github/workflows", ignore = TRUE)
  new <- usethis::write_over(path = ".github/workflows/main.yml",
                             lines = yaml_file_new, quiet = TRUE)
  if (new) {
    usethis::ui_done(x = "GitHub actions is set up and ready to go.")
    usethis::ui_todo(x = "Commit and push the changes.")
    usethis::ui_todo(x = "Visit the actions tab of your repository on github.com to check the results.")
  }
  invisible(new)
}
