################################################################################
##
## [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
##          21st century broadband access and education
## [ FILE ] make_data_geo.R
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

## which ACS and FCC data to use
acs_dat <- "acs_2015_2019_seq_135_sumlvl_140_us.RDS"
fcc_dat <- "broadband_bg.RDS"

## -----------------------------------------------------------------------------
## GEOGRAPHY (SHAPEFILES)
## -----------------------------------------------------------------------------

## -------------------------------------
## HOLC
## -------------------------------------

## Clean up HOLC shapefiles

## holc files
df_holc <- st_read(file.path(hol_dir, "holc_ad_data.shp")) %>%
  ## ...drop area descriptions since they have lots of text
  select(-area_descr) %>%
  ## ...project to common CRS
  st_transform(st_crs(common_crs)) %>%
  ## ...set edge buffer to 0
  st_buffer(dist = 0) %>%
  ## ...add unique id since some polygon ids are missing
  mutate(id = row_number()) %>%
  ## ...compute area for each polygon
  mutate(holc_area = as.numeric(st_area(geometry)))

## save
saveRDS(df_holc, file.path(cln_dir, "sf_holc.RDS"))

## -------------------------------------
## TIGER
## -------------------------------------

## Combine state TIGER shapefiles (tract and blockgroup) into single
## national file

## init length (2) list vector for tract and blockgroup data
shp_list <- list("tr" = NA, "bg" = NA)

## loop through each census level
for (i in c("tr", "bg")) {
  ## get subdirectories (one for each state)
  stdirs <- list.dirs(tig_dir, full.names = FALSE, recursive = FALSE)
  ## pattern
  pattern <- ifelse(i == "tr", "_tract$", "_bg$")
  ## i == "tr"? "_tract" : "_bg"
  stdirs <- grep(pattern, stdirs, value = TRUE)
  ## init empty list
  file_list <- vector("list", length = length(stdirs))
  ## loop through subdirectories
  for (j in seq_along(stdirs)) {
    ## get state-specific subdirectory
    stdir <- stdirs[j]
    ## file name is just subdirectory name + ".shp"
    file <- paste0(stdir, ".shp")
    ## read in shapefile
    file_list[[j]] <- st_read(file.path(tig_dir, stdir, file)) %>%
      ## ...project to common CRS
      st_transform(st_crs(common_crs)) %>%
      ## ...lower all column names
      rename_all(tolower) %>%
      ## ...create area measure
      mutate(area = as.numeric(st_area(geometry))) %>%
      select(geoid, area, geometry)
  }
  ## bind state-specific files into one w/zero buffer
  shp_list[[i]] <- do.call(rbind, file_list) %>% st_buffer(dist = 0)
}

## save
saveRDS(shp_list[["bg"]], file.path(cln_dir, "sf_bg_us.RDS"))
saveRDS(shp_list[["tr"]], file.path(cln_dir, "sf_tr_us.RDS"))

## -------------------------------------
## intersections: blocks over HOLC
## -------------------------------------

## intersection of blockgroups with HOLC maps
df_int_bg <- st_intersection(df_holc, shp_list[["bg"]]) %>%
  ## ...compute intersection areas
  mutate(iarea = as.numeric(st_area(geometry))) %>%
  ## - weight is the proportion of HOLC zone overlapped
  ## ...group by unique id
  group_by(id) %>%
  ## ...area weights
  mutate(area_w = log_divide(iarea, holc_area)) %>%
  ## ...ungroup
  ungroup() %>%
  ## ...left join broadband speeds
  left_join(readRDS(file.path(cln_dir, fcc_dat)),
            by = c("geoid" = "bg"))

## save
saveRDS(df_int_bg, file.path(cln_dir, "sf_bg_holc.RDS"))

## -------------------------------------
## intersections: HOLC over tracts
## -------------------------------------

df_int_tr <- st_intersection(shp_list[["tr"]], df_holc) %>%
  ## ...compute intersection areas
  mutate(iarea = as.numeric(st_area(geometry))) %>%
  ## - weight is the proportion of census tract overlapped
  ## ...group by unique id
  group_by(geoid) %>%
  ## ...area weights
  mutate(area_w = log_divide(iarea, holc_area)) %>%
  ## ...ungroup
  ungroup() %>%
  ## ...left join ACS measures
  left_join(readRDS(file.path(cln_dir, acs_dat)) %>%
              as_tibble,
            by = c("geoid" = "fips"))

## save
saveRDS(df_int_tr, file.path(cln_dir, "sf_tr_holc.RDS"))

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
