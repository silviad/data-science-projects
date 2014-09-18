# load libraries
library(shiny)
library(rworldmap)
library(RColorBrewer)
library(UsingR)

# initial operations
data(wellbeing)  
sPDF <- joinCountryData2Map(wellbeing, joinCode = "NAME", 
                            nameJoinColumn = "Country")
colourPalette <- brewer.pal(5, 'RdPu')


shinyServer(
  
  function(input, output) {

       # load table data
       output$table = renderDataTable({
         wellbeing
       })    
       
       # render measures maps
       output$map <- renderPlot({
           mapParams <- mapCountryData(sPDF, 
                                       nameColumnToPlot = input$Parameter, 
                                       mapTitle = input$Parameter, 
                                       mapRegion = "Europe",
                                       colourPalette = colourPalette, 
                                       addLegend = FALSE, 
                                       missingCountryCol = "grey70",
                                       oceanCol = "lightblue", 
                                       borderCol = "black")       
           do.call(addMapLegend, c(mapParams, legendWidth = 0.5, legendMar = 2, 
                                  legendLabels = "all"))
       
       })

       # render plots
       output$regression = renderPlot({
            formulaLm <- reactive({
            paste("Well.being ~", "as.numeric(", input$Parameter, ")")
            })    
            with(wellbeing, {
                fit <- lm(as.formula(formulaLm()))
                plot(as.formula(formulaLm()), xlab = input$Parameter)
                abline(fit, col = "purple")
            })
       })
       
       # render wellbeing map
       output$wellbeing.map = renderPlot({             
            mapParamsWell <- mapCountryData(sPDF, 
                                            nameColumnToPlot = "Well.being", 
                                            mapTitle = "Well.being", 
                                            mapRegion = "Europe",
                                            colourPalette = colourPalette, 
                                            addLegend = FALSE, 
                                            missingCountryCol = "grey70",
                                            oceanCol = "lightblue", 
                                            borderCol = "black") 
            do.call(addMapLegend, c(mapParamsWell, legendWidth = 0.5, legendMar = 2, 
                                    legendLabels = "all"))
       })
       
  }
)


