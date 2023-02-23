################################################################################
##
## [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
##          21st century broadband access and education
## [ FILE ] clean_data_fcc.R
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

## -------------------------------------
## access by tech code within blockgroup
## -------------------------------------

## read in broadband data
bb <- readRDS(file.path(cln_dir, paste0("broadband_bg.RDS")))

## expand
bb_expand <- bb %>%
    expand(bg, year, month) %>%
    filter(!(year == 2014 & month == "Jun"),
           !(year == 2019 & month == "Dec"))

## compute access
## 0 := no access at all in block group
## 1 := at least one provider of technology in blockgroup
bb_access <- map2(techlist,
                  names(techlist),
                  ~ bb_expand %>%
                      left_join(bb %>%
                                filter(techcode %in% .x) %>%
                                mutate(access = 1) %>%
                                select(bg, year, month, access),
                                by = c("bg", "year", "month")) %>%
                      mutate(access = ifelse(is.na(access), 0, access)) %>%
                      rename(!!sym(paste0(.y, "_access")) := access)) %>%
    reduce(left_join, by = c("bg", "year", "month")) %>%
    filter(as.numeric(str_sub(bg, 1, 2)) < 60) %>%
    mutate(stfips = as.integer(str_sub(bg, 1, 2))) %>%
    left_join(crosswalkr::stcrosswalk, by = "stfips")

## save
saveRDS(bb_access, file.path(cln_dir, "bb_access_bg.RDS"))

## -------------------------------------
## join with geo data
## -------------------------------------

## read in holc blockgroup geo data
df_int_bg <- readRDS(file.path(cln_dir, "sf_bg_holc.RDS"))

## setting up data
df <- df_int_bg %>%
    ## ...dropping geometry b/c we don't need it at the moment
    st_drop_geometry() %>%
    ## ...left join access measures
    left_join(bb_access,
              by = c("geoid" = "bg", "year", "month"))

## get *_access column names
acc_vars <- grep(".+_access", names(df), value = TRUE)

## get within group summaries (within city)
holc_fcc <- map(acc_vars,
                ~ df %>%
                    ## convert 0/1 to 0/100 for prop --> pct
                    mutate(!!sym(.x) := !!sym(.x) * 100) %>%
                    group_by(year, month,
                             city, stabbr, stname, cenreg,
                             cenregnm,
                             holc_grade) %>%
                    summarise(acc = weighted.mean(!!sym(.x),
                                                  area_w,
                                                  na.rm = TRUE),
                              .groups = "drop") %>%
                    mutate(tech = .x)) %>%
    bind_rows %>%
    arrange(year, desc(month), tech, city, holc_grade) %>%
    select(city, stabbr, stname, cenreg, cenregnm,
           holc_grade, year, month, tech, acc)

## save
saveRDS(holc_fcc, file.path(cln_dir, "holc_fcc_analysis.RDS"))

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
