# proc�dure de calibrage du mod�le Hull&White

# d�finition de l'environnement
chemin = "C:/Users/mengr/OneDrive/Documents/Universit�/Master 1_Semestre 1_2021-2022/M�moire de M1/M�moire GSE - Paris Dauphine & Prim'Act"
chemin_fct = paste(chemin,"/Fonction", sep="")
setwd(chemin)

# librairie utile
library(readxl)
library(dfoptim)

# importation fonctions utiles du Hull&White
source(paste(chemin_fct,"\\HW_fonction.R",sep=""))

# importation donn�es utiles pour le calibrage
sheetDGlo <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 1)
sheetCali <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 3)

Maturite <- as.numeric(sheetDGlo$`Courbe des taux ZC`[7:156])
TauxZC <- as.numeric(sheetDGlo$...2[7:156])
PrixZC <- exp(-Maturite*TauxZC)
PrixCaps <- as.numeric(sheetCali$...5[3:22])

### PREPARATION FONCTION INTERPOLATION ###############################
PZC_fct <- splinefun(x = Maturite, y = PrixZC, method = "natural")
logPZC_fct <- splinefun(x = Maturite, y = log(PrixZC), method = "natural")
TfI <- -logPZC_fct(Maturite, deriv=1)
TfI_fct <- splinefun(x = Maturite, y = TfI, method = "natural")

dTfI <- TfI_fct(Maturite, deriv=1)
dTfI_fct <- splinefun(x = Maturite, y = dTfI, method = "natural")

### CALIBRATION #########################################################
(K_ATM = (PrixZC[5]-PrixZC[24])/sum(PrixZC[5:24]))

param_init <- c(0.5,0.5)
LB = c(1e-16,1e-16)
UB = c(1,1)

(paramHW <- hjkb(param_init,ecart_HW_cap,lower=LB,upper=UB)$par)

ecart_HW_cap(paramHW) # 1.687805e-05
ecart_HW_TZC(paramHW) # 3.201471e-10
