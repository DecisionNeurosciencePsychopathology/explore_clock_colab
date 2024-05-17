# Clock Explore Examine Model Fits
# Angela Ianni
# April 26, 2024

rm(list=ls())

library(dplyr)
library(tidyverse)
library(rstatix)
library(ggpubr)
library(ggplot2)
library(gridExtra)

#modelfit_df <- read_csv("/Users/angela/OneDrive\ -\ UPMC/Documents/Research/Explore_Project/temporal_instrumental_agent/clock_task/vba_fmri/RESULTS/vba_out/explore/mfx/decay_factorize_selective_psequate_fixedparams_fmri/explore_decay_factorize_selective_psequate_fixedparams_fmri_mfx_sceptic_global_statistics.csv")
#sub_df <- readRDS("~/Documents/Research/Explore/explore_n146.rds") %>% mutate(id = registration_redcapid)

modelfit_df <- read_csv('/Users/andypapale/clock_analysis/fmri/data/mmclock_fmri_decay_factorize_selective_psequate_mfx_sceptic_global_statistics.csv')
#modelfit_df <- read_csv('/Users/andypapale/clock_analysis/meg/data/mmclock_meg_decay_factorize_selective_psequate_mfx_sceptic_global_statistics.csv')
sub_df <- read.table(file=file.path('/Users/andypapale/clock_analysis/fmri/data/mmy3_demographics.tsv'),sep='\t',header=TRUE)
sub_df <- sub_df %>% rename(id=lunaid)
sub_df <- sub_df %>% select(!adult & !scandate)
combined_df <- left_join(sub_df,modelfit_df,by="id")

#Model fits for whole sample
summary(modelfit_df$R2)
#Summary of model fits by group
tapply(combined_df$R2, combined_df$Group, summary)
#Anova to see if model fits differ by group
aov <- combined_df %>% anova_test(R2 ~ Group)
aov #F stat is 2.046, p=0.11

#Create histograms
#All subjects
p1<-ggplot(data=combined_df, aes(x=R2,color=Group)) + geom_histogram(color="black",fill="white",binwidth=0.01) +
  xlim(0,0.3) + ggtitle("All subjects")
#p1<-ggplot(data=combined_df, aes(x=R2,color=Group)) + geom_histogram(fill="white",binwidth=0.01) +
#  xlim(0,0.3) + ggtitle("All subjects")
#Control only
controls_df <- combined_df %>% filter(Group=="Controls")
p2<-ggplot(data=controls_df, aes(x=R2,color=Group)) + geom_histogram(color="black",fill="white",binwidth=0.01) +
  xlim(0,0.3) + ggtitle("Controls Only")
grid.arrange(p1,p2,nrow=2)
#depressed only
dep_df <- combined_df %>% filter(Group=="Depressed")
p3<-ggplot(data=dep_df, aes(x=R2,color=Group)) + geom_histogram(color="black",fill="white",binwidth=0.01) +
  xlim(0,0.3) + ggtitle("Depressed Only")
#ideators only
ide_df <- combined_df %>% filter(Group=="Ideators")
p4<-ggplot(data=ide_df, aes(x=R2,color=Group)) + geom_histogram(color="black",fill="white",binwidth=0.01) +
  xlim(0,0.3) + ggtitle("Ideators Only")
#attempters only
att_df <- combined_df %>% filter(Group=="Attempters")
p5<-ggplot(data=att_df, aes(x=R2,color=Group)) + geom_histogram(color="black",fill="white",binwidth=0.01) +
  xlim(0,0.3) + ggtitle("Attempters Only")
grid.arrange(p1,p2,p3,p4,p5,nrow=5)