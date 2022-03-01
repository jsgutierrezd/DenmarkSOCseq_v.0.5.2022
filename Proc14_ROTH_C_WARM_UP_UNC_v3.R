#===============================================================
# Code 14 - WARM UP
#===============================================================
rm(list = ls())

# 1) Set working directory
setwd("~/AARHUS_PhD/DSMactivities/1_SOCseq/DenmarkSOCseq_v.0.5.2022")

# 2) Load libraries

pckg <- c('terra',     
          'rgdal',
          'SoilR',
          'soilassessment'
)

usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
lapply(pckg,usePackage)


#Open empty vector

Vector<-vect("pointsFromQGIS.shp")

#Open Warm Up Stack

Stack_Set_warmup<- rast("Stack_Set_WARM_UP_AOI.tif")

# Open Result from SPIN UP PROCESS. A vector with 5 columns , one for each pool

Spin_up<-vect("SPIN_UP_AOI.shp")
Spin_up<-as.data.frame(Spin_up)

# Open Precipitation , temperature, and EVapotranspiration file 20 anios x 12 = 240 layers x 3

# CRU LAYERS
#PREC<-stack("INPUTS/CRU_LAYERS/Prec_Stack_216_01-18_CRU.tif")
#TEMP<-stack("INPUTS/CRU_LAYERS/Temp_Stack_216_01-18_CRU.tif")
#PET<-stack("INPUTS/CRU_LAYERS/PET_Stack_216_01-18_CRU.tif")

# TERRA CLIMATE LAYERS . Check the units of temperature and PET.
PREC<-rast("Prec_Stack_01-18_TC.tif")
TEMP<-rast("Temp_Stack_01-18_TC.tif")#*0.1
PET<-rast("PET_Stack_01-18_TC.tif")#*0.1

#Also check that the number of layers of DR and Land use are the same as the years of climate data. 


#Open Mean NPP MIAMI 1981 - 2000

NPP<-rast("NPP_MIAMI_MEAN_81-00_AOI.tif")
NPP <- projectRaster(NPP,crs = CRS("+proj=longlat +datum=WGS84 +no_defs"))

NPP_MEAN_MIN<-raster("NPP_MIAMI_MEAN_81-00_AOI_MIN.tif")
NPP_MEAN_MIN <- projectRaster(NPP_MEAN_MIN,crs = CRS("+proj=longlat +datum=WGS84 +no_defs"))
NPP_MEAN_MIN <- resample(NPP_MEAN_MIN,NPP)

NPP_MEAN_MAX<-raster("NPP_MIAMI_MEAN_81-00_AOI_MAX.tif")
NPP_MEAN_MAX <- projectRaster(NPP_MEAN_MAX,crs = CRS("+proj=longlat +datum=WGS84 +no_defs"))
NPP_MEAN_MAX <- resample(NPP_MEAN_MAX,NPP)

#Open LU layer (year 2000).

LU_AOI<-raster("ESA_Land_Cover_13clases_FAO_AOI_00.tif")
LU_AOI <- resample(LU_AOI,NPP)


#Apply NPP coeficientes

NPP_MEAN_MIN<-(LU_AOI==2 | LU_AOI==12)*NPP_MEAN_MIN*0.53+ (LU_AOI==4)*NPP_MEAN_MIN*0.88 + (LU_AOI==3 | LU_AOI==5 | LU_AOI==6 | LU_AOI==8)*NPP_MEAN_MIN*0.72
NPP_MEAN_MAX<-(LU_AOI==2 | LU_AOI==12)*NPP_MEAN_MAX*0.53+ (LU_AOI==4)*NPP_MEAN_MAX*0.88 + (LU_AOI==3 | LU_AOI==5 | LU_AOI==6 | LU_AOI==8)*NPP_MEAN_MAX*0.72

# NPPt forests = NPPMIAMI x 0.88 (13)
# NPPt grasslands = NPPMIAMI x 0.72 (14)
# NPPt croplands = NPPMIAMI x 0.53 (15)

# CodeBasemap03	NameBasemap03	                                              NewCode	  NewName
# 110000	      Building	                                                  1	        Artificial
# 121000	      Low built up	                                              1	        Artificial
# 121110	      Low built up; Building	                                    1	        Artificial
# 122000	      High built up	                                              1	        Artificial
# 122110	      High built up; Building	                                    1	        Artificial
# 123000	      City centre	                                                1	        Artificial
# 123110	      City centre; Building	                                      1	        Artificial
# 124000	      Other built up	                                            1	        Artificial
# 124110	      Other built up; Building	                                  1	        Artificial
# 125000	      Industry/business	                                          1	        Artificial
# 125110	      Industry/business; Building	                                1	        Artificial
# 126000	      Airport/runway	                                            1	        Artificial
# 126110	      Airport/runway;Building	                                    1	        Artificial
# 130000	      Recreation area/sports ground	                              1	        Artificial
# 130110	      Recreation area/sports ground; Building	                    1	        Artificial
# 141000	      Road, paved	                                                1	        Artificial
# 142000	      Road, not paved	                                            1	        Artificial
# 150000	      Railway	                                                    1	        Artificial
# 150110	      Railway; Building	                                          1	        Artificial
# 160000	      Resource extraction	                                        1	        Artificial
# 211000	      Agriculture, intensive, temporary crops	                    2	        Crop
# 212000	      Agriculture, intensive, permanent crops	                    2	        Crop
# 220000	      Agriculture, extensive	                                    3	        Grassland
# 230000	      Agriculture, not classified	                                7	        Spare
# 311000	      Forest	                                                    4	        Forest
# 312000	      Forest, wet	                                                4	        Forest
# 321000	      Nature, dry	                                                5	        Shrub
# 321220	      Nature, dry; Agriculture, extensive	                        5	        Shrub
# 322000	      Nature, wet	                                                6	        Nature wet
# 322220	      Nature, wet; Agriculture, extensive	                        6	        Nature wet
# 411000	      Lake	                                                      8	        Water
# 412000	      Stream	                                                    8	        Water
# 420000	      Sea	                                                        8	        Water
# 800000	      Unmapped	                                                  NA	      NA

# Extract variables to points

Vector_points<-extract(Stack_Set_warmup,Vector,sp=TRUE)
Vector_points<-extract(TEMP,Vector_points,sp=TRUE)
Vector_points<-extract(PREC,Vector_points,sp=TRUE)
Vector_points<-extract(PET,Vector_points,sp=TRUE)
Vector_points<-extract(NPP,Vector_points,sp=TRUE)
Vector_points<-extract(NPP_MEAN_MIN,Vector_points,sp=TRUE)
Vector_points<-extract(NPP_MEAN_MAX,Vector_points,sp=TRUE)

WARM_UP<-Vector

#use only for backup

#WARM_UP<-readOGR("WARM_UP_AOI.shp")

# Warm Up number of years simulation: 18

yearsSimulation<-dim(TEMP)[3]/12

clim_layers<-yearsSimulation*12

nppBand<-nlayers(Stack_Set_warmup)+clim_layers*3+2

firstClimLayer<-nlayers(Stack_Set_warmup)+2

nppBand_min<-nppBand+1

nppBand_max<-nppBand+2

nDR_beg<-(16+yearsSimulation)
nDR_end<-nDR_beg+(yearsSimulation-1)

# Extract the layers from the Vector

SOC_im<-Vector_points[[2]] 

clay_im<-Vector_points[[3]] 

LU_im<-Vector_points[[16]]

NPP_im<-Vector_points[[nppBand]]

NPP_im_MIN<-Vector_points[[nppBand_min]]

NPP_im_MAX<-Vector_points[[nppBand_max]]

# Define Years

years=seq(1/12,1,by=1/12)


# ROTH C MODEL FUNCTION . 

###########function set up starts################
Roth_C<-function(Cinputs,years,DPMptf, RPMptf, BIOptf, HUMptf, FallIOM,Temp,Precip,Evp,Cov,Cov1,Cov2,soil.thick,SOC,clay,DR,bare1,LU)
  
{
  
  # Paddy fields coefficent fPR = 0.4 if the target point is class = 13 , else fPR=1
  # From Shirato and Yukozawa 2004
  
  fPR=(LU == 13)*0.4 + (LU!=13)*1
  
  #Temperature effects per month
  fT=fT.RothC(Temp[,2]) 
  
  #Moisture effects per month . Si se usa evapotranspiracion pE=1
  
  fw1func<-function(P, E, S.Thick = 30, pClay = 32.0213, pE = 1, bare) 
  {
    
    M = P - E * pE
    Acc.TSMD = NULL
    for (i in 2:length(M)) {
      B = ifelse(bare[i] == FALSE, 1, 1.8)
      Max.TSMD = -(20 + 1.3 * pClay - 0.01 * (pClay^2)) * (S.Thick/23) * (1/B)
      Acc.TSMD[1] = ifelse(M[1] > 0, 0, M[1])
      if (Acc.TSMD[i - 1] + M[i] < 0) {
        Acc.TSMD[i] = Acc.TSMD[i - 1] + M[i]
      }
      else (Acc.TSMD[i] = 0)
      if (Acc.TSMD[i] <= Max.TSMD) {
        Acc.TSMD[i] = Max.TSMD
      }
    }
    b = ifelse(Acc.TSMD > 0.444 * Max.TSMD, 1, (0.2 + 0.8 * ((Max.TSMD - 
                                                                Acc.TSMD)/(Max.TSMD - 0.444 * Max.TSMD))))
    b<-clamp(b,lower=0.2)
    return(data.frame(b))
  }
  
  
  fW_2<- fw1func(P=(Precip[,2]), E=(Evp[,2]), S.Thick = soil.thick, pClay = clay, pE = 1, bare=bare1)$b 
  
  #Vegetation Cover effects  C1: No till Agriculture, C2: Conventional Agriculture, C3: Grasslands and Forests, C4 bareland and Urban
  
  fC<-Cov2[,2]
  
  # Set the factors frame for Model calculations
  
  xi.frame=data.frame(years,rep(fT*fW_2*fC*fPR,length.out=length(years)))
  
  # RUN THE MODEL from SoilR
  #Loads the model Si pass=TRUE genera calcula el modelo aunque sea invalido. 
  #Model3_spin=RothCModel(t=years,C0=c(DPMptf, RPMptf, BIOptf, HUMptf, FallIOM),In=Cinputs,DR=DR,clay=clay,xi=xi.frame, pass=TRUE) 
  #Calculates stocks for each pool per month
  #Ct3_spin=getC(Model3_spin)
  
  # RUN THE MODEL from soilassesment
  
  Model3_spin=carbonTurnover(tt=years,C0=c(DPMptf, RPMptf, BIOptf, HUMptf, FallIOM),In=Cinputs,Dr=DR,clay=clay,effcts=xi.frame, "euler") 
  
  Ct3_spin=Model3_spin[,2:6]
  
  # Get the final pools of the time series
  
  poolSize3_spin=as.numeric(tail(Ct3_spin,1))
  
  return(poolSize3_spin)
  
}
##############funtion set up ends##########

# Iterates over the area of interest and over 18 years 

Cinputs<-c()
Cinputs_min<-c()
Cinputs_max<-c()
NPP_M_MIN<-c()
NPP_M_MAX<-c()
NPP_M<-c()

############for loop starts################
for (i in 1:(length(Vector_points))) {
  
  gt<-firstClimLayer
  gp<-gt+clim_layers
  gevp<-gp+clim_layers
  
  for (w in 1:(dim(TEMP)[3]/12)) {
    
    print(c("year:",w))
    # Extract the variables 
    
    Vect<-as.data.frame(Vector_points[i,])
    
    Temp<-as.data.frame(t(Vect[gt:(gt+11)]))
    Temp<-data.frame(Month=1:12, Temp=Temp[,1])
    
    Precip<-as.data.frame(t(Vect[gp:(gp+11)]))
    Precip<-data.frame(Month=1:12, Precip=Precip[,1])
    
    Evp<-as.data.frame(t(Vect[gevp:(gevp+11)]))
    Evp<-data.frame(Month=1:12, Evp=Evp[,1])
    
    Cov<-as.data.frame(t(Vect[4:15]))
    Cov1<-data.frame(Cov=Cov[,1])
    Cov2<-data.frame(Month=1:12, Cov=Cov[,1])
    
    DR_im<-as.data.frame(t(Vect[nDR_beg:nDR_end])) # DR one per year according to LU
    DR_im<-data.frame(DR_im=DR_im[,1])
    
    gt<-gt+12
    gp<-gp+12
    gevp<-gevp+12
    
    #Avoid calculus over Na values 
    
    if (any(is.na(Evp[,2])) | any(is.na(Temp[,2])) | any(is.na(SOC_im[i])) | any(is.na(clay_im[i])) | any(is.na(Spin_up[i,3]))  | any(is.na(NPP_im[i])) | any(is.na(Precip[,2]))  |  any(is.na(Cov2[,2]))  |  any(is.na(Cov1[,1]))  | any(is.na(DR_im[,1]))    |  (SOC_im[i]<0) | (clay_im[i]<0) | (Spin_up[i,3]<=0) ) {WARM_UP[i,2]<-0}else{
      
      # Get the variables from the vector
      
      soil.thick=30  #Soil thickness (organic layer topsoil), in cm
      SOC<-SOC_im[i]      #Soil organic carbon in Mg/ha 
      clay<-clay_im[i]        #Percent clay %
      
      DR<-DR_im[w,1]              # DPM/RPM (decomplosable vs resistant plant material.)
      bare1<-(Cov1>0.8)           # If the surface is bare or vegetated
      NPP_81_00<-NPP_im[i]
      NPP_81_00_MIN<-NPP_im_MIN[i]
      NPP_81_00_MAX<-NPP_im_MAX[i]
      
      # PHASE 2  : WARM UP .  years (w)
      
      # Cinputs 
      T<-mean(Temp[,2])
      P<-sum(Precip[,2])
      NPP_M[w]<-NPPmodel(P,T,"miami")*(1/100)*0.5
      NPP_M[w]<-(LU_im[i]==2 | LU_im[i]==12 | LU_im[i]==13)*NPP_M[w]*0.53+ (LU_im[i]==4)*NPP_M[w]*0.88 + (LU_im[i]==3 | LU_im[i]==5 | LU_im[i]==6 | LU_im[i]==8)*NPP_M[w]*0.72
      
      if (w==1) {Cinputs[w]<-(Spin_up[i,3]/NPP_81_00)*NPP_M[w]} else {Cinputs[w]<-(Cinputs[[w-1]]/ NPP_M[w-1]) * NPP_M[w]} 
      
      # Cinputs MIN
      
      Tmin<-mean(Temp[,2]*1.02)
      Pmin<-sum(Precip[,2]*0.95)
      NPP_M_MIN[w]<-NPPmodel(Pmin,Tmin,"miami")*(1/100)*0.5
      NPP_M_MIN[w]<-(LU_im[i]==2 | LU_im[i]==12 | LU_im[i]==13)*NPP_M_MIN[w]*0.53+ (LU_im[i]==4)*NPP_M_MIN[w]*0.88 + (LU_im[i]==3 | LU_im[i]==5 | LU_im[i]==6 | LU_im[i]==8)*NPP_M_MIN[w]*0.72
      
      if (w==1) {Cinputs_min[w]<-(Spin_up[i,10]/NPP_81_00)*NPP_M_MIN[w]} else {Cinputs_min[w]<-(Cinputs_min[[w-1]]/ NPP_M_MIN[w-1]) * NPP_M_MIN[w]} 
      
      # Cinputs MAX
      
      Tmax<-mean(Temp[,2]*0.98)
      Pmax<-sum(Precip[,2]*1.05)
      NPP_M_MAX[w]<-NPPmodel(Pmax,Tmax,"miami")*(1/100)*0.5
      NPP_M_MAX[w]<-(LU_im[i]==2 | LU_im[i]==12 | LU_im[i]==13)*NPP_M_MAX[w]*0.53+ (LU_im[i]==4)*NPP_M_MAX[w]*0.88 + (LU_im[i]==3 | LU_im[i]==5 | LU_im[i]==6 | LU_im[i]==8)*NPP_M_MAX[w]*0.72
      
      if (w==1) {Cinputs_max[w]<-(Spin_up[i,11]/NPP_81_00)*NPP_M_MAX[w]} else {Cinputs_max[w]<-(Cinputs_max[[w-1]]/ NPP_M_MAX[w-1]) * NPP_M_MAX[w]} 
      
      # Run the model for 2001-2018 
      
      if (w==1) {
        f_wp<-Roth_C(Cinputs=Cinputs[1],years=years,DPMptf=Spin_up[i,5], RPMptf=Spin_up[i,6], BIOptf=Spin_up[i,7], HUMptf=Spin_up[i,8], FallIOM=Spin_up[i,9],Temp=Temp,Precip=Precip,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC,clay=clay,DR=DR,bare1=bare1,LU=LU_im[i])
      } else {
        f_wp<-Roth_C(Cinputs=Cinputs[w],years=years,DPMptf=f_wp[1], RPMptf=f_wp[2], BIOptf=f_wp[3], HUMptf=f_wp[4], FallIOM=f_wp[5],Temp=Temp,Precip=Precip,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC,clay=clay,DR=DR,bare1=bare1,LU=LU_im[i])
      }
      
      f_wp_t<-f_wp[1]+f_wp[2]+f_wp[3]+f_wp[4]+f_wp[5]
      
      # Run the model for minimum values
      
      if (w==1) {
        f_wp_min<-Roth_C(Cinputs=Cinputs_min[1],years=years,DPMptf=Spin_up[i,13], RPMptf=Spin_up[i,14], BIOptf=Spin_up[i,15], HUMptf=Spin_up[i,16], FallIOM=Spin_up[i,17],Temp=Temp*1.02,Precip=Precip*0.95,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC*0.8,clay=clay*0.9,DR=DR,bare1=bare1,LU=LU_im[i])
      } else {
        f_wp_min<-Roth_C(Cinputs=Cinputs_min[w],years=years,DPMptf=f_wp_min[1], RPMptf=f_wp_min[2], BIOptf=f_wp_min[3], HUMptf=f_wp_min[4], FallIOM=f_wp_min[5],Temp=Temp*1.02,Precip=Precip*0.95,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC*0.8,clay=clay*0.9,DR=DR,bare1=bare1,LU=LU_im[i])
      }
      
      f_wp_t_min<-f_wp_min[1]+f_wp_min[2]+f_wp_min[3]+f_wp_min[4]+f_wp_min[5]
      
      # Run the model for maximum values
      
      if (w==1) {
        f_wp_max<-Roth_C(Cinputs=Cinputs_max[1],years=years,DPMptf=Spin_up[i,19], RPMptf=Spin_up[i,20], BIOptf=Spin_up[i,21], HUMptf=Spin_up[i,22], FallIOM=Spin_up[i,23],Temp=Temp*0.98,Precip=Precip*1.05,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC*1.2,clay=clay*1.1,DR=DR,bare1=bare1,LU=LU_im[i])
      } else {
        f_wp_max<-Roth_C(Cinputs=Cinputs_max[w],years=years,DPMptf=f_wp_max[1], RPMptf=f_wp_max[2], BIOptf=f_wp_max[3], HUMptf=f_wp_max[4], FallIOM=f_wp_max[5],Temp=Temp*0.98,Precip=Precip*1.05,Evp=Evp,Cov=Cov,Cov1=Cov1,Cov2=Cov2,soil.thick=soil.thick,SOC=SOC*1.2,clay=clay*1.1,DR=DR,bare1=bare1,LU=LU_im[i])
      }
      
      f_wp_t_max<-f_wp_max[1]+f_wp_max[2]+f_wp_max[3]+f_wp_max[4]+f_wp_max[5]
      
      print(w)
      #print(c(i,SOC,Spin_up[i,3],NPP_81_00,Cinputs[w],f_wp_t))
      print(c(NPP_M[w],Cinputs[w]))
    }
  }
  if (is.na(mean(Cinputs))){ CinputFOWARD<-NA} else { 
    
    CinputFOWARD<-mean(Cinputs)
    
    CinputFOWARD_min<-mean(Cinputs_min)
    
    CinputFOWARD_max<-mean(Cinputs_max)
    
    WARM_UP[i,2]<-SOC
    WARM_UP[i,3]<-Cinputs[18]
    WARM_UP[i,4]<-f_wp_t
    WARM_UP[i,5]<-f_wp[1]
    WARM_UP[i,6]<-f_wp[2]
    WARM_UP[i,7]<-f_wp[3]
    WARM_UP[i,8]<-f_wp[4]
    WARM_UP[i,9]<-f_wp[5]
    WARM_UP[i,10]<-CinputFOWARD
    WARM_UP[i,11]<-f_wp_t_min
    WARM_UP[i,12]<-f_wp_min[1]
    WARM_UP[i,13]<-f_wp_min[2]
    WARM_UP[i,14]<-f_wp_min[3]
    WARM_UP[i,15]<-f_wp_min[4]
    WARM_UP[i,16]<-f_wp_min[5]
    WARM_UP[i,17]<-f_wp_t_max
    WARM_UP[i,18]<-f_wp_max[1]
    WARM_UP[i,19]<-f_wp_max[2]
    WARM_UP[i,20]<-f_wp_max[3]
    WARM_UP[i,21]<-f_wp_max[4]
    WARM_UP[i,22]<-f_wp_max[5]
    WARM_UP[i,23]<-CinputFOWARD_min
    WARM_UP[i,24]<-CinputFOWARD_max
    
    Cinputs<-c()
    Cinputs_min<-c()
    Cinputs_max<-c()
  }
  print(i)
}

################for loop ends#############

colnames(WARM_UP@data)[2]="SOC_FAO"
colnames(WARM_UP@data)[3]="Cin_t0"
colnames(WARM_UP@data)[4]="SOC_t0"
colnames(WARM_UP@data)[5]="DPM_w_up"
colnames(WARM_UP@data)[6]="RPM_w_up"
colnames(WARM_UP@data)[7]="BIO_w_up"
colnames(WARM_UP@data)[8]="HUM_w_up"
colnames(WARM_UP@data)[9]="IOM_w_up"
colnames(WARM_UP@data)[10]="Cin_mean"
colnames(WARM_UP@data)[11]="SOC_t0min"
colnames(WARM_UP@data)[12]="DPM_w_min"
colnames(WARM_UP@data)[13]="RPM_w_min"
colnames(WARM_UP@data)[14]="BIO_w_min"
colnames(WARM_UP@data)[15]="HUM_w_min"
colnames(WARM_UP@data)[16]="IOM_w_min"
colnames(WARM_UP@data)[17]="SOC_t0max"
colnames(WARM_UP@data)[18]="DPM_w_max"
colnames(WARM_UP@data)[19]="RPM_w_max"
colnames(WARM_UP@data)[20]="BIO_w_max"
colnames(WARM_UP@data)[21]="HUM_w_max"
colnames(WARM_UP@data)[22]="IOM_w_max"
colnames(WARM_UP@data)[23]="Cin_min"
colnames(WARM_UP@data)[24]="Cin_max"


# SAVE the Points (shapefile)
#setwd("C:/TRAINING_MATERIALS_GSOCseq_MAPS_12-11-2020/OUTPUTS/2_WARM_UP")
writeOGR(WARM_UP,".", "WARM_UP_AOI", driver="ESRI Shapefile",overwrite=TRUE)




