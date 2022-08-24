"The neurocognitive role of working memory load when Pavlovian motivational control affects instrumental learning"

Heesun Park 2662266@snu.ac.kr
- `code`: code for analysis and plotting
  - `1_task_performance`: behavioral analysis; Figure 2
  - `2_fit_model`: fit models using Rstan (Hierarchical Bayesian Analysis)
  - `3_plot_modeling_output`: compare models with leave-one-out cross-validation information criterion (LOOIC) and plot posterior distributions of the best-fitting model; Figure 3
  - `4_choice_consistency`: plot choice consistency with task data and model regressors
- `data`: task data and model regressors
  - `data_behav`: task data
  - `data_modelregW`: model regressors (action weights for go (Wgo) and nogo (Wnogo))
- `stanmodel`: stan files for models
