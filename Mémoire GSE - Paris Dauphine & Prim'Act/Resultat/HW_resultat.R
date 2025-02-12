rm(list = ls())
library(readxl)
library(dfoptim)
chemin = "C:/Users/mengr/OneDrive/Documents/Universit�/Master 1_Semestre 1_2021-2022/M�moire de M1/M�moire GSE - Paris Dauphine & Prim'Act"
chemin_fct = paste(chemin,"/Fonction", sep="")
chemin_cal = paste(chemin,"/Calibrage", sep="")
setwd(chemin)

### Importation des donnees ###################################################
source(paste(chemin_fct,"\\HW_fonction.R",sep=""))
source(paste(chemin_cal,"\\HW_calibrage.R",sep=""))

sheetDGlo <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 1)
sheetCali <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 3)

Maturite <- as.numeric(sheetDGlo$`Courbe des taux ZC`[7:156])
TauxZC <- as.numeric(sheetDGlo$...2[7:156])
Maturite10 <- Maturite[1:10]
Maturite15 <- Maturite[1:15]
Maturite30 <- Maturite[1:30]
Maturite50 <- Maturite[1:50]

N = 1000

### Plot du HW ###################################################
# test pour le PZC
plot(PZC_HW_sim(N=1,0,Maturite,paramHW),type="l",lwd=2,
     main = 'V�rification avec le prix z�ro-coupon', 
     xlab = 'Maturit�', ylab = 'Prix z�ro-coupon')
lines(PrixZC,col="red",lty=3,lwd=2)
# pour t=0, PZC est ferm�e, il suffit de faire "1" simulation
legend("topright",legend=c("PZC donn�e (input)","PZC du mod�le HW"),
       col=c("red","black"),pch=20,
       cex=0.6)

# test pour le TZC
plot(TZC_HW_sim(N=1,0,Maturite,paramHW),type="l",lwd=2,
     main = 'V�rification avec le taux z�ro-coupon', 
     xlab = 'Maturit�', ylab = 'Taux ZC')
lines(TauxZC,col="red",lty=3,lwd=2)
legend("bottomright",legend=c("TZC donn�e (input)","TZC du mod�le HW"),
       col=c("red","black"),pch=20,
       cex=0.6)

# simulation PZC dans 1 an pour diff�rentes maturit�s
PZCt1 <- PZC_HW_sim.T(N,1,Maturite,paramHW)
matplot(Maturite,t(PZCt1[1:10,]),type='l',
        main = 'Prix z�ro-coupon dans 1 an simul� par HW',
        xlab = 'Maturit�', ylab = 'Prix ZC')
lines(colMeans(PZCt1),type="l",lwd=2,col="red")
lines(PrixZC)
legend("topright",legend=c("PZC en t=1","PZC en t=0"),
       col=c("red","black"),pch=20,
       cex=0.6)

# trajectoire du PZC de maturit� 10 ans
PZCT10 <- c()
for (t in c(0,Maturite)){PZCT10 <- cbind(PZCT10,PZC_HW_sim(N,t,t+10,paramHW))}
matplot(t(PZCT10[1:10,]),type='l',
        main = 'Trajectoire prix z�ro-coupon de maturit� 10 ans',
        xlab = 'Temps', ylab = 'Prix ZC')
lines(colMeans(PZCT10),type="l",lwd=2,col="red")



