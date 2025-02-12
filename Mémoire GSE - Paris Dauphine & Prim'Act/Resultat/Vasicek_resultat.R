rm(list = ls())
library(readxl)
library(dfoptim)
chemin = "C:/Users/mengr/OneDrive/Documents/Universit�/Master 1_Semestre 1_2021-2022/M�moire de M1/M�moire GSE - Paris Dauphine & Prim'Act"
chemin_fct = paste(chemin,"/Fonction", sep="")
chemin_cal = paste(chemin,"/Calibrage", sep="")
setwd(chemin)

### Importation des donnees ###################################################
source(paste(chemin_fct,"\\Vasicek_fonction.R",sep=""))
source(paste(chemin_cal,"\\Vasicek_calibrage.R",sep=""))

sheetDGlo <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 1)
sheetCali <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 3)

Maturite <- as.numeric(sheetDGlo$`Courbe des taux ZC`[7:156])
TauxZC <- as.numeric(sheetDGlo$...2[7:156])
Maturite10 <- Maturite[1:10]
Maturite15 <- Maturite[1:15]
Maturite30 <- Maturite[1:30]
Maturite50 <- Maturite[1:50]

N = 1000

### Plot du Vasicek ###################################################
# plot calibrage TZC
plot(TauxZC, type="l", main="Calibrage du taux z�ro-coupon",col="red",lty=3,lwd=2,
     xlab="Maturit�",ylab="Taux z�ro-coupon")
lines(TZC_Vas_FF_calibrage(Maturite,paramVas),lwd=2)
legend("bottomright",legend=c("Courbe EIOPA (input)","Courbe TZC du mod�le"),
       col=c("red","black"),pch=20,
       cex=0.6)

# plot calibrage PZC
plot(exp(-Maturite*TauxZC), type="l", main="V�rification avec le prix z�ro-coupon",col="red",lty=3,lwd=2,
     xlab="Maturit�",ylab="Prix z�ro-coupon")
lines(PZC_Vas_FF_calibrage(Maturite,paramVas),lwd=2)
legend("topright",legend=c("Courbe issue de la EIOPA","Courbe PZC du mod�le"),
       col=c("red","black"),pch=20,
       cex=0.6)

# simulation TZC de maturit� 10 ans (1000 simulations)
plotTZC <- c()
for (t in c(0,Maturite)){plotTZC <- cbind(plotTZC,TZC_Vas_FF_sim(N, t, t+10, paramVas))}
matplot(t(plotTZC[1:10,]),type="l",
        main="Sc�narios de taux z�ro-coupon de maturit� 10 ans",
        xlab="Temps",ylab="TZC")
lines(colMeans(plotTZC),type="l",lwd=2,col="red",
     main="Moyenne de taux z�ro-coupon de maturit� 10 ans",
     xlab="Temps",ylab="TZC")

# simulation PZC de maturit� 10 ans (1000 simulations)
plotPZC <- c()
for (t in c(0,Maturite)){plotPZC <- cbind(plotPZC,PZC_Vas_FF_sim(N, t, t+10, paramVas))}
matplot(t(plotPZC[1:10,]),type="l",
        main="Sc�narios de prix z�ro-coupon de maturit� 10 ans",
        xlab="Temps",ylab="PZC")
lines(colMeans(plotPZC),type="l",lwd=2,col="red",
      main="Moyenne de prix z�ro-coupon de maturit� 10 ans",
      xlab="Temps",ylab="PZC")


