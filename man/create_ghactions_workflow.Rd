% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_ghactions_workflow.R
\name{create_ghactions_workflow}
\alias{create_ghactions_workflow}
\title{Creates a GithubAction Workflow}
\usage{
create_ghactions_workflow(
  cron = NULL,
  name,
  container_name = "rocker/tidyverse:4.1.2",
  env = NULL,
  scripts,
  repo = get_repo_name(),
  commit_message = "Automated changes by GitHub Actions",
  token = get_git_pwd()
)
}
\arguments{
\item{cron}{A string specifying the schedule in cron notation (e.g., "0 0 * * *" for daily at midnight).}

\item{name}{Name of the workflow}

\item{container_name}{Name of the container. This can be any docker container publicly available. Default is rocker/tidyverse:4.1.2}

\item{env}{Named list of environmental Variables such as keys that are used in the script(s). All given variables will be set as Actions secrets on GitHub.}

\item{scripts}{A vector of the paths of R scripts that should be executed in the workflow}

\item{repo}{Name of the repo. By default the function retreives the name of the current repo by using \code{\link[=get_repo_name]{get_repo_name()}}}

\item{commit_message}{Commit Message for automatic commits}

\item{token}{Personal Access Token with the necessary permissions to set Actions Secrets. By default the function retreives the password from the git.config by using \code{\link[=get_git_pwd]{get_git_pwd()}}}
}
\value{
list with the full workflow
}
\description{
This function sets up a GitHub Action workflow using a cron job by doing the following steps:
\itemize{
\item Creates the necessary directory structure.
\item Creates the YAML file to configure the workflow.
\item Sets Actions Secrets if needed.
}
}
\details{
IMPORTANT: The directory where the workflow should be created has to be a git repository!
}
\examples{
\dontrun{
create_ghactions_workflow(cron = "31 2 * * *",
                         name = "Test",
                         env = list(ODS_KEY = Sys.getenv("ODS_KEY")),
                         scripts = "test.R")
}
}
