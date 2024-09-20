#' Create nested list for a [workflow block](https://help.github.com/en/articles/workflow-syntax-for-github-actions)
#'
#' The `workflow()` function is imported from `ghactions`. All credits go to
#' `ghactions` authors. See \url{https://github.com/maxheld83/ghactions/blob/master/R/syntax.R}
#' for details.
#'
#' @param name `[character(1)]`
#' giving the [name](https://help.github.com/en/articles/workflow-syntax-for-github-actions#name) of the workflow.
#' Defaults to `NULL`, for no name, in which case GitHub will use the file name.
#'
#' @param on `[character()]`
#' giving the [GitHub Event](https://help.github.com/en/articles/events-that-trigger-workflows) on which to trigger the workflow.
#' Must be a subset of ghactions::ghactions_events().
#' Defaults to `"push"`, in which case the workflow is triggered on every push event.
#' Can also be a named list as returned by ghactions::on() for additional filters.
#'
#' @param jobs `[list()]`
#' giving a *named* list of jobs, with each list element as returned by [job()].
#'
#' @examples
#' workflow(
#'   name = "Render",
#'   on = "push",
#'   jobs = NULL
#' )
#'
#' @keywords internal
#' @noRd
workflow <- function(name = NULL, on = "push", jobs = NULL) {
  checkmate::assert_string(x = name, null.ok = TRUE, na.ok = FALSE)
  if (is.character(on)) {
    checkmate::assert_subset(
      x = on,
      choices = c(
        "check_run",
        "check_suite",
        "commit_comment",
        "create",
        "delete",
        "deployment",
        "deployment_status",
        "fork",
        "gollum",
        "issue_comment",
        "issues",
        "label",
        "member",
        "milestone",
        "page_build",
        "project",
        "project_card",
        "project_column",
        "public",
        "pull_request",
        "pull_request_review_comment",
        "pull_request_review",
        "push",
        "repository_dispatch",
        "release",
        "schedule",
        "status",
        "watch"
      ),
      empty.ok = FALSE
    )
  } else {
    checkmate::assert_list(
      x = on,
      any.missing = FALSE,
      names = "named"
    )
  }
  checkmate::assert_list(
    x = jobs,
    any.missing = FALSE,
    null.ok = TRUE,
    names = "unique"
  )

  purrr::compact(as.list(environment()))
}
