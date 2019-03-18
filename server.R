library(shiny)
library(tidyverse)
library(DT)

source("assessment.R")
source("javascript.R")


shinyServer(function(input, output, session) {
  
  colsrequired<-c("Criteria",
                  "Indicator",
                  "Target",
                  "Status",
                  "Response")
  
  colsrestricted<-c(colsrequired,"Weight") # these should not be used for grouping the data!
  
  
  session$onFlushed(function() {
    session$sendCustomMessage(type='jsCode', list(value = script))
  }, FALSE)
  
  showNA = F
  
  
  # Get the selected column separator character
  sepchar<-reactive({
    sep<-";"
    if(length(input$sepname)>0){
      if(input$sepname=="Comma"){sep<-","}
      if(input$sepname=="Semi-colon"){sep<-";"}
      if(input$sepname=="Tab"){sep<-"\t"}
    }
    return(sep)
  })
  
  # if file is selected then show the separation character selection 
  output$selectSepChar <- renderUI({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }else{
    tagList(
      selectInput('sepname','Column Separator:',c("Comma","Semi-colon","Tab"),selected="Semi-colon")
      )}
  })
  
  #This function is repsonsible for loading in the selected file
  filedata <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }else{
      dfencode<-guess_encoding(infile$datapath,n_max=-1)
      filedata<-read.table(infile$datapath, sep=sepchar(),
                           encoding=dfencode$encoding[1], header=T, stringsAsFactors=F)
      return(filedata)
    }
  })
  
  datacolumns<-reactive({
    df<-""
      if(!is.null(filedata())){
        df<-names(filedata())
        df<-df[!df %in% colsrestricted]
      }
    
    return(df)
  })
  
  
  
  ErrText<-reactive({
    filedata()
    df<-""
    if(!is.null(filedata())){
      df<-names(filedata())
      df<-colsrequired[!colsrequired %in% df]
      if(length(df)>0){
        df<-paste(df,collapse=", ")
        df<-paste0("Missing columns: ",df)
      }
      }
    return(df)
  })
  

  
  # show the item selection for grouping 
  output$selectGroups <- renderUI({
    if(length(datacolumns())>1){
      tagList(selectInput(
        "Group",
        "Select Group Variable(s)",
        choices = datacolumns(),
        #selected = "none",
        multiple = TRUE
      ))
    }else{
      return(NULL)
    }
  })
  
  output$showBlanks <- renderUI({
    ui<-NULL
    if(length(datacolumns())>1){
      if(!is.null(input$Group)){
      ui<-tagList(checkboxInput(
        "chkShowBlanks",
        "Show missing group combinations in results.",
        value=F
      ))}
    }
    return(ui)
  })
  
  showNA<-reactive({
    show<-F
    if(!is.null(input$chkShowBlanks)){
      if(input$chkShowBlanks){
        show<-T
      }
    }
    return(show)
  })
  
  resOverall <- reactive({
    df<-filedata()
    if (is.null(df)){return(NULL)} 
    out<-Assessment(df,2,group_variables=input$Group,showNA())
    return(out)
  })
  resIndicators <- reactive({
    df<-filedata()
    if (is.null(df)){return(NULL)} 
    out<-Assessment(df,1,group_variables=input$Group)    
    return(out)
  })
  resCriteria <- reactive({
    df<-filedata()
    if (is.null(df)){return(NULL)} 
    out<-Assessment(df,3,group_variables=input$Group,showNA())   
    return(out)
  })
  
  InData <- reactive({
    df<-filedata()
    group_variables<-input$Group
    dat<-list(df,group_variables)
    if (is.null(df)){return(NULL)} 
    out<-df 
    return(out)
  })
  
  output$InDatatable <- renderTable({return(InData())},na="")
  
  
  output$dataErrors <- renderText({
    ErrText()
  })
  
  
  output$tblIndicators <- renderTable({
    df<-data.frame()
    Err<-ErrText()
    if(length(Err)==0){
      df<-resIndicators()
    }else if(ErrText()==""){
      df<-resIndicators()
    }
    return(df)
  },na="")
  
    output$tblCriteria <- renderTable({    
      
      df<-data.frame()
      Err<-ErrText()
      if(length(Err)==0){
        df<-resCriteria()
        }else if(ErrText()==""){
        df<-resCriteria()
        }
    return(df)
    },na="")

    output$tblOverall <- renderTable({    
      df<-data.frame()
      Err<-ErrText()
      if(length(Err)==0){
        df<-resOverall()
      }else if(ErrText()==""){
        df<-resOverall()
      }
      return(df)
    },na="")

  
    output$btnCriteria <- renderUI({
    
  })
  
  output$tblOverallJS <- renderUI({
      list(
       tags$head(tags$script(HTML('Shiny.addCustomMessageHandler("jsCode", function(message) { eval(message.value); });')))
        , tableOutput("tblOverall")
      )})
  output$tblCriteriaJS <- renderUI({
    list(
      tags$head(tags$script(HTML('Shiny.addCustomMessageHandler("jsCode", function(message) { eval(message.value); });')))
      , tableOutput("tblCriteria")
    )})

    filesuffix <- reactive({
      if(sepchar() %in% c(",",";")){
        return("csv")
      }else{
        return("txt")
      }
    })
  
  
  # Downloadable file of criteria results ----
  output$downloadCriteria <- downloadHandler(
    filename = function() {
      paste("HEAT_criteria_results.",filesuffix,sep="")
    },
    content = function(file) {
      write.table(resCriteria(),file,row.names=F,sep=sepchar(),quote=F)
    }
  )
  
  # Downloadable file of overall results ----
  output$downloadOverall <- downloadHandler(
    filename = function() {
      paste("HEAT_results.",filesuffix,sep="")
    },
    content = function(file) {
      write.table(resOverall(),file,row.names=F,sep=sepchar(),quote=F)
    }
  )
  
})