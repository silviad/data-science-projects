library(shiny)

shinyUI(fluidPage(
  
    #tags$style("body {background-color: OldLace;}"),
    titlePanel("Predictive Text Shiny App"),
    br(),
    h4("Instructions"),
    p("Before using this application, please read this short documentation:",
      a("User Guide", href="index.html")),   
    br(),
    br(),
    h4("Choose a style:"),
    p(a("Twitter", href="https://silviad.shinyapps.io/shiny_app_twitter")),
    p(a("Blogs", href="https://silviad.shinyapps.io/shiny_app_blogs")),
    p(a("News", href="https://silviad.shinyapps.io/shiny_app_news")),
    br(),
    br(),
    br(),
    br(),
    br(),
    h4("Useful documentation"),
    p("The exploratory analysis is available here:", 
      a("exploratory analysis", href="http://rpubs.com/silviad/datasciencereport")),    
    p("The deck slide presentation is available here:", 
      a("presentation", href="http://rpubs.com/silviad/predictiveappslide")),    
    p("The source code is available here:", 
      a("GitHub repo", href="https://github.com/silviad/data-science-projects/tree/master/data-science-certification/10-capstone-project"))
              
))
