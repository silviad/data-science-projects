
load.libraries.functions <- function() {
    #
    # Load libraries and utility functions
    #
  
    # load libraries
    library(tm)
    library(R.utils)
    library(RWeka)
    library(openNLP)
    library(NLP)
    library(openNLPdata)
    library(rJava)    
    library(stringi)
    library(plyr)
    library(data.table)
    library(RSQLite)
    library(DBI)
    library(sqldf)

    # load functions 
    source("preprocessing.R")
    source("ngram_model.R")
    source("interface_db.R")
      
}