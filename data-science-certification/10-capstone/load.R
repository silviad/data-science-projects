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
    library(qdap)
    library(stylo)
    library(wordcloud)
    #library(koRpus)
    #library(tm.plugin.dc)
    #library(hive)

    # load utility functions
    source("file_preprocessing.R")
    source("text_preprocessing.R")
    source("train_corpus.R")
    source("model_building.R")
    source("KNsmoothing.R")
    
}