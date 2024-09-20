#' Creates a GithubAction Workflow
#'
#' This function sets up a GitHub Action workflow using a cron job by doing the following steps:
#' - Creates the necessary directory structure.
#' - Creates the YAML file to configure the workflow.
#' - Sets Actions Secrets if needed.
#'
#' IMPORTANT: The directory where the workflow should be created has to be a git repository!
#'
#' @param cron A string specifying the schedule in cron notation (e.g., "0 0 * * *" for daily at midnight).
#' @param name Name of the workflow
#' @param container_name Name of the container. This can be any docker container publicly available. Default is rocker/tidyverse:4.1.2
#' @param env Named list of environmental Variables such as keys that are used in the script(s). All given variables will be set as Actions secrets on GitHub.
#' @param scripts A vector of the paths of R scripts that should be executed in the workflow
#' @param repo Name of the repo. By default the function retreives the name of the current repo by using [get_repo_name()]
#' @param commit_message Commit Message for automatic commits
#' @param token Personal Access Token with the necessary permissions to set Actions Secrets. By default the function retreives the password from the git.config by using [get_git_pwd()]
#'
#' @return list with the full workflow
#' @export
#'
#' @examples
#'\dontrun{
#'create_ghactions_workflow(cron = "31 2 * * *",
#'                          name = "Test",
#'                          env = list(ODS_KEY = Sys.getenv("ODS_KEY")),
#'                          scripts = "test.R")
#'}
create_ghactions_workflow <- function(cron = NULL, name,container_name = "rocker/tidyverse:4.1.2", env = NULL,scripts,repo = get_repo_name(), commit_message = "Automated changes by GitHub Actions", token = get_git_pwd()){


  env <- tryCatch({
    checkmate::assert_list(x = env, any.missing = FALSE,
                           names = "named", null.ok = FALSE)
  }, error = function(cond){
    message(cond)
    NULL
  })

  if (!is.null(env)){
    env_names <- names(env)
    secrets_string <- paste0("${{ secrets.",env_names," }}")
    env_list <- as.list(secrets_string)
    names(env_list) <- env_names

    # Set the relevant repository secrets
    responses <- lapply(seq_along(env), function(i){
      gha_add_secret(secret = env[[i]],name = names(env[i]))
    })
  } else {
    env_list <- NULL
  }

  on <- function(event, ...) {
    checkmate::assert_choice(
      x = event,
      choices = c("push", "pull_request", "schedule")
    )
    rlang::set_names(x = list(purrr::compact(list(...))), nm = event)
  }

  on_schedule <- function(cron = NULL) {
    on(event = "schedule", cron = cron)
  }

  on_trigger = on_schedule(cron = cron)
  on_trigger$workflow_dispatch = NULL


  git_setup <- c(paste0('git config --global --add safe.directory /__w/',repo,'/',repo),
                 'git config --global user.name "GitHub Actions"',
                 'git config --global user.email "username@users.noreply.github.com"')


  full_workflow <- workflow(
    name = name,
    on = on_trigger,
    jobs = job(
      id = "run_script",
      container = container_name,
      `runs-on` = "ubuntu-latest",
      steps = list(
        step(name = "Checkout Repository",
             uses = "actions/checkout@v4"),
        step(name = "Execute Script",
             env = env_list,
             run = paste0("Rscript ",scripts)),
        step(name="Set up Git",
             run = git_setup),
        step(name = "Check if there are changes to commit",
            id = "changes_check",
            run = c("git add .",
                    "if git diff-index --quiet HEAD; then",
                    '   echo "changes=false" >>$GITHUB_OUTPUT',
                    "else",
                    '   echo "changes=true" >> $GITHUB_OUTPUT',
                    "fi")),
        step(name= "Commit changes",
             `if` = "${{ steps.changes_check.outputs.changes == 'true' }}",
             run = c(paste0('git commit -m "',commit_message,'"'))
        ),
        step(name = "Push changes",
             `if` = "${{ steps.changes_check.outputs.changes == 'true' }}",
             run = "git push"
        )

      )
    )
  )

  use_ghactions_ogd(full_workflow)

  return(full_workflow)
}
