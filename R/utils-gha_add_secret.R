#' Add a GitHub Actions secret to a repository
#'
#' The `gha_add_secret()` function is imported from `tic`. All credits go to
#' `tic` authors. See \url{https://docs.ropensci.org/tic/reference/gha_add_secret.html}
#' for details.
#'
#' Encrypts the supplied value using `libsodium` and adds it as a
#' secret to the given GitHub repository. Secrets can be be used in GitHub
#' Action runs as environment variables.
#' A common use case is to encrypt Personal Access Tokens (PAT) or API keys.
#'
#' This is the same as adding a secret manually in GitHub via
#' `"Settings" -> "Secrets" -> "New repository secret"`
#'
#' @param secret `[character]`\cr
#'   The value which should be encrypted (e.g. a Personal Access Token).
#'
#' @param name `[character]`\cr
#'   The name of the secret as which it will appear in the "Secrets" overview of
#'   the repository.
#'
#' @param visibility `[character]`\cr
#'   The level of visibility for the secret. One of `"all"`, `"private"`, or
#'   `"selected"`.
#'   See https://developer.github.com/v3/actions/secrets/#create-or-update-an-organization-secret
#'   for more information.
#' @param selected_repositories `[character]`\cr
#'   Vector of repository ids for which the secret is accessible.
#'   Only applies if `visibility = "selected"` was set.
#' @param repo_slug `[character]`\cr
#'   Repository slug of the repository to which the secret should be added.
#'   Must follow the form `owner/repo`.
#' @param remote `[character]`\cr
#'   If `repo_slug = NULL`, the `repo_slug` is determined by the respective git
#'   remote.
#' @examples
#' \dontrun{
#' gha_add_secret("supersecret", name = "MY_SECRET", repo = "ropensci/tic")
#' }
#' @keywords internal
#' @noRd
gha_add_secret <- function(secret,
                           name,
                           repo_slug = NULL,
                           remote = "origin",
                           visibility = "all",
                           selected_repositories = NULL) {
  requireNamespace("sodium", quietly = TRUE)
  requireNamespace("gh", quietly = TRUE)

  stopc <- function(...) {
    stop(..., call. = FALSE, domain = NA)
  }

  get_remote_url <- function(path, remote) {
    r <- git2r::repository(path, discover = TRUE)
    remote_names <- git2r::remotes(r)
    if (!length(remote_names)) {
      stopc("Failed to lookup git remotes")
    }
    remote_name <- remote
    if (!(remote_name %in% remote_names)) {
      stopc(sprintf(
        "No remote named '%s' found in remotes: '%s'.",
        remote_name, remote_names
      ))
    }
    git2r::remote_url(r, remote_name)
  }

  extract_repo <- function(url) {
    # Borrowed from gh:::github_remote_parse
    re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
    m <- regexec(re, url)
    match <- regmatches(url, m)[[1]]

    if (length(match) == 0) {
      stopc("Unrecognized repo format: ", url)
    }

    paste0(match[2], "/", match[3])
  }

  get_repo_data <- function(repo) {
    req <- gh::gh("/repos/:repo", repo = repo)
    return(req)
  }

  github_info <- function(path = usethis::proj_get(),
                          remote = "origin") {
    remote_url <- get_remote_url(path, remote)
    repo <- extract_repo(remote_url)
    get_repo_data(repo)
  }

  get_owner <- function(remote = "origin") {
    github_info(path = usethis::proj_get(), remote = remote)$owner$login
  }

  get_repo <- function(remote = "origin") {
    github_info(
      path = usethis::proj_get(),
      remote = remote
    )$name
  }

  if (is.null(repo_slug)) {
    owner <- get_owner(remote)
    repo <- get_repo(remote)
    repo_slug <- paste(get_owner(remote), "/", get_repo(remote))
  } else {
    slug <- strsplit(repo_slug, "/")[[1]]
    owner <- slug[1]
    repo <- slug[2]
  }

  auth_github <- function() {
    # authenticate on github
    token <- gh::gh_token()
    if (token == "") {
      cli::cli_alert_danger("{.pkg tic}: Call
      {.code usethis::browse_github_token()} and follow the instructions.
      Then restart the session and try again.", wrap = TRUE)
      stopc("Environment variable 'GITHUB_PAT' not set.")
    }
  }

  auth_github()

  key_id <- gh::gh("GET /repos/:owner/:repo/actions/secrets/public-key",
                   owner = owner,
                   repo = repo
  )$key_id

  pub_key_gh <- gh::gh("GET /repos/:owner/:repo/actions/secrets/public-key",
                       owner = owner,
                       repo = repo
  )$key

  key_id <- gh::gh("GET /repos/:owner/:repo/actions/secrets/public-key",
                   owner = owner,
                   repo = repo
  )$key_id

  # convert to raw for sodium
  secret_raw <- charToRaw(secret)
  # decode public key
  pub_key_gh_dec <- base64enc::base64decode(pub_key_gh)
  # encrypt using the pub key
  secret_raw_encr <- sodium::simple_encrypt(secret_raw, pub_key_gh_dec)
  # base64 encode secret
  secret_raw_encr <- base64enc::base64encode(secret_raw_encr)

  # add private key
  gh::gh("PUT /repos/:owner/:repo/actions/secrets/:secret_name",
         owner = owner,
         repo = repo,
         secret_name = name,
         key_id = key_id,
         encrypted_value = secret_raw_encr,
         visibility = visibility,
         selected_repository_ids = selected_repositories
  )

  cli::cli_alert_success("Successfully added secret {.env {name}} to repo
   {.field {owner}/{repo}}.", wrap = TRUE)
}
