// =============================================================================
//
// [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
//          21st century broadband access and education
// [ FILE ] model_acs.stan
// [ AUTH ] Benjamin Skinner (@btskinner), Hazel Levy, & Taylor Burtch
// [ INIT ] 23 January 2023
//
// =============================================================================

data {
  int<lower=1> L;	 // # regions
  int<lower=1> M;	 // # states
  int<lower=1> P;        // # cities
  int<lower=1> N;	 // # obs
  int<lower=1> K_zone;   // # unique HOLC zones
  array[N] int y;
  array[N] int total;
  array[N] int region;         // vars
  array[N] int state;
  array[N] int city;
  array[N] int zone;	   
}
parameters {
  // intercepts: overall, region, state, city
  real alpha;
  real<lower=0> sigma_alpha_region;
  vector<multiplier=sigma_alpha_region>[L] alpha_region;
  real<lower=0> sigma_alpha_state;
  vector<multiplier=sigma_alpha_state>[M] alpha_state;
  real<lower=0> sigma_alpha_city;
  vector<multiplier=sigma_alpha_city>[P] alpha_city; 
  // zone
  real<lower=0> sigma_beta_zone;
  vector<multiplier=sigma_beta_zone>[K_zone] beta_zone;
}
model {
  // likelihood
  y ~ binomial_logit(total, alpha
		     + beta_zone[zone]
		     + alpha_city[city]
		     + alpha_state[state]
		     + alpha_region[region]);
  // priors: coefficients
  alpha ~ normal(0,2);
  beta_zone ~ normal(0,sigma_beta_zone);
  alpha_region ~ normal(0,sigma_alpha_region);
  alpha_state ~ normal(0,sigma_alpha_state);
  alpha_city ~ normal(0,sigma_alpha_city);
  // priors: standard deviations
  sigma_alpha_region ~ normal(0,1);
  sigma_alpha_state ~ normal(0,1);
  sigma_alpha_city ~ normal(0,1);
  sigma_beta_zone ~ normal(0,1);
}
