# train more corpus and put all together to manage memory problems

preproc.corpus <- function(file.pattern, size, chunk=size, ngram=4, 
                           step="extract") { 
    # sample files 
    if (step == "extract") {
        extract.sample.files(file.pattern, size, chunk)
        step = "clean"
    }
    # clean files
    if (step == "clean") {
        clean.bad.char()
        step = "ngram"
    }
    # create corpus and n-grams matrix
    if (step == "ngram") {
        # create a list of term document matrix
        tdm.list <- get.list.matrix(ngram)
        # transform term document matrix in data frame
        for (n in 1:ngram) { 
            # create a dataframe
            tdm.df <- create.dataframe(tdm.list[[n]], n) 
            # write the dataframe in a file
            write.RDS(tdm.df, n)
            # garbage collector
            remove(tdm.df)
            gc()
        }  
        step = "db"
    }
    # save n-grams file in the db
    if (step == "db") {
        load.sqlite.from.rds()
    }
}


# create a list of term document matrix

get.list.matrix <- function(ngram, dirout = "sample") {   
    first <- TRUE
    tdm.list <- list()   
    files <- list.files(dirout)     
    for (file in files) {
      print(paste(file, date(), sep = " "))
      # create a corpus for each chuncks
      docs <- create.corpus(file.pattern = file)
      print(paste("bind matrix", date()))      
      for (n in 1:ngram) {
          # create n-grams token and bind with the other n-grams tokens
          tdm <- tokenizer(n, docs)
          mtx <- matrix(tdm, nrow=1)
          colnames(mtx) <- colnames(tdm)       
          if (first) {         
            tdm.list[[n]] <- mtx
          }
          else {            
            tdm.list[[n]] <- t(as.matrix(colSums(do.call(rbind.fill.matrix, 
                                                         list(mtx, tdm.list[[n]])), na.rm=T)))
          }
          # garbage collector
          remove(mtx)
          remove(tdm)
          gc() 
      }
      first <- FALSE
      # garbage collector
      remove(docs)
      gc()
    }
    return(tdm.list)  
}


create.dataframe <- function(df, ngram) {   
  
    # convert to data.frame
    print(paste("dataframe", date()))   
    word <- colnames(df)
    total <- df[1,]
    if (ngram == 1) {
        tdm.df <- data.frame(total, word)
        print(paste("dataframe created", date()))
    }
    else {
        l <- strsplit(as.character(word), ' (?=[^ ]+$)', perl=TRUE)
        l[sapply(l, is.null)] <- " "       
        print(paste("split", date()))
        first <- sapply(l, "[", 1)
        print(paste("extract first", date()))
        word <- sapply(l, "[", 2)
        print(paste("extract word", date()))
        tdm.df <- data.frame(total, first, word)
        print(paste("dataframe created", date()))
        # garbage collector
        remove(l) 
        remove(first) 
        remove(word)
        gc()
    }   
    
    # garbage collector
    remove(total)
    gc()  
    
    return(tdm.df)  
}

