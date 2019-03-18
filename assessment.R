#' HEAT3 
#' 
#' function for assessing eutrophication status
#' by comparing indicator observed values with target
#'
#' 
#' @param df A dataframe 
#'   The dataframe should contain the
#'   following variables:
#'   
#'   \item{Indicator} 
#'   \item{Criteria} 
#'   \item{Status}
#'   \item{Target}
#'   \item{Weight}
#'   \item{Response}
#'   #'   
#' 
#' @param string specifiying the aggregation level: 
#' @param string list of columns to group by : e.g. c("WB","Period") 
#'  
#' 
#' 

require("dplyr")
require("tidyr")

Assessment<- function(assessmentdata,summarylevel=1,group_variables="",showblanks=T){
  
  df <- assessmentdata
  
  bDropGroup<-F
  if(is.null(group_variables)){
    bDropGroup<-T
  }else if(length(group_variables)==1){
    if(group_variables==""){
      bDropGroup<-T
    }else{
      bDropGroup<-F
    } 
  }
  if(bDropGroup){
      group_variables=c("XXXXXXXX")
      df$XXXXXXXX<-1
  }
  if(!is.null(group_variables)){
  for(gv in group_variables){
    df[,gv] <- factor(df[,gv], levels=unique(df[,gv]))
  }
}
  requiredcols <- c("Criteria","Indicator","Target","Status")
  confcols<-c("Conf_Status","Conf_Target")
  extracols <- c("Weight")
  
  #Check column names in the imported data
  cnames<-names(df)
  nimp = ncol(df)
  nreq = length(requiredcols)
  nextra = length(extracols)
  nconf = length(confcols)
    
  ok <- rep(0, nreq)
  okextra <- rep(0, nextra)
  okconf<- rep(0, nconf)
  
  foundresponse=FALSE
  
  for (i in 1:nimp){
    for (j in 1:nreq){
      if(toupper(requiredcols[j])==toupper(cnames[i])){
        names(df)[i] <- requiredcols[j]
        ok[j]=1
      }
    }
    for (j in 1:nextra){
      if(toupper(extracols[j])==toupper(cnames[i])){
        names(df)[i] <- extracols[j]
        okextra[j]=1
      }
    }
    for (j in 1:nconf){
      if(toupper(confcols[j])==toupper(cnames[i])){
        names(df)[i] <- confcols[j]
        okconf[j]=1
      }
    }
  }
  
  
  
  n<-sum(ok, na.rm = TRUE)
  nconfok<-sum(okconf, na.rm = TRUE)
  if(nconfok<length(confcols)){
    bConf<-FALSE
  }else{
    bConf<-TRUE
  }
  
  if(n<nreq){
    # The required columns were not found in the input data
    message("Error! Required column(s) were not found in the input data:")
    for (j in 1:nreq){
      if(ok[j]!=1){
        message(paste("    ",requiredcols[j]))
      }
    }
    if(summarylevel==1){
      return(df)
    }else{    return(NA)}
  }else{
    # The required columns are present - do the assessment
    for(j in 1:nextra){
      if(okextra[j]==0){
          df[[extracols[j]]]<-1
        }
      }
    #}

    # Change order of Criteria factors
    cat1<-data.frame(unique(df$Criteria))
    names(cat1)[1] <- 'Criteria'
    cat1$char<-as.character(cat1$Criteria)
    cat1$len<-nchar(cat1$char)
    cat1<-arrange(cat1,len, char)
    
    df$Criteria <- factor(df$Criteria, levels = cat1$char)
    
    group_variables_criteria <- c(group_variables,"Criteria")
    
    df <- df %>% 
      arrange_(.dots=group_variables_criteria)
    
    
    # All combinations of categories and waterbodies
    # This is used to ensure that a NA is returned where the combinations are missing
    n<-length(group_variables_criteria)
    for(i in 1:n){
      if(i>1){
        varold<-var
      }
      var<-distinct_(df,group_variables_criteria[i])
      if(i>1){
        var$X<-1
        varold$X<-1
        var<-left_join(varold,var,by="X") %>%
          select(-X)
      }
      if(i==n-1){combinations<-var}
    }
    
    combinations_criteria<-var
    
    
    if(!is.numeric(df$Response)){
      df <- df %>% 
        mutate(Response = ifelse(Response=="-",-1,1))
    }
    
    df <- df %>% 
      mutate(ER=EutrophicationRatio(Target,Status,Response))
    # confidence assessment
    if(bConf){
      df <- df %>% 
        mutate(Confidence=IndicatorConfidence(Conf_Target,Conf_Status))
    }
    
    
    
    if("Weight" %in% extracols){
      df <- df %>% 
        mutate(WeightX=ifelse(is.na(Weight),1,Weight))
      
      if(bConf){
      QEdata<-df %>% 
        group_by(.dots=group_variables_criteria) %>%
        summarise(IndCount=n(),ER=sum(ER*WeightX,na.rm = TRUE)/sum(WeightX,na.rm = TRUE),
                  Confidence=sum(Confidence*WeightX,na.rm = TRUE)/sum(WeightX,na.rm = TRUE))
      }else{
        QEdata<-df %>% 
          group_by(.dots=group_variables_criteria) %>%
          summarise(IndCount=n(),ER=sum(ER*WeightX,na.rm = TRUE)/sum(WeightX,na.rm = TRUE))
      }
      df <- df %>%
        select(-WeightX)
    }else{
      if(bConf){
      QEdata<-df %>% 
        group_by(.dots=group_variables_criteria) %>%
        summarise(IndCount=n(),ER=mean(ER,na.rm = TRUE),Confidence=mean(Confidence,na.rm=F))
      }else{
        QEdata<-df %>% 
          group_by(.dots=group_variables_criteria) %>%
          summarise(IndCount=n(),ER=mean(ER,na.rm = TRUE))
      }
    }
    
  
    if(bConf){
      QEspr<-QEdata %>%
        ungroup() %>%
        select(-c(IndCount,Confidence)) %>%
        spread(key=Criteria,value=ER)
    }else{
      QEspr<-QEdata %>%
        ungroup() %>%
        select(-IndCount) %>%
        spread(key=Criteria,value=ER)
    }
    
    QEdata$CriteriaClass<-HEATStatus(QEdata$ER)
    
    if(bConf){
      Overall<-QEdata %>%
        ungroup() %>%
        group_by_(.dots=group_variables) %>%
        summarise(ER=max(ER, na.rm = TRUE),
                  Confidence=mean(Confidence,na.rm=T))
      
      OverallQE<- QEdata %>%
      ungroup() %>%
      select(-c(IndCount,Confidence)) %>%
      inner_join(Overall, by=c(group_variables,"ER"))
    }else{
      Overall<-QEdata %>%
        ungroup() %>%
        group_by_(.dots=group_variables) %>%
        summarise(ER=max(ER, na.rm = TRUE))
      
      OverallQE<- QEdata %>%
        ungroup() %>%
        select(-IndCount) %>%
        inner_join(Overall, by=c(group_variables,"ER"))
    }
    
    OverallQE<-rename(OverallQE,Class=CriteriaClass,Worst=Criteria)
    QEdata<-QEdata %>% arrange_(.dots=group_variables_criteria)
    QEspr<-inner_join(QEspr, OverallQE, by=group_variables)
    if(bConf){
      QEdata <- QEdata %>%
        select_(.dots=c(group_variables,"Criteria","IndCount","ER","CriteriaClass","Confidence"))
      QEdata <- QEdata %>%
        mutate(ConfClass=ConfidenceClass(Confidence))
      QEspr <- QEspr %>%
        mutate(ConfClass=ConfidenceClass(Confidence))
      OverallQE <- OverallQE %>%
        mutate(ConfClass=ConfidenceClass(Confidence))
    }
    

    
    # -----------------------------    
    Indicators <- df
    
    if(showblanks){
      QEdata<-combinations_criteria %>%
        left_join(QEdata,by=group_variables_criteria)
      QEspr<-combinations %>%
        left_join(QEspr,by=group_variables)
      OverallQE<-combinations %>%
        left_join(OverallQE,by=group_variables)
    }
    if(bDropGroup){
      QEdata<- QEdata %>% 
        ungroup() %>%
        select(-XXXXXXXX)
      QEspr<- QEspr %>% select(-XXXXXXXX)
      OverallQE<- OverallQE %>% select(-XXXXXXXX)
      Indicators<- Indicators %>% 
        ungroup() %>% 
        select(-XXXXXXXX)
    }
    
    
    #return(n)
    if(summarylevel==1){
      return(Indicators)
    }else if(summarylevel==2){
      return(QEspr)
    }else if(summarylevel==3){
      return(QEdata)
    }else if(summarylevel==4){
      return(OverallQE)
    }else{
      return(assessmentdata)
    }
    #
  }
}

#===============================================================================
# function EutrophicationRatio
EutrophicationRatio<- function(target, status, response=1,replaceinf=T){
  # If response is not specified, it will be assumed to be positive
  # i.e. EutrophicationRatio increases (worsens) with increasing status value
  if (missing(response)){
    response<-1
  }
  response<-ifelse(is.na(response), 1, response)
  if(is.logical(response)){
    response<-ifelse(response,1,-1)
    }
  
  # EutrophicationRatio calculated depending on Response direction
  er<-ifelse(response>0, status/target, target/status)
  if(replaceinf){
    replaceval<-100
    }else{
      replaceval<-NA
      }
  er<-ifelse(is.infinite(er),replaceval,er)
  return(er)
}

#===============================================================================
#Function HEATStatus
HEATStatus<-function(er){
  status<-ifelse(er>0.5, "Good", "High")
  status<-ifelse(er>1, "Moderate", status)
  status<-ifelse(er>1.5, "Poor", status)
  status<-ifelse(er>2, "Bad",status )
  return(status)
}

AddColours<-function(er){
  co<-ifelse(er>0.5, '#66FF66', '#3399FF')
  co<-ifelse(er>1, '#FFFF66', co)
  co<-ifelse(er>1.5, '#FF9933', co)
  co<-ifelse(er>2, '#FF6600',co)
  return(co)
}

#===============================================================================
#Function ConfidenceClass
ConfidenceClass<-function(Confidence){
  class<-ifelse(Confidence<0.5,"III","II")
  class<-ifelse(Confidence>=0.75,"I",class)
  return(class)
}

#===============================================================================
#Function Indicator Confidence 

IndicatorConfidence<-function(Conf_Target,Conf_Status){
  Conf_Target<-toupper(substr(Conf_Target,1,1))
  Conf_Status<-toupper(substr(Conf_Status,1,1))
  ct<-ifelse(Conf_Target=="H",1,ifelse(Conf_Target=="M",0.5,ifelse(Conf_Target=="L",0,NA)))
  cs<-ifelse(Conf_Status=="H",1,ifelse(Conf_Status=="M",0.5,ifelse(Conf_Status=="L",0,NA)))
  c<-0.5*(ct+cs)
  return(c)
}
