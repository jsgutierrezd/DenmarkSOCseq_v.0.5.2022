#==============================================
# Code 2 - Climate variables for WARM_UP phase
#==============================================

# In FAO methodology, this script corresponds to Proc02_CRU_variables_WARM_UP.R. This script takes into account the danish climate data

rm(list = ls())
# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('terra',     
          'rgdal',
          'abind',
          'parallel'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)

#==================
# 3) TEMPERATURE
#==================

# 3.1) Open the temperature file
temp <- rast("CHELSATEMP80_20.tif")
names(temp) <- readRDS("NamesCHELSATEMP80_20.rds")
names(temp)


# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 2001 to 2018

temp01_18 <- temp[[253:468]]
names(temp01_18)

# This raster stack contains monthly raster files with temperature data from January 2001 to December 2018. 
# We need to generate a multi-annual average by month, from 2001 to 2018

# 3.2) Compute multi-annual average
Temp_Stack <- rast()
for (i in 1:12) {
  layers <- temp01_18[[seq(i,216,12)]]
  average <- app(layers,fun=mean,cores=15)
  Temp_Stack <- c(Temp_Stack,average)
}
Temp_Stack <- terra::project(Temp_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Temp_Stack) <- paste0("Temp_Stack_01.18_CRU.",1:12)

# 3.3) Export the results
terra::writeRaster(Temp_Stack,filename='Temp_Stack_01-18_CRU.tif',overwrite=T)
saveRDS(names(Temp_Stack), "NamesTemp_Stack_01-18_CRU.rds")


# 3.4) Calculate annual average for MIAMI MODEL

Temp_Mean <- app(Temp_Stack,fun=mean,cores=15)
writeRaster(Temp_Mean,filename='Temp_mean_01-18_CRU.tif',"GTiff",overwrite=TRUE)

# 3.5) SAVE 1 layer per month per year
names(temp01_18) <- paste0("Temp_Stack_216_01.18_CRU.",1:216)
terra::writeRaster(temp01_18,filename='Temp_Stack_216_01-18_CRU.tif',overwrite=TRUE)
saveRDS(names(temp01_18), "NamesTemp_Stack_216_01-18_CRU.rds")


#==================
# 4) PRECIPITATION
#==================

rm(list = ls())

# 4.1) Open the temperature file
prec <- rast("CHELSAPREC80_20.tif")
names(prec) <- readRDS("NamesCHELSATEMP80_20.rds")
names(prec)


# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 2001 to 2018

prec01_18 <- prec[[253:468]]
names(prec01_18)

# This raster stack contains monthly raster files with temperature data from January 2001 to December 2018. 
# We need to generate a multi-annual average by month, from 2001 to 2018

# 4.2) Compute multi-annual average
Prec_Stack <- rast()
for (i in 1:12) {
  layers <- prec01_18[[seq(i,216,12)]]
  average <- app(layers,fun=mean,cores=15)
  Prec_Stack <- c(Prec_Stack,average)
}

Prec_Stack <- terra::project(Prec_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Prec_Stack) <- paste0("Prec_Stack_01.18_CRU.",1:12)

# 4.3) Export the results
terra::writeRaster(Prec_Stack,filename='Prec_Stack_01-18_CRU.tif',overwrite=T)
saveRDS(names(Prec_Stack), "NamesPrec_Stack_01-18_CRU.rds")

# 4.4) Calculate annual average for MIAMI MODEL
Prec_Mean <- app(Prec_Stack,fun=mean,cores=15)
writeRaster(Prec_Mean,filename='Prec_Mean_01-18_CRU.tif',overwrite=TRUE)


# 4.5) SAVE 1 layer per month per year
names(prec01_18) <- paste0("Prec_Stack_216_01.18_CRU.",1:216)
terra::writeRaster(prec01_18,filename='Prec_Stack_216_01-18_CRU.tif',overwrite=TRUE)
saveRDS(names(prec01_18), "NamesPrec_Stack_216_01-18_CRU.rds")

#==================================
# 5) POTENTIAL EVAPOTRANSPIRATION
#==================================

rm(list = ls())

# 5.1) Open the potential evapotranspiration file
pet <- rast("CHELSAPET80_20.tif")
names(pet) <- readRDS("NamesCHELSAPET80_20.rds")
names(pet)

# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 2001 to 2018

pet01_18 <- pet[[253:468]]
names(pet01_18)

# This raster stack contains monthly raster files with temperature data from January 2001 to December 2018. 
# We need to generate a multi-annual average by month, from 2001 to 2018

# 5.2) Compute multi-annual average

Pet_Stack <- rast()
for (i in 1:12) {
  layers <- pet01_18[[seq(i,216,12)]]
  average <- app(layers,fun=mean,cores=15)
  Pet_Stack <- c(Pet_Stack,average)
}

Pet_Stack <- terra::project(Pet_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Pet_Stack) <- paste0("Pet_Stack_01.18_CRU.",1:12)

# 5.3) Export the results
terra::writeRaster(Pet_Stack,filename='Pet_Stack_01-18_CRU.tif',overwrite=T)
saveRDS(names(Pet_Stack), "NamesPet_Stack_01-18_CRU.rds")

# 5.4) Calculate annual average for MIAMI MODEL

Pet_Mean <- app(Pet_Stack,fun=mean,cores=15)
terra::writeRaster(Pet_Mean,filename='Pet_Mean_01-18_CRU.tif',overwrite=TRUE)


# 5.5) SAVE 1 layer per month per year
names(pet01_18) <- paste0("Pet_Stack_216_01.18_CRU.",1:216)
terra::writeRaster(pet01_18,filename='Pet_Stack_216_01-18_CRU.tif',overwrite=TRUE)
saveRDS(names(pet01_18), "NamesPet_Stack_216_01-18_CRU.rds")



