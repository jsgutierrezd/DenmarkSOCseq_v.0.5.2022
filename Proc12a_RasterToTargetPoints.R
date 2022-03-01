
#===============================================================
# Code bonus - Raster to target points
#===============================================================
rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('raster',     
          'rgdal',
          'sp'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)

LU<-stack("ESA_Land_Cover_13clases_FAO_AOI_00_20.tif")
names(LU)
LU <- LU[["ESA_CCI_2018"]]
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


points<-rasterToPoints(LU,fun=function(x){x==2|x==3|x==5|x==12},sp=TRUE)

writeOGR(points, ".", "pointsFromR", driver="ESRI Shapefile",overwrite=TRUE) 
