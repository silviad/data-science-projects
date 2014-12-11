library(shiny)

shinyUI(fluidPage(
  
    titlePanel("Predictive Text Shiny App"),
    
    h4("Instructions"),
    p("Before using this application, please read this short documentation:",
      a("User Guide",href="index.html")),
    
    tags$style("body {background-color: OldLace;}"),
    h3("Choose a style:"),
    p(a("Twitter", href="http://silviad.shinyapps.io/shiny_app_test")),
    p(a("Blogs", href="http://silviad.shinyapps.io/shiny_app_test")),
    p(a("News", href="http://silviad.shinyapps.io/shiny_app_test")),
    
    h4("Useful documentation"),
    p("The exploratory analysis is available here:", 
      a("exploratory analysis", href="http://rpubs.com/silviad/datasciencereport")),    
    p("The deck slide presentation is available here:", 
      a("presentation", href="http://rpubs.com/silviad/predictiveappslide")),    
    p("The source code is available here:", 
      a("GitHub repo", href="https://github.com/silviad/data-science-projects/tree/master/data-science-certification/10-capstone-project"))

))
