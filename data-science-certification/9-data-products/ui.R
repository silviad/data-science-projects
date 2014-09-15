library(shiny)

shinyUI(
    navbarPage("What makes us happy?",
        tabPanel("Introduction",
            titlePanel("Wellbeing in Europe"),
            h4("Documentation"),
            p("Before usign this application, please read this short documentation"),
            a("http://silviad.github.io/wellbeingdoc/documentation"),  
            p(""),
            h4("Data set"),
            p("The data used for this analysis is the data set wellbeing of the package UsingR. ",
              "The data set is about what makes people happy (well being) in Europe. ",
              "It contains 22 observations, one for each different country. ",
              "Each observation has 12 variables described in the table below:"),
            p("Country. Name of the country. Type: factor."),
            p("Well.being. Well being level. Type: numeric."),
            p("GDP. Gross domestic product per person (US$). Type: numeric."),
            p("Equality. Equality (based on GINI index). Type: numeric. ",
              "Value: from 0 = low equality to 100 = high equality."),
            p("Food.consumption. Food supply (kCal per day per person). Type: numeric."),
            p("Alcohol.consumption. Alcohol consumption (litres of pure alchohol ",
              "per year per person). Type: numeric."),
            p("Energy.consumption. Residential electricity use (kWh per year per person).",
              " Type: numeric."),
            p("Family. Fertility (children per women). Type: numeric."),
            p("Working.hours. Average working hours per week per person. Type: numeric."),
            p("Work.income. Hourly pay per person (US$). Type: numeric."),
            p("Health.spending. Government health spending (% of government spend). Type: numeric."),
            p("Military.spending. Military spending (% of GDP). Type: numeric."),
            
            h4("References"),
            a("http://prcweb.co.uk/lab/what-makes-us-happy/"),
            p(""),
            a("http://www.nationalaccountsofwellbeing.org/")
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
            plotOutput('wellbeing.map')
        ),
        tabPanel("Code",
            titlePanel("The code"), 
            p("The source code is available here:"),
            a("https://github.com/silviad/wellbeingcode")
        )
   )
)