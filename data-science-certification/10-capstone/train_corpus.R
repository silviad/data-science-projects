# train more corpus and put all together to manage memory problems

train.corpus <- function(file.pattern, size, chunk, colour, ngram = 4, 
                         step = "extract") { 
    
    # prepare files 
    if (step == "extract") {
        extract.sample.files(file.pattern, size, chunk)
        step = "clean"
    }
    if (step == "clean") {
        clean.bad.char()
        step = "ngram"
    }
    if (step == "ngram") {
        # create a list of term document matrix
        tdm.list <- get.list.tdm(ngram, colour)
        df.list <- list()
        # transform term document matrix in data frame
        for (n in 1:ngram) {
            tdm <- tdm.list[[n]]            
            total <- display.summaries(tdm, n)
            display.barplot(tdm, n, colour)
            df.list[[n]] <- create.dataframe(total, n)    
            write.csv(as.matrix(df.list[[n]]), file=paste("gram", n, ".csv", 
                                                           sep =""))
        } 
        remove(tdm.list)
        gc()
    }
    return(df.list)
    
}

# create a list of term document matrix

get.list.tdm <- function(ngram, colour, dirout = "sample") { 
 
    files <- list.files(dirout)    
    first <- TRUE
    tdm.list <- list()
    
    for (file in files) {
        #print(paste(file, date(), sep = " "))
        # create a corpus for each chuncks
        docs <- create.corpus(file.pattern = file)
        for (n in 1:ngram) {
            # create n-grams token and bind with the same n-gram of the other chunks
            tdm <- tokenizer(n, docs)
            if (first) {         
               tdm.list[[n]] <- tdm
            }
            else {
               tdm.list[[n]] <- c(tdm.list[[n]], tdm) 
            }
            remove(tdm)
        }
        first <- FALSE
        remove(docs)
        gc()
    }
    return(tdm.list)
  
}

# train a corpus

train.corpus.one <- function(file.pattern, size, colour, ngram = 4, 
                             step = "extract") { 
  
    # prepare files 
    if (step == "extract") {
        extract.sample.files(file.pattern, size)
        step = "clean"
    }
    if (step == "clean") {
        clean.bad.char()
        step = "ngram"
    }
    if (step == "ngram") {
        docs <- create.corpus()
        tdm.list <- list()
        for (n in 1:ngram) {
            tdm  <- tokenizer(n, docs)
            total <- display.summaries(tdm, n)
            display.barplot(tdm, n, colour)
            tdm.list[[n]] <- create.dataframe(total, ngram)
            write.csv(as.matrix(tdm.list[[n]]), file=paste("gram", n, ".csv", 
                                                           sep =""))
        }        
    }    
    return(tdm.list)
    
}

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
        tdm.list <- lapply(c(1:ngram), function(x) 
                            {tokenizer(x, docs)})    
    }    
    return(tdm.list)
  
}