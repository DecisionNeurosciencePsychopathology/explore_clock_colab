list.files()
nF = list.files(); for (iF in 1:length(nF)){ print(nF[iF])}
fb <- data.frame(); 
nF = list.files(pattern='^sub*'); 
for (iF in 1:length(nF)){ 
  print(nF[iF]); 
  fb0 <- data.table::fread(nF[iF]); 
  fb0 <- fb0 %>% mutate(file = rep(nF[iF],nrow(fb0))) 
  fb <- rbind(fb,fb0)
}
fb <- fb %>% mutate(id = str_extract(file,"\\d\\d\\d\\d\\d\\d"), run = str_extract(file,"run\\d"))
fb <- fb %>% mutate(run = str_extract(run,"\\d"))
fb$run <- as.numeric(fb$run)
fb$id <- as.numeric(fb$id)
source('~/explore_clock/get_trial_data_explore.R')
df <- get_trial_data_explore(repo_directory='~/explore_clock/data/',dataset='explore_clock',censor_early_trials=FALSE)
df <- df %>% select(id,run_number,trial,iti_ideal,iti_prev,iti_onset,clock_onset,feedback_onset,feedback_onset_prev,rt_csv,rt_lag)
df <- df %>% rename(run = run_number)
fb1 <- merge(fb,df,by=c('id','run','trial')) %>% arrange('id','run','trial')
write.csv(fb1,'clock.csv')
