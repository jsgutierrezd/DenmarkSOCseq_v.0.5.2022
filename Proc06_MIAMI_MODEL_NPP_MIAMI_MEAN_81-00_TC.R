#===============================================================
# Code 6 - Miami model for MPP 81-00
#===============================================================
# In FAO methodology, this script corresponds to Proc06_MIAMI_MODEL_NPP_MIAMI_MEAN_81-00.R. This script takes into account the Danish climate data

rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('terra',     
          'rgdal',
          'sp',
          'parallel',
          'terra'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)



# 3) Open Anual Precipitation (mm) and Mean Anual Temperature (grades C) stacks

Temp<-rast("Temp_Stack_240_81-00_CRU.tif")
Prec<-rast("Prec_Stack_240_81-00_CRU.tif")

#setwd(WD_AOI)
AOI<-vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")
AOI <- project(AOI,crs(Temp))

Temp<-terra::crop(Temp,AOI)


Prec<-terra::crop(Prec,AOI)

# 4) Temperature Annual Mean 

k<-1
TempList<-list()
#######loop for starts#########
for (i in 1:(dim(Temp)[3]/12)){
  
  Temp1<-mean(Temp[[k:(k+11)]])
  TempList[i]<-Temp1
  
  k<-k+12
}
#######loop for ends##########

TempStack<-rast(TempList)
#TempStack<-TempStack*0.1 # rescale to °C

# 5) Annual Precipitation

k<-1
PrecList<-list()
########loop for starts#######
for (i in 1:20){
  
  Prec1<-sum(Prec[[k:(k+11)]])
  PrecList[i]<-Prec1
  
  k<-k+12
}
########loop for ends#######
PrecStack<-rast(PrecList)

# 6) Calculate eq 1 from MIAMI MODEL (g DM/m2/day)

NPP_Prec<-3000*(1-exp(-0.000664*PrecStack))

# 7) Calculate eq 2 from MIAMI MODEL (g DM/m2/day)

NPP_temp<-3000/(1+exp(1.315-0.119*TempStack))

# 8) Calculate eq 3 from MIAMI MODEL (g DM/m2/day)

NPP_MIAMI_List<-list()

########loop for starts#######
for (i in 1:20){
  NPP_MIAMI_List[i]<-min(NPP_Prec[[i]],NPP_temp[[i]])
}
########loop for ends#######

NPP_MIAMI<-rast(NPP_MIAMI_List)

# 9) NPP_MIAMI gDM/m2/year To tn DM/ha/year

NPP_MIAMI_tnDM_Ha_Year<-NPP_MIAMI*(1/100)

# 10) NPP_MIAMI tn DM/ha/year To tn C/ha/year

NPP_MIAMI_tnC_Ha_Year<-NPP_MIAMI_tnDM_Ha_Year*0.5

# 11) Save WORLD NPP MIAMI MODEL tnC/ha/year

#setwd(WD_NPP)

terra::writeRaster(NPP_MIAMI_tnC_Ha_Year,filename="NPP_MIAMI_tnC_Ha_Year_STACK_81-00.tif",overwrite=TRUE)

NPP_MIAMI_tnC_Ha_Year<-rast("NPP_MIAMI_tnC_Ha_Year_STACK_81-00.tif")

# 12) NPP MEAN

NPP_MIAMI_MEAN_81_00<-mean(NPP_MIAMI_tnC_Ha_Year)

# 13) Open FAO GSOC MAP 

#setwd(WD_GSOC)

SOC_MAP_AOI<-rast("SOC_MAP_AOI.tif")
plot(SOC_MAP_AOI)


# 14) Crop & mask
NPP_MIAMI_MEAN_81_00_AOI<-terra::crop(NPP_MIAMI_MEAN_81_00,AOI)
NPP_MIAMI_MEAN_81_00_AOI<-terra::resample(NPP_MIAMI_MEAN_81_00_AOI,SOC_MAP_AOI)


terra::writeRaster(NPP_MIAMI_MEAN_81_00_AOI,filename="NPP_MIAMI_MEAN_81-00_AOI.tif",overwrite=TRUE)
terra::writeRaster(NPP_MIAMI_MEAN_81_00,filename="NPP_MIAMI_MEAN_81-00.tif",overwrite=TRUE)


# 15) UNCERTAINTIES MINIMUM TEMP , PREC

Temp_min<-Temp*1.02
Prec_min<-Prec*0.95

# 16) Temperature Annual Mean 

k<-1
TempList<-list()
########loop for starts#######
for (i in 1:20){
  
  Temp1<-mean(Temp_min[[k:(k+11)]])
  TempList[i]<-Temp1
  
  k<-k+12
}
########loop for ends#######

TempStack<-rast(TempList)
#TempStack<-TempStack*0.1 # rescale to °C

# 17) Annual Precipitation

k<-1
PrecList<-list()

########loop for starts#######
for (i in 1:20){
  
  Prec1<-sum(Prec_min[[k:(k+11)]])
  PrecList[i]<-Prec1
  
  k<-k+12
}
########loop for ends#######

PrecStack<-rast(PrecList)

# 18) Calculate eq 1 from MIAMI MODEL (g DM/m2/day)

NPP_Prec<-3000*(1-exp(-0.000664*PrecStack))

# 19) Calculate eq 2 from MIAMI MODEL (g DM/m2/day)

NPP_temp<-3000/(1+exp(1.315-0.119*TempStack))

# 20) Calculate eq 3 from MIAMI MODEL (g DM/m2/day)

NPP_MIAMI_List<-list()

########loop for starts#######
for (i in 1:20){
  NPP_MIAMI_List[i]<-min(NPP_Prec[[i]],NPP_temp[[i]])
}
########loop for ends#######

NPP_MIAMI<-rast(NPP_MIAMI_List)

# 21) NPP_MIAMI gDM/m2/year To tn DM/ha/year

NPP_MIAMI_tnDM_Ha_Year<-NPP_MIAMI*(1/100)

# 22) NPP_MIAMI tn DM/ha/year To tn C/ha/year

NPP_MIAMI_tnC_Ha_Year<-NPP_MIAMI_tnDM_Ha_Year*0.5

# 23) Save WORLD NPP MIAMI MODEL tnC/ha/year

terra::writeRaster(NPP_MIAMI_tnC_Ha_Year,filename="NPP_MIAMI_tnC_Ha_Year_STACK_81-00_MIN.tif",overwrite=TRUE)

# 24) NPP MEAN

NPP_MIAMI_MEAN_81_00<-mean(NPP_MIAMI_tnC_Ha_Year)

# 25) Crop & and mask

NPP_MIAMI_MEAN_81_00_AOI<-terra::crop(NPP_MIAMI_MEAN_81_00,AOI)
NPP_MIAMI_MEAN_81_00_AOI<-terra::resample(NPP_MIAMI_MEAN_81_00_AOI,SOC_MAP_AOI)
#NPP_MIAMI_MEAN_81_00_AOI<-mask(NPP_MIAMI_MEAN_81_00_AOI,AOI)

terra::writeRaster(NPP_MIAMI_MEAN_81_00_AOI,filename="NPP_MIAMI_MEAN_81-00_AOI_MIN.tif",overwrite=TRUE)
terra::writeRaster(NPP_MIAMI_MEAN_81_00,filename="NPP_MIAMI_MEAN_81-00_MIN.tif",overwrite=TRUE)

# 26) UNCERTAINTIES MAXIMUM TEMP , PREC

# Open Anual Precipitation (mm) and Mean Anual Temperature (grades C) stacks

Temp_max<-Temp*0.98
Prec_max<-Prec*1.05

# 27) Temperature Annual Mean 

k<-1
TempList<-list()

########loop for starts#######
for (i in 1:20){
  
  Temp1<-mean(Temp_max[[k:(k+11)]])
  TempList[i]<-Temp1
  
  k<-k+12
}
########loop for ends#######

TempStack<-rast(TempList)
#TempStack<-TempStack*0.1 # rescale to °C

# 28) Annual Precipitation

k<-1
PrecList<-list()

########loop for starts#######
for (i in 1:20){
  
  Prec1<-sum(Prec_max[[k:(k+11)]])
  PrecList[i]<-Prec1
  
  k<-k+12
}
########loop for ends#######

PrecStack<-rast(PrecList)

# 29) Calculate eq 1 from MIAMI MODEL (g DM/m2/day)

NPP_Prec<-3000*(1-exp(-0.000664*PrecStack))

# 30) Calculate eq 2 from MIAMI MODEL (g DM/m2/day)

NPP_temp<-3000/(1+exp(1.315-0.119*TempStack))

# 31) Calculate eq 3 from MIAMI MODEL (g DM/m2/day)

NPP_MIAMI_List<-list()

########loop for starts#######
for (i in 1:20){
  NPP_MIAMI_List[i]<-min(NPP_Prec[[i]],NPP_temp[[i]])
}

########loop for ends#######


NPP_MIAMI<-rast(NPP_MIAMI_List)

# 32) NPP_MIAMI gDM/m2/year To tn DM/ha/year

NPP_MIAMI_tnDM_Ha_Year<-NPP_MIAMI*(1/100)

# 33) NPP_MIAMI tn DM/ha/year To tn C/ha/year

NPP_MIAMI_tnC_Ha_Year<-NPP_MIAMI_tnDM_Ha_Year*0.5

# 34) Save NPP MIAMI MODEL tnC/ha/year

# setwd(WD_NPP)

terra::writeRaster(NPP_MIAMI_tnC_Ha_Year,filename="NPP_MIAMI_tnC_Ha_Year_STACK_81-00_MAX.tif",overwrite=TRUE)

# 35) NPP MEAN

NPP_MIAMI_MEAN_81_00<-mean(NPP_MIAMI_tnC_Ha_Year)

# Crop & and mask

#setwd(WD_NPP)


NPP_MIAMI_MEAN_81_00_AOI<-terra::crop(NPP_MIAMI_MEAN_81_00,AOI)
NPP_MIAMI_MEAN_81_00_AOI<-terra::resample(NPP_MIAMI_MEAN_81_00_AOI,SOC_MAP_AOI)
#NPP_MIAMI_MEAN_81_00_AOI<-mask(NPP_MIAMI_MEAN_81_00_AOI,AOI)

terra::writeRaster(NPP_MIAMI_MEAN_81_00_AOI,filename="NPP_MIAMI_MEAN_81-00_AOI_MAX.tif",overwrite=TRUE)
terra::writeRaster(NPP_MIAMI_MEAN_81_00,filename="NPP_MIAMI_MEAN_81-00_MAX.tif",overwrite=TRUE)





