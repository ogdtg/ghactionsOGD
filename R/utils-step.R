#' Create nested list for *one* [job](https://help.github.com/en/articles/workflow-syntax-for-github-actions#jobs)
#'
#' The `step()` function is imported from `ghactions`. All credits go to
#' `ghactions` authors. See \url{https://github.com/maxheld83/ghactions/blob/master/R/syntax.R}
#' for details.
#'
#' @param id,if,name,uses,shell `[character(1)]`
#' giving additional options for the step.
#' Multiline strings are not supported.
#' Defaults to `NULL`.
#'
#' @param run `[character()]`
#' giving commands to run.
#' Will be turned into a multiline string.
#' Defaults to `NULL`.
#'
#' @param with,env `[list()]`
#' giving a named list of additional parameters.
#' Defaults to `NULL`.
#'
#' @param working-directory `[character(1)]`
#' giving the default working directory.
#' Defaults to `NULL`.
#'
#' @param continue-on-error `[logical(1)]`
#' giving whether to allow a job to pass when this step fails.
#' Defaults to `NULL`.
#'
#' @param timeout-minutes `[integer(1)]`
#' giving the maximum number of minutes to run the step before killing the process.
#' Defaults to `NULL`.
#'
#' @family syntax
#' @keywords internal
#' @noRd
step <- function(name = NULL,
                 id = NULL,
                 `if` = NULL,
                 uses = NULL,
                 run = NULL,
                 shell = NULL,
                 with = NULL,
                 env = NULL,
                 `working-directory` = NULL,
                 `continue-on-error` = NULL,
                 `timeout-minutes` = NULL) {
  purrr::walk(
    .x = list(id, `if`, name, uses, shell, `working-directory`),
    .f = checkmate::assert_string,
    na.ok = FALSE,
    null.ok = TRUE
  )
  checkmate::assert_character(x = run, any.missing = FALSE, null.ok = TRUE)
  purrr::walk(
    .x = list(with, env),
    .f = checkmate::assert_list,
    any.missing = FALSE,
    null.ok = TRUE,
    names = "unique"
  )
  checkmate::assert_flag(x = `continue-on-error`, na.ok = FALSE, null.ok = TRUE)
  checkmate::assert_scalar(x = `timeout-minutes`, na.ok = FALSE, null.ok = TRUE)

  # linebreaks for run
  run <- glue::glue_collapse(x = run, sep = "\n", last = "\n")

  purrr::compact(as.list(environment()))
}
