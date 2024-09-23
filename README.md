
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
need to be part of your dependencies on GitHub later on.

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
workflow <- create_ghactions_workflow(cron = "31 2 * * *",
                          name = "Test Run",
                          env = list(ODS_KEY = Sys.getenv("ODS_KEY")),
                          scripts = "test.R")
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

Furthermore this command will set the necessary Actions Secrets. These
can be used as environmental Variables in the R script. In this case you
can use `Sys.getenv("ODS_KEY")` inside the `test.R` file an you will
receive the value defined in the `create_ghactions_workflow` function.

### YAML File

This YAML file represents a simple workflow which can be used to do
small-scale data-retrieval tasks. For a better understanding the content
will be discussde in more detail.

#### Event trigger

``` yaml
'on':
  schedule:
    - cron: 31 2 * * *
  workflow_dispatch: ~
```

This part defines, when the workflow should be triggered. Per default
the `create_ghactions_workflow` adds a cron schedule that you can define
in the function and a `workflow_dispatch` trigger. With this schedule,
the workflow will be triggered every day at 2:31. The
`workflow_dispatch` trigger allows you to trigger the workflow manually,
which is useful for testing purposes.

#### Initialise Container

``` yaml
runs-on: ubuntu-latest
container: rocker/tidyverse:4.1.2
```

In this section the system is defined and the docker image that should
be used. You can see a list of all rocker images
[here](https://rocker-project.org/images/). You can also use your own
image which has to be deployed on docker and must be publicly available.

#### Execute Script

``` yaml
- name: Execute Script
        run: Rscript test.R
        env:
          ODS_KEY: ${{ secrets.ODS_KEY }}
```

In this step the script is executed. Make sure that all needed packages
are installed in the Image or in the script itself. I would recommend to
use an image where all packages are preinstalled. This ensures stability
and reproducability.

All variables that are defined in `env` must be stored as Actions
Secrets. The `create_ghactions_workflow` takes care for this and
initializes the Action secrets accordingly. You can find the Action
Secrets on GitHub under `Settings -> Secrets and Variables -> Actions`

#### Push the Results to the Repo

``` yaml

      - name: Checkout Repository
        uses: actions/checkout@v4
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
```

To actually use the results your script you have to push them to the
Repo you are running the Workflow in. Therefore you need to checkout
your repository, set up git, add , commit and push the content.

There is also a functionality to check whether something has changed
e.g. if a push is neccessary.

## Acknowledgment

The package is using R functions internally imported directly from other
R packages. The following R functions have been integrated as utilities
functions:

- **[tic](https://github.com/ropensci/tic)**: `gha_add_secret()`
- **[ghactions](https://github.com/maxheld83/ghactions)**: `job()`,
  `step()`, `workflow()`

All credits for these imported functions goes to the authors of the
**tic** and **ghactions** R packages.
