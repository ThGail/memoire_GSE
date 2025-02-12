rm(list = ls())
library(readxl)
library(dfoptim)
chemin = "C:/Users/mengr/OneDrive/Documents/Universit�/Master 1_Semestre 1_2021-2022/M�moire de M1/M�moire GSE - Paris Dauphine & Prim'Act"
chemin_fct = paste(chemin,"/Fonction", sep="")
chemin_cal = paste(chemin,"/Calibrage", sep="")
setwd(chemin)

### Importation des donnees ###################################################
source(paste(chemin_fct,"\\Vasicek_fonction.R",sep=""))
source(paste(chemin_fct,"\\CIR_fonction.R",sep=""))
source(paste(chemin_cal,"\\Vasicek_calibrage.R",sep=""))
source(paste(chemin_cal,"\\CIR_calibrage.R",sep=""))

sheetDGlo <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 1)
sheetCali <- read_excel("Input_20210118_18h41m33s.xlsm", sheet = 3)

Maturite <- as.numeric(sheetDGlo$`Courbe des taux ZC`[7:156])
TauxZC <- as.numeric(sheetDGlo$...2[7:156])
SpreadMarket  <- as.numeric(sheetDGlo$...15[3:9])
Maturite10 <- Maturite[1:10]
Maturite15 <- Maturite[1:15]
Maturite30 <- Maturite[1:30]
Maturite50 <- Maturite[1:50]

N = 1000

### Plot CIR ####################################################
# loi de lambda est suit une Chi-2 ? 
hist(lambdat_CIR_sim(N, 3, param_init), freq=FALSE, main='Histogramme des simulations (param random)', xlab='Simulation des lambda t = 3')

# plot du spread pour tous les rating sur 30 ans
plot(Maturite30,spread_CIR_FF_calibrage(Maturite30, paramCIR$AAA, LGD), main='Les spread de cr�dit reproduits par le mod�le CIR', type='l', ylab="Spread", xlab="Maturit�", ylim=c(0.001, 0.03), col='red')
lines(spread_CIR_FF_calibrage(Maturite30, paramCIR$AA, LGD), col='orange')
lines(spread_CIR_FF_calibrage(Maturite30, paramCIR$A, LGD), col='brown')
lines(spread_CIR_FF_calibrage(Maturite30, paramCIR$BBB, LGD), col='lightblue')
lines(spread_CIR_FF_calibrage(Maturite30, paramCIR$BB, LGD), col='blue')
lines(spread_CIR_FF_calibrage(Maturite30, paramCIR$B, LGD), col='purple')
legend("topright", c("AAA", "AA", "A", "BBB", "BB", "B"),
       col = c("red", "orange", "brown", "lightblue", "blue", "purple"), lty = c(1, 1, 1), cex = 0.6)
# remarque : on trouve pareil avec 
# plot(colMeans(spread_CIR_sim.T(N,0,Maturite30,paramCIR$AAA,LGD)))

# simulation spread B pour une maturit� de 3 ans
SP <- c()
for (t in c(0,Maturite50)){SP <- cbind(SP,spread_CIR_sim(N,t,t+3,paramCIR$B,LGD))}
matplot(t(SP[1:10,]),type="l",
        main=c("Evolution de spread B de maturit� 3 ans sur 50 ans","CIR"),
        ylab="Spread",xlab="Temps")
lines(colMeans(SP),col="red",lwd=2)

### (Test de martingalit� CIR) ###################################################
plot(Maturite,PZCr_CIR_FF(Maturite, paramVas, paramCIR$AAA, LGD)/colMeans(PZCr_CIR_Vas_sim.T(N, 0, Maturite, paramVas, paramCIR$AAA, LGD)),"l",
     ylab="CashFlow Actualis�",ylim=c(0.99,1.01),
     main="Test de martingalit� CIR", 
     col = 'red')
lines(Maturite,PZCr_CIR_FF(Maturite, paramVas, paramCIR$AA, LGD)/colMeans(PZCr_CIR_Vas_sim.T(N, 0, Maturite, paramVas, paramCIR$AA, LGD)),"l",col="orange")
lines(Maturite,PZCr_CIR_FF(Maturite, paramVas, paramCIR$A, LGD)/colMeans(PZCr_CIR_Vas_sim.T(N, 0, Maturite, paramVas, paramCIR$A, LGD)),"l",col="brown")
lines(Maturite,PZCr_CIR_FF(Maturite, paramVas, paramCIR$BBB, LGD)/colMeans(PZCr_CIR_Vas_sim.T(N, 0, Maturite, paramVas, paramCIR$BBB, LGD)),"l",col="brown")
lines(Maturite,PZCr_CIR_FF(Maturite, paramVas, paramCIR$BB, LGD)/colMeans(PZCr_CIR_Vas_sim.T(N, 0, Maturite, paramVas, paramCIR$BB, LGD)),"l",col="brown")
lines(Maturite,PZCr_CIR_FF(Maturite, paramVas, paramCIR$B, LGD)/colMeans(PZCr_CIR_Vas_sim.T(N, 0, Maturite, paramVas, paramCIR$B, LGD)),"l",col="brown")
legend("topright",legend=c("AAA","AA", "A","BBB","BB","B"),
       col=c("red","orange", "brown", "lightblue", "blue", "purple"),pch=20,
       cex=0.8)
