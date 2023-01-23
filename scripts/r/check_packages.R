################################################################################
##
## [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
##          21st century broadband access and education
## [ FILE ] check_packages.R
## [ AUTH ] Benjamin Skinner (@btskinner), Hazel Levy, & Taylor Burtch
## [ INIT ] 23 January 2023
##
################################################################################

## directories
args <- commandArgs(trailingOnly = TRUE)
root <- ifelse(length(args) == 0, file.path("..", ".."), args)
scr_dir <- file.path(root, "scripts", "r")

## packages required for this project
req_packages <- c("tidyverse",
                  "extrafont",
                  "rstan",
                  "data.table",
                  "readxl",
                  "knitr",
                  "gtools",
                  "crosswalkr",
                  "sf",
                  "patchwork",
                  "ggthemes",
                  "lubridate",
                  "xtable",
                  "purrr",
                  "devtools")

## packages that are not installed
mask <- (req_packages %in% installed.packages()[,"Package"])
miss_packages <- req_packages[!mask]

## install any missing
if (length(miss_packages)) {
    message("Installing missing packages")
    install.packages(miss_packages)
} else {
    message("All required packages found")
}

## check for cmdstanr
if (!("cmdstanr" %in% installed.packages()[,"Package"])) {
    ## install cmdstanr
    install.packages("cmdstanr",
                     repos = c("https://mc-stan.org/r-packages/",
                               getOption("repos")))
    ## install cmdstan under the hood
    cmdstanr::install_cmdstan(cores = getOption("mc.cores", 2))
}

## make sure we import fonts for figures
have_times_font <- grepl("Times", extrafont::fonts())
if (length(have_times_font) == 0 || !have_times_font) {
    message("Importing Times typeface for paper graphics")
    extrafont::font_import(prompt = FALSE, pattern = "Times")
}

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
