
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
            li("Criteria"),
            li("Indicator"),
            li("Target"),
            li("Status"),
            li("Response")
          ),
          p("The following columns are optional:"),
          ul(
            li("Weight"),
            li(HTML("<i>grouping columns e.g. Waterbody ID</i>"))
          ),
          
          p("If grouping columns are specified, separate assessments are made for each unique combination of group variables. 
            If no grouping columns are specified, all indicators are combined in a single assessment unit."),
          p("For each assessment, indicators are aggregated within criteria. The criteria having the highest (worst) Eutrophication Ratio determines the overall assessment result."),
          p("Download example data from Andersen et al. (2017)",HTML("<a href='andersen_et_al_2017_biol_rev.csv' target='_blank'>here</a>.")),
          p("For more information, see ",HTML("<a href='https://onlinelibrary.wiley.com/doi/full/10.1111/brv.12221' target='_blank'>Andersen et al. (2017)
                                              <i>Biol. Rev. </i>92, 135–149. doi: 10.1111/brv.12221</a>")),
            p("or contact:", HTML("<a href='https://niva-denmark.dk' target='_blank'>https://niva-denmark.dk</a>"))
            )})
        ),

        mainPanel(
          tabsetPanel(
            tabPanel("Data", tableOutput("InDatatable")),
            tabPanel("Indicators",
                     fluidRow(
                       column(6,tableOutput("tblIndicators"))
                     )
            ),
            tabPanel("Criteria",
                     fluidRow(
                       column(6,uiOutput("tblCriteriaJS")),
                       column(2,downloadButton("downloadCriteria", "Download"))
                     )
            ),
            tabPanel("Overall",
                     fluidRow(
                       column(6,uiOutput("tblOverallJS")),
                       column(2,downloadButton("downloadOverall", "Download"))
                     )
                     )
            
            )) # tabsetPanel
        )
      )
  )