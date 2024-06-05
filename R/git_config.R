#' Retrieve GitHub Password used in current repo
#'
#' @return password
#' @export
#'
get_git_pwd <- function(){
  system("git config user.password", intern = TRUE)
}

#' Retrieve GitHub User of current repo
#'
#' @return username
#' @export
#'
get_git_user <- function(){
  system("git config user.name", intern = TRUE)
}

#' Retrieve GitHub owner and repo name
#'
#' @return owner/repo
#' @export
#'
get_git_remote <- function(){
  gsub("\\.git$","",gsub("https://github.com/","",system("git config remote.origin.url", intern = TRUE)))
}


#' Retrieve GitHub repo name
#'
#' @return repo name
#' @export
#'
get_repo_name <- function(){

  tryCatch({
    system("git rev-parse --show-toplevel", intern = TRUE) %>% basename()
  }, error = function(cond){
    warning("Repo name cannot be retrieved automatically.")
    NULL
  })
}
