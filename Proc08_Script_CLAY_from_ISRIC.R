#===============================================================
# Code 8 - Clay layer
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
# WD_ISRIC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")
# 
# WD_CLAY<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")

# 1) Open the shapefile of the region/country
AOI<-vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")
#AOI <- sp::spTransform(AOI,CRS("+proj=longlat +datum=WGS84 +no_defs"))

# 2) Open Clay layer, generated in AU

#setwd(WD_ISRIC)
Clay_WA <- rast("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/INPUTS/RASTER/GSOCMap/aclaynor.tif")
plot(Clay_WA)
# Clay1<-raster("CLYPPT_M_sl1_250m_ll_subs.tif")
# Clay2<-raster("CLYPPT_M_sl2_250m_ll_subs.tif")
# Clay3<-raster("CLYPPT_M_sl3_250m_ll_subs.tif")
# Clay4<-raster("CLYPPT_M_sl4_250m_ll_subs.tif")


# Clay1_AOI<-crop(Clay1,AOI)
# Clay2_AOI<-crop(Clay2,AOI)
# Clay3_AOI<-crop(Clay3,AOI)
# Clay4_AOI<-crop(Clay4,AOI)

# Weighted Average of four depths 

# WeightedAverage<-function(r1,r2,r3,r4){return(r1*(1/30)+r2*(4/30)+r3*(10/30)+r4*(15/30))}

# Clay_WA<-overlay(Clay1_AOI,Clay2_AOI,Clay3_AOI,Clay4_AOI,fun=WeightedAverage)

Clay_WA <- terra::project(Clay_WA,"+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs")
Clay_WA_AOI<-crop(Clay_WA,AOI)
Clay_WA_AOI <- terra::project(Clay_WA_AOI,"+proj=longlat +datum=WGS84 +no_defs")

SOC_MAP_AOI<-rast("SOC_MAP_AOI.tif")
Clay_WA_AOI <- terra::resample(Clay_WA_AOI,SOC_MAP_AOI,method="bilinear",filename="Clay_WA_AOI.tif",
                                overwrite=TRUE)



