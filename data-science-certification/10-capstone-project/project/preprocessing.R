#
# Procedures for creating a corpus, preparing ngrams and loading ngrams 
# on temporary SQLite tables where prunining and refining words
#

# Set constants
maxngram <- 4   # max ngrams
dir.file <- "sample"  # temporary working directory

preproc.corpus.refine <- function(step="profanity") {
    #
    # Main procedure. Refine corpus
    #  
    # Args:
    #   step:  step from which to restart
    #
    # apply profanity filter 
    if (step == "profanity") {
        print(paste(step, date()))
        profanity.filter()
        step = "prune.unigram"
    }
    # prune unigrams
    if (step == "prune.unigram") {
        print(paste(step, date()))
        prune.unigrams()
        step = "POS"
    }  
    # add POS tag
    if (step == "POS") {
        print(paste(step, date()))
        add.POStag()
        step = "prune"
    } 
    # add ngrams
    if (step == "prune") {
        print(paste(step, date()))
        prune.ngrams()
        step = "update.word.numbers"
    }    
    # generate numbers code for words in order to substitute strings with numbers
    if (step == "update.word.numbers") {
        print(paste(step, date()))
        update.word.numbers()
        step = "write.file"
    }  
    # load data from SQLite tables to final RDS files
    if (step == "write.file") {
        print(paste(step, date()))
        write.file.from.sqlite()
        step = "end"
    }   
}


preproc.corpus <- function(file.pattern, size, chunk=size, step="extract") {   
    #
    # Main procedure. Create corpus. 
    # Split the initial file in small subfiles.
    #  
    # Args:
    #   file.pattern:  pattern of files to read
    #   size:          number of lines to extract in total
    #   chunk:         number of lines for each subfiles
    #   step:          step from which to restart
  
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
        tdm.list <- get.list.matrix()
        # transform term document matrix in data frame
        for (n in 1:maxngram) { 
            # create a dataframe
            tdm.df <- create.dataframe(tdm.list[[n]], n) 
            # write the dataframe in a file
            print(paste("rds writing", date()))
            saveRDS(tdm.df, paste0(dir.file, "/samplegram", n, ".rds"))
            # garbage collector
            remove(tdm.df)
            gc()
        }  
        step = "db"
    }
    # load n-grams file into the db
    if (step == "db") {
        print(paste("load db", date()))
        load.sqlite.from.rds()
    }
}


get.list.matrix <- function() {   
    #
    # Create a list of term document matrix
    #  
    # Returns: a list of term document matrix
    #
    first <- TRUE
    tdm.list <- list()   
    files <- list.files(dir.file)     
    for (file in files) {
        print(paste(file, date()))
        # create a corpus for each chuncks
        docs <- create.corpus(file)
        print(paste("bind matrix", date()))      
        for (n in 1:maxngram) {
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
    #
    # Create a data frame to load on SQLite db
    #  
    # Args:
    #   df: term document matrix of frequencies 
    #   ngram: number of grams 
    #
    # Returns: a data frame
    #
    print(paste("dataframe", date()))   
    word <- colnames(df)
    total <- df[1,]
    if (ngram == 1) {
        tdm.df <- data.frame(total=as.integer(total), word)
        tdm.df$POStag <- ""
        tdm.df$wordcode <- seq(from = 1, to = nrow(tdm.df))       
        print(paste("dataframe created", date()))
    }
    else {
        l <- strsplit(as.character(word), ' (?=[^ ]+$)', perl=TRUE)
        l[sapply(l, is.null)] <- ""       
        first <- sapply(l, "[", 1)
        word <- sapply(l, "[", 2)
        tdm.df <- data.frame(total=as.integer(total), first, word)   
        print(paste("dataframe created", date()))
        if (ngram == 3) {            
            l <- strsplit(as.character(first), ' (?=[^ ]+$)', perl=TRUE)
            tdm.df$word1str <- sapply(l, "[", 1)
            tdm.df$word2str <- sapply(l, "[", 2)
        }
        else if (ngram == 4) {            
            l <- strsplit(as.character(first), ' (?=[^ ]+$)', perl=TRUE)
            first <- sapply(l, "[", 1)
            word3 <- sapply(l, "[", 2)            
            l <- strsplit(as.character(first), ' (?=[^ ]+$)', perl=TRUE)
            tdm.df$word1str <- sapply(l, "[", 1)
            tdm.df$word2str <- sapply(l, "[", 2)        
            tdm.df$word3str <- word3
        }
        print(paste("split done", date()))
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


extract.sample.files <- function(file.pattern, size, chunck = size) {  
    #
    # File sample extraction
    #  
    # Args:
    #   file.pattern:  pattern of files to read (usaully one file at a time)
    #   size:          number of lines to extract in total
    #   chunk:         number of lines for each subfiles
    #    
    print(paste("extract.sample.files", date()))
    dir.original.file <- "document"
    set.seed(5305)    
    # remove old files
    files.out <- list.files(dir.file)
    if (length(files.out) != 0) {
        files.out <- paste(dir.file, files.out, sep = "/")
        res <- lapply(files.out, function(x) {file.remove(x)})      
    }    
    # exctract sample
    files <- list.files(dir.original.file, pattern = file.pattern)    
    res <- lapply(files, function(x) {      
        # read the file
        file.name <- paste(dir.original.file, x, sep = "/")
        res <- system(paste("wc -l", file.name, sep = " "), intern = TRUE)
        line.count <- unlist(strsplit(res, " "))[1]
        data.file <- readLines(file.name)
        data.file <- data.file[sample(1:line.count, size, replace = FALSE)]  
        # write file or subfiles with the sample data
        write.files(x, data.file, size, chunck) 
  })
}


write.files <- function(file, data.file, size, chunck) {
    #
    # Write a single file or a file divided in chunks
    #  
    # Args:
    #   file:      name of the file to write 
    #   data.file: data to write 
    #   size:      number of lines to extract in total
    #   chunk:     number of lines for each subfiles
    #  
    print(paste("write.files", date()))
    if (chunck == size) {
        output.file <- paste(dir.file, paste("sample", file, sep ="."), sep ="/")           
        write(data.file, output.file)          
    }
    else {
        # for sentence classification
        output.file <- paste("sample_archive", paste("sample", file, sep ="."), sep ="/")           
        write(data.file, output.file)  
        ini <- 1
        end <- ini + chunck - 1
        while (end <= size) {
            # write the file in the output directory
            output.file <- paste(dir.file, paste("sample", ini, file, sep = "."),
                                 sep = "/")  
            write(data.file[ini:end], output.file)
            ini <- end + 1
            end <- ini + chunck - 1
        }         
    }
}


clean.bad.char <- function() {  
    #
    # Clean bad characters of all files in the working directory
    # 
    print(paste("clean.bad.char", date()))
    files <- list.files(dir.file)    
    res <- lapply(files, function(x) {
        # read the file
        name.file <- paste(dir.file, x, sep = "/")
        con <- file(name.file, "r") 
        data.file <- readLines(con)
        close(con)  
        # clean
        data.file <- stri_trans_general(data.file, "en_US")
        data.file <- gsub('[])(;:#%$^*\\~{}[&+=@/"`|<>_]+', " ", data.file)
        data.file <- gsub("[¤º-»«Ã¢â¬Å¥¡Â¿°£·©Ë¦¼¹¸±???ð\u201E\u201F\u0097\u0083\u0082\u0080\u0081\u0090\u0095\u009f\u0098\u008d\u008b\u0089\u0087\u008a?????????.]+", " ", data.file)
        data.file <- gsub("[\002\020\023\177\003]", "", data.file)    
        # save update file
        write(data.file, name.file)
  })
}


create.corpus <- function(name.file) {    
    #
    # Create and clean the corpus from a file
    #  
    # Args:
    #   name.file:  file from which create the corpus
    #   
    # Returns: a corpus
    # 
    # create the corpus
    print(paste("create corpus", date()))
    docs <- Corpus(DirSource(dir.file, encoding = "UTF-8", pattern = name.file), 
                   readerControl = list(language = "en"))   
    # cleaning the corpus
    print(paste("clean corpus", date()))
    docs <- tm_map(docs, content_transformer(tolower))
    docs <- tm_map(docs, removeNumbers)
    #docs <- tm_map(docs, removePunctuation) 
    regexp <- "(?!['|\\r|\\n|\\t|.|,|;|:|\"|(|)|?|!])[[:punct:]]+"
    removePunctuationExApo <- function(x) {
        x <- gsub("(\\w)-(\\w)", "\\1\1\\2", x)
        x <- gsub(regexp, "", x, perl=TRUE)
        x <- gsub("\1", "-", x, fixed = TRUE)
    }
    docs <- tm_map(docs, content_transformer(removePunctuationExApo))   
    #removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
    #docs <- tm_map(docs, removeWords, removeURL)
    docs <- tm_map(docs, stripWhitespace)
    return(docs)      
}


tokenizer <- function(ngram, docs) { 
    #
    # Tokenize corpus and create n-grams term document matrix
    #  
    # Args:
    #   ngram:  number of grams
    #   docs:   corpus
    #   
    # Returns: a term document matrix
    # 
    print(paste("tokenize", date()))
    # create Term Document Matrix for n.grams
    tokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngram, 
                                                            max = ngram,
                                                            delimiters = " \\r\\n\\t.,;:\"()?!"))
    tdm <- DocumentTermMatrix(docs, control = list(tokenize = tokenizer,
                                                   wordLengths = c(1, Inf)))
    # remove sparse term
    tdm <- removeSparseTerms(tdm, 0.1)
    return(tdm)
}






