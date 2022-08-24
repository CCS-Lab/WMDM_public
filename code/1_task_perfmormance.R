#### Figure 2

########################################################################
## Settings ############################################################
########################################################################

## -- load packages
library(tidyverse)
library(ggplot2)
library(ggpubr)
library(wesanderson) # color palette


## -- load data
ROOT = '/home/heesun/project/project_WMDM/open_access_prep/'
PATH_DATA = sprintf('%sdata/', ROOT)
data = read.table(sprintf('%sdata_behav.txt', PATH_DATA), 
                  sep = '\t', header = TRUE)
accuracy = data %>% 
  group_by(subject, task) %>%
  summarise(accuracy = mean(is_correct))

########################################################################
## Analysis ############################################################
########################################################################


########################################################################
## Fig 2A. Task accuracy in the GNG and WMGNG tasks

## -- preprocess
accuracy = data %>% 
  group_by(subject, task) %>%
  summarise(accuracy = mean(is_correct))

## -- plot 
accuracy %>% 
  ggplot(aes(x=task, y=accuracy))+
  geom_violin(aes(fill=task), size=0.7, color='black')+
  geom_dotplot(binaxis='y', stackdir='center', 
               dotsize=0.3, alpha=0.15, aes(fill=task))+
  geom_line(aes(group=subject), alpha = 0.05)+
  stat_summary(fun=mean, geom="point", size=1, color="black")+
  stat_summary(fun.data=mean_se, geom="linerange", 
               size=0.5, color="black")+
  stat_compare_means(comparisons=list(c("GNG", "WMGNG")), paired=T, 
                     hide.ns=F, method="t.test", label="p.signif", size=8)+
  ylab("Accuracy")+
  xlab("")+
  scale_fill_manual(values = wes_palette("Royal1", n=2))+
  ylim(c(0.39, 1.05))+
  theme_bw()+ 
  theme(legend.position = "none",
                    axis.text.x = element_text(size = 11, color = 'black'),
                    axis.text.y = element_text(size=9, color = 'black'),
                    axis.title.y = element_text(size = 13, color = 'black'),
                    title = element_text(size = 15))

########################################################################
## Fig 2B. Accuracy in each of the 4 trial types between the two tasks

## -- preprocess
acc_cue = data %>% 
  group_by(subject, task, cue) %>% 
  summarise(accuracy = mean(is_correct)) %>%
  mutate(cue = factor(cue, levels = c(
    'go to win', 'no-go to win', 'go to avoid losing', 'no-go to avoid losing')),
         Con = ifelse(
           cue == 'go to win' | cue == 'no-go to avoid losing', 1, 0)) 

comp_a <- list(c("go to win", "no-go to win"))
comp_b <- list(c("go to avoid losing", "no-go to avoid losing"))

## -- without WM load
acc_cue %>% filter(task=="GNG") %>%
  ggplot(aes(y = accuracy, x = cue)) + 
  geom_bar(aes(y = accuracy, x = cue, fill = factor(Con)), 
           stat = "summary", fun = "mean", color = "black", size = 1) +
  stat_summary(fun.data=mean_se, geom="errorbar", width=0.2, size=0.8)+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=0.3, alpha = 0.15)+
  geom_line(aes(group = subject), alpha = 0.05) +
  stat_compare_means(comparisons = comp_a, paired = T, hide.ns = F, 
                     method = "t.test", label = "p.signif", size = 8) +
  stat_compare_means(comparisons = comp_b, paired = T, hide.ns = F, 
                     method = "t.test", label = "p.signif", size = 8) +
  ylab("Accuracy")+xlab("\nGNG task (control condition)") +
  scale_x_discrete(breaks=c("go to win","no-go to win","go to avoid losing", "no-go to avoid losing"),
                   labels=c("go\nto win","no-go\nto win","go\nto avoid", "no-go\nto avoid"))+
  coord_cartesian(ylim=c(0, 1.14))+
  theme_bw() + 
  theme(legend.position = "none",
        axis.text.x = element_text(size = 17, color = "black"),
        axis.text.y = element_text(size = 17, color = "black"),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size=20))    


## -- with WM load
acc_cue %>% filter(task=="WMGNG") %>%
  ggplot(aes(y = accuracy, x = cue)) + 
  geom_bar(aes(y = accuracy, x = cue, fill = factor(Con)), 
           stat = "summary", fun = "mean", color = "black", size = 1) +
  stat_summary(fun.data=mean_se, geom="errorbar", width=0.2, size=0.8)+
  geom_dotplot(binaxis='y', stackdir='center', dotsize=0.3, alpha = 0.15)+
  geom_line(aes(group = subject), alpha = 0.05) +
  stat_compare_means(comparisons = comp_a, paired = T, hide.ns = F, 
                     method = "t.test", label = "p.signif", size = 8) +
  stat_compare_means(comparisons = comp_b, paired = T, hide.ns = F, 
                     method = "t.test", label = "p.signif", size = 8) +
  ylab("Accuracy")+xlab("\nWMGNG task (control condition)") +
  scale_x_discrete(breaks=c("go to win","no-go to win","go to avoid losing", "no-go to avoid losing"),
                   labels=c("go\nto win","no-go\nto win","go\nto avoid", "no-go\nto avoid"))+
  coord_cartesian(ylim=c(0, 1.14))+
  theme_bw() + 
  theme(legend.position = "none",
        axis.text.x = element_text(size = 17, color = "black"),
        axis.text.y = element_text(size = 17, color = "black"),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size=20))    


########################################################################
## Figure 2C. Learning curves in the two tasks #########################

## -- define moving average function
movingAvg = function(rawDat, fsize, nt) {
  # nt: the number of trials
  # rawDat: raw data (1-D vector)
  # fsize: filter size
  
  grand_pr_moving = array(NA, c(nt) ) # grand average after moving filter
  for (i in 1:nt)  {
    if ( i - fsize < 1 )  {
      mstart = 1
    } else mstart = i - fsize
    if ( i + fsize > nt )  {
      mend = nt
    } else mend = i + fsize
    grand_pr_moving[i] = mean( rawDat[mstart : mend] )
  }
  return(grand_pr_moving)
}

## -- plot
fsize = 5
nt = 120

data %>% 
  group_by(subject, task) %>%
  mutate(trial_per_task = row_number(),
         is_correct = movingAvg(is_correct, fsize, nt)) %>%
  ggplot(aes(x = trial_per_task, y = is_correct)) +
  stat_summary(geom = 'ribbon', fun.data = mean_se, alpha = 0.5, aes(fill = task)) +
  stat_summary(geom = 'line', fun = mean, aes(color = task), size = 0.8) +
  # stat_summary(geom = 'point', fun = mean) +
  xlab('Trial') +
  ylab('Accuracy') +
  scale_color_manual(values = wes_palette("Royal1", n=2))+
  scale_fill_manual(values = wes_palette("Royal1", n=2))+
  theme_bw() + theme(legend.position = "right",
                     axis.text.x = element_text(size = 11, color = 'black'),
                     axis.text.y = element_text(size=9, color = 'black'),
                     axis.title.y = element_text(size = 13, color = 'black'),
                     title = element_text(size = 15))

########################################################################
## Figure 2D. Pavlovian bias in the two tasks ##########################

## -- preprocess
pav = acc_cue %>%
  select(-Con) %>%
  group_by(subject, task) %>%
  spread(key = cue, value = accuracy) %>%
  summarise(
    pav_bias = `go to win` + `no-go to avoid losing` - `no-go to win` - `go to avoid losing`) %>%
  mutate(task = factor(task, levels = c("GNG", "WMGNG")))

## -- plot
pav %>% 
  ggplot(aes(x = task, y = pav_bias)) +
  geom_violin(aes(fill = task), size = 0.7, color = 'black') +
  geom_dotplot(binaxis='y', stackdir='center', 
               dotsize=0.3, alpha = 0.15, aes(fill=task)) +
  geom_line(aes(group = subject), alpha = 0.05) +
  stat_summary(fun = mean, geom="point", size = 1, color="black") +
  stat_summary(fun.data=mean_se, geom="linerange", size = 0.5, color="black") +
  stat_compare_means(comparisons = list(c("GNG", "WMGNG")), paired = T, 
                     hide.ns = F, method = "t.test", label = "p.signif") +
  ylab("Pavlovian bias (task accuracy)")+xlab("") +
  scale_fill_manual(values = wes_palette("Royal1", n=2))+
  theme_bw()+ theme(legend.position = "none",
                    axis.text.x = element_text(size = 13, color = 'black'),
                    axis.text.y = element_text(size=13, color = 'black'),
                    axis.title.y = element_text(size = 16, color = 'black'))
