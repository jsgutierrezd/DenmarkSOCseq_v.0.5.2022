#===============================================================
# Code 11a - Warm up stack V5
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


#### Prepare the layers for the WARM UP Roth C Model. 

# 1) Set the number of years of the warm up
nWUP<-18

# WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")
# 
# WD_SOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")
# 
# WD_CLAY<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/CLAY")
# 
# WD_CLIM<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/Terra_climate")
# 
# WD_LU<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/LAND_USE")
# 
# WD_COV<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/COV")
# 
# WD_STACK<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/STACK")
# 
# WD_NPP<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/NPP")


# 2) Open the shapefile of the region/country
AOI<-vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")
AOI <- project(AOI,"+proj=longlat +datum=WGS84 +no_defs")

# 3) Open SOC MAP 
SOC_MAP_AOI<-rast("SOC_MAP_AOI.tif")

# 4) Open Clay layers  (ISRIC)
Clay_WA_AOI<-rast("Clay_WA_AOI.tif")
Clay_WA_AOI_res<-resample(Clay_WA_AOI,SOC_MAP_AOI,method='bilinear') 


# 5) OPen Land Use layer (ESA)

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

# We need the layer from 2001 to 2018
LU_AOI<-rast("ESA_Land_Cover_13clases_FAO_AOI_00_20.tif")
names(LU_AOI)

# 6) Open Vegetation Cover layer 


Cov_AOI<-rast('Cov_stack_AOI.tif')

# 7) Open Land Use Stack , One Land use layer for each year (in this case we use the right layer for the 18 year period)
#LU_Stack <- rast(replicate(nWUP, LU_AOI))

LU_Stack <- LU_AOI[[2:19]]
names(LU_Stack)

# 8) Convert LU layer  to DR layer (ESA land use , 14 classes)

#DPM/RPM (decomplosable vs resistant plant material)
#(1) Most agricultural crops and improved grassland or tree crops 1.44 
#(2) Unimproved grassland and schrub 0.67
#(3) Deciduous and tropical woodland 0.25    


plot(DR_Stack)
DR_Stack<-LU_Stack

for (i in 1:nlyr(LU_Stack)){
  DR_Stack[[i]]<-(LU_Stack[[i]]==2 | LU_Stack[[i]]==12)*1.44+ (LU_Stack[[i]]==4)*0.25 + (LU_Stack[[i]]==3 | LU_Stack[[i]]==5 | LU_Stack[[i]]==6 | LU_Stack[[i]]==8)*0.67
}
plot(DR_Stack)
# 9) STACK all layers

Stack_Set_AOI<-c(SOC_MAP_AOI,Clay_WA_AOI_res,Cov_AOI,LU_Stack,DR_Stack)

terra::writeRaster(Stack_Set_AOI,filename=("Stack_Set_WARM_UP_AOI.tif"),overwrite=TRUE)

