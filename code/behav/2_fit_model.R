## -- load packages and set path
library(rstan)
library(tidyverse)
ROOT = 'PATH/TO/YOUR/GIT/project_WMDM_public/'
PATH_DATA = sprintf('%sdata/', ROOT)
PATH_STAN = sprintf('%sstanmodel/', ROOT)

FILE_DATA = sprintf("%sdata_behav.txt", PATH_DATA)

INCLUDE_REGRESSOR = 0

## -- models and parameters of interest for each model
models = c("gng",
           "gngwm_ep-1", "gngwm_pi-1", "gngwm_xi-1",
           "gngwm_pi_ep-1", "gngwm_xi_ep-1", "gngwm_xi_pi-1",
           "gngwm_xi_ep_pi-1")

POIs = list(
  "gng" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", "mu_rhoRew", "mu_rhoPun", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", 
    "log_lik"),
  "gngwm_ep-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", 
    "mu_rhoRew", "mu_rhoPun", "mu_ep_wm", "sigma", 
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "ep_wm", 
    "log_lik"),
  "gngwm_pi-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", 
    "mu_rhoRew", "mu_rhoPun", "mu_pi_wm", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "pi_wm",
    "log_lik"),
  "gngwm_xi-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", 
    "mu_rhoRew", "mu_rhoPun", "mu_xi_wm", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "xi_wm", 
    "log_lik"),
  "gngwm_pi_ep-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", "mu_rhoRew", 
    "mu_rhoPun", "mu_ep_wm", "mu_pi_wm", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "ep_wm", "pi_wm",
    "log_lik"),
  "gngwm_xi-ep-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", 
    "mu_rhoRew", "mu_rhoPun", "mu_xi_wm", "mu_ep_wm", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "xi_wm", "ep_wm",
    "log_lik"),
  "gngwm_xi_pi-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", "mu_rhoRew", "mu_rhoPun", "mu_xi_wm", "mu_pi_wm", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "xi_wm", "pi_wm",
    "log_lik"),
  "gngwm_xi_ep_pi-1" = c(
    "mu_xi", "mu_ep", "mu_b", "mu_pi", "mu_rhoRew", "mu_rhoPun", "mu_xi_wm", 
    "mu_pi_wm", "mu_ep_wm", "sigma",
    "xi", "ep", "b", "pi", "rhoRew", "rhoPun", "xi_wm", "pi_wm", "ep_wm",
    "log_lik")
)

## -- load and preprocess data
data <- read.table(FILE_DATA, sep = '\t', header = T) %>%
  group_by(subject, task) %>%
  mutate(trial_per_block = row_number(),
         wm = ifelse(task=="GNG", 0, 1),
         cue = case_when(cue == 'go to win' ~ 1,
                         cue == 'no-go to win' ~ 2,
                         cue == 'go to avoid losing' ~ 3,
                         cue == 'no-go to avoid losing' ~ 4))
  
n_subj = length(unique(data$subject))
b_max = length(unique(data$wm))
b_subjs = rep(b_max, n_subj)
t_max = max(data$trial_per_block)
t_subjs = array(t_max, c(n_subj, b_max))

wmload        <- array( 0, c(n_subj, b_max, t_max))
cue           <- array( 0, c(n_subj, b_max, t_max))
pressed       <- array( 0, c(n_subj, b_max, t_max))
outcome       <- array( 0, c(n_subj, b_max, t_max))

row = 0
for (i in 1:n_subj) {
  for (bl in 1:b_subjs[i]){
    for (t in 1:t_subjs[i, bl]){
      row = row + 1
      wmload[i, bl, t]      <- data$wm[row]
      cue[i, bl, t]         <- data$cue[row]
      pressed[i, bl, t]         <- data$key_pressed[row]
      outcome[i, bl, t]         <- data$outcome[row]
    }
  }
}


data_list <- list(
  N             = n_subj,
  B             = b_max,
  Bsubj         = b_subjs,
  T             = t_max,
  Tsubj         = t_subjs,
  wmload        = wmload,
  cue           = cue,
  pressed       = pressed,
  outcome       = outcome
)

## -- run all models
options(mc.cores = 4)
for (NAME_MODEL in models){
  if (INCLUDE_REGRESSOR == 1){
    POI = c(POIs[[NAME_MODEL]], c("Qgo", "Qnogo", "Wgo", "Wnogo", "SV", "DV"))
  } else {POI = POIs[[NAME_MODEL]]}
  
  FILE_MODEL = sprintf('%s%s.stan', PATH_STAN, NAME_MODEL)
  FILE_OUTPUT = sprintf('%soutput_%s.RData', PATH_DATA, NAME_MODEL)
  
  gng_model = stan_model(file = FILE_MODEL, model_name = NAME_MODEL)
  
  output <- sampling(gng_model,
                     data = data_list,
                     pars = POI,
                     chains = 4,
                     iter = 4000,
                     warmup = 2000,
                     init = "random",
                     thin = 1,
                     control = list(adapt_delta   = 0.99,
                                    max_treedepth = 10,
                                    stepsize      = 1))
  
  save(output, file = FILE_OUTPUT)
}

