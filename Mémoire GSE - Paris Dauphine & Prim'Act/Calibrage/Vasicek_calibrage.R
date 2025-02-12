# proc�dure de calibrage du mod�le Vasicek

# d�finition de l'environnement
chemin = "C:/Users/mengr/OneDrive/Documents/Universit�/Master 1_Semestre 1_2021-2022/M�moire de M1/M�moire GSE - Paris Dauphine & Prim'Act"
chemin_fct = paste(chemin,"/Fonction", sep="")
setwd(chemin)

# librairie utile
library(readxl)
library(dfoptim)

# importation fonctions utiles du Vasicek
source(paste(chemin_fct,"\\Vasicek_fonction.R",sep=""))

# importation donn�es utiles pour le calibrage
sheetDGlo <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 1)
sheetCali <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 3)

Maturite <- as.numeric(sheetDGlo$`Courbe des taux ZC`[7:156])
TauxZC <- as.numeric(sheetDGlo$...2[7:156])

### CALIBRAGE ####################################################
param_init = c(0.005,0.005,0.005)
LB = c(0,0,1e-3)
UB = c(1,1,1)
(paramVas = hjkb(param_init,ecart_Vas,lower=LB,upper=UB)$par)
ecart_Vas(paramVas)
