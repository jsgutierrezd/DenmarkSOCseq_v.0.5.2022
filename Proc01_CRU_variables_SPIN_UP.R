#==============================================
# Code 1 - Climate variables for SPIN_UP phase
#==============================================

# In FAO methodology, this script corresponds to Proc1_CRU_variables_SPIN_UP.R. This script takes into account the danish climate data
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

#Chelsa layers - monthly values 1980-2020
temp <- rast("O:/Tech_AGRO/Jord/Sebastian/CHELSA_LAYERS/CHELSATemp011980_122019.tif")
names(temp) <- readRDS("O:/Tech_AGRO/Jord/Sebastian/CHELSA_LAYERS/NamesCHELSATemp011980_122019.rds")
names(temp)
ordered <- c(seq(1,441,by=40), seq(2,442,by=40),seq(3,443,by=40),seq(4,444,by=40),
             seq(5,445,by=40),seq(6,446,by=40),seq(7,447,by=40),seq(8,448,by=40),
             seq(9,449,by=40),seq(10,450,by=40),seq(11,451,by=40),seq(12,452,by=40),
             seq(13,453,by=40),seq(14,454,by=40),seq(15,455,by=40),seq(16,456,by=40),
             seq(17,457,by=40),seq(18,458,by=40),seq(19,459,by=40),seq(20,460,by=40),
             seq(21,461,by=40),seq(22,462,by=40),seq(23,463,by=40),seq(24,464,by=40),
             seq(25,465,by=40),seq(26,466,by=40),seq(27,467,by=40),seq(28,468,by=40),
             seq(29,469,by=40),seq(30,470,by=40),seq(31,471,by=40),seq(32,472,by=40),
             seq(33,473,by=40),seq(34,474,by=40),seq(35,475,by=40),seq(36,476,by=40),
             seq(37,477,by=40),seq(38,478,by=40),seq(39,479,by=40),seq(40,480,by=40))
temp <- temp[[ordered]]


tempdk <- rast("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_1/TEMP80_21.tif")
names(tempdk) <- readRDS("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_1/NamesTEMP80_21.rds")
names(tempdk)
tempdk1 <- tempdk[[481:492]]
tempdk1 <- terra::project(tempdk1,temp)

temp <- c(temp,tempdk1)
names(temp) <- names(tempdk)[1:492]

terra::writeRaster(temp,"CHELSATEMP80_20.tif",overwrite=T)
saveRDS(names(temp),"NamesCHELSATEMP80_20.rds")

# 3.1) Open the temperature file
temp <- rast("CHELSATEMP80_20.tif")
names(temp) <- readRDS("NamesCHELSATEMP80_20.rds")
names(temp)


# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 1981 to 2000

temp81_00 <- temp[[13:252]] #Selecting only data from January 1981 to December 2020
names(temp81_00)


# This raster stack contains monthly raster files with temperature data from January 1981 to December 2000. 
# We need to generate a multi-annual average by month, from 1981 to 2000

# 3.2) Compute multi-annual average
Temp_Stack <- rast()
for (i in 1:12) {
  layers <- temp81_00[[seq(i,240,12)]]
  average <- app(layers,fun=mean,cores=15)
  Temp_Stack <- c(Temp_Stack,average)
}
Temp_Stack <- project(Temp_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Temp_Stack) <- paste0("Temp_Stack_81.00_CRU.",1:12)


# 3.3) Export the results
terra::writeRaster(Temp_Stack,filename='Temp_Stack_81-00_CRU.tif',overwrite=T)
saveRDS(names(Temp_Stack), "NamesTemp_Stack_81-00_CRU.rds")

#==================
# 4) PRECIPITATION
#==================

# 4.1) Open the precipitation file
prec <- rast("O:/Tech_AGRO/Jord/Sebastian/CHELSA_LAYERS/CHELSAPrec011979_122018.tif")
names(prec) <- readRDS("O:/Tech_AGRO/Jord/Sebastian/CHELSA_LAYERS/NamesCHELSAPrec011979_122018.rds")
names(prec)
prec <- prec[[-c(41,82,123,164,205,246)]] # Removing layers from 2019 since they are not available for the 12 months

ordered <- c(seq(1,480,by=40), seq(2,480,by=40),seq(3,480,by=40),seq(4,480,by=40),
             seq(5,480,by=40),seq(6,480,by=40),seq(7,480,by=40),seq(8,480,by=40),
             seq(9,480,by=40),seq(10,480,by=40),seq(11,480,by=40),seq(12,480,by=40),
             seq(13,480,by=40),seq(14,480,by=40),seq(15,480,by=40),seq(16,480,by=40),
             seq(17,480,by=40),seq(18,480,by=40),seq(19,480,by=40),seq(20,480,by=40),
             seq(21,480,by=40),seq(22,480,by=40),seq(23,480,by=40),seq(24,480,by=40),
             seq(25,480,by=40),seq(26,480,by=40),seq(27,480,by=40),seq(28,480,by=40),
             seq(29,480,by=40),seq(30,480,by=40),seq(31,480,by=40),seq(32,480,by=40),
             seq(33,480,by=40),seq(34,480,by=40),seq(35,480,by=40),seq(36,480,by=40),
             seq(37,480,by=40),seq(38,480,by=40),seq(39,480,by=40),seq(40,480,by=40))

prec <- prec[[ordered]]
data.frame(names(prec))
prec <- prec[[-c(1:12)]] # Removing layers from 1979

precdk <- rast("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_1/PREC80_21.tif")
names(precdk) <- readRDS("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_1/NamesTEMP80_21.rds")
names(precdk)
precdk1 <- precdk[[469:492]]
precdk1 <- terra::project(precdk1,prec)

prec <- c(prec,precdk1)
names(prec) <- names(precdk[[1:492]])

# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 1981 to 2000
prec <- terra::project(prec,temp)
terra::writeRaster(prec,"CHELSAPREC80_20.tif",overwrite=T)
saveRDS(names(prec), "NamesCHELSAPREC80_20.tif")


## Read precipitation
prec <- rast("CHELSAPREC80_20.tif")
names(prec) <- readRDS("NamesCHELSAPREC80_20.tif")
names(prec)


# This raster stack contains monthly raster files with precipitation data from January 1980 to November 2020. 
# We need to generate a multi-annual average by month, from 1981 to 2000

prec81_00 <- prec[[13:252]]
names(prec81_00)

# This raster stack contains monthly raster files with temperature data from January 1981 to December 2000. 
# We need to generate a multi-annual average by month, from 1981 to 2000

# 4.2) Compute multi-annual average
Prec_Stack <- rast()
for (i in 1:12) {
  layers <- prec81_00[[seq(i,240,12)]]
  average <- app(layers,fun=mean,cores=15)
  Prec_Stack <- c(Prec_Stack,average)
}

Prec_Stack <- terra::project(Prec_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Prec_Stack) <- paste0("Prec_Stack_81.00_CRU.",1:12)

# 4.3) Export the results
terra::writeRaster(Prec_Stack,filename='Prec_Stack_81-00_CRU.tif',overwrite=T)
saveRDS(names(Prec_Stack), "NamesPrec_Stack_81-00_CRU.rds")

#==================================
# 5) POTENTIAL EVAPOTRANSPIRATION
#==================================

# 5.1) Open the precipitation file
pet <- rast("O:/Tech_AGRO/Jord/Sebastian/CHELSA_LAYERS/CHELSAPet011980_122018.tif")
names(pet) <- readRDS("O:/Tech_AGRO/Jord/Sebastian/CHELSA_LAYERS/NamesCHELSAPet011980_122018.rds")
names(pet)

# This raster stack contains monthly raster files with potential evapotranspiration data from January 1980 to December 2018

ordered <- c(seq(1,468,by=39), seq(2,468,by=39),seq(3,468,by=39),seq(4,468,by=39),
             seq(5,468,by=39),seq(6,468,by=39),seq(7,468,by=39),seq(8,468,by=39),
             seq(9,468,by=39),seq(10,468,by=39),seq(11,468,by=39),seq(12,468,by=39),
             seq(13,468,by=39),seq(14,468,by=39),seq(15,468,by=39),seq(16,468,by=39),
             seq(17,468,by=39),seq(18,468,by=39),seq(19,468,by=39),seq(20,468,by=39),
             seq(21,468,by=39),seq(22,468,by=39),seq(23,468,by=39),seq(24,468,by=39),
             seq(25,468,by=39),seq(26,468,by=39),seq(27,468,by=39),seq(28,468,by=39),
             seq(29,468,by=39),seq(30,468,by=39),seq(31,468,by=39),seq(32,468,by=39),
             seq(33,468,by=39),seq(34,468,by=39),seq(35,468,by=39),seq(36,468,by=39),
             seq(37,468,by=39),seq(38,468,by=39),seq(39,468,by=39))

ordered
pet <- pet[[ordered]]
names(pet)


petdk <- rast("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_1/PET80_21.tif")
names(petdk) <- readRDS("C:/Users/au704633/OneDrive - Aarhus Universitet/Documents/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_1/NamesTEMP80_21.rds")
names(petdk)
petdk1 <- petdk[[469:492]]
petdk1 <- terra::project(petdk1,pet)

pet <- c(pet,petdk1)
names(pet) <- names(petdk[[1:492]])

# This raster stack contains monthly raster files with temperature data from January 1980 to November 2021. 
# We need to generate a multi-annual average by month, from 1981 to 2000
pet <- terra::project(pet,temp)
terra::writeRaster(pet,"CHELSAPET80_20.tif",overwrite=T)
saveRDS(names(pet), "NamesCHELSAPET80_20.tif")


## Read potential evapotranspiration
pet <- rast("CHELSAPET80_20.tif")
names(pet) <- readRDS("NamesCHELSAPET80_20.tif")
names(pet)


# This raster stack contains monthly raster files with potential evapotranspiration data from January 1980 to November 2020. 
# We need to generate a multi-annual average by month, from 1981 to 2000


# We need to generate a multi-annual average by month, from 1981 to 2000

pet81_00 <- pet[[13:252]]
names(pet81_00)

# This raster stack contains monthly raster files with temperature data from January 1981 to December 2000. 
# We need to generate a multi-annual average by month, from 1981 to 2000

# 5.2) Compute multi-annual average
Pet_Stack <- rast()
for (i in 1:12) {
  layers <- pet81_00[[seq(i,240,12)]]
  average <- app(layers,fun=mean,cores=15)
  Pet_Stack <- c(Pet_Stack,average)
}

Pet_Stack <- terra::project(Pet_Stack,"+proj=longlat +datum=WGS84 +no_defs")
names(Pet_Stack) <- paste0("Prec_Stack_81.00_CRU.",1:12)

# 5.3) Export the results
terra::writeRaster(Pet_Stack,filename='Pet_Stack_81.00_CRU.tif',overwrite=T)
saveRDS(names(Pet_Stack), "NamesPet_Stack_81.00_CRU.rds")
