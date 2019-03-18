
library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)

ui <- 
  shinyUI(
    fluidPage(
      
      titlePanel("HEAT 3.0 Eutrophication Assessment"),
      sidebarLayout(
        sidebarPanel(
          fileInput('datafile', 'Choose input file'),
          uiOutput('selectSepChar'),
          uiOutput('selectGroups'),
          uiOutput('showBlanks'),
          #uiOutput('selectIndicator'),
          
          withTags({
            div(class="header", checked=NA,
          h4("Instructions"),
          p("Select the file containing input data for the assessment.
            The file must be in text format and column headers must be included.
            The required columns are:"),
          ul(
            li(HTML("<b>Criteria</b>"),": text, category of indicator - nutrients, direct effects or indirect effects"),
            li(HTML("<b>Indicator</b>"),": text, indicator name or decription"),
            li(HTML("<b>Target</b>"),": value, the boundary between eutrophic and non-eutrophic status"),
            li(HTML("<b>Status</b>"),": value, the observed status of the indicator"),
            li(HTML("<b>Response</b>"),": value, 1 or -1 (alternatively: text '+' or '-')")
          ),
          p("The following columns are optional:"),
          ul(
            li(HTML("<i>grouping columns e.g. Waterbody ID</i>"),
            li(HTML("<b>Weight</b>"," : value, relative weight assigned to indicator within Criteria group")),
            li(HTML("<b>Conf_Target</b>"," : Confidence rating for Target value"), 
               HTML("(<b>L</b>ow, <b>M</b>edium, <i>or</i> <b>H</b>igh.)")),
            li(HTML("<b>Conf_Status</b>"," : Confidence rating for Status value"), 
               HTML("(<b>L</b>ow, <b>M</b>edium, <i>or</i> <b>H</b>igh.)"))
            )
          ),
          h4("Grouping"),
          p("If grouping columns are specified, separate assessments are made for each unique combination of group variables. 
            If no grouping columns are specified, all indicators are combined in a single assessment unit."),
          p("For each assessment, indicators are aggregated within criteria. The criteria having the highest (worst)",
            " Eutrophication Ratio (ER) determines the overall assessment result."),
          h4("Confidence"),
          p("If both columns", HTML("<b>Conf_Target</b>"), " and ",HTML("<b>Conf_Status</b>"), " are present,",
            " then a confidence assessment will be made, in addition to the primary status assessment. ") )
            
            })
          
          
        ),

        mainPanel(
          tabsetPanel(
            tabPanel("Data", 
                     fluidRow(
                       column(9,h3(textOutput("dataErrors"), style="color:red"))
                     ),
                     fluidRow(
                       column(9,tableOutput("InDatatable"))
                       )),
            tabPanel("Indicators",
                     fluidRow(
                       column(9,h3(""))),
                     fluidRow(
                       column(9,tableOutput("tblIndicators"))
                     )
            ),
            tabPanel("Criteria",
                     fluidRow(
                       column(9,h3(""))),
                     fluidRow(
                       column(8,uiOutput("tblCriteriaJS")),
                       column(1,downloadButton("downloadCriteria", "Download"))
                     )
            ),
            tabPanel("Overall",
                     fluidRow(
                       column(9,h3(""))),
                     fluidRow(
                       column(8,uiOutput("tblOverallJS")),
                       column(1,downloadButton("downloadOverall", "Download"))
                     )
                     )
            
            )) # tabsetPanel
        )
      )
  )