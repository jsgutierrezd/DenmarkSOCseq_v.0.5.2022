#===============================================================
# Code 12 - FORWARD stack
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

# 3) Open the shapefile of the region/country
AOI<-vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")
AOI <-project(AOI,"+proj=longlat +datum=WGS84 +no_defs")

# 4) Open SOC MAP 
SOC_MAP_AOI<-rast("SOC_MAP_AOI.tif")

# 5) Open Clay layers  (ISRIC)
Clay_WA_AOI<-rast("Clay_WA_AOI.tif")
plot(Clay_WA_AOI)
Clay_WA_AOI_res<-resample(Clay_WA_AOI,SOC_MAP_AOI,method='bilinear')  

# 6) Open Precipitation layer 
PREC<-rast("Prec_Stack_01-18_TC.tif")

PREC_AOI<-terra::crop(PREC,AOI,mask=T,snap="near")
PREC_AOI<-terra::resample(PREC_AOI,SOC_MAP_AOI,method='bilinear')


# 7) Open Temperatures layer 

TEMP<-rast("Temp_Stack_01-18_TC.tif")

TEMP_AOI<-terra::crop(TEMP,AOI,mask=T,snap="near")
TEMP_AOI<-terra::resample(TEMP_AOI,SOC_MAP_AOI,method='bilinear')


# 8) Open Potential Evapotranspiration layer 

PET<-rast("PET_Stack_01-18_TC.tif")

PET_AOI<-terra::crop(PET,AOI,mask=T,snap="near")
PET_AOI<-terra::resample(PET_AOI,SOC_MAP_AOI,method='bilinear')


# 10) OPen Land Use layer (ESA)

# Code        	NameMap	                                                                                NewCode	  NewName
#   10...........Cropland,rainfed........................................................................2.........Croplands
#   11...........Cropland, rainfed, herbaceous cover.....................................................2.........Croplands
#   12...........Cropland, rainfed, tree or shrub cover..................................................12........Tree crops
#   20...........Cropland, irrigated or postflooding ....................................................13........Flooded crops
#   30...........Mosaic cropland (>50%)/natural vegetation (tree, shrub,herbaceous cover) (<50%) ........2.........Croplands
#   40...........Mosaic natural vegetation (tree, shrub, herbaceous cover) (>50%) / cropland (<50%) .....2.........Croplands
#   50...........Tree cover, broadleaved, evergreen, closed to open (>15%)...............................4.........Tree covered
#   60...........Tree cover, broadleaved, deciduous, closed to open (>15%) ..............................4.........Tree covered
#   61...........Tree cover, broadleaved, deciduous, closed (>40%) ......................................4.........Tree covered
#   62...........Tree cover, broadleaved, deciduous, open (15-40%) ......................................4.........Tree covered
#   70...........Tree cover, needleleaved, evergreen, closed to open (>15%)..............................4.........Tree covered
#   71...........Tree cover, needleleaved, evergreen, closed (>40%) .....................................4.........Tree covered
#   72...........Tree cover, needleleaved, evergreen, open (15-40%) .....................................4.........Tree covered
#   80...........Tree cover, needleleaved, deciduous, closed to open (>15%)..............................4.........Tree covered
#   81...........Tree cover, needleleaved, deciduous, closed (>40%) .....................................4.........Tree covered
#   82...........Tree cover, needleleaved, deciduous, open (15-40%) .....................................4.........Tree covered
#   90...........Tree cover, mixed leaf type (broadleaved and needleleaved) .............................4.........Tree covered
#   100..........Mosaic tree and shrub (>50%) / herbaceous cover (<50%) .................................4.........Tree covered
#   110..........Mosaic herbaceous cover (>50%) / tree and shrub (<50%) .................................4.........Tree covered
#   120..........Shrubland ..............................................................................5.........Shrubland
#   121..........Evergreen shrubland.....................................................................5.........Shrubland
#   122..........Deciduous shrubland ....................................................................5.........Shrubland
#   130..........Grassland ..............................................................................3.........Grassland
#   140..........Lichens and mosses .....................................................................0.........No data
#   150..........Sparse vegetation (tree, shrub, herbaceous cover) (<15%) ...............................8.........Sparse vegetation
#   151..........Sparse tree (<15%) .....................................................................8.........Sparse vegetation
#   152..........Sparse shrub (<15%).....................................................................8.........Sparse vegetation
#   153..........Sparse herbaceous cover (<15%)..........................................................8.........Sparse vegetation
#   160..........Tree cover, flooded, fresh or brakish water.............................................6.........Herbaceous vegetation flooded
#   170..........Tree cover, flooded, saline water.......................................................7.........Mangroves
#   180..........Shrub or herbaceous cover, flooded, fresh/saline/brakish water..........................6.........Herbaceous vegetation flooded
#   190..........Urban areas ............................................................................1.........Artificial
#   200..........Bare areas .............................................................................9.........Bare soil
#   201..........Consolidated bare areas.................................................................9.........Bare soil
#   202..........Unconsolidated bare areas...............................................................9.........Bare soil
#   210..........Water bodies............................................................................11........Water

LU_AOI<-rast("ESA_Land_Cover_13clases_FAO_AOI_00_20.tif")
names(LU_AOI)
LU_AOI <- LU_AOI[["ESA_CCI_2018"]]

# 11) Open Vegetation Cover 


Cov_AOI<-rast('Cov_stack_AOI.tif')

# Open Land use layer and convert it to DR layer (mod 12 , 14 classes)

#DPM/RPM (decomplosable vs resistant plant material...como se divide los C inputs)
#(1) Most agricultural crops and improved grassland or tree crops 1.44 
#(2) Unimproved grassland and schrub 0.67
#(3) Deciduous and tropical woodland 0.25    

DR<-(LU_AOI==2 | LU_AOI==12)*1.44+ (LU_AOI==4)*0.25 + (LU_AOI==3 | LU_AOI==5 | LU_AOI==6| LU_AOI==8)*0.67
plot(DR)

# STACK all layers

Stack_Set_AR<-c(SOC_MAP_AOI,Clay_WA_AOI_res,TEMP_AOI,PREC_AOI,PET_AOI,DR,LU_AOI,Cov_AOI)

terra::writeRaster(Stack_Set_AR,filename=("Stack_Set_FOWARD.tif"),overwrite=TRUE)


