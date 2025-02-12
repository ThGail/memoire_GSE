# d�finition des fonctions utiles du mod�le JLT

### Pour la partie pr�paration des donn�es ###################################
# transformation en matrice log
puissanceMatrice <- function(A, n){
  mat = diag(length(A[1,]))
  for (i in 1:n){mat = mat%*%A}
  return(mat)
}

logMatrice <- function(Q, n){
  QI = Q-diag(length(Q[1,])) # Q-Identite
  mat = matrix(rep(0,length(Q[1,])^2),nrow=length(Q[1,]))
  for (i in 1:n){
    mat = mat + (-1)**(i+1)*puissanceMatrice(QI,i)/i
  }
  return(mat)
}

expMatrice <- function(Q, n){
  mat = matrix(rep(0,length(Q[1,])^2),nrow=length(Q[1,]))
  for (i in 0:n){
    mat = mat + puissanceMatrice(Q,i)/factorial(i)
  }
  return(mat)
}

### D�finition des fonctions utiles ################################
A_JLT <- function(u, param, dj) {
  k = param[1:8]
  mu = param[9:16]
  sigma = param[17]
  ga <- sqrt(k**2 - 2 * dj * sigma**2)
  return(((2 * ga * exp((k + ga) * (u / 2))) / ((k + ga) * (exp(ga * u) - 1) + 2 * ga))**((2 * k * mu) / (sigma**2)))
}

B_JLT <- function(u, param, dj) {
  k = param[1:8]
  mu = param[9:16]
  sigma = param[17]
  ga <- sqrt(k**2 - 2 * dj * sigma**2)
  return((- 2 * dj * (exp(ga * u) - 1)) / ((k + ga) * (exp(ga * u) - 1) + 2 * ga))
}

# la dynamique pour la proba de d�faut
pit_JLT <- function(N, t, param) {
  k <- matrix(rep(param[1:8], N), nrow = 8)
  mu <- matrix(rep(param[(1:8)+8], N), nrow = 8)
  sigma <- matrix(rep(param[17], N*8), nrow = 8)
  pi_t <- matrix(rep(param[18:25], N), nrow = 8)
  
  if (t==0) {return(pi_t)}
  for (i in 1:t){
    pi_t <- abs(pi_t + k * (mu - pi_t) + t(t(sigma * sqrt(pi_t)) * rnorm(N, 0, 1)))}
  return(pi_t)
}

# la proba de faire d�faut � partir du rating i
proba_defaut_i_JLT <- function(N, t, TT, param, M, D, i){
  # pour un rating donn�e, on fait N simulations
  
  invM <- solve(M)
  K <- length(D[1,])
  
  sum <- 0
  for (j in (1:(K-1))){
    esp <- (A_JLT(TT-t, param, D[j,j])*exp(-B_JLT(TT-t, param, D[j,j])*pit_JLT(N,t,param)))[i,]
    sum <- sum + M[i,j]*invM[j,K]*(esp-1)
  }
  return(sum)
}
proba_defaut_i_JLT.T <- Vectorize(proba_defaut_i_JLT,"TT")
proba_defaut_i_JLT.t <- Vectorize(proba_defaut_i_JLT,"t")

# privil�gier l'utilisation de la proba de d�faut 
proba_survie_i_JLT <- function(N, t, TT, param, M, D, i){
  return(pmin(1,1-proba_defaut_i_JLT(N, t, TT, param, M, D, i)))}
proba_survie_i_JLT.T <- Vectorize(proba_survie_i_JLT,'TT')
proba_survie_i_JLT.t <- Vectorize(proba_survie_i_JLT,'t')

# pareil en version calibrage
proba_defaut_i_JLT_calibrage <- function(TT, param, M, D, i){
  # pour un rating donn�e, et une maturit� TT donn�e, on a juste besion de t=0
  
  invM <- solve(M)
  K <- length(D[1,])
  pi0 = param[18:25]
  
  sum <- 0
  for (j in (1:(K-1))){
    esp <- A_JLT(TT, param, D[j,j])[i]*exp(-B_JLT(TT, param, D[j,j])[i]*pi0[i])
    sum <- sum + M[i,j]*invM[j,K]*(esp-1)
  }
  return(sum)
}
proba_defaut_i_JLT_calibrage.T <- Vectorize(proba_defaut_i_JLT_calibrage,"TT")

# formule g�n�rale de la proba de passage
proba_passage_ij_JLT <- function(N, t, TT, param, M, D, i, j){
  # pour un rating donn�e, on fait N simulations
  
  invM <- solve(M)
  K <- length(D[1,])
  
  sum <- 0
  for (k in (1:(K-1))){
    esp <- (A_JLT(TT-t, param, D[k,k])*exp(-B_JLT(TT-t, param, D[k,k])*pit_JLT(N,t,param)))[i,]
    sum <- sum + M[i,k]*invM[k,j]*esp
  }
  
  sum <- sum + M[i,K]*invM[K,j]
  return(sum)
}

# calcule du spread de rating i
spread_i_JLT <- function(N, t, TT, param, M, D, i, LGD){
  if (t==TT){return(rep(0,N))}
  # if (1- LGD * proba_defaut_i_JLT(N, t, TT, param, M, D, i)<=0){return(0)}
  return(-(1/(TT-t))*log(1- LGD * proba_defaut_i_JLT(N, t, TT, param, M, D, i)))
}
spread_i_JLT.t <- Vectorize(spread_i_JLT,"t")
spread_i_JLT.T <- Vectorize(spread_i_JLT,"TT")

# spread pour la calibration
spread_i_JLT_calibrage <- function(TT, param, M, D, i, LGD){
  if (TT==0){return(0)}
  return(-log(1 - LGD * proba_defaut_i_JLT_calibrage(TT, param, M, D, i))/TT)
}
spread_i_JLT_calibrage.T <- Vectorize(spread_i_JLT_calibrage,"TT")

# fonction a minimiser
ecart_JLT <- function(param){
  e <- 0
  for (t in 1:TT){ for (i in 1:6){
    # spread <- spread_i_fct(1000, t, TT, param_test, M, D, i,LGD)
    spread <- spread_i_JLT_calibrage(t, param, M, D, i, LGD)
    e <- e + (spread-SpreadMarket[i])^2
  }}
  return(e)
} ## parametre sur le rating

### Pour la partie martingale Cash Flow (Vas) ############################
# prix risqu� � t=0, calcul� � partir du spread FF et PZC FF
PZCr_i_CF_JLT_Vas_FF <- function(TT, param_Vas, param_JLT, M, D, i, LGD){
  return(PZC_Vas_FF_calibrage.T(TT, param_Vas)/(1+spread_i_JLT_calibrage.T(TT, param_JLT, M, D, i, LGD))^TT)
}

# moyenne prix ZC risqu� CF actualis� au taux sans risque
PZCr_i_CF_JLT_Vas_sim <- function(N, t, TT, param_Vas, param_JLT, M, D, i, LGD){
  pd_i <- t(t(proba_defaut_i_JLT(N, t, TT, param_JLT, M, D, i)))
  pzc <- PZC_Vas_FF_sim(N,t,TT,param_Vas)
  return(pzc*(1*(1-pd_i)+(1-LGD)*pd_i))
}
PZCr_i_CF_JLT_Vas_sim.T <- Vectorize(PZCr_i_CF_JLT_Vas_sim,"TT")

### Pour la partie martingalit� en Z�ro coupon (Vas) #########################################
# moyenne prix ZC risqu� actualis� au taux sans risque
PZCr_i_JLT_Vas_sim <- function(N, t, TT, param_Vas, param_JLT, M, D, i, LGD){
  sum = proba_defaut_i_JLT_calibrage(t, param_JLT, M, D, i)*(1-LGD)*array(PZC_Vas_FF_sim(N,t,TT,paramVas))
  for (l in 1:(8-1)){
    p_il = proba_passage_ij_JLT(N, 0, t, param_JLT, M, D, i, l)
    PZCr_l = array(PZCr_i_CF_JLT_Vas_sim(N, t, TT, param_Vas, param_JLT, M, D, l, LGD))
    sum = sum + p_il*PZCr_l
  }
  if (TT==t){defla=rep(1,N)}
  else {defla = array(deflateur_Vas(N,0,t,param_Vas))}
  return(defla*sum)
}
PZCr_i_JLT_Vas_sim.T <- Vectorize(PZCr_i_JLT_Vas_sim,"TT")

### Pour la partie martingale Cash Flow (HW) ############################
# prix risqu� � t=0, calcul� � partir du spread FF et PZC FF
PZCr_i_CF_JLT_HW_FF <- function(TT, param_HW, param_JLT, M, D, i, LGD){
  return(PZC_HW_FF(TT, param_HW)/(1+spread_i_JLT_calibrage.T(TT, param_JLT, M, D, i, LGD))^TT)
}

# moyenne prix ZC risqu� CF actualis� au taux sans risque
PZCr_i_CF_JLT_HW_sim <- function(N, t, TT, param_HW, param_JLT, M, D, i, LGD){
  pd_i <- proba_defaut_i_JLT(N, t, TT, param_JLT, M, D, i)
  pzc <- PZC_HW_sim(N,t,TT,param_HW)
  return(pzc*(1*(1-pd_i)+(1-LGD)*pd_i))
}
PZCr_i_CF_JLT_HW_sim.T <- Vectorize(PZCr_i_CF_JLT_HW_sim,"TT")


### Pour la partie martingalit� en Z�ro coupon (HW) #########################################
# moyenne prix ZC risqu� actualis� au taux sans risque
PZCr_i_JLT_HW_sim <- function(N, t, TT, param_HW, param_JLT, M, D, i, LGD){
  sum = proba_defaut_i_JLT_calibrage(t, param_JLT, M, D, i)*(1-LGD)*PZC_HW_sim(N, t, TT, param_HW)
  for (l in 1:(8-1)){
    p_il = proba_passage_ij_JLT(N, 0, t, param_JLT, M, D, i, l)
    PZCr_l = PZCr_i_CF_JLT_HW_sim(N, t, TT, param_HW, param_JLT, M, D, l, LGD)
    sum = sum + p_il*PZCr_l
  }
  if (TT==t){defla=rep(1,N)}
  else {defla = deflateur_HW(N,0,t,param_HW)}
  return(defla*sum)
}
PZCr_i_JLT_HW_sim.T <- Vectorize(PZCr_i_JLT_HW_sim,"TT")
