#===================================
# Code 0 - Denmark SOC map and AOI
#===================================

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('raster',     
          'rgdal',
          'SoilR',
          'Formula',
          'soilassessment',
          'abind',
          'ncdf4',
          'terra'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)

# 3)Load layer 1km to resample the finer-resolution layers
dem1km <- rast("dem1km.tif")
plot(dem1km)
dem1km <- terra::project(dem1km,"+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs")

# 3) Load Denmark SOC map
SOC_MAP <- rast("OCk_BDk_BDw_th.tif")

# 4) Load AOI Denmark
AOI <- vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")

# 5) Crop and mask SOC map by the AOI layer and save it
SOC_MAP_AOI<-crop(SOC_MAP,AOI)
SOC_MAP_AOI <- resample(SOC_MAP_AOI,dem1km,method="bilinear")
SOC_MAP_AOI <- project(SOC_MAP_AOI,"+proj=longlat +datum=WGS84 +no_defs")
plot(SOC_MAP_AOI)
terra::writeRaster(SOC_MAP_AOI,filename="SOC_MAP_AOI.tif",overwrite=TRUE)

# The final raster layer contains SOC values at 1 Km-spatial resolution

