library(shiny)

shinyUI(fluidPage(  
    titlePanel("Predictive Text Shiny App"),
    h3("Blogs Style", style = "color:LimeGreen"),
    h4("Instructions"),
    p("1. Please, wait until the three bottoms appear above the green text area before starting to write."),
    p("2. If the three buttons are visible, it is possible to start writing in the text area."),
    p("3. Press the buttons to use these words to complete the sentence."),
    p("4. Press the Reset button to clean the text area."),
    br(),
    br(),
    fluidRow(column(1, uiOutput("uiActionButton3"), offset = 1), 
             column(1, uiOutput("uiActionButton2"), offset = 1)),
    br(),
    fluidRow(column(1, uiOutput("uiActionButton1"), offset = 2)),
    br(),
    fluidRow(column(1, uiOutput("reset"), offset = 4)),
    fluidRow(column(12, tags$textarea(id="sentence", rows="5", cols="50", 
                            style = "background-color:LimeGreen"), offset = 1))
    
))
