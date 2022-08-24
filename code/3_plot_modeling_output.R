#### Figure 3

########################################################################
## Settings ############################################################
########################################################################

## -- load packages and set path
library(rstan)
library(tidyverse)
ROOT = '/home/heesun/project/WMDM_public'
PATH_DATA = sprintf('%sdata/', ROOT)

## -- models
models = c("gng",
           "gngwm_ep-1", "gngwm_pi-1", "gngwm_xi-1",
           "gngwm_pi_ep-1", "gngwm_xi-ep-1", "gngwm_xi_pi-1",
           "gngwm_xi_ep_pi-1")

model_labels = c('Baseline',
                 'Separate pi', 'Separate xi', 'Separate ep',
                 'Separate xi & ep', 'Separate pi & ep', 'Separate xi & pi',
                 'Separate xi & ep & pi')

## -- define a function for compute Higest-Density Interval (HDI)
# Downloaded from John Kruschke's website 
# (http://www.indiana.edu/~kruschke/DoingBayesianDataAnalysis/)
HDIofMCMC = function(sampleVec, 
                     credMass = 0.95 ) {
  # sampleVec: A vector of representative values 
  #            from a probability distribution (e.g., MCMC samples).
  # credMass: A scalar between 0 and 1, 
  #           indicating the mass within the credible interval that is to be estimated.
  sortedPts = sort( sampleVec )
  ciIdxInc = floor( credMass * length( sortedPts ) )
  nCIs = length( sortedPts ) - ciIdxInc
  ciWidth = rep( 0 , nCIs )
  for ( i in 1:nCIs ) {
    ciWidth[ i ] = sortedPts[ i + ciIdxInc ] - sortedPts[ i ]
  }
  HDImin = sortedPts[ which.min( ciWidth ) ]
  HDImax = sortedPts[ which.min( ciWidth ) + ciIdxInc ]
  HDIlim = c( HDImin , HDImax )
  return( HDIlim ) # A vector containing the limits of the HDI
}

########################################################################
## Analysis ############################################################
########################################################################

########################################################################
## Fig 3A. Model comparison with LOOIC

## -- extract LOOIC 
looics = c()
for (NAME_MODEL in models){
  FILE_OUTPUT = sprintf('%soutput_%s.RData', PATH_DATA, NAME_MODEL)
  load(FILE_OUTPUT)
  index = loo(output, pars="log_lik")
  looic = index$estimates['looic', 'Estimate']
  looics = c(looics, looic)
}

looic_df = data.frame(model = models,
                      model_label = model_labels,
                      looic = looics)

## -- Calculate LOOIC difference
min_looic = min(looic_df$looic)
looic_df = looic_df %>%
  mutate(looic_diff = looic - min_looic) %>%
  arrange(looic_diff)

## -- Set model order for plotting
looic_df$model_label = factor(looic_df$model_label, looic_df$model_label)

## -- plot!
ggplot(looic_df, aes(x=model_label, y=looic_diff)) +
  geom_bar(stat = "identity", color = 'black') +
  coord_flip() + 
  theme_classic() + 
  xlab("") + 
  ylab(expression(paste(Delta,"LOOIC"))) +
  scale_x_discrete(labels=c(
    "Baseline"="Baseline",
    "Separate pi"=expression(paste("Separate  ", pi)),
    "Separate ep"=expression(paste("Separate  ", epsilon)),
    "Separate xi" = expression(paste("Separate  ", xi)),
    "Separate xi & ep" = expression(paste("Separate  ",epsilon," & ",xi)),
    "Separate pi & xi" = expression(paste("Separate  ",pi," & ",xi)),
    "Separate pi & ep" = expression(paste("Separate  ",epsilon," & ",pi)),
    "Separate xi & ep & pi" = expression(paste("Separate  ",epsilon," & ",pi," & ", xi))
    ))+
  geom_hline(yintercept = 0, color = "black") +
  theme(axis.text.y = element_text(size = 18, color = 'black'),
        axis.title.x = element_text(size=22, color = 'black'))

########################################################################
## Fig 3B. Posterior distributions of group-level parameters

## -- extract samples
best_model = "gngwm_xi_ep_pi-1"
load(sprintf('%soutput_%s.RData', PATH_DATA, best_model))
posterior <- as.matrix(output)
posterior <- as.data.frame(posterior)

## -- plot!

# Pavlovian bias
hdi_mu_pi = HDIofMCMC(posterior$mu_pi, credMass=0.95)
hdi_mu_pi_wm = HDIofMCMC(posterior$mu_pi_wm, credMass=0.95)
median(posterior$mu_pi)

posterior %>%
  dplyr::select(mu_pi, mu_pi_wm) %>%
  mutate(index = row_number()) %>%
  gather(variable, value, c(mu_pi, mu_pi_wm)) %>%
  ggplot(aes(x = value, y = variable)) +
  geom_density_ridges(aes(fill = variable), alpha = 0.5, scale=0.5)  +
  geom_segment(
    aes(x=hdi_mu_pi[1], xend=hdi_mu_pi[2], y="mu_pi", yend="mu_pi"),
    size = 0.75, alpha=0.4)+
  geom_point(
    aes(x=median(posterior$mu_pi), y="mu_pi"),
    size=1.5, shape=19)+
  geom_segment(
    aes(x=hdi_mu_pi_wm[1], xend=hdi_mu_pi_wm[2], y="mu_pi_wm", yend="mu_pi_wm"),
    size = 0.75, alpha=0.2)+
  geom_point(
    aes(x=median(posterior$mu_pi_wm), y="mu_pi_wm"),
    size=1.5, shape=19)+
  scale_fill_manual(values = wes_palette("Royal1", n=2))+
  ggtitle("Pavlovian bias")+
  scale_y_discrete(expand = expansion(add = c(0.1, 0.6)),
                   labels=c("mu_pi_wm"=expression(pi[wm]),
                            "mu_pi" = expression(pi)
                   ))+
  xlab("")+ylab("")+
  theme_bw()+
  theme(
    legend.position="none",
    title=element_text(size=12),
    axis.text.y=element_text(color="black", size = 15),
    axis.text.x = element_text(color="black", size =12))

# Learning rate
hdi_mu = HDIofMCMC(posterior$mu_ep, credMass=0.95)
hdi_mu_wm = HDIofMCMC(posterior$mu_ep_wm, credMass=0.95)

posterior %>%
  dplyr::select(mu_ep, mu_ep_wm) %>%
  mutate(index = row_number()) %>%
  gather(variable, value, c(mu_ep, mu_ep_wm)) %>%
  ggplot(aes(x = value, y = variable)) +
  geom_density_ridges(aes(fill = variable), alpha = 0.5, scale=0.5)  +
  geom_segment(
    aes(x=hdi_mu[1], xend=hdi_mu[2], y="mu_ep", yend="mu_ep"),
    size = 0.75, alpha=0.4)+
  geom_point(
    aes(x=median(posterior$mu_ep), y="mu_ep"),
    size=1.5, shape=19)+
  geom_segment(
    aes(x=hdi_mu_wm[1], xend=hdi_mu_wm[2], y="mu_ep_wm", yend="mu_ep_wm"),
    size = 0.75, alpha=0.2)+
  geom_point(
    aes(x=median(posterior$mu_ep_wm), y="mu_ep_wm"),
    size=1.5, shape=19)+
  scale_fill_manual(values = wes_palette("Royal1", n=2))+
  ggtitle("Learning rate")+
  scale_y_discrete(expand = expansion(add = c(0.1, 0.6)),
                   labels=c("mu_ep_wm"=expression(epsilon[wm]),
                            "mu_ep" = expression(epsilon)))+
  xlab("")+ylab("")+
  theme_bw()+
  theme(
    legend.position="none",
    title=element_text(size=12),
    axis.text.y=element_text(color="black", size = 15),
    axis.text.x = element_text(color="black", size =12))

# Irreducible noise
hdi_mu = HDIofMCMC(posterior$mu_xi, credMass=0.95)
hdi_mu_wm = HDIofMCMC(posterior$mu_xi_wm, credMass=0.95)
posterior %>%
  dplyr::select(mu_xi, mu_xi_wm) %>%
  mutate(index = row_number()) %>%
  gather(variable, value, c(mu_xi, mu_xi_wm)) %>%
  ggplot(aes(x = value, y = variable)) +
  geom_density_ridges(aes(fill = variable), alpha = 0.5, scale=0.7)  +
  geom_segment(
    aes(x=hdi_mu[1], xend=hdi_mu[2], y="mu_xi", yend="mu_xi"),
    size = 0.75, alpha=0.4)+
  geom_point(
    aes(x=median(posterior$mu_xi), y="mu_xi"),
    size=1.5, shape=19)+
  geom_segment(
    aes(x=hdi_mu_wm[1], xend=hdi_mu_wm[2], y="mu_xi_wm", yend="mu_xi_wm"),
    size = 0.75, alpha=0.2)+
  geom_point(
    aes(x=median(posterior$mu_xi_wm), y="mu_xi_wm"),
    size=1.5, shape=19)+
  scale_fill_manual(values = wes_palette("Royal1", n=2))+
  ggtitle("Irreducible noise")+
  scale_y_discrete(expand = expansion(add = c(0.1, 0.6)),
                   labels=c("mu_xi_wm"=expression(xi[wm]),
                            "mu_xi" = expression(xi)
                   ))+
  xlab("")+ylab("")+
  theme_bw()+
  theme(
    legend.position="none",
    title=element_text(size=12),
    axis.text.y=element_text(color="black", size = 15),
    axis.text.x = element_text(color="black", size =12))

# Go bias
hdi_mu = HDIofMCMC(posterior$mu_b, credMass=0.95)
posterior %>%
  dplyr::select(mu_b) %>%
  mutate(index = row_number()) %>%
  gather(variable, value, mu_b) %>%
  ggplot(aes(x=value, y=variable)) +
  geom_density_ridges(aes(fill=variable), alpha = 0.5, scale=0.2)  +
  geom_segment(aes(x=hdi_mu[1], xend=hdi_mu[2], y="mu_b", yend="mu_b"),
               size = 0.75, alpha=0.4)+
  geom_point(aes(x=median(posterior$mu_b), y="mu_b"),
             size=1.5, shape=19)+
  scale_fill_manual(values = wes_palette("Zissou1", n=1))+
  ggtitle(expression(paste("Go bias (",b,")")))+
  scale_y_discrete(expand=expansion(add = c(0.1, 0.6)))+
  xlab("")+ylab("")+
  theme_bw()+
  theme(
    legend.position="none",
    title=element_text(size=13),
    axis.text.y=element_blank(),
    axis.text.x = element_text(color="black", size =12))

# Reward sensitivity
hdi_mu = HDIofMCMC(posterior$mu_rhoRew, credMass=0.95)
posterior %>%
  dplyr::select(mu_rhoRew) %>%
  mutate(index = row_number()) %>%
  gather(variable, value, mu_rhoRew) %>%
  ggplot(aes(x=value, y=variable)) +
  geom_density_ridges(aes(fill=variable), alpha = 0.5, scale=1)  +
  geom_segment(aes(x=hdi_mu[1], xend=hdi_mu[2], y="mu_rhoRew", yend="mu_rhoRew"),
               size = 0.75, alpha=0.4)+
  geom_point(aes(x=median(posterior$mu_rhoRew), y="mu_rhoRew"),
             size=1.5, shape=19)+
  scale_fill_manual(values = wes_palette("Zissou1", n=1))+
  ggtitle(expression(paste("Reward sensitivity (", rho[rew], ")")))+
  scale_y_discrete(
    expand=expansion(add = c(0.1, 0.4)))+
  xlab("")+ylab("")+
  theme_bw()+
  theme(
    legend.position="none",
    title=element_text(size=13),
    axis.text.y=element_blank(),
    axis.text.x = element_text(color="black", size =12))

# Punishment sensitivity
hdi_mu = HDIofMCMC(posterior$mu_rhoPun, credMass=0.95)
posterior %>%
  dplyr::select(mu_rhoPun) %>%
  mutate(index = row_number()) %>%
  gather(variable, value, mu_rhoPun) %>%
  ggplot(aes(x=value, y=variable)) +
  geom_density_ridges(aes(fill=variable), alpha = 0.5, scale=1)  +
  geom_segment(aes(x=hdi_mu[1], xend=hdi_mu[2], y="mu_rhoPun", yend="mu_rhoPun"),
               size = 0.75, alpha=0.4)+
  geom_point(aes(x=median(posterior$mu_rhoPun), y="mu_rhoPun"),
             size=1.5, shape=19)+
  scale_fill_manual(values = wes_palette("Zissou1", n=1))+
  ggtitle(expression(paste("Punishment sensitivity (", rho[pun], ")")))+
  scale_y_discrete(
    expand=expansion(add = c(0.1, 0.5)))+
  xlab("")+ylab("")+
  theme_bw()+
  theme(
    legend.position="none",
    title=element_text(size=11.5),
    axis.text.y=element_blank(),
    axis.text.x = element_text(color="black", size =12))