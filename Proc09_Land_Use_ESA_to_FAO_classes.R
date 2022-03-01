#===============================================================
# Code 9a - Land use layer
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


# WD_AOI<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/AOI_POLYGON")
# 
# WD_LU<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/LAND_USE")
# 
# WD_SOC<-("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/INPUTS/SOC_MAP")

# 3) Open the shapefile of the region/country
AOI<-vect("C:\\Users\\au704633\\OneDrive - Aarhus Universitet\\Documents\\AARHUS_PhD\\DSMactivities\\1_SOCseq\\INPUTS\\SHP\\LIMIT\\LIMIT.shp")
AOI <- project(AOI,"+proj=longlat +datum=WGS84 +no_defs")


# 4) Open Land Use layers 2000-2020 


# LAND USE 2000 -----------------------------------------------------------

ESA_LU <- terra::rast("ESA_CCI_00_20.tif")
names(ESA_LU) <- readRDS("NamesESA_CCI_00_20.rds")
ESA_LU <- terra::project(ESA_LU,"+proj=longlat +datum=WGS84 +no_defs")
#plot(ESA_LU)

# 5) Cut the LU layer by the country polygon
ESA_LU_AOI<-terra::crop(ESA_LU,AOI,mask=T,snap="near")
plot(ESA_LU_AOI[[1]])

# 6) Reclassify Land use map to the needed classes for the RothC model
#


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


# 7) Create a reclassification matrix. "Is" to "become"

is<-c(10,
      11,
      12,
      20,
      30,
      40,
      50,
      60,
      61,
      62,
      70,
      71,
      72,
      80,
      81,
      82,
      90,
      100,
      110,
      120,
      121,
      122,
      130,
      140,
      150,
      151,
      152,
      153,
      160,
      170,
      180,
      190,
      200,
      201,
      202,
      210)
      

become<-c(2,
          2,
          12,
          13,
          2,
          2,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          4,
          5,
          5,
          5,
          3,
          0,
          8,
          8,
          8,
          8,
          6,
          7,
          6,
          1,
          9,
          9,
          9,
          11
  
)

recMat<-matrix(c(is,become),ncol=2,nrow=36)


# 8) Reclassify

ESA_FAO <- terra::classify(ESA_LU_AOI, recMat)

# 9) Resample to SOC map layer extent and resolution
SOC_MAP_AOI<-rast("SOC_MAP_AOI.tif")
#SOC_MAP_AOI <- projectRaster(SOC_MAP_AOI, crs = "+proj=longlat +datum=WGS84 +no_defs")

ESA_FAO_res<-terra::resample(ESA_FAO,SOC_MAP_AOI,method='near') 
ESA_FAO_mask<-terra::crop(ESA_FAO_res,SOC_MAP_AOI,mask=T,snap="near") 

# 10) Save Land Use raster
#setwd(WD_LU)
terra::writeRaster(ESA_FAO_mask,filename="ESA_Land_Cover_13clases_FAO_AOI_00_20.tif",overwrite=TRUE)
plot(ESA_FAO_mask[[8]])


