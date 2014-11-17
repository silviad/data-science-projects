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
    profanity <- read.table("profanity.txt")
    names(profanity) <- "badword"
    profanity <- as.vector(profanity$badword)
    docs <- tm_map(docs, removeWords, profanity)
    
    #removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
    #docs <- tm_map(docs, removeWords, removeURL)
    docs <- tm_map(docs, stripWhitespace)
    # return the corpus
    return(docs)     
  
}

# Tokenize corpus

tokenizer <- function(ngram, docs) { 
  
    #print(paste("tokenize", date()))
    # create Term Document Matrix for n.grams
    tokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngram, 
                                                            max = ngram))
    # only for exploratory analysis
    tdm <- TermDocumentMatrix(docs, control = list(tokenize = tokenizer))
    #tdm <- TermDocumentMatrix(docs, control = list(tokenize = tokenizer,
    #                                               wordLengths = c(1, Inf)))
    # remove sparse term
    #print(paste("remove sparse", date()))
    tdm <- removeSparseTerms(tdm, 0.1)
    # return Term Document Matrix  
    return(tdm)
}

# Plots and statistics for n-grams tokens

display.barplot <- function(tdm, ngram, colour, max = 30) { 
    
    total <- rowSums(as.matrix(tdm))
    mostfreq <- tail(sort(total), max)
    # display a barplot of ngram counts
    title <- paste(max, "most frequent", ngram, "ngram", sep = " ")
    barplot(mostfreq, main = title, xlab = "Frequency", col = colour, 
            horiz = TRUE, las = 2)
    
}  

display.summaries <- function(tdm, ngram, max = 10) { 
  
    # create a matrix
    tdm.matrix <- as.matrix(tdm)
    # display summary statistics of ngram counts
    print(paste("Total number of", ngram, "ngram:", nrow(tdm.matrix), 
                sep = " "))
    print(paste("Frequency of the", max, "most frequent", ngram, 
                "ngrams", sep = " "))               
    total <- rowSums(tdm.matrix)
    mostfreq <- tail(sort(total), max)
    print(mostfreq)
    
}  

display.clouds <- function(list) {  
  
    # display word clouds
    set.seed(375) 
    layout(matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, ncol = 3),  heights=c(1, 4))
    par(mar=rep(0, 4))   
    for (n in 1:length(l)) {
        plot.new()
        freq <- sort(rowSums(as.matrix(l[[n]])), decreasing=TRUE)[1:150]        
        if (n == 1) {
            title <- "Twitter"
        }
        else if (n == 2) {
            title <- "Blog"
        }
        else if (n == 3) {
            title <- "News"
        }
        text(x = 0.5, y = 0.5, cex = 3, title)
        wordcloud(words=names(freq), scale = c(7,2), freq = freq, min.freq =3, 
                   random.order = FALSE, colors = brewer.pal(8, "Dark2"))
    }
  
}

display.histogram <- function(file, dir = "sample_archive") { 
  
    file.name <- paste(dir, file, sep ="/")
    df <- data.frame(readLines(file.name))  
    len <- sapply(df, function(x) nchar(as.character(x)))
    word <- sapply(df, function(x) stri_count(as.character(x), regex = "\\S+"))
    if (file == "sample.twitter.txt") {
        colour <- "yellow"
        title <- "Twitter"
    }
    else if (file == "sample.blogs.txt") {
        colour <- "green"
        title <- "Blog"
    }
    else if (file == "sample.news.txt") {
        colour <- "purple"
        title <- "News"
    }
    # display histograms of length sentences 
    len <- len[len < 1000]
    max <- max(len)
    bin <- 20
    upper.limit <- max + bin
    hist.data <- hist(len, main = title, xlab = "Text length in characters", 
                      col = colour, breaks = seq(0, upper.limit, bin), 
                      xlim = c(0, upper.limit), include.lowest = TRUE)     
    
    word <- word[word < 300]
    max <- max(word)
    bin <- 5
    upper.limit <- max + bin
    hist.data <- hist(word, main = title, xlab = "Text length in words", 
                      col = colour, breaks = seq(0, upper.limit, bin),                         
                      xlim = c(0, upper.limit), include.lowest = TRUE)
  
}  

# Create n-grams dataframe
  
create.dataframe <- function(total, ngram) {   
    
    # create a data frame
    print(paste("dataframe", date()))
    tdm.df <- data.frame(grams=names(total), total)
    #print(paste(ngram, "n-grams", nrow(tdm.df), sep = " "))
    l <- strsplit(as.character(tdm.df$grams), " ")
    if (ngram > 1) {
        tdm.df$first <- lapply(l, function(x) paste(x[1:ngram-1], 
                                                    collapse = " "))
        tdm.df$second <- lapply(l, function(x) x[ngram]) 
    }
    return(tdm.df)
  
}

