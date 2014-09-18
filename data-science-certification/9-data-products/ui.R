library(shiny)

shinyUI(fluidPage(
    navbarPage("What makes us happy?",
        tabPanel("Introduction",
            titlePanel("Wellbeing in Europe"),
            h4("Documentation"),
            p("Before using this application, please read this short documentation:",
               a("Project",href="index.html")),
            p(""),
            h4("Data set"),
            p("The data used for this analysis is the data set wellbeing of the package UsingR. ",
              "The data set is about what makes people happy (well being) in Europe. ",
              "It contains 22 observations, one for each different country. ",
              "Each observation has 12 variables described in the table below:"),
            p(""),
            fluidRow(column(2,"1. Country."), 
                     column(4,"Name of the country."), 
                     column(3,"Type: factor.")),
            fluidRow(column(2,"2. Well.being"), 
                     column(4,"Well being level." ), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"3. GDP."), 
                     column(4,"Gross domestic product per person (US$)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"4. Equality."), 
                     column(4,"Equality (based on GINI index)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"5. Food.consumption."), 
                     column(4,"Food supply (kCal per day per person)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"6. Alcohol.consumption."), 
                     column(4,"Alcohol consumption (litres of pure alchohol per year per person)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"7. Energy.consumption."), 
                     column(4,"Residential electricity use (kWh per year per person)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"8. Family."), 
                     column(4,"Fertility (children per women)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"9. Working.hours."), 
                     column(4,"Average working hours per week per person."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"10. Work.income."), 
                     column(4,"Hourly pay per person (US$)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"11. Health.spending."), 
                     column(4,"Government health spending (% of government spend)."), 
                     column(3,"Type: numeric.")),
            fluidRow(column(2,"12. Military.spending."), 
                     column(4,"Military spending (% of GDP)."), 
                     column(3,"Type: numeric.")),
            h4("References"),
            p("Well-being data is from the New Economics Foundation's ", 
              a("National Accounts of Well-being", href="http://www.nationalaccountsofwellbeing.org/"))
        ),
        tabPanel("Data",
            titlePanel("The dataset"),
            p("The table below shows the wellbeing dataset."),
            dataTableOutput('table')    
        ),
        tabPanel("Analysis",
            titlePanel("The analysis"),
            p("Exploratory analysis of the relationship between well-being and economic/social measures."),            
            sidebarLayout(
                sidebarPanel(     
                    radioButtons("Parameter", label ="Well-being measure",
                         choices = c("GDP" = "GDP",
                                     "Equality" = "Equality",
                                     "Food Consumption" = "Food.consumption",
                                     "Alcohol Consumption" = "Alcohol.consumption",
                                     "Energy Consumption" = "Energy.consumption",  
                                     "Family" = "Family",  
                                     "Working Hours" = "Working.hours",  
                                     "Work Income" = "Work.income",	
                                     "Health Spending" = "Health.spending",	
                                     "Military Spending" = "Military.spending"
                                     )
                        )
                ),
                mainPanel(
                    tabsetPanel(type = "tabs",                        
                        tabPanel("Regression", plotOutput('regression')),
                        tabPanel("Map", plotOutput('map'))
                    )
                )
            )
        ),
        tabPanel("Wellbeing Map",
            titlePanel("The Map"),
            p("The map below shows the total wellbeing distribution around Europe."),  
            fluidRow(column(7,plotOutput('wellbeing.map')))
        ),
        tabPanel("Code",
            titlePanel("The code"), 
            p("The source code is available here:", 
              a("GitHub repo", href="https://github.com/silviad/wellbeingcode"))
        )
   )
))