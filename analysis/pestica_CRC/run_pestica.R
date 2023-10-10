require(tidyverse)
afnidir <- '/ihome/crc/install/afni/18.0.22/bin'
Sys.setenv(AFNIDIR=afnidir)

pestica_dir <- "/bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA"
setwd(pestica_dir)
if (file.exists("run_level_niftis.csv")) {
    sub_df <- read.csv("run_level_niftis.csv")
} else {
    files <- dir('/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_BIDS', pattern='sub-[0-9]*$')
    idlist <- stringr::str_split(files, pattern="-") %>% unlist %>% as.numeric %>% na.omit %>% as.vector
    sub_df <- data.frame(id=rep(idlist, each=2), run=c(1,2), nifti=1)
    for (i in 1:nrow(sub_df)) {
        id <- sub_df$id[i]
        func_data <- list.files(paste0('/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_BIDS/sub-', id, '/func'))
        if (length(func_data)==0) {
            message(paste('Subject', id, 'has no func folder.'))
            sub_df[which(sub_df$id==id),3] <- NA
            next
        }
        clock_runs <- func_data[grep("bold.nii.gz", func_data)]
        clock_1 <- clock_runs[which(grepl('run-01', clock_runs))]
        clock_2 <- clock_runs[which(grepl('run-02', clock_runs))]
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
    sub_df <- sub_df %>%
        filter(!is.na(nifti))
}

for (i in 1:nrow(sub_df)) {
    id <- sub_df$id[i]
    run <- sub_df$run[i]
    nifti <- sub_df$nifti[i]
    full_nifti <- file.path('/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_BIDS', paste0("sub-",id), "func", nifti)
    sub_dir <- file.path('/bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA/subjects', id)
    # create subject level directory
    if (file.exists(sub_dir)) {
        setwd(sub_dir)
    } else {
        dir.create(sub_dir)
        setwd(sub_dir)
    }
    #create run level folder inside of subject level folder
    if (file.exists(file.path(sub_dir, paste0("run-", run)))) {
        setwd(paste0("run-", run))
    } else {
        dir.create(paste0("run-", run))
        setwd(paste0("run-", run))
    }
    # inside the subject/run level directory we need COPIES of the NIFTI for both runs of clock
    # as well as a shell file that specifies the command line arguments to run_pestica *** for each individual run ***
    # copy NIFTI file to folder
    if (!file.exists(file.path(getwd(), nifti))) {
        print(paste("Copying file", nifti, "to", getwd()))
        file.copy(full_nifti, getwd(), overwrite=FALSE)
    } else {
        print(paste('NIFTI already copied.'))
    }
    shell_file <- paste0("pestica_", id, "_run", run, ".sh")
    c("#!/bin/bash", 
      paste0("#SBATCH --job-name=pestica_", id, "_run", run),
      paste0("#SBATCH --output=pestica_", id, "_run", run),
      "#SBATCH --nodes=1",
      "#SBATCH --ntasks-per-node=1",
      "#SBATCH --time=24:00:00",
      "#SBATCH --partition=htc",
      "#SBATCH --cpus-per-task=1\n",
      "module load matlab/R2022a",
      paste0("cd /bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA/subjects/", id, "/run-", run),
      "source /bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA/pestica_afni_v5.5/setup_pestica.sh",
      paste0("run_pestica.sh -d sub-", id, "_task-clockRev_run-0", run, "_bold -m 5 -b")
    ) %>% writeLines(shell_file)
    system(paste("sbatch", shell_file))
}



#sbatch -p htc -N 1 --mem 20g -n 1 -t 23:00:00 -c 1 --wrap 'source ~/.bashrc; source /bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA/pestica_afni_v5.5/setup_pestica.sh; /bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA/pestica_afni_v5.5/run_pestica.sh -d /bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_BIDS/sub-202200_task-clockRev_run-01_bold.nii.gz -m 5 -b'

#sbatch -p htc -N 1 --mem 20g -n 1 -t 23:00:00 -c 1 --wrap 'source /bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA/pestica_afni_v5.5/setup_pestica.sh; cd /bgfs/adombrovski/DNPL_DataMesh/Data/PESTICA; run_pestica.sh -d sub-202200_task-clockRev_run-01_bold -m 5 -b'

