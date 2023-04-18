# 2023-03-23 AndyP
# create run_level_niftis for MMClock MEDuSA

libs <- .libPaths()

library(tidyverse,lib.loc=libs[3])
library(stringr)
# base folder
Fs <- data.frame(folders=list.files('/bgfs/adombrovski/MMClock/MR_Proc',full.names=TRUE))

# extract subject IDs
Fs <- Fs %>% filter(grepl("[0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]",folders)) 
nF <- nrow(Fs)

df <- NULL
for (iF in 1:nF){
  fs <- Fs[iF,]
  id <- str_split(fs,'/')
  id <- id[[1]][length(id[[1]])] # [0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
  id <- str_split(id,'_')
  id <- id[[1]][1] # [0-9][0-9][0-9][0-9][0-9]
  run_dir <- data.frame(folders=list.files(paste0(fs,'/mni_5mm_aroma'),full.names=TRUE))
  runs <- run_dir %>% filter(grepl("clock[0-9]",folders))
  nR <- nrow(runs)
  if (nR!=8){
    message(paste0('run missing subject ', fs))
  }
  
  
  for (iR in 1:nR){
    fr <- runs[iR,]
    run <- str_split(fr,'/')
    run <- run[[1]][length(run[[1]])] # clock[0-9]
    run_num <- as.integer(substr(run,nchar(run),nchar(run))) # [0-9]
    niftis <- data.frame(nifti=list.files(fr,full.names=TRUE),run=run_num,id=id)
    niftis <- niftis %>% filter(grepl("nfaswuktm",nifti) & grepl("drop",nifti) & grepl("trunc",nifti) & !grepl("mean",nifti))
    if (nrow(niftis)==0){
      niftis <- data.frame(nifti=list.files(fr,full.names=TRUE),run=run_num,id=id)
      niftis <- niftis %>% filter(grepl("nfaswuktm",nifti) & grepl("drop",nifti) & !grepl("mean",nifti)) # drop 'trunc' requirement of string
    }
    if (nrow(niftis)==0){
      niftis <- data.frame(nifti=list.files(fr,full.names=TRUE),run=run_num,id=id)
      niftis <- niftis %>% filter(grepl("nfaswuktm",nifti) & grepl("clock",nifti) & !grepl("mean",nifti)) # drop 'drop' requirement of string
    }
    if (nrow(niftis)==0){
      message(paste0('error in ', fr, ' no files match'))
    } else if (nrow(niftis==1)){
      df <- rbind(df,niftis)
    } else if(nrow(niftis>1)){
      message(paste0('error in ', fr, ' too many niftis match'))
    }
    
  }
}

write.csv(df,file='run_level_niftis_mmclock.csv')
