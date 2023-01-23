################################################################################
##
## [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
##          21st century broadband access and education
## [ FILE ] functions.R
## [ AUTH ] Benjamin Skinner (@btskinner), Hazel Levy, & Taylor Burtch
## [ INIT ] 23 January 2023
##
################################################################################

## log division (assuming all positive and non-missing)
log_divide <- function(num, den) {
    exp(log(num) - log(den))
}

## convert state abbreviation to collapsed state name
stabbr_to_name <- function(stabbr,
                           cw = crosswalkr::stcrosswalk,
                           stabbr_col = "stabbr",
                           stname_col = "stname") {

    stabbr <- toupper(stabbr)
    stname <- cw[stname_col][cw[stabbr_col] == stabbr]
    str_replace_all(stname, "[:space:]", "")
}

## inverse logit function
inv_logit <- function(x) { exp(-log(1 + exp(-x))) }

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
