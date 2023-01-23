################################################################################
##
## [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
##          21st century broadband access and education
## [ FILE ] macros_stan.R
## [ AUTH ] Benjamin Skinner (@btskinner), Hazel Levy, & Taylor Burtch
## [ INIT ] 23 January 2023
##
################################################################################

stan_seed <- 8643
stan_adapt_delta <- .99
stan_max_depth <- 15L
stan_num_cores <- 4
stan_num_chains <- 4
stan_num_threads <- 1
stan_num_warmup <- 1000L
stan_num_samples <- stan_num_warmup

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
