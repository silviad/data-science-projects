
load.libraries.functions <- function() {
    #
    # Load libraries and utility functions
    #
  
    # load libraries
    suppressWarnings(library(plyr))   
    suppressWarnings(library(stringr))
    suppressWarnings(library(data.table))
    
    # load functions
    source("ngram_model.R")
}