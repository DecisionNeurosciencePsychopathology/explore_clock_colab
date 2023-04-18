require(stringr)

run_level_niftis <- read.csv('/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/run_level_niftis_mmclock.csv')

afnidir <- '/ihome/crc/install/afni/18.0.22/bin'
Sys.setenv(AFNIDIR=afnidir)

# iterative deconvolution
decon_outdir <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed'
mask <- 'vta-mmclock'

for (i in 1:nrow(run_level_niftis)) {
    subj = run_level_niftis$id[i]
    nifti = run_level_niftis$nifti[i]
    #run = str_extract(str_extract(nifti, pattern="run-[0-9]"), pattern="[0-9]")
	run = run_level_niftis$run[i]
    d_file = file.path(decon_outdir, mask, "deconvolved", paste0("sub", subj, "_run", run, "_deconvolved.csv.gz"))
    if (!file.exists(d_file) & !is.na(nifti)) {
        system(paste("sbatch -p smp -N 1 --mem 20g -n 1 -t 23:00:00 -c 1 --wrap 'source ~/.bashrc; Rscript /bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/medusa_crc.R --subj", subj, "--l1_nifti", nifti, "'"))
    } else {
        print(paste("Subject", subj, "run", run, "is already deconvolved or there is no NIFTI for this run."))
    }
}

# iterative decon alignment 
d_files <- list.files("/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_444_3.125mm/deconvolved", full.names=T)
decon_outdir <- '/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed'

for (i in 1:length(d_files)) {
    file_path <- d_files[i]
    subj <- gsub("sub", "", str_extract(file_path, pattern="sub[0-9]*"))
    run <- str_extract(str_extract(file_path, pattern="run[0-9]"), pattern="[0-9]")
    rt_out <- file.path(decon_outdir, "transformed_schaefer_444_3.125mm", "interpolated", "rt_aligned", paste0("sub", subj, "_run", run, "_interpolated.csv.gz"))
    clock_out <- file.path(decon_outdir, "transformed_schaefer_444_3.125mm", "interpolated", "clock_aligned", paste0("sub", subj, "_run", run, "_interpolated.csv.gz"))
    if (!file.exists(rt_out) | !file.exists(clock_out)) {
        print(paste("Submitting batch job for subject", subj, "run", run))
        system(paste("sbatch -p smp -N 1 --mem 20g -n 1 -t 23:00:00 -c 1 --wrap 'source ~/.bashrc; Rscript /bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/medusa_alignment.R --subj", subj, "--run", run, "--d_file", file_path, "'"))
    } else {
        print(paste("Subject", subj, "run", run, "is already done."))
    }
}
