#' Create nested list for *one* [job](https://help.github.com/en/articles/workflow-syntax-for-github-actions#jobs)
#'
#' The `job()` function is imported from `ghactions`. All credits go to
#' `ghactions` authors. See \url{https://github.com/maxheld83/ghactions/blob/master/R/syntax.R}
#' for details.
#'
#' @param id,name `[character(1)]`
#' giving additional options for the job.
#' Defaults to `NULL`.
#'
#' @param needs `[character()]`
#' giving the jobs that must complete successfully before this job is run.
#' Defaults to `NULL` for no dependencies.
#'
#' @param runs-on `[character(1)]`
#' giving the type of virtual host machine to run the job on.
#' Defaults to `"ubuntu-18.04"`.
#'
#' @param steps `[list()]`
#' giving an *unnamed* list of steps, with each element as returned by [step()].
#' Defaults to `NULL`.
#'
#' @param timeout_minutes `[integer(1)]`
#' giving the maximum number of minutes to let a workflow run before GitHub automatically cancels it.
#' Defaults to `NULL`.
#'
#' @param strategy `[list()]`
#' giving a named list as returned by ghactions::strategy().
#' Defaults to `NULL`.
#'
#' @param container `[character(1)]`/`[list()]`
#' giving a published container image.
#' For advanced options, use ghactions::container().
#' Defaults to `NULL`.
#'
#' @param services `[list()]`
#' giving additional containers to host services for a job in a workflow in a *named* list.
#' Use ghactions::container() to construct the list elements.
#' Defaults to `NULL`.
#'
#' @family syntax
#' @keywords internal
#' @noRd
job <- function(id,
                name = NULL,
                needs = NULL,
                `runs-on` = "ubuntu-18.04",
                steps = NULL,
                timeout_minutes = NULL,
                strategy = NULL,
                container = NULL,
                services = NULL) {
  checkmate::assert_string(x = id, na.ok = FALSE)
  checkmate::assert_string(x = name, na.ok = FALSE, null.ok = TRUE)
  checkmate::assert_character(
    x = needs,
    any.missing = FALSE,
    unique = TRUE,
    null.ok = TRUE
  )
  checkmate::assert_choice(
    x = `runs-on`,
    choices = c(
      "ubuntu-latest",
      "ubuntu-18.04",
      "ubuntu-16.04",
      "windows-latest",
      "windows-2019",
      "windows-2016",
      "macOS-latest",
      "macOS-10.14"
    ),
    null.ok = FALSE
  )
  checkmate::assert_list(
    x = steps,
    null.ok = TRUE,
    names = "unnamed"
  )
  checkmate::assert_scalar(
    x = timeout_minutes,
    na.ok = FALSE,
    null.ok = TRUE
  )
  checkmate::assert_list(
    x = strategy,
    any.missing = FALSE,
    names = "unique",
    null.ok = TRUE
  )
  if (is.character(container)) {
    checkmate::assert_string(x = container, na.ok = FALSE, null.ok = TRUE)
  } else {
    checkmate::assert_list(
      x = container,
      any.missing = FALSE,
      null.ok = TRUE,
      names = "unique"
    )
  }
  checkmate::assert_list(
    x = services,
    any.missing = FALSE,
    null.ok = TRUE,
    names = "unique"
  )

  res <- as.list(environment())
  res$id <- NULL  # that's the name of the list, not *in* the list
  res <- purrr::compact(res)
  rlang::set_names(x = list(res), nm = id)
}
