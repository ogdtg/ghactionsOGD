
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ghactionsOGD

<!-- badges: start -->

[![R-CMD-check](https://github.com/ogdtg/ghactionsOGD/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ogdtg/ghactionsOGD/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of ghactionsOGD is to simplify the usage of Github Actions for
small-scale data retrieval processes. A typical workflow would be to
scrape data from a website on a daily basis and publish it as Open
Government Data (OGD). In such a scenario the packages helps the user to
set up the correct GitHub Actions Workflow including setting Actions
Secrets and specifying the YAML Workflow file.

Since the package is only used for setting up the workflow, it does not
need to be part of your depencencies on GitHub later on.

## Installation

You can install the development version of ghactionsOGD from
[GitHub](https://github.com/ogdtg/ghactionsOGD/tree/main) with:

``` r
# install.packages("devtools")
devtools::install_github("ogdtg/ghactionsOGD")
```

## Example

To create a workflow and set Actions Secrets that can be used in the R
script you can use the following command. Before running the command you
should have cloned the GitHub Repo to your local machine and you should
run this command from within the cloned repo.

``` r
library(ghactionsOGD)
create_ghactions_workflow(cron = "31 2 * * *",
                          name = "Test Run",
                          env = list(ODS_KEY = Sys.getenv("ODS_KEY")),
                          scripts = "test.R")
#> ✔ Setting active project to '/r-proj/stat/ogd/ghactionsOGD'
#> ✔ Successfully added secret ODS_KEY to repo ogdtg/ghactionsOGD.
#> Warning: Multiple github remotes found. Using origin.
#> ✔ Adding '^\\.github/workflows$' to '.Rbuildignore'
#> ✔ GitHub actions is set up and ready to go.
#> • Commit and push the changes.
#> • Visit the actions tab of your repository on github.com to check the results.
#> $name
#> [1] "Test Run"
#> 
#> $on
#> $on$schedule
#> $on$schedule$cron
#> [1] "31 2 * * *"
#> 
#> 
#> 
#> $jobs
#> $jobs$run_script
#> $jobs$run_script$`runs-on`
#> [1] "ubuntu-latest"
#> 
#> $jobs$run_script$steps
#> $jobs$run_script$steps[[1]]
#> $jobs$run_script$steps[[1]]$name
#> [1] "Checkout Repository"
#> 
#> $jobs$run_script$steps[[1]]$uses
#> [1] "actions/checkout@v4"
#> 
#> $jobs$run_script$steps[[1]]$run
#> 
#> 
#> 
#> $jobs$run_script$steps[[2]]
#> $jobs$run_script$steps[[2]]$name
#> [1] "Execute Script"
#> 
#> $jobs$run_script$steps[[2]]$run
#> Rscript test.R
#> 
#> $jobs$run_script$steps[[2]]$env
#> $jobs$run_script$steps[[2]]$env$ODS_KEY
#> [1] "${{ secrets.ODS_KEY }}"
#> 
#> 
#> 
#> $jobs$run_script$steps[[3]]
#> $jobs$run_script$steps[[3]]$name
#> [1] "Set up Git"
#> 
#> $jobs$run_script$steps[[3]]$run
#> git config --global --add safe.directory /__w/ghactionsOGD/ghactionsOGD
#> git config --global user.name "GitHub Actions"
#> git config --global user.email "username@users.noreply.github.com"
#> 
#> 
#> $jobs$run_script$steps[[4]]
#> $jobs$run_script$steps[[4]]$name
#> [1] "Check if there are changes to commit"
#> 
#> $jobs$run_script$steps[[4]]$id
#> [1] "changes_check"
#> 
#> $jobs$run_script$steps[[4]]$run
#> git add .
#> if git diff-index --quiet HEAD; then
#>    echo "changes=false" >>$GITHUB_OUTPUT
#> else
#>    echo "changes=true" >> $GITHUB_OUTPUT
#> fi
#> 
#> 
#> $jobs$run_script$steps[[5]]
#> $jobs$run_script$steps[[5]]$name
#> [1] "Commit changes"
#> 
#> $jobs$run_script$steps[[5]]$`if`
#> [1] "${{ steps.changes_check.outputs.changes == 'true' }}"
#> 
#> $jobs$run_script$steps[[5]]$run
#> git commit -m "Automated changes by GitHub Actions"
#> 
#> 
#> $jobs$run_script$steps[[6]]
#> $jobs$run_script$steps[[6]]$name
#> [1] "Push changes"
#> 
#> $jobs$run_script$steps[[6]]$`if`
#> [1] "${{ steps.changes_check.outputs.changes == 'true' }}"
#> 
#> $jobs$run_script$steps[[6]]$run
#> git push
#> 
#> 
#> 
#> $jobs$run_script$container
#> [1] "rocker/tidyverse:4.1.2"
```

First, this command will produce the file `.github/workflows/main.yml`
in your working directory (e.g. your local git repository). The file
looks like this:

``` yaml
name: Test
'on':
  schedule:
    - cron: 31 2 * * *
  workflow_dispatch: ~
jobs:
  run_script:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      - name: Execute Script
        run: Rscript test.R
        env:
          ODS_KEY: ${{ secrets.ODS_KEY }}
      - name: Set up Git
        run: |-
          git config --global --add safe.directory /__w/github_test/github_test
          git config --global user.name "GitHub Actions"
          git config --global user.email "username@users.noreply.github.com"
      - name: Check if there are changes to commit
        id: changes_check
        run: |-
          git add .
          if git diff-index --quiet HEAD; then
             echo "changes=false" >>$GITHUB_OUTPUT
          else
             echo "changes=true" >> $GITHUB_OUTPUT
          fi
      - name: Commit changes
        if: ${{ steps.changes_check.outputs.changes == 'true' }}
        run: git commit -m "Automated changes by GitHub Actions"
      - name: Push changes
        if: ${{ steps.changes_check.outputs.changes == 'true' }}
        run: git push
    container: rocker/tidyverse:4.1.2
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
