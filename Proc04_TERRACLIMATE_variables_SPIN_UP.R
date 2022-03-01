#===============================================================
# Code 4 - TERRACLIMATE variables for SPIN_UP phase
#===============================================================
# In FAO methodology, this script corresponds to Proc04_TERRACLIMATE_variables_SPIN_UP.R. This script takes into account the Danish climate data

rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('terra',     
          'rgdal',
          'parallel'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)

# TERRA CLIME FROM GOOGLE EARTH ENGINE
#Abatzoglou, J.T., S.Z. Dobrowski, S.A. Parks, K.C. Hegewisch, 2018, Terraclimate, 
#a high-resolution global dataset of monthly climate and climatic water balance from 1958-2015, Scientific Data,
#######################################################################################

# 3) Open climate layers

tmp_81_00 <- rast("Temp_Stack_240_81-00_CRU.tif")

prec_81_00<-rast("Prec_Stack_240_81-00_CRU.tif")


#==================
# 4) TEMPERATURE
#==================

# 4.1) Compute multi-annual average

Temp_Stack <- rast()
for (i in 1:12) {
  layers <- tmp_81_00[[seq(i,240,12)]]
  average <- app(layers,fun=mean,cores=17)
  Temp_Stack <- c(Temp_Stack,average)
}


Temp_Stack <- terra::project(Temp_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Temp_Stack) <- paste0("Temp_Stack_81.00_TC.",1:12)

# 4.2) Export the results
terra::writeRaster(Temp_Stack,filename='Temp_Stack_81-00_TC.tif',overwrite=T)
saveRDS(names(Temp_Stack), "NamesTemp_Stack_81-00_TC.rds")

#==================
# 4) PRECIPITATION
#==================

# 4.1) Compute multi-annual average

Prec_Stack <- rast()
for (i in 1:12) {
  layers <- prec_81_00[[seq(i,240,12)]]
  average <- app(layers,fun=mean,cores=17)
  Prec_Stack <- c(Prec_Stack,average)
}


Prec_Stack <- terra::project(Prec_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Temp_Stack) <- paste0("Prec_Stack_81.00_TC.",1:12)

# 4.2) Export the results
terra::writeRaster(Prec_Stack,filename='Prec_Stack_81-00_TC.tif',overwrite=T)
saveRDS(names(Prec_Stack), "NamesPrec_Stack_81-00_TC.rds")

#=================================
# 5) POTENTIAL EVAPOTRANSPIRATION
#=================================

rm(list = ls())

# 5.1) Open the potential evapotranspiration file
pet <- rast("CHELSAPET80_20.tif")
names(pet) <- readRDS("NamesCHELSAPET80_20.rds")
names(pet)

# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 1981 to 2000

pet_81_00 <- pet[[13:252]]
names(pet_81_00) <- paste0("Pet_Stack_240_81.00_CRU.",1:240)

# 5.2) SAVE 1 layer per month per year
terra::writeRaster(pet_81_00,filename='Pet_Stack_240_81-00_CRU.tif',overwrite=TRUE)
saveRDS(names(pet_81_00),"NamesPet_Stack_240_81-00_CRU.rds")

#####
# 5.3) Compute multi-annual average
Pet_Stack <- rast()
for (i in 1:12) {
  layers <- pet_81_00[[seq(i,240,12)]]
  average <- app(layers,fun=mean,cores=17)
  Pet_Stack <- c(Pet_Stack,average)
}


Pet_Stack <- terra::project(Pet_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Pet_Stack) <- paste0("Pet_Stack_81.00_TC.",1:12)

# 5.4) Export the results
terra::writeRaster(Pet_Stack,filename='Pet_Stack_81-00_TC.tif',overwrite=T)
saveRDS(names(Pet_Stack), "NamesPet_Stack_81-00_TC.rds")