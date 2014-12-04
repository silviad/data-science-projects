# load libraries
library(shiny)
source("load_shiny.R")
load.libraries.functions()

shinyServer(function(input, output, session) {
  
    words <- reactive({    
        sentence <- input$sentence
        style <- input$style
        ngram.model(sentence=sentence, style=style)       
    })
  
    output$uiActionButton1 <- renderUI({  
        word <- words()[1] 
        wordChunk <- words()[4]
        buttonClick <- paste("$('#sentence').val($('#sentence').val() + '", wordChunk, " ').trigger('change')", sep='')
        #buttonClick <- paste("$('#sentence').val($('#sentence').val() + ' ", word, "').trigger('change')", sep='')
        tags$button(type="button", id="word1", word, class="btn action-button shiny-bound-input" ,
                    onclick=buttonClick,  style ="color: Indigo")     
     })
      
    output$uiActionButton2 <- renderUI({      
      word <- words()[2]
      wordChunk <- words()[5]
      buttonClick <- paste("$('#sentence').val($('#sentence').val() + '", wordChunk, " ').trigger('change')", sep='')
      #buttonClick <- paste("$('#sentence').val($('#sentence').val() + ' ", word, "').trigger('change')", sep='')
      tags$button(type="button", id="word2", word, class="btn action-button shiny-bound-input" ,
                  onclick=buttonClick, style ="color: purple")
    
    })
    
    output$uiActionButton3 <- renderUI({      
      word <- words()[3]
      wordChunk <- words()[6]
      buttonClick <- paste("$('#sentence').val($('#sentence').val() + '", wordChunk, " ').trigger('change')", sep='')
      #buttonClick <- paste("$('#sentence').val($('#sentence').val() + ' ", word, "').trigger('change')", sep='')
      tags$button(type="button", id="word3", word, class="btn action-button shiny-bound-input" ,
                  onclick=buttonClick, style ="color: Orchid")
      
    })   

})
