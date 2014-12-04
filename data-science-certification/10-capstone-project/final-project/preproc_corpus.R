# Create and prepare the corpus

create.corpus <- function(dir = "sample", file.pattern = "*.*") {    
  
    # create the corpus
    print(paste("create corpus", date()))
    docs <- Corpus(DirSource(dir, encoding = "UTF-8", pattern = file.pattern), 
                     readerControl = list(language = "en"))   
    print(paste("clean corpus", date()))
    # cleaning the corpus
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
    # return the corpus
    return(docs)     
  
}

# Tokenize corpus

tokenizer <- function(ngram, docs) { 
  
    print(paste("tokenize", date()))
    # create Term Document Matrix for n.grams
    tokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ngram, 
                                                            max = ngram,
                                    delimiters = " \\r\\n\\t.,;:\"()?!"))
    tdm <- DocumentTermMatrix(docs, control = list(tokenize = tokenizer,
                                                   wordLengths = c(1, Inf)))
    # remove sparse term
    #print(paste("remove sparse", date()))
    tdm <- removeSparseTerms(tdm, 0.1)
    # return Term Document Matrix  
    return(tdm)
}

