# create df of id and nifti run
files <- dir('/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_fmriprep/fmriprep', pattern='sub-[0-9]*$')
idlist <- stringr::str_split(files, pattern="-") %>% unlist %>% as.numeric %>% na.omit %>% as.vector
sub_df <- data.frame(id=rep(idlist, each=2), run=c(1,2), nifti=1)
for (i in 1:nrow(sub_df)) {
    id <- sub_df$id[i]
    func_data <- list.files(paste0('/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_fmriprep/fmriprep/sub-', id, '/func'))
    if (length(func_data)==0) {
        message(paste('Subject', id, 'has no func folder.'))
        sub_df[which(sub_df$id==id),3] <- NA
        next
    }
    clock_runs <- func_data[grep("nfas", func_data)]
    clock_1 <- clock_runs[which(grepl('run-1', clock_runs))]
    clock_2 <- clock_runs[which(grepl('run-2', clock_runs))]
    if (length(clock_1)==0) {
        message(paste('Subject', id, 'is missing run 1.'))
        sub_df[which(sub_df$run==1&sub_df$id==id),3] <- NA
    } else {
        sub_df[which(sub_df$run==1&sub_df$id==id),3] <- clock_1
    }
    if (length(clock_2)==0) {
        message(paste('Subject', id, 'is missing run 2.'))
        sub_df[which(sub_df$run==2&sub_df$id==id),3] <- NA
    } else {
        sub_df[which(sub_df$run==2&sub_df$id==id),3] <- clock_2
    }
}
write.csv(sub_df, "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/run_level_niftis.csv")

#run level decon
d_files <- list.files("/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_444_3.125mm/deconvolved", full.names=T)