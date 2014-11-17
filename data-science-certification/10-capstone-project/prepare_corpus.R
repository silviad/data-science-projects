# prepare a corpus for the exploratory analysis repo

prepare.corpus <- function(file.pattern, size, ngram = 4, step = "extract") { 
  
    # sample files
    if (step == "extract") {
        extract.sample.files(file.pattern, size)
        step = "clean"
    }
    # clean files
    if (step == "clean") {
        clean.bad.char()
        step = "ngram"
    }
    # create corpus and n-grams matrix
    if (step == "ngram") {
        docs <- create.corpus()
        tdm.list <- lapply(c(1:ngram), function(x) {tokenizer(x, docs)})    
    }    
    return(tdm.list)
    
  }