# load libraries and utility functions

load.libraries.functions <- function() {
  
    # load libraries
    library(tm)
    library(R.utils)
    library(SnowballC)
    library(RWeka)
    library(openNLP)
    library(NLP)
    library(openNLPdata)
    library(rJava)    
    library(stringi)
    library(plyr)
    #library(qdap)
    library(data.table)
    library(RSQLite)
    library(DBI)
    library(sqldf)

    # load utility functions preprocess
    source("preproc_main.R")
    source("preproc_file.R")
    source("preproc_corpus.R")
    
    # load utility functions model
    source("model_main.R")
    source("model_POS.R")
    source("interface_db.R")
}