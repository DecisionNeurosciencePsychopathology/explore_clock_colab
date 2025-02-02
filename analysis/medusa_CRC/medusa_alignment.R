subj <- R.utils::cmdArg("subj")
d_file <- R.utils::cmdArg("d_file")
run <- R.utils::cmdArg("run")

# event lock and interpolate script 
setwd('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa')
require(tidyverse)
require(foreach)
require(oro.nifti)
require(data.table)
require(fmri.pipeline)
source('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/fmri.pipeline/R/spm_funcs.R')
source('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/get_trial_data.R')
afnidir <- '/ihome/crc/install/afni/18.0.22/bin'
Sys.setenv(AFNIDIR=afnidir)

# decon settings
decon_outdir <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed'
atlas_file <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/ph_da_striatum/masks/mmclock_pauli_combined_integermask_2.3mm.nii.gz'
#atlas_file <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/transformed_schaefer_dan_3.125mm.nii'
decon_beta <- 1
tr <- 1
aggregate_by <- "atlas_value"

cat("Loading trial_df for Explore Clock. \n")

trial_df <- get_trial_data(repo_directory='/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/',dataset="mmclock_fmri") %>%
  dplyr::mutate(rt_time=clock_onset + rt_csv, #should be pretty redundant with isi_onset, but still - already in seconds
    #rt_vmax=rt_vmax/10, #to put into seconds - already in seconds
    rt_vmax_cum=clock_onset + rt_vmax)
# subsetting for run data 
  subj_df <- trial_df %>% filter(id == !!subj & run == !!run)
# read decon data
cat("Reading deconvolved data from the following file: ", d_file, "\n")
d <- data.table::fread(d_file, data.table=FALSE)
d[[aggregate_by]] <- as.numeric(d[[aggregate_by]]) # convert atlas values to numbers explicitly

### 2. event-lock and interpolate
# generate fmri_ts object
tsobj <- fmri_ts$new(
      ts_data = d, event_data = subj_df, tr = tr,
      vm = list(value = c("decon"), key = c("vnum", aggregate_by))
    )

# CLOCK ALIGNED
if (!file.exists(file.path(decon_outdir, "mmclock_pauli_combined_integermask_2.3mm", "interpolated", "clock_aligned", paste0("sub", subj, "_run", run, "_interpolated.csv.gz")))) {
  cat("Interpolating fMRI time series (Clock aligned): \n")
  # clock aligned
  interp_dt_clock <- tryCatch({
    interp_dt_clock <- get_medusa_interpolated_ts(tsobj, event="clock_onset", time_before=-6, time_after=9,
                                            output_resolution = tr,
                                            group_by = c(aggregate_by, "trial"))
    #interp_dt_clock %>% mutate(id=subj, run=run) -> interp_dt_clock
  }, error=function(err) { print(as.character(err)); save(fmri_event_data, file="problem_case.RData"); return(NULL) })

  cat("Writing output... \n")
  if(!is.null(interp_dt_clock)){
    # saving event-locked and interpolated fmri_ts:
    interp_outdir_clock <- file.path(decon_outdir, "mmclock_pauli_combined_integermask_2.3mm", "interpolated", "clock_aligned")
    if(!dir.exists(interp_outdir_clock)) {dir.create(interp_outdir_clock)}
    write.csv(interp_dt_clock, file = file.path(interp_outdir_clock, paste0("sub", subj, "_run", run, "_interpolated.csv.gz")))
  } 
} else {
  cat("The output file for Clock aligned already exists. \n")
}

# RT ALIGNED
if (!file.exists(file.path(decon_outdir, "mmclock_pauli_combined_integermask_2.3mm", "interpolated", "rt_aligned", paste0("sub", subj, "_run", run, "_interpolated.csv.gz")))) {
  cat("Interpolating fMRI time series (RT aligned): \n")
  # rt aligned
  interp_dt_rt <- tryCatch({
    interp_dt_rt <- get_medusa_interpolated_ts(tsobj, event="rt_time", time_before=-6, time_after=9,
                                               output_resolution = tr,
                                               group_by = c(aggregate_by, "trial"))
    #interp_dt_rt %>% mutate(id=subj, run=run) -> interp_dt_rt
  }, error=function(err) { print(as.character(err)); save(fmri_event_data, file="problem_case.RData"); return(NULL) })

  cat("Writing output... \n")
  if(!is.null(interp_dt_rt)){
    # saving event-locked and interpolated fmri_ts:
    interp_outdir_rt <- file.path(decon_outdir, "mmclock_pauli_combined_integermask_2.3mm", "interpolated", "rt_aligned")
    if(!dir.exists(interp_outdir_rt)) {dir.create(interp_outdir_rt)}
    write.csv(interp_dt_rt, file = file.path(interp_outdir_rt, paste0("sub", subj, "_run", run, "_interpolated.csv.gz")))
  }
} else {
  cat("The output file for RT aligned already exists.")
}
