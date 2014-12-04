# load libraries and utility functions

load.libraries.functions <- function() {
  
    # load libraries
    library(RSQLite)
    library(DBI)
    library(sqldf)
    library(plyr)   
    library(R.utils)
    
    # load utility functions model
    source("model_main.R")
    source("interface_db.R")
}