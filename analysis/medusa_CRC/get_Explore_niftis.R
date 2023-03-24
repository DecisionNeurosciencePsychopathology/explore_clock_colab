# 2023-03-23 AndyP
# create run_level_niftis for Explore Clock MEDuSA
library(tidyverse)
library(stringr)
# base folder
Fs <- data.frame(folders=list.files('/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_fmriprep/fmriprep',full.names=TRUE))

# extract subject IDs
Fs <- Fs %>% filter(grepl("[0-9][0-9][0-9][0-9][0-9]",folders) & dir.exists(folders)) 
nF <- nrow(Fs)

df <- NULL
for (iF in 1:nF){
  fs <- Fs[iF,]
  id <- str_split(fs,'/')
  id <- id[[1]][length(id[[1]])] # [0-9][0-9][0-9][0-9][0-9]
  id <- str_split(id,'-')
  id <- id[[1]][2] # [0-9][0-9][0-9][0-9][0-9]
  run_dir <- data.frame(folders=list.files(paste0(fs,'/func'),full.names=TRUE))
  runs <- run_dir %>% filter(grepl("nfas",folders) & grepl('clock',folders))
  nR <- nrow(runs)
  if (nR!=2){
    message(paste0('run missing subject ', fs))
  }
  
  
  for (iR in 1:nR){
    fr <- runs[iR,]
    run <- str_split(fr,'/')
    run <- run[[1]][length(run[[1]])] # clock[0-9]
    run_num <- str_split(run,'_')
    run_num <- run_num[[1]][3]
    run_num <- as.integer(substr(run_num,nchar(run_num),nchar(run_num))) # [0-9]
    niftis <- data.frame(nifti=fr,run=run_num,id=id)
    
    if (nrow(niftis)==0){
      message(paste0('error in ', fr, ' no files match'))
    } else if (nrow(niftis==1)){
      df <- rbind(df,niftis)
    } else if(nrow(niftis>1)){
      message(paste0('error in ', fr, ' too many niftis match'))
    }
    
  }
}

setwd('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/')
write.csv(df,file='run_level_niftis_explore.csv')
