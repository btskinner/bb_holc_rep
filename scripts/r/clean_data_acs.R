################################################################################
##
## [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
##          21st century broadband access and education
## [ FILE ] clean_data_acs.R
## [ AUTH ] Benjamin Skinner (@btskinner), Hazel Levy, & Taylor Burtch
## [ INIT ] 23 January 2023
##
################################################################################

## libraries
libs <- c("data.table", "tidyverse", "readxl", "sf", "crosswalkr")
sapply(libs, require, character.only = TRUE)

## directory paths
args <- commandArgs(trailingOnly = TRUE)
root <- ifelse(length(args) == 0, file.path("..", ".."), args)
dat_dir <- file.path(root, "data")
acs_dir <- file.path(dat_dir, "acs")
bbd_dir <- file.path(dat_dir, "broadband")
cln_dir <- file.path(dat_dir, "clean")
hol_dir <- file.path(dat_dir, "holc")
tig_dir <- file.path(dat_dir, "tiger")
scr_dir <- file.path(root, "scripts", "r")

## external functions
source(file.path(scr_dir, "functions.R"))

## external macros
source(file.path(scr_dir, "macros.R"))

## data.table options
options(datatable.integer64 = "character")

## -----------------------------------------------------------------------------
## clean ACS analysis data
## -----------------------------------------------------------------------------

## read in holc tract geo data
df_int_tr <- readRDS(file.path(cln_dir, "sf_tr_holc.RDS"))

## setting up data
df <- df_int_tr %>%
    ## ...dropping geometry b/c we don't need it at the moment
    st_drop_geometry() %>%
    ## add in crosswalk variables
    mutate(stfips = as.integer(str_sub(geoid, 1, 2))) %>%
    ## join stcrosswalk variables
    left_join(crosswalkr::stcrosswalk, by = "stfips") %>%
    ## arrange columns
    relocate(stfips:cendivnm, geoid)

## get count column names
count_vars <- grep("^v[0-9]+$", names(df), value = TRUE)

## get ACS values within HOLC zones
holc_acs <- map(count_vars,
                ~ df %>%
                    mutate(!!paste0(.x, "_wc") := area_w * !!sym(.x)) %>%
                    select(geoid, id, !!paste0(.x, "_wc"))) %>%
    reduce(left_join, by = c("geoid", "id")) %>%
    group_by(id) %>%
    summarise(across(ends_with("_wc"),
                     ~ sum(.x) %>% ceiling)) %>%
    left_join(df %>%
              distinct(id, .keep_all = TRUE) %>%
              select(c(id, city:holc_area, stfips:cendivnm)),
              by = "id") %>%
    relocate(c(id, city:holc_area, stfips:cendivnm))

## save
saveRDS(holc_acs, file.path(cln_dir, "holc_acs_analysis.RDS"))

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
