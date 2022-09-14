subj <- R.utils::cmdArg("subj")
l1_nifti <- R.utils::cmdArg("l1_nifti")

#subj <- 35780

#subj <- Sys.getenv("subj")
#l1_nifti <- Sys.getenv("l1_nifti")

l1_nifti <- file.path("/bgfs/adombrovski/DNPL_DataMesh/Data/EXP/data_fmriprep/fmriprep", paste0("sub-", subj), "func", l1_nifti)

if (grepl("run-1", l1_nifti)) {
  run <- 1
} else if (grepl("run-2", l1_nifti)) {
  run <- 2
}

#run <- 1

require(tidyverse)
require(foreach)
require(oro.nifti)
require(data.table)

setwd('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa')

require("devtools")
library(fmri.pipeline)
source('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/fmri.pipeline/R/spm_funcs.R')

afnidir <- '/ihome/crc/install/afni/18.0.22/bin'
Sys.setenv(AFNIDIR=afnidir)

decon_outdir <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed'
#200
#atlas_file <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/transformed_schaefer_dan_3.125mm.nii'
#400
atlas_file <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/transformed_schaefer_444_3.125mm.nii'

#hc right
#atlas_file <- "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/transformed_hc_right.nii"
#hc left
#atlas_file <- "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/transformed_hc_left.nii"

decon_beta <- 60 
#td_path <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Task_Designs/td_antAct_samp5_smid5_tr1_snr1_nC5_nT500_subject_001.RData'

metadata <- data.frame(TR = .6,
                       decon_beta = decon_beta)

### step 1. deconvolve signal
fmri.pipeline::voxelwise_deconvolution(l1_nifti, 
                        add_metadata=metadata, 
                        out_dir = decon_outdir, 
                        TR=metadata$TR,
                        atlas_files=atlas_file, 
                        decon_settings=list(nev_lr = .01, #neural events learning rate (default in algorithm)
                                            epsilon = .005, #convergence criterion (default)
                                            beta = decon_beta, #best from Bush 2015 update
                                            kernel = spm_hrf(metadata$TR)$hrf, #canonical SPM difference of gammas
                                            Nresample = 25),  
                        mask=NULL,
                        nprocs=1, 
                        save_original_ts=FALSE,  
                        out_file_expression=paste0("sub", subj, "_run", run),
                        #force_decon = TRUE
)

#decon_dat <- read.csv(file.path(decon_outdir, "transformed_schaefer_dan_3.125mm", "deconvolved", paste0("sub", subj, "_run", run, "_deconvolved.csv.gz")))
#decon_dat <- read.csv('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_dan_3.125mm/deconvolved/sub35780_run1_deconvolved.csv.gz')
#decon_dat <- decon_dat %>% select(vnum, time, decon, atlas_value) %>% mutate(atlas_value = round(atlas_value)-1) %>% data.table() 

# this is the output of get_trial_data for ALL subjects
#event_data_tot <- get(load(td_path))
# you need to filter trial df by run/subject first before generating
# the fmri_ts object.
#event_data <- event_data_tot$ev_times %>% mutate(id = subj) %>% select(id, event, run, trial, start_vol) %>% spread(event, start_vol) %>% tibble()

### 2. event-lock and interpolate
# generate fmri_ts object
#fmri_event_data <- fmri_ts$new(ts_data=decon_dat, event_data=event_data, tr=metadata$TR,
#                               vm=list(value=c("decon"), key=c("vnum", "atlas_value")))

# event-lock and interpolate fmri_ts
#interp_dt <- tryCatch({
#  interp_dt <- get_medusa_interpolated_ts(fmri_event_data, event="feedback", time_before=-3.0, time_after=3.0,
#                                          collide_before="feedback", collide_after=NULL,
#                                          pad_before=-1.5, pad_after=1.5, output_resolution = metadata$TR,
#                                          group_by = c("atlas_value", "trial"))
  
#  interp_dt
#}, error=function(err) { print(as.character(err)); save(fmri_event_data, file="problem_case.RData"); return(NULL) })

#if(!is.null(interp_dt)){
  # saving event-locked and interpolated fmri_ts:
#  interp_outdir <- file.path(decon_outdir, "transformed_schaefer_dan_3.125mm", "interpolated")
#  if(!dir.exists(interp_outdir)) {dir.create(interp_outdir)}
#  write.csv(interp_dt, file = file.path(interp_outdir, paste0("sub", subj, "_run", run, "_interpolated.csv.gz")))
#}

