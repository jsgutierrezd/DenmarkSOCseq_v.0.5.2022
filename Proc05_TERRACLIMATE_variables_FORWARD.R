#===============================================================
# Code 5 - TERRACLIMATE variables for FORWARD phase
#===============================================================
# In FAO methodology, this script corresponds to Proc05_TERRACLIMATE_variables_FORWARD.R. This script takes into account the Danish climate data

rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")


# 2) Load libraries

pckg <- c('raster',     
          'rgdal',
          'parallel'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)


# 3) Open Terra Climate downloaded from Google Earth Engine

tmp_01_18<-rast("Temp_Stack_216_01-18_CRU.tif")

pre_01_18<-rast("Prec_Stack_216_01-18_CRU.tif")

pet_01_18<-rast("Pet_Stack_216_01-18_CRU.tif")


#==================
# 4) TEMPERATURE
#==================

# 4.1) Compute multi-annual average

Temp_Stack <- rast()
for (i in 1:12) {
  layers <- tmp_01_18[[seq(i,216,12)]]
  average <- app(layers,fun=mean,cores=17)
  Temp_Stack <- c(Temp_Stack,average)
}

Temp_Stack <- terra::project(Temp_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Temp_Stack) <- paste0("Temp_Stack_01-18_TC.",1:12)

# 4.2) Export the results
terra::writeRaster(Temp_Stack,filename='Temp_Stack_01-18_TC.tif',overwrite=TRUE)
saveRDS(names(Temp_Stack), "NamesTemp_Stack_01-18_TC.rds")

#############################################################################################################################

#==================
# 5) PRECIPITATION
#==================


# 5.1) Compute multi-annual average
Prec_Stack <- rast()
for (i in 1:12) {
  layers <- pre_01_18[[seq(i,216,12)]]
  average <- app(layers,fun=mean,cores=17)
  Prec_Stack <- c(Prec_Stack,average)
}

Prec_Stack <- terra::project(Prec_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Prec_Stack) <- paste0("Prec_Stack_01-18_TC.",1:12)

# 5.2) Export the results
terra::writeRaster(Prec_Stack,filename='Prec_Stack_01-18_TC.tif',overwrite=TRUE)
saveRDS(names(Prec_Stack), "NamesPrec_Stack_01-18_TC.rds")

########################################################################

#=================================
# 6) POTENTIAL EVAPOTRANSPIRATION
#================================= 


# 6.1) Compute multi-annual average

Pet_Stack <- rast()
for (i in 1:12) {
  layers <- pet_01_18[[seq(i,216,12)]]
  average <- app(layers,fun=mean,cores=17)
  Pet_Stack <- c(Pet_Stack,average)
}

Pet_Stack <- terra::project(Pet_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Pet_Stack) <- paste0("Pet_Stack_01-18_TC.",1:12)

# 6.2) Export the results
terra::writeRaster(Pet_Stack,filename='Pet_Stack_01-18_TC.tif',overwrite=TRUE)
saveRDS(names(Pet_Stack), "NamesPet_Stack_01-18_TC.rds")