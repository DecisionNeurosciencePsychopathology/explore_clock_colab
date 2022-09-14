# includes adding id and run as variables directly from filename using purrr::map_dfr

dan_values <- c(69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,86,87,88,89,90,91,145,245,271,272,273,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,355)
vpfc_values <- c(67,171,65,170,66,89,194,88,192,84,191,86,161,55,160,159,56)
hc_values <- c(423,425,401,424,426,402,429,430,428,427)

# 400 PARCELLATION

# CLOCK
setwd("/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_444_3.125mm/interpolated/clock_aligned")
list.files(getwd()) -> filelist
str_split(filelist, pattern="_interpolated") -> x
names(filelist) <- sapply(x, head, 1)
purrr::map_dfr(filelist, data.table::fread, .id="id") -> clock_aligned_444_wb
clock_aligned_444_wb %>% 
    mutate(run=str_extract(id, pattern="run\\d"), subj=str_extract(id, pattern="\\d{5,}")) %>% 
    select(-id) %>% 
    select(id=subj, run, atlas_value, trial, evt_time, decon_mean, decon_median, decon_sd) -> clock_aligned_444_wb
clock_aligned_444_wb %>% filter(atlas_value %in% dan_values) -> clock_aligned_444_dan
clock_aligned_444_wb %>% filter(atlas_value %in% vpfc_values) -> clock_aligned_444_vpfc
clock_aligned_444_wb %>% filter(atlas_value %in% hc_values) -> clock_aligned_444_hc

data.table::fwrite(clock_aligned_444_wb,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/clock_aligned_444_wb.csv.gz")
data.table::fwrite(clock_aligned_444_dan,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/clock_aligned_444_dan.csv.gz")
data.table::fwrite(clock_aligned_444_vpfc,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/clock_aligned_444_vpfc.csv.gz")
data.table::fwrite(clock_aligned_444_hc,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/clock_aligned_444_hc.csv.gz")

# FEEDBACK
setwd("/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_444_3.125mm/interpolated/rt_aligned")
list.files(getwd()) -> filelist
str_split(filelist, pattern="_interpolated") -> x
names(filelist) <- sapply(x, head, 1)
purrr::map_dfr(filelist, data.table::fread, .id="id") -> rt_aligned_444_wb
rt_aligned_444_wb %>% 
    mutate(run=str_extract(id, pattern="run\\d"), subj=str_extract(id, pattern="\\d{5,}")) %>% 
    select(-id) %>% 
    select(id=subj, run, atlas_value, trial, evt_time, decon_mean, decon_median, decon_sd) -> rt_aligned_444_wb
rt_aligned_444_wb %>% filter(atlas_value %in% dan_values) -> rt_aligned_444_dan
rt_aligned_444_wb %>% filter(atlas_value %in% vpfc_values) -> rt_aligned_444_vpfc
rt_aligned_444_wb %>% filter(atlas_value %in% hc_values) -> rt_aligned_444_hc

data.table::fwrite(rt_aligned_444_wb,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/rt_aligned_444_wb.csv.gz")
data.table::fwrite(rt_aligned_444_dan,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/rt_aligned_444_dan.csv.gz")
data.table::fwrite(rt_aligned_444_vpfc,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/rt_aligned_444_vpfc.csv.gz")
data.table::fwrite(rt_aligned_444_hc,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/444/rt_aligned_444_hc.csv.gz")

# 200 PARCELLATION

# CLOCK 
# interp dir labelled 'dan' but actually wb 200 parcel
setwd("/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_dan_3.125mm/interpolated/clock_aligned")
list.files(getwd()) -> filelist
str_split(filelist, pattern="_interpolated") -> x
names(filelist) <- sapply(x, head, 1)
purrr::map_dfr(filelist, data.table::fread, .id="id") -> clock_aligned_200_wb
clock_aligned_200_wb %>% 
    mutate(run=str_extract(id, pattern="run\\d"), subj=str_extract(id, pattern="\\d{5,}")) %>% 
    select(-id) %>% 
    select(id=subj, run, atlas_value, trial, evt_time, decon_mean, decon_median, decon_sd) -> clock_aligned_200_wb
clock_aligned_200_wb %>% filter(atlas_value %in% vpfc_values) -> clock_aligned_200_vpfc

data.table::fwrite(clock_aligned_200_wb,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/200/clock_aligned_200_wb.csv.gz")
data.table::fwrite(clock_aligned_200_vpfc,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/200/clock_aligned_200_vpfc.csv.gz")

# FEEDBACK 
# interp dir labelled 'dan' but actually wb 200 parcel
setwd("/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/transformed_schaefer_dan_3.125mm/interpolated/rt_aligned")
list.files(getwd()) -> filelist
str_split(filelist, pattern="_interpolated") -> x
names(filelist) <- sapply(x, head, 1)
purrr::map_dfr(filelist, data.table::fread, .id="id") -> rt_aligned_200_wb
rt_aligned_200_wb %>% 
    mutate(run=str_extract(id, pattern="run\\d"), subj=str_extract(id, pattern="\\d{5,}")) %>% 
    select(-id) %>% 
    select(id=subj, run, atlas_value, trial, evt_time, decon_mean, decon_median, decon_sd) -> rt_aligned_200_wb
rt_aligned_200_wb %>% filter(atlas_value %in% vpfc_values) -> rt_aligned_200_vpfc

data.table::fwrite(rt_aligned_200_wb,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/200/rt_aligned_200_wb.csv.gz")
data.table::fwrite(rt_aligned_200_vpfc,file= "/bgfs/adombrovski/DNPL_DataMesh/Data/bea_demo/Medusa/Medusa_Preanalyzed/Data_Concat/200/rt_aligned_200_vpfc.csv.gz")


