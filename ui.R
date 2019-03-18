
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
            li(HTML("<b>Weight</b>"," : value, relative weight assigned to indicator within Criteria group")),
            li(HTML("<i>grouping columns e.g. Waterbody ID</i>"),
            li(HTML("<b>Conf_Target</b>"," : Condidence rating for Target value"), 
               HTML("(<b>L</b>ow, <b>M</b>edium, <i>or</i> <b>H</b>igh.)")),
            li(HTML("<b>Conf_Status</b>"," : Condidence rating for Status value"), 
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
            " then a confidence assessment will be made, in addition to the primary status assessment. ", 
            "For more information on the confidence assessment method, see Fleming-Lehtinen et al. (2015)"),           
          
          h4("Example data"),
          p("Example data from Fleming-Lehtinen et al. (2015) includes Confidence assessment. Download it",HTML("<a href='Fleming-Lehtinen_et_al_2015_ecol_ind.csv' target='_blank'>here</a>."),
          "Download example data from Andersen et al. (2017)",HTML("<a href='andersen_et_al_2017_biol_rev.csv' target='_blank'>here</a>.")),
          h4("More information"),
          p(HTML("Andersen et al. (2017) <i>Biol. Rev. </i>92, 135–149.<br>"),
            HTML("<a href='https://onlinelibrary.wiley.com/doi/full/10.1111/brv.12221' target='_blank'>doi: 10.1111/brv.12221</a>")),
          p(HTML("Fleming-Lehtinen et al. (2015) <i>Ecol. Indic. </i>48 , pp. 380-388.<br>"),
            HTML("<a href='https://doi.org/10.1016/j.ecolind.2014.08.022' target='_blank'>doi: 10.1016/j.ecolind.2014.08.022</a>")),
          h4("R code"),
          p("Download the ", HTML("<a href='HEAT3.0_R-code.zip' target='_blank'>HEAT 3.0 R code</a>."))
            )
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