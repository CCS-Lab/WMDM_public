This repository contains analysis code and data for the following manuscript:

Park, Doh, Lee, Park, and Ahn "The neurocognitive role of working memory load when Pavlovian motivational control affects instrumental learning"

preprint DOI: https://doi.org/10.1101/2022.08.01.502269
fMRI data: https://openneuro.org/datasets/ds004647/versions/1.0.2

- `code`: code for analysis and plotting
  - `behav`: code for behavioral analysis
    - `1_task_performance`: behavioral analysis; Figure 2
    - `2_fit_model`: fit models using Rstan (Hierarchical Bayesian Analysis)
    - `3_plot_modeling_output`: compare models with leave-one-out cross-validation information criterion (LOOIC) and plot posterior distributions of the best-fitting model; Figure 3
    - `4_choice_consistency`: plot choice consistency with task data and model regressors
  - `fMRI`: code for fMRI analysis; each folder includes 1st-level and 2nd-level GLM codes
    - `GLM1`: model-based fMRI analysis using reward prediction error (RPE); Figure 5A
    - `GLM2`: categorical fMRI analysis related to Pavlovian bias
    - `GLM3`: model-based fMRI analysis using decision value
    - `PPI`: PPI analysis; Figure 5B
    - `smoothing`: codes for smoothing
- `data`: task data and model regressors
  - `covariates`: covariate table for fMRI analysis
  - `data_behav`: task data
  - `data_modelregW`: model regressors (action weights for go (Wgo) and nogo (Wnogo))
  - `seed_striatum_cluster_forPPI`: seed region (striatum) cluster for PPI analysis
- `stanmodel`: stan files for models
