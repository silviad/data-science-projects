# Create and prepare the corpus

create.corpus <- function(dir = "sample", file.pattern = "*.*") {    
  
    # create the corpus
    #print(paste("create corpus", date()))
    docs <- Corpus(DirSource(dir, encoding = "UTF-8", pattern = file.pattern), 
                     readerControl = list(language = "en"))   
    #print(paste("clean corpus", date()))
    # cleaning the corpus
    docs <- tm_map(docs, content_transformer(tolower))
    docs <- tm_map(docs, removeNumbers)
    docs <- tm_map(docs, removePunctuation) 
    
    # only for exploratory analysis
    docs <- tm_map(docs, removeWords, stopwords("english")) 
    
    #removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
    #docs <- tm_map(docs, removeWords, removeURL)
    profanity <- read.table("profanity.txt")
    names(profanity) <- "badword"
    profanity <- as.vector(profanity$badword)
    docs <- tm_map(docs, removeWords, profanity)
    docs <- tm_map(docs, stripWhitespace)
    # return the corpus
    return(docs)     
  
}

# Tokenize corpus and analyze n-gram tokens

tokenizer <- function(ngram, docs) { 
  
  #print(paste("tokenize", date()))
    # create Term Document Matrix for n.grams
    tokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngram, 
                                                            max = ngram))
    tdm <- TermDocumentMatrix(docs, control = list(tokenize = tokenizer
                                                   #wordLengths = c(1, Inf)
                                                   ))
    # remove sparse term
    #print(paste("remove sparse", date()))
    tdm <- removeSparseTerms(tdm, 0.1)
    # return Term Document Matrix  
    return(tdm)
}

# Plots and statistics for n-grams tokens

display.barplot <- function(tdm, ngram, colour, maxgram = 30) { 
    
    total <- rowSums(as.matrix(tdm))
    mostfreq <- head(sort(total, decreasing=TRUE), maxgram)
    # display a barplot of ngram counts
    title <- paste(maxgram, "most frequent", ngram, "ngram", sep = " ")
    barplot(mostfreq, main = title, xlab= "Frequency", col = colour, 
            horiz = TRUE, las = 2)
    # returns frenquencies to create a dataframe
    return(total)
}  

display.summaries <- function(tdm, ngram, maxgram = 30) { 
  
    # create a matrix
    tdm.matrix <- as.matrix(tdm)
    # display summary statistics of ngram counts
    print(paste("Total number of", ngram, "ngram:", nrow(tdm.matrix), sep = " "))
    print(paste("Frequency of the", maxgram, "most frequent", ngram, 
                "ngrams", sep = " "))               
    total <- rowSums(tdm.matrix)
    mostfreq <- head(sort(total, decreasing=TRUE), maxgram)
    print(mostfreq)
    # returns frenquencies to create a dataframe
    return(total)
}  

display.clouds <- function(list) {  
  
    # display word clouds
    set.seed(375) 
    par(mar=c(1,1,1,1), mfrow=c(1,3))
    res <- lapply(list, function (x) {
      freq <- sort(rowSums(as.matrix(x)), decreasing=TRUE)[1:150]
      wordcloud(words=names(freq), scale=c(7,2), freq=freq, min.freq=3, 
                random.order=FALSE, colors=brewer.pal(8,"Dark2"))
    })
  
}

# Create n-grams dataframe
  
create.dataframe <- function(total, ngram) {   
    
    # create a data frame
    #print(paste("dataframe", date()))
    tdm.df <- data.frame(grams=names(total), total)
    #print(paste(ngram, "n-grams", nrow(tdm.df), sep = " "))
    l <- strsplit(as.character(tdm.df$grams), " ")
    if (ngram > 1) {
        #print(ngram)
        tdm.df$first <- lapply(l, function(x) paste(x[1:ngram-1], 
                                                    collapse = " "))
        tdm.df$second <- lapply(l, function(x) x[ngram]) 
    }
    return(tdm.df)
  
}

