#### Figure 4

########################################################################
## Settings ############################################################
########################################################################

## -- load packages
library(tidyverse)
library(ggplot2)
library(ggpubr)
library(gtools)
library(wesanderson) # color palette
library(lsr)


## -- load data
ROOT = '/home/heesun/project/WMDM_public'
PATH_DATA = sprintf('%sdata/', ROOT)
data_behav = read.table(sprintf('%sdata_behav.txt', PATH_DATA), 
                  sep = '\t', header = TRUE)
data_model = read.csv(sprintf('%sdata_modelregW.csv', PATH_DATA),
                      sep = ',', header = TRUE)

## -- merge the behav and model data
data_merged = merge(data_behav, data_model, by = c('subject', 'trial')) %>%
  arrange(subject, trial) %>%
  mutate(diff_W = Wgo - Wnogo,
         absdiff_W = abs(diff_W))

## -- get subjects
subjects = unique(data_merged$subject)


########################################################################
## Analysis ############################################################
########################################################################

########################################################################
## Fig 4A. Go ratio for different quantiles of decision values

## -- Calculate decision value (Wgo-Wnogo) quantile for each subject
data_diff_W = data.frame()
for (i in 1:length(subjects)) {
  # Get one subject data
  data_subj = data_merged %>% 
    filter(subject == subjects[i])
  
  data_subj_0 = data_subj %>% filter(task == "GNG")
  data_subj_1 = data_subj %>% filter(task == "WMGNG")
  
  data_subj_0$diff_W_ = quantcut(data_subj_0$diff_W, q = seq(0, 1, by=0.1))
  data_subj_0$diff_W_ = factor(data_subj_0$diff_W_,
                               levels(data_subj_0$diff_W_),
                               c('1', '2', '3', '4', '5', '6', '7', '8', '9', '10'))
  
  data_subj_1$diff_W_ = quantcut(data_subj_1$diff_W, q = seq(0, 1, by=0.1))
  data_subj_1$diff_W_ = factor(data_subj_1$diff_W_,
                               levels(data_subj_1$diff_W_),
                               c('1', '2', '3', '4', '5', '6', '7', '8', '9', '10'))
  # Concatenate
  data_diff_W = rbind(data_diff_W, data_subj_0)
  data_diff_W = rbind(data_diff_W, data_subj_1)
}

## -- t-test for plotting
tmp_for_t_test <- data_diff_W %>%
  group_by(task, subject, diff_W_) %>%
  summarise(go_ratio = mean(key_pressed)) %>%
  pivot_wider(id_cols = subject, names_from = c(task, diff_W_), values_from = go_ratio) %>%
  ungroup()

for (i in c(1:10)){
  x_var = sprintf("GNG_%d", i)
  y_var = sprintf("WMGNG_%d", i)
  
  test <- t.test(tmp_for_t_test[[x_var]], tmp_for_t_test[[y_var]], paired = TRUE)
  d = cohensD(x = tmp_for_t_test[[x_var]], y = tmp_for_t_test[[y_var]], method = "paired")
  if (test$p.value < 0.0001){
    p_sig = "****"
  } else if (test$p.value < 0.001){p_sig = "***"}
  else if (test$p.value < 0.01){p_sig = "**"}
  else if (test$p.value < 0.05){p_sig = "*"}
  else {p_sig = "ns"}
  print(sprintf(
    "%d quantile: t(48)=%.2f, p=%.3f, d=%.2f, sig=%s", 
    i, round(test$statistic,2), round(test$p.value,3), round(d,2), p_sig))
}

## -- plot!
data_diff_W %>%
  group_by(task, subject, diff_W_) %>%
  summarise(go_ratio = mean(key_pressed)) %>%
  ggplot(aes(x = diff_W_, y = go_ratio, group = task, color = task)) +
  stat_summary(geom = 'errorbar', fun.data = mean_se, width = 0.3) +
  stat_summary(geom = 'line', fun = mean) +
  stat_summary(geom = 'point', fun = mean, size = 1) +
  scale_color_manual(values = wes_palette("Royal1", n=2))+
  annotate("text", x = 1, y = 0.17, label = "***", size = 6)+
  annotate("text", x = 2, y = 0.21, label = "**", size = 6)+
  annotate("text", x = 3, y = 0.35, label = "*", size = 6)+
  annotate("text", x = 8, y = 0.95, label = "**", size = 6)+
  annotate("text", x = 10, y = 1, label = "**", size = 6)+
  xlab('Decision value quantile (Wgo - Wnogo)') +
  ylab('Go ratio') +
  theme_bw() + 
  labs(colour="Task")+
  scale_x_discrete(labels=c("1"="1st", "2"="2nd", "3"= "3rd",
                            "4"="4th", "5"="5th", "6"="6th", "7"="7th",
                            "8"="8th", "9"="9th", "10"="10th"))+
  theme(
    axis.text.x = element_text(size = 9, color = 'black'),
    axis.text.y = element_text(size=11, color = 'black'),
    axis.title.y = element_text(size = 13, color = 'black'),
    title = element_text(size = 13))


########################################################################
## Fig 4B. Mean accuracies for different quantiles of choice difficulty

## -- Calculate choice difficulty (|Wgo-Wnogo|) quantile for each subject
data_absdiff_W = data.frame()
for (i in 1:length(subjects)) {
  # Get one subject data
  data_subj = data_merged %>% 
    filter(subject == subjects[i])
  
  
  data_subj_0 = data_subj %>% filter(task == "GNG")
  data_subj_1 = data_subj %>% filter(task == "WMGNG")
  data_subj_0$absdiff_W_ = quantcut(data_subj_0$absdiff_W, q = seq(0, 1, by=0.1))
  data_subj_0$absdiff_W_ = factor(data_subj_0$absdiff_W_,
                              levels(data_subj_0$absdiff_W_),
                              c('1', '2', '3', '4', '5', '6', '7', '8', '9', '10'))
  data_subj_1$absdiff_W_ = quantcut(data_subj_1$absdiff_W, q = seq(0, 1, by=0.1))
  data_subj_1$absdiff_W_ = factor(data_subj_1$absdiff_W_,
                              levels(data_subj_1$absdiff_W_),
                              c('1', '2', '3', '4', '5', '6', '7', '8', '9', '10'))  
  # Concatenate
  data_absdiff_W = rbind(data_absdiff_W, data_subj_0)
  data_absdiff_W = rbind(data_absdiff_W, data_subj_1)
}

## -- t-test for plotting
tmp_for_t_test <- 
  data_absdiff_W %>%
  group_by(task, subject, absdiff_W_) %>%
  summarise(accuracy = mean(is_correct)) %>%
  pivot_wider(id_cols = subject, names_from = c(task, absdiff_W_), values_from = accuracy) %>%
  ungroup()

for (i in c(1:10)){
  x_var = sprintf("GNG_%d", i)
  y_var = sprintf("WMGNG_%d", i)
  
  test <- t.test(tmp_for_t_test[[x_var]], tmp_for_t_test[[y_var]], paired = TRUE)
  d = cohensD(x = tmp_for_t_test[[x_var]], y = tmp_for_t_test[[y_var]], method = "paired")
  if (test$p.value < 0.0001){
    p_sig = "****"
  } else if (test$p.value < 0.001){p_sig = "***"}
  else if (test$p.value < 0.01){p_sig = "**"}
  else if (test$p.value < 0.05){p_sig = "*"}
  else {p_sig = "ns"}
  print(sprintf(
    "%d quantile: t(48)=%.2f, p=%.3f, d=%.2f, sig=%s", 
    i, round(test$statistic,2), round(test$p.value,3), round(d,2), p_sig))
}

## -- plot!
data_absdiff_W %>%
  group_by(task, subject, absdiff_W_) %>%
  summarise(accuracy = mean(is_correct)) %>%
  ggplot(aes(x = absdiff_W_, y = accuracy, group = task, color = task)) +
  stat_summary(geom = 'errorbar', fun.data = mean_se, width = 0.3) +
  stat_summary(geom = 'line', fun = mean) +
  stat_summary(geom = 'point', fun = mean, size = 1) +
  annotate("text", x = 5, y = 0.9, label = "***", size = 6)+
  annotate("text", x = 6, y = 0.91, label = "**", size = 6)+
  annotate("text", x = 7, y = 0.9, label = "*", size = 6)+
  annotate("text", x = 8, y = 0.94, label = "**", size = 6)+
  annotate("text", x = 9, y = 0.97, label = "**", size = 6)+
  annotate("text", x = 10, y = 0.99, label = "*", size = 6)+
  scale_color_manual(values = wes_palette("Royal1", n=2))+
  xlab('Choice difficulty (|Wgo-Wnogo|)') +
  ylab('Accuracy') +
  labs(colour = "Task")+
  theme_bw()  + 
  scale_x_discrete(labels=c("1"="1st", "2"="2nd", "3"= "3rd",
                            "4"="4th", "5"="5th", "6"="6th", "7"="7th",
                            "8"="8th", "9"="9th", "10"="10th"))+
  theme(
    axis.text.x = element_text(size = 9, color = 'black'),
    axis.text.y = element_text(size=11, color = 'black'),
    axis.title.y = element_text(size = 13, color = 'black'),
    title = element_text(size = 13))
