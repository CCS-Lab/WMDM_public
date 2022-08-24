data {
  int<lower=1> N;
  int<lower=1> B;
  int<lower=1, upper=B> Bsubj[N];
  int<lower=1> T;
  int<lower=1, upper=T> Tsubj[N, B];
  int<lower=0, upper=1> wmload[N, B, T];
  int<lower=1, upper=4> cue[N, B, T];
  int<lower=-1, upper=1> pressed[N, B, T];
  real outcome[N, B, T];
}

transformed data {
  vector[4] initV;
  initV = rep_vector(0.0, 4);
}

parameters {
  // declare as vectors for vectorizing
  vector[7] mu_pr;
  vector<lower=0>[7] sigma;
  vector[N] xi_pr;         // noise
  vector[N] ep_pr;         // learning rate
  vector[N] b_pr;          // go bias
  vector[N] pi_pr;         // pavlovian bias
  vector[N] rhoRew_pr;     // rho reward, inv temp
  vector[N] rhoPun_pr;     // rho punishment, inv temp
  vector[N] xi_wm_pr;      // noise under WM load
}

transformed parameters {
  vector<lower=0, upper=1>[N] xi;
  vector<lower=0, upper=1>[N] ep;
  vector[N] b;
  vector[N] pi;
  vector<lower=0>[N] rhoRew;
  vector<lower=0>[N] rhoPun;
  vector<lower=0, upper=1>[N] xi_wm;  

  for (i in 1:N) {
    xi[i]     = Phi_approx(mu_pr[1] + sigma[1] * xi_pr[i]);
    ep[i]     = Phi_approx(mu_pr[2] + sigma[2] * ep_pr[i]);
    xi_wm[i]  = Phi_approx(mu_pr[7] + sigma[7] * xi_wm_pr[i]);
  }
  b      = mu_pr[3] + sigma[3] * b_pr; // vectorization
  pi     = mu_pr[4] + sigma[4] * pi_pr;
  rhoRew = exp(mu_pr[5] + sigma[5] * rhoRew_pr);
  rhoPun = exp(mu_pr[6] + sigma[6] * rhoPun_pr);
}

model {
  // hyper parameters
  mu_pr[1]  ~ normal(0, 1.0);
  mu_pr[2]  ~ normal(0, 1.0);
  mu_pr[3]  ~ normal(0, 10.0);
  mu_pr[4]  ~ normal(0, 10.0);
  mu_pr[5]  ~ normal(0, 1.0);
  mu_pr[6]  ~ normal(0, 1.0);
  mu_pr[7]  ~ normal(0, 1.0);
  sigma[1:2] ~ normal(0, 0.2);
  sigma[3:4] ~ cauchy(0, 1.0);
  sigma[5:6] ~ normal(0, 0.2);
  sigma[7]   ~ normal(0, 0.2);

  // individual parameters w/ Matt trick
  xi_pr     ~ normal(0, 1.0);
  ep_pr     ~ normal(0, 1.0);
  b_pr      ~ normal(0, 1.0);
  pi_pr     ~ normal(0, 1.0);
  rhoRew_pr ~ normal(0, 1.0);
  rhoPun_pr ~ normal(0, 1.0);
  xi_wm_pr  ~ normal(0, 1.0);

  for (i in 1:N) {
    for (bl in 1:Bsubj[i]){
      vector[4] wv_g;  // action weight for go
      vector[4] wv_ng; // action weight for nogo
      vector[4] qv_g;  // Q value for go
      vector[4] qv_ng; // Q value for nogo
      vector[4] sv;    // stimulus value
      vector[4] pGo;   // prob of go (press)
      real xi_tmp;     // temporary variable for storing irreducible noise on a trial
  
      wv_g  = initV;
      wv_ng = initV;
      qv_g  = initV;
      qv_ng = initV;
      sv    = initV;
  
      for (t in 1:Tsubj[i, bl]) {
        // Adjust parameter values
        if (wmload[i, bl, t] == 1){
          xi_tmp = xi_wm[i];
        } else {
          xi_tmp = xi[i];
        }   
        
        // Make a choice
        wv_g[cue[i, bl, t]]  = qv_g[cue[i, bl, t]] + b[i] + pi[i] * sv[cue[i, bl, t]];
        wv_ng[cue[i, bl, t]] = qv_ng[cue[i, bl, t]];  // qv_ng is always equal to wv_ng (regardless of action)
        pGo[cue[i, bl, t]]   = inv_logit(wv_g[cue[i, bl, t]] - wv_ng[cue[i, bl, t]]);
        {  // noise
          pGo[cue[i, bl, t]]   *= (1 - xi_tmp);
          pGo[cue[i, bl, t]]   += xi_tmp/2;
        }
        pressed[i, bl, t] ~ bernoulli(pGo[cue[i, bl, t]]);
        
        // after receiving feedback, update sv[t + 1]
        if (outcome[i, bl, t] >= 0) {
          sv[cue[i, bl, t]] += ep[i] * (rhoRew[i] * outcome[i, bl, t] - sv[cue[i, bl, t]]);
        } else {
          sv[cue[i, bl, t]] += ep[i] * (rhoPun[i] * outcome[i, bl, t] - sv[cue[i, bl, t]]);
        }
  
        // update action values
        if (pressed[i, bl, t]) { // update go value
          if (outcome[i, bl, t] >=0) {
            qv_g[cue[i, bl, t]] += ep[i] * (rhoRew[i] * outcome[i, bl, t] - qv_g[cue[i, bl, t]]);
          } else {
            qv_g[cue[i, bl, t]] += ep[i] * (rhoPun[i] * outcome[i, bl, t] - qv_g[cue[i, bl, t]]);
          }
        } else { // update no-go value
          if (outcome[i, bl, t] >=0) {
            qv_ng[cue[i, bl, t]] += ep[i] * (rhoRew[i] * outcome[i, bl, t] - qv_ng[cue[i, bl, t]]);
          } else {
            qv_ng[cue[i, bl, t]] += ep[i] * (rhoPun[i] * outcome[i, bl, t] - qv_ng[cue[i, bl, t]]);
          }
        }
      } // end of t loop
    }
  } // end of i loop
}

generated quantities {
  real<lower=0, upper=1> mu_xi;
  real<lower=0, upper=1> mu_ep;
  real mu_b;
  real mu_pi;
  real<lower=0> mu_rhoRew;
  real<lower=0> mu_rhoPun;
  real<lower=0, upper=1> mu_xi_wm;
  real log_lik[N];
  real Qgo[N, B, T];
  real Qnogo[N, B, T];
  real Wgo[N, B, T];
  real Wnogo[N, B, T];
  real SV[N, B, T];
  real DV[N, B, T];

  // For posterior predictive check
  real y_pred[N, B, T];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (bl in 1:B){
      for (t in 1:T) {
        y_pred[i, bl, t] = -1;
      }
    }
  }

  mu_xi     = Phi_approx(mu_pr[1]);
  mu_ep     = Phi_approx(mu_pr[2]);
  mu_b      = mu_pr[3];
  mu_pi     = mu_pr[4];
  mu_rhoRew = exp(mu_pr[5]);
  mu_rhoPun = exp(mu_pr[6]);
  mu_xi_wm  = Phi_approx(mu_pr[7]);

  { // local section, this saves time and space
    for (i in 1:N) {
      for (bl in 1:Bsubj[i]){
        vector[4] wv_g;  // action weight for go
        vector[4] wv_ng; // action weight for nogo
        vector[4] qv_g;  // Q value for go
        vector[4] qv_ng; // Q value for nogo
        vector[4] sv;    // stimulus value
        vector[4] pGo;   // prob of go (press)
        real xi_tmp;     // temporary variable for storing irreducible noise on a trial        
  
        wv_g  = initV;
        wv_ng = initV;
        qv_g  = initV;
        qv_ng = initV;
        sv    = initV;
  
        log_lik[i] = 0;
  
        for (t in 1:Tsubj[i, bl]) {
          // Adjust parameter values
          if (wmload[i, bl, t] == 1){
            xi_tmp = xi_wm[i];
          } else {
            xi_tmp = xi[i];
          }   
          
          // Make a choice
          wv_g[cue[i, bl, t]]  = qv_g[cue[i, bl, t]] + b[i] + pi[i] * sv[cue[i, bl, t]];
          wv_ng[cue[i, bl, t]] = qv_ng[cue[i, bl, t]];  // qv_ng is always equal to wv_ng (regardless of action)
          pGo[cue[i, bl, t]]   = inv_logit(wv_g[cue[i, bl, t]] - wv_ng[cue[i, bl, t]]);
          {  // noise
            pGo[cue[i, bl, t]]   *= (1 - xi_tmp);
            pGo[cue[i, bl, t]]   += xi_tmp/2;
          }
          log_lik[i] += bernoulli_lpmf(pressed[i, bl, t] | pGo[cue[i, bl, t]]);
  
          // generate posterior prediction for current trial
          y_pred[i, bl, t] = bernoulli_rng(pGo[cue[i, bl, t]]);
  
          // Model regressors --> store values before being updated
          Qgo[i, bl, t]   = qv_g[cue[i, bl, t]];
          Qnogo[i, bl, t] = qv_ng[cue[i, bl, t]];
          Wgo[i, bl, t]   = wv_g[cue[i, bl, t]];
          Wnogo[i, bl, t] = wv_ng[cue[i, bl, t]];
          SV[i, bl, t]    = sv[cue[i, bl, t]];
          if (pressed[i, bl, t] == 1) {
            DV[i, bl, t] = wv_g[cue[i, bl, t]] - wv_ng[cue[i, bl, t]];
          } else {
            DV[i, bl, t] = wv_ng[cue[i, bl, t]] - wv_g[cue[i, bl, t]];
          }
  
         // after receiving feedback, update sv[t + 1]
          if (outcome[i, bl, t] >= 0) {
            sv[cue[i, bl, t]] += ep[i] * (rhoRew[i] * outcome[i, bl, t] - sv[cue[i, bl, t]]);
          } else {
            sv[cue[i, bl, t]] += ep[i] * (rhoPun[i] * outcome[i, bl, t] - sv[cue[i, bl, t]]);
          }
    
          // update action values
          if (pressed[i, bl, t]) { // update go value
            if (outcome[i, bl, t] >=0) {
              qv_g[cue[i, bl, t]] += ep[i] * (rhoRew[i] * outcome[i, bl, t] - qv_g[cue[i, bl, t]]);
            } else {
              qv_g[cue[i, bl, t]] += ep[i] * (rhoPun[i] * outcome[i, bl, t] - qv_g[cue[i, bl, t]]);
            }
          } else { // update no-go value
            if (outcome[i, bl, t] >=0) {
              qv_ng[cue[i, bl, t]] += ep[i] * (rhoRew[i] * outcome[i, bl, t] - qv_ng[cue[i, bl, t]]);
            } else {
              qv_ng[cue[i, bl, t]] += ep[i] * (rhoPun[i] * outcome[i, bl, t] - qv_ng[cue[i, bl, t]]);
            }
          }
        } // end of t loop
      }
    } // end of i loop
  } // end of local section
}

