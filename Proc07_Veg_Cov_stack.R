#===============================================================
# Code 7 - Vegetation Cov stack for RothC model
#===============================================================
rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('terra',     
          'rgdal',
          'sp'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)


# 
# WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")
# 
# WD_SOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")
# 
# WD_COV<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/COV")

# 1) Open the shapefile of the region/country

#setwd(WD_AOI)
AOI<-vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")
AOI <- project(AOI,"+proj=longlat +datum=WGS84 +no_defs")

#2) Open SOC MAP FAO
SOC_MAP_AOI<-rast("SOC_MAP_AOI.tif")


# 3) Open Vegetation Cover layer based only in proportion of NDVI pixels grater than 0.6 

#setwd(WD_COV)

Cov1<-rast("Denmark_NDVI_2001-2020_prop_gt04_M01.tif")
Cov1[is.na(Cov1)] <- 0
plot(Cov1_res)
Cov1_crop<-terra::crop(Cov1,AOI)
Cov1_res<-terra::resample(Cov1_crop,SOC_MAP_AOI,method='bilinear') 

Cov2<-rast("Denmark_NDVI_2001-2020_prop_gt04_M02.tif")
Cov2[is.na(Cov2)] <- 0
Cov2_crop<-crop(Cov2,AOI)
Cov2_res<-resample(Cov2_crop,SOC_MAP_AOI,method='bilinear') 

Cov3<-rast("Denmark_NDVI_2001-2020_prop_gt04_M03.tif")
Cov3[is.na(Cov3)] <- 0
Cov3_crop<-crop(Cov3,AOI)
Cov3_res<-resample(Cov3_crop,SOC_MAP_AOI,method='bilinear') 

Cov4<-rast("Denmark_NDVI_2001-2020_prop_gt04_M04.tif")
Cov4[is.na(Cov4)] <- 0
Cov4_crop<-crop(Cov4,AOI)
Cov4_res<-resample(Cov4_crop,SOC_MAP_AOI,method='bilinear') 

Cov5<-rast("Denmark_NDVI_2001-2020_prop_gt04_M05.tif")
Cov5[is.na(Cov5)] <- 0
Cov5_crop<-crop(Cov5,AOI)
Cov5_res<-resample(Cov5_crop,SOC_MAP_AOI,method='bilinear') 

Cov6<-rast("Denmark_NDVI_2001-2020_prop_gt04_M06.tif")
Cov6[is.na(Cov6)] <- 0
Cov6_crop<-crop(Cov6,AOI)
Cov6_res<-resample(Cov6_crop,SOC_MAP_AOI,method='bilinear') 

Cov7<-rast("Denmark_NDVI_2001-2020_prop_gt04_M07.tif")
Cov7[is.na(Cov7)] <- 0
Cov7_crop<-crop(Cov7,AOI)
Cov7_res<-resample(Cov7_crop,SOC_MAP_AOI,method='bilinear') 

Cov8<-rast("Denmark_NDVI_2001-2020_prop_gt04_M08.tif")
Cov8[is.na(Cov8)] <- 0
Cov8_crop<-crop(Cov8,AOI)
Cov8_res<-resample(Cov8_crop,SOC_MAP_AOI,method='bilinear') 

Cov9<-rast("Denmark_NDVI_2001-2020_prop_gt04_M09.tif")
Cov9[is.na(Cov9)] <- 0
Cov9_crop<-crop(Cov9,AOI)
Cov9_res<-resample(Cov9_crop,SOC_MAP_AOI,method='bilinear') 

Cov10<-rast("Denmark_NDVI_2001-2020_prop_gt04_M10.tif")
Cov10[is.na(Cov10)] <- 0
Cov10_crop<-crop(Cov10,AOI)
Cov10_res<-resample(Cov10_crop,SOC_MAP_AOI,method='bilinear') 

Cov11<-rast("Denmark_NDVI_2001-2020_prop_gt04_M11.tif")
Cov11[is.na(Cov11)] <- 0
Cov11_crop<-crop(Cov11,AOI)
Cov11_res<-resample(Cov11_crop,SOC_MAP_AOI,method='bilinear') 

Cov12<-rast("Denmark_NDVI_2001-2020_prop_gt04_M12.tif")
Cov12[is.na(Cov12)] <- 0
Cov12_crop<-crop(Cov12,AOI)
Cov12_res<-resample(Cov12_crop,SOC_MAP_AOI,method='bilinear') 

Stack_Cov<-c(Cov1_res,Cov2_res,Cov3_res,Cov4_res,Cov5_res,Cov6_res,Cov7_res,Cov8_res,Cov9_res,Cov10_res,Cov11_res,Cov12_res)

# 4) Rescale values to 1 if it is bare soil and 0.6 if it is vegetated.

Cov<-((Stack_Cov)*(-0.4))+1

plot(Cov[[4]],Stack_Cov[[4]])
plot(Cov[[4]])
terra::writeRaster(Cov,filename='Cov_stack_AOI.tif',overwrite=TRUE)



