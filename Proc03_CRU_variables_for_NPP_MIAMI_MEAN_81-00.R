#===============================================================
# Code 3 - Climate variables for NPP Miami model mean 1981-2000
#===============================================================

# In FAO methodology, this script corresponds to Proc03_CRU_variables_for_NPP_MIAMI_MEAN_81-00.R. This script takes into account the danish climate data
rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('terra',     
          'rgdal',
          'abind',
          'paralel',
          'ncdf4'
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
# We need to generate a multi-annual average by month, from 1981 to 2000

temp81_00 <- temp[[13:252]]
names(temp81_00) <- paste0("Temp_Stack_240_81.00_CRU.",1:240)

# 3.2) SAVE 1 layer per month per year
terra::writeRaster(temp81_00,filename='Temp_Stack_240_81-00_CRU.tif',overwrite=TRUE)
saveRDS(names(temp81_00),"NamesTemp_Stack_240_81-00_CRU.rds")

#==================
# 4) PRECIPITATION
#==================

rm(list = ls())

# 3.1) Open the temperature file
prec <- rast("CHELSAPREC80_20.tif")
names(prec) <- readRDS("NamesCHELSATEMP80_20.rds")
names(prec)

# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 1981 to 2000

prec81_00 <- prec[[13:252]]
names(prec81_00) <- paste0("Prec_Stack_240_81.00_CRU.",1:240)

# 3.2) SAVE 1 layer per month per year
terra::writeRaster(prec81_00,filename='Prec_Stack_240_81-00_CRU.tif',overwrite=TRUE)
saveRDS(names(prec81_00),"NamesPrec_Stack_240_81-00_CRU.rds")

