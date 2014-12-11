library(shiny)

shinyUI(fluidPage(
  
    titlePanel("Predictive Text Shiny App"),
    tags$style("body {background-color: Gold;}"),
    h5("Twitter Style"),
    fluidRow(column(1, uiOutput("uiActionButton3"), offset = 2), 
             column(1, uiOutput("uiActionButton2"), offset = 1)),
    fluidRow(column(1, uiOutput("uiActionButton1"), offset = 3)),
    h5("Type a sentence:"),
    fluidRow(column(12,tags$textarea(id="sentence", rows="5", cols="50"), offset = 2))
    
))
