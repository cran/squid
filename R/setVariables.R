# setVariables: test and initialize input variables
#
# Args:
#   input          list of all the inputs used to run the model.
#   module         character of the name of the module.
#   environment    list of the model environments.
#
# Returns:
#   list of all model variables

setVariables <- function(input, module, environments, sep){
  
  ##############################################################
  ################## VARIABLES DECLARATION #####################
  ##############################################################  
  
  # Variables 
  Variables <- list(
    "nb.IS"    = 4,   # Minimum number of intercepts + slopes
    "nb.KE"    = 2,   # Number of known environment 
    "B0"       = 1,   # Position of intercept component in the (Co)variance matrix
    "X1"       = 2,   # Position of environment X1 component in the (Co)variance matrix
    "X2"       = 3,   # Position of environment X2 component in the (Co)variance matrix
    "X1X2"     = 4    # Position of environment interaction X1xX2 component in the (Co)variance matrix
  )
  
  inputNames <- list(
    "B"              = paste(module,"B"            , sep = sep),
    "Vind"           = paste(module,"Vind"         , sep = sep),
    "Ve"             = paste(module,"Ve"           , sep = sep),
    "VG"             = paste(module,"VG"           , sep = sep),
    "Tmax"           = paste(module,"Tmax"         , sep = sep),
    "Time_sampling"  = paste(module,"Time_sampling", sep = sep),
    "Vhsi"           = paste(module,"Vhsi"         , sep = sep),
    "NR_ind"         = paste(module,"NR_ind"       , sep = sep),
    "NR_trait"       = paste(module,"NR_trait"     , sep = sep),
    "ST_ind"         = paste(module,"ST_ind"       , sep = sep),
    "ST_trait"       = paste(module,"ST_trait"     , sep = sep),
    "NR_Fixe"        = paste(module,"NR_Fixe"      , sep = sep),
    "NP"             = paste(module,"NP"           , sep = sep),
    "NI"             = paste(module,"NI"           , sep = sep),
    "NT"             = paste(module,"NT"           , sep = sep),
    "NR"             = paste(module,"NR"           , sep = sep),
    "NG"             = paste(module,"NG"           , sep = sep),
    "PB"             = paste(module,"PB"           , sep = sep)
  )
  
  ##############################################################
  #################### INPUT VARIABLES  ########################
  ############################################################## 
  
  Mu   <- 0    # mean value of the normal distribution
  
  x <- ifelse(inputNames$Tmax %in% names(input),
              error_management(input[[inputNames$Tmax]], 
                               inputNames$Tmax, 
                               "check_one_integer",
                               minimum=1),
              1)
  
  if(inputNames$Time_sampling %in% names(input)){
    y <- input[[inputNames$Time_sampling]]
  }else{
    y <- c(1,x)
  }
  
  # Time 
  Time <- list(
    "Tmin"     = 1,                           # Start time
    "Tmax"     = x,                           # End time
    "TS"       = 1,                           # Time step value
    "Ts"       = y[1],                        # Start time of sampling
    "Te"       = y[2],                        # End time of sampling (Max = Tmax)
    "Tsamp"    = y[2]-y[1]+1,                 # Total sampling time
    "TsampI"   = 0,                           # Sampling time per individual
    
    "Vhsi"  = ifelse(inputNames$Vhsi %in% names(input),
                     error_management(input[[inputNames$Vhsi]], 
                                      inputNames$Vhsi, 
                                      "check_one_numeric",
                                      minimum=0,
                                      maximum=0.95),
                     0), # Among-individual variance in timing of sampling (between 0 and 1)
    
    "NR_ind"   = ifelse(inputNames$NR_ind %in% names(input),
                        error_management(input[[inputNames$NR_ind]], 
                                         inputNames$NR_ind, 
                                         "check_one_boolean"),
                        TRUE),            
    # Number of records among individuals
    # TRUE  : same number in records for all individuals
    # FALSE : different number of records among individuals
    "NR_trait" = ifelse(inputNames$NR_trait  %in% names(input),
                        error_management(input[[inputNames$NR_trait]], 
                                         inputNames$NR_trait, 
                                         "check_one_boolean"),
                        TRUE),
    # Number of records among traits within individuals
    # TRUE  : same number of records among traits within individuals
    # FALSE : different number of records among traits whitin individua    
    "ST_ind"   = ifelse(inputNames$ST_ind   %in% names(input),
                        error_management(input[[inputNames$ST_ind]], 
                                         inputNames$ST_ind, 
                                         "check_one_boolean"),
                        TRUE),          
    # Sampling time among individuals
    # TRUE  : same sampling time among individuals
    # FALSE : different sampling time individuals
    "ST_trait" = ifelse(inputNames$ST_trait %in% names(input),
                        error_management(input[[inputNames$ST_trait]], 
                                         inputNames$ST_trait, 
                                         "check_one_boolean"),
                        TRUE),     
    # Sampling time among traits within individuals
    # TRUE  : same sampling time among traits within individuals
    # FALSE : different sampling time among traits whitin individuals
    "NR_Fixe"  = ifelse(inputNames$NR_Fixe %in% names(input),input[[inputNames$NR_Fixe]],TRUE) # if TRUE the same NR for all the populations
  )
  
  Time$TsampI <- ifelse(Time$Vhsi > 0.95, round(Time$Tsamp*0.05,0), round(Time$Tsamp*(1-Time$Vhsi),0)) 
  Time$TsampI <- ifelse(Time$TsampI != 0, Time$TsampI, 1)
  
  N <- list(
    "NP"  = ifelse(inputNames$NP %in% names(input),
                   error_management(input[[inputNames$NP]], 
                                    inputNames$NP, 
                                    "check_one_integer",
                                    minimum=1),
                   1),      # Number of populations (between 1 and inf)
    "NI"  = ifelse(inputNames$NI %in% names(input),
                   error_management(input[[inputNames$NI]], 
                                    inputNames$NI, 
                                    "check_one_integer",
                                    minimum=1),
                   1),      # Number of individuals (between 2 and inf)
    "NT"  = ifelse(inputNames$NT %in% names(input),
                   error_management(as.numeric(input[[inputNames$NT]]), 
                                    inputNames$NT, 
                                    "check_one_integer",
                                    minimum=1,
                                    maximum=2),
                   1),   # Number of traits (between 1 and inf)
    "NS"  = (Time$Tmax - Time$Tmin + 1)/Time$TS,                                   # Number of step of time 
    "NR"  = ifelse(inputNames$NR %in% names(input),
                   error_management(input[[inputNames$NR]], 
                                    inputNames$NR, 
                                    "check_one_integer",
                                    minimum=1),
                   1),      # Number of mean records by individual (between 1 and inf) 
    "NRI" = NULL,                                                                  # Number of records for each individual
    "NG"  = ifelse(inputNames$NG %in% names(input),
                   error_management(input[[inputNames$NG]], 
                                    inputNames$NG, 
                                    "check_one_integer"),
                   1)       # Number of high-level groups
  )
  
  if(N$NG < 1 || N$NG > N$NI){
    stop(paste0("input[[",inputNames$NG,"]] must be an integer between 1 and input[[",inputNames$NI,"]] (number of individuals)."), 
         call. = FALSE)
  }
  # check if NI is divisible by NG
  if(N$NI %% N$NG != 0){
    stop(paste0("input[[",inputNames$NI,"]] (number of individuals) must be divisible by input[[",inputNames$NG,"]] (number of higher-level groups)."), 
         call. = FALSE)
  }
  
  # Variance 
  V <- list(
    "Vp"     = 1          # Totale variance value (Vp = Vind0 + Vind1 + Vt + Ve)
  )
  
  # Ve: residual (Co)variance matrix
  if(inputNames$Ve %in% names(input)){
    
    V$Ve <- as.matrix(input[[inputNames$Ve]])
    V$Ve <- error_management(V$Ve, inputNames$Ve, 
                             "check_matrix", 
                             nb_col = N$NT, 
                             nb_row = N$NT)
  }else{
    V$Ve <- matrix(0, N$NT, N$NT)
  }
  
  # Ve: residual (Co)variance matrix
  if(inputNames$VG %in% names(input)){
    
    V$VG <- as.matrix(input[[inputNames$VG]])
    V$VG <- error_management(V$VG, inputNames$VG, 
                             "check_matrix", 
                             nb_col = N$NT, 
                             nb_row = N$NT)
  }else{
    V$VG <- matrix(0, N$NT, N$NT)
  }
  
  # Vind0 : Random intercept Variance (among-individual variance)
  # Vind1 : Random slope variance 1   (within-individual variance)
  # Vind2 : Random slope variance 2   (within-individual variance)
  # Vind3 : Random slope variance 3   (within-individual variance)
  if(inputNames$Vind %in% names(input)){
    V$Vind <- as.matrix(input[[inputNames$Vind]])
    V$Vind <- error_management(V$Vind, inputNames$Vind, 
                               "check_matrix", 
                               nb_col=Variables$nb.IS*N$NT, 
                               nb_row=Variables$nb.IS*N$NT)
    
    tmp_Vind       <- V$Vind
    diag(tmp_Vind) <- 0
    if(any(diag(V$Vind) < 0) || any(tmp_Vind < -1) || any(tmp_Vind > 1)){
      stop(paste0("input[[",inputNames$Vind,"]] is a variance/correlation matrix. The variances are on the matrix diagonal and must be postive numeric numbers. The correlation values are on the lower half of the matrix and must be between -1 and 1."), 
      call. = FALSE)
    }
    
    if(!environments$X1$state){
      V$Vind[seq(from=Variables$X1, to=(Variables$nb.IS*N$NT), by=Variables$nb.IS), ] <- 0 
      V$Vind[ ,seq(from=Variables$X1, to=(Variables$nb.IS*N$NT), by=Variables$nb.IS)] <- 0 
    }
    if(!environments$X2$state){
      V$Vind[seq(from=Variables$X2, to=(Variables$nb.IS*N$NT), by=Variables$nb.IS), ] <- 0 
      V$Vind[ ,seq(from=Variables$X2, to=(Variables$nb.IS*N$NT), by=Variables$nb.IS)] <- 0 
    }
    if(!environments$Interaction){
      V$Vind[seq(from=Variables$X1X2, to=(Variables$nb.IS*N$NT), by=Variables$nb.IS), ] <- 0 
      V$Vind[ ,seq(from=Variables$X1X2, to=(Variables$nb.IS*N$NT), by=Variables$nb.IS)] <- 0 
    }

  }else{
    V$Vind <- matrix(0,Variables$nb.IS, Variables$nb.IS)
  }
  
  # Population mean in the intercept and the slopes
  if(inputNames$B %in% names(input)){
    B <- matrix(input[[inputNames$B]], nrow=1)
    B <- error_management(B, inputNames$B, "check_matrix", nb_col=Variables$nb.IS*N$NT, nb_row=1)
    
    if(!environments$X1$state)    B[seq(from=Variables$X1, to=Variables$X1+(Variables$nb.IS*(N$NT-1)), by=Variables$nb.IS)]     <- 0 
    if(!environments$X2$state)    B[seq(from=Variables$X2, to=Variables$X2+(Variables$nb.IS*(N$NT-1)), by=Variables$nb.IS)]     <- 0 
    if(!environments$Interaction) B[seq(from=Variables$X1X2, to=Variables$X1X2+(Variables$nb.IS*(N$NT-1)), by=Variables$nb.IS)] <- 0 
    
    B <- repmat(as.matrix(B),N$NI*N$NS*N$NP, 1)
    B <- reshapeMat(B, Variables$nb.IS)
  }else{
    B <- matrix(0,N$NI*N$NS*N$NP*N$NT, Variables$nb.IS)
  }
  
  return(list("Mu"=Mu,"N"=N, "B"=B, "V"=V, "Time"=Time, "Variables"=Variables))
  
}