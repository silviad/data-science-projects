#
# Procedures for predict next word using linear interpolation ngrams
#

ngram.model <- function(sentence, answers = vector(), list.table) {    
    #
    # Main function. Predict next words. 
    #  
    # Args:
    #   sentence:    sentence to complete
    #   answers:     filter on particular next words
    #   list.table:  list of data table containing ngrams data
    #
    # Returns: a vector of most likely 3 words 
    #         and the part to autocomplete if in case
    # 
    #clean the sentence
    sentence <- clean.sentence(sentence)        
    # autocomplete
    last.char <- substr(sentence, nchar(sentence), nchar(sentence))
    autocomplete <- last.char != " " & sentence != ""    
    # split
    sentence.split <- unlist(strsplit(sentence, " "))
    len.sentence <- length(sentence.split)
    # last word to complete
    last.word.init <- ""
    if (autocomplete) {
        #print("autocomplete")  
        last.word.init <- sentence.split[len.sentence]
        len.sentence <- len.sentence - 1
        sentence.split <- sentence.split[1:len.sentence]
    }    
    # get next words
    next.words <- get.next.words(sentence.split, last.word.init, answers, list.table)
    # autocomplete
    if (autocomplete) {  
        next.words[4:6] <- gsub(last.word.init, "", next.words[1:3]) 
    }  
    else {  
        next.words[4:6] <- next.words[1:3]
    }  
    return(next.words)
} 


clean.sentence <- function (sentence) {
    #
    # Clean the input sentence as done for the corpus 
    #  
    # Args:
    #   sentence:    sentence to clean
    #
    # Returns: a cleaned sentence
  
    # ltrim
    if (str_trim(sentence) == "") {
        sentence <- "" 
    } 
    # tolower
    sentence <- tolower(sentence)  
    # removeNumbers
    sentence <- gsub('[0-9]', '', sentence)
    # removePunctuation exept apostrophes. end of sentence ad dots
    sentence <- gsub("(?!['|\\r|\\n|\\t|.|,|;|:|\"|(|)|?|!|-])[[:punct:]]+", "", 
                     sentence, perl=TRUE)   
    # stripWhitespace
    sentence <- gsub("[[:space:]]+", " ", sentence)
    return(sentence)
} 


get.next.words <- function (sentence.split, last.word.init, answers, list.table) {  
    #
    # Predict next words. 
    #  
    # Args:
    #   sentence.split:sentence to complete split in word without the last word
    #                  if autocomplete has to be applied
    #   last.word.init:     initial part of the next word if autocomplete has to be applied
    #   answers:       filter on particular next words
    #   list.table:    list of data table containing ngrams data
    #
    # Returns: a vector of most likely 3 words 
  
    # initialize parameters and variables
    n.choises <- 3
    maxgram <- 4
    lambda <- c(0.7,0.3) 
    count <- 0  
    len.sentence <- length(sentence.split)
    #print(sentence)      
    # check if the last word is a contraction
    contractions <- list.table[[5]]
    last.word.contraction <- last.word.init != "" && 
                         nrow(select.contractions(contractions, last.word.init)) > 0
    # loop back on n-grams models and combine the first two
    mtx1 <- matrix()
    mtx2 <- matrix()
    ngram.max <- min(maxgram, len.sentence + 1)  
    for (ngram in ngram.max:1) {   
        words <- get.first.part.ngram(len.sentence, ngram, sentence.split,  
                                last.word.contraction, last.word.init, contractions)     
        word.list <- select.next.word(list.table, ngram, words, answers, last.word.init)
        if (nrow(word.list) > 0) {
            count <- count + 1
            if (ngram > 1) {
                word.list <- POS.model(word.list)
            }    
            mtx <- matrix(word.list$total, nrow =1)
            colnames(mtx) <- word.list$word    
            mtx <- lambda[count] * mtx/sum(word.list$total)
            if (count == 1) {
                mtx1 <- mtx
            }
            else{
                mtx2 <- mtx
            }
          }        
          if (count == 2) break
    }
    if (!is.na(mtx2[1,1])){
        grand.total <- t(as.matrix(colSums(do.call(rbind.fill.matrix,
                                                 list(mtx1, mtx2)), na.rm=T)))
    }
    else if (!is.na(mtx1[1,1])) {
        grand.total <- t(as.matrix(colSums(do.call(rbind.fill.matrix,
                                                 list(mtx1)), na.rm=T)))
    }
    else {
        next.words <- rep("",6)
        return(next.words)
    }    
    mtx <- matrix(grand.total, ncol =1)
    rownames(mtx) <- colnames(grand.total)  
    mtx <- mtx[order(-mtx[, 1]), ]     
    # managing tie
    max.freq <- mtx[1]
    ngram <- ngram - 1
    if (length(mtx) > n.choises & mtx[n.choises + 1] == max.freq & ngram > 1) {
        words <- get.first.part.ngram(len.sentence, ngram, sentence.split,  
                               last.word.contraction, last.word.init, contractions) 
        mtx <- manage.tie(mtx, ngram, len.sentence, sentence.split, max.freq, 
                          lambda[count], mtx1, mtx2, last.word.init, list.table, words)     
    }   
    #print(head(mtx, 50))    
    # return words
    next.words <- names(mtx[1:min(n.choises, ncol(mtx))])
    if (is.na(next.words[2])) next.words[2] <- ""
    if (is.na(next.words[3])) next.words[3] <- ""       
    return(next.words)
}


get.first.part.ngram <- function(len.sentence, ngram, sentence.split, 
                                 last.word.contraction, last.word.init, contractions) {
    #
    # Extract initial part of the ngram include genitive sasson
    #  
    # Args:
    #   len.sentence:     length of sentence
    #   ngram:             number of ngrams
    #   sentence.split:   sentence to complete split in word without the last word
    #                     if autocomplete has to be applied
    #   last.word.contraction: true if the last word is a contraction
    #   last.word.init:        initial part of the next word if autocomplete has to be applied
    #   contractions:     data frame of contractions 
    #   
    # Returns: one or a more initial part of the ngram 
    #           
    init <- len.sentence - ngram + 2      
    words <- ""  
    if (len.sentence >= init){
        words <- paste(sentence.split[init:len.sentence], collapse = " ")  
    }   
    # expande sentence for genitive sasson
    if (length(sentence.split) > 0 && !last.word.contraction && ngram > 1) {        
        sentence.equivalent <- expand.sentence(words, contractions)  
        if (length(sentence.equivalent) > 0) {
            if (last.word.init != "") {
                sentence.equivalent <- paste(sentence.equivalent, last.word.init)
            }        
            words <- sentence.equivalent
        }
    } 
    return(words)
}


expand.sentence <- function (sentence, contractions) {
    #
    # Create a list of equivalent sentences for genitive sasson
    #  
    # Args:
    #   sentence:      input sentence
    #   contractions:  data frame of contractions
    #   
    # Returns: a list of sentences equivalent to the input sentence
    #          for genitive sasson
    sentence.split <- unlist(strsplit(sentence, " "))
    len.sentence <- length(sentence.split)  
    expansion <- get.equivalent.words(len.sentence, sentence.split, contractions) 
    list.sentences <- vector()   
    if (length(expansion) > 0) {    
        first <- TRUE
        curr.pos <- 0
        for (i in 1:length(expansion)) {
            if (!is.na(expansion[[i]][1])) {
                if (first) {
                    sentence.init <- paste(head(sentence.split, n=i-1), 
                                           collapse=" ")
                    sentence.exp <- paste(sentence.init, expansion[[i]])
                    list.sentences <- c(list.sentences,sentence.exp)
                    first <- FALSE
                }
                else {             
                    init <- curr.pos + 1
                    end <- i - 1
                    sentence.init <- paste(sentence.split[init:end], 
                                           collapse=" ")
                    sentence.exp <- paste(sentence.init, expansion[[i]])
                    list.sentences.appo <- vector()
                    for (s in sentence.exp) {
                        list.sentences.appo <- c(list.sentences.appo, 
                                                 paste(list.sentences, s))
                    }
                    list.sentences <- list.sentences.appo              
                }
                curr.pos <- i
            }
        }
        if (is.na(expansion[[length(expansion)]][1])) {
            init <- curr.pos + 1
            end <- len.sentence
            sentence.tail <- paste(sentence.split[init:end], collapse=" ")
            sentence.exp <- paste(list.sentences, sentence.tail)
            list.sentences <- sentence.exp
        }
        list.sentences <- str_trim(list.sentences)
    }
    return(list.sentences)
}


get.equivalent.words <- function (len.sentence, sentence.split, contractions) {
    #
    # Create a list of equivalent words to manage genitive sasson
    #  
    # Args:
    #   len.sentence:     number of words in the sentence
    #   sentence.split:   sentence split in words
    #   contractions:     data frame of contractions
    #   
    # Returns: a list of vectors, for each word of the sentence the vector contains equivalent 
    #          words to genitive sasson otherwise a NULL 
    expansion <- list()
    for (i in 1:len.sentence) {
        expansion[[i]] <- NA
        contractions <- select.contractions(contractions, sentence.split[i])
        # sasson genitive
        if (nrow(contractions) == 0) {
            word <- sentence.split[i]
            if (substr(word, nchar(word) - 1, nchar(word)) == "'s") {
                #print("genitive")
                form.no.gen.sas <- substr(word, 1, nchar(word) - 2)
                expansion[[i]] <- c(word, form.no.gen.sas)
            }            
        }
    }      
    return(expansion)
}


manage.tie <- function (mtx, ngram, len.sentence, sentence.split, max.freq, 
                        lambda, mtx1, mtx2, last.word.init, list.table, words) {
    #
    # Manage a tie using a lower ngram filtered on the words of the tie
    #   
    #     
    #print("tie")  
    answers <- names(mtx[mtx==max.freq]) 
    word.list <- select.next.word(list.table, ngram, words, answers, last.word.init)
    if (nrow(word.list) > 0) {
        word.list <- POS.model(word.list)
        mtx <- matrix(word.list$total, nrow =1)
        colnames(mtx) <- word.list$word    
        mtx <- lambda * mtx/sum(word.list$total)
        grand.total <- t(as.matrix(colSums(do.call(rbind.fill.matrix,
                                   list(mtx1, mtx2, mtx)), na.rm=T)))
        mtx <- matrix(grand.total, ncol =1)
        rownames(mtx) <- colnames(grand.total)  
        mtx <- mtx[order(-mtx[, 1]), ]
    }               
}


POS.model <- function(word.list) {
    #
    # Select next words with the most frequent POS tag
    #  
    # Args:
    #   word.list:   list of the words that can complete the sentence
    #
    # Returns: a vector of most likely words 
    #           
    next.words <- word.list$word    
    tags <- word.list$POStag    
    grand.total <- sum(word.list$total) 
    # create table frequencies
    #freq.pos <- sort(table(tags), decreasing = TRUE) 
    freq.pos <- table(tags)
    freq.pos.perc <- c(rep(0,length(freq.pos)))
    names(freq.pos.perc) <- names(freq.pos)               
    for (i in 1:length(freq.pos.perc)) {                 
        next.words.appo <- next.words[tags==names(freq.pos.perc[i])]
        total <- sum(word.list[word.list$word %in% next.words.appo,]$total)  
        freq.pos.perc[i] <- total/grand.total
    }  
    # sort in decreasing order
    freq.pos.perc <- sort(freq.pos.perc, decreasing = TRUE)
    # select the most frequent POS tag and the second if it is above a threashold
    max.freq.tag <- names(freq.pos.perc[1])
    if (length(freq.pos.perc) > 1 & (freq.pos.perc[2] > freq.pos.perc[1]/2)) {
        max.freq.tag <- c(max.freq.tag, names(freq.pos.perc[2]))
    }     
    # return the complete list of words of the POS tag selected
    word.list <- word.list[word.list$word %in% 
                           next.words[tags %in% max.freq.tag], ]    
    return(word.list)
}


load.file.in.memory <- function() { 
    #
    # Load final RDS files into memory for shiny application
    #  
    # Returns: a list of data frames containing the RDS data
    # 
    list.df <- list()
    list.df[[1]] <- data.table(readRDS("sampleprunegram1.rds"))
    list.df[[2]] <- data.table(readRDS("sampleprunegram2.rds"))
    list.df[[3]] <- data.table(readRDS("sampleprunegram3.rds"))
    list.df[[4]] <- data.table(readRDS("sampleprunegram4.rds"))
    list.df[[5]] <- readRDS("contractions.rds")   
    return (list.df)
  
}


select.next.word <- function(list.table, ngram, sentence, answers, word.init) { 
    #
    # Select next words order by frequencies
    #  
    # Args:
    #   list.df:  contractions data frame
    #   ngram:    ngram (from 1 to maxngram)
    #   sentence: first part of the sentence to complete
    #   answers:  filter on particular next words
    #   word.init: initial part of the next word if autocomplete has to be applied
    #
    # Returns: next words order by frequencies
    #   
    expansion <- length(sentence) > 1
    #print(paste("expansion", expansion))
    #print(sentence)

    for (i in 1:length(sentence)) {      
        # intial step
        sentence.appo <- sentence[i]
        words <- unlist(strsplit(sentence.appo, " "))        
        table <- list.table[[ngram]]
        # Where clause
        if (ngram > 1) {
            ngram1 <- subset(list.table[[1]], select = c("word", "POStag", "wordcode"))  
            wordcode <- vector()
            for (n in 1:length(words)) {
                if (nrow(ngram1[ngram1$word == words[n], ]) > 0) {
                    wordcode[n] <- ngram1[ngram1$word == words[n], ]$wordcode
                }
                # not exist the word in the vocabulary
                else {
                    return(data.frame())
                }            
            }
            table <- table[word1 == wordcode[1], ] 
            if (ngram == 3) {
                table <- table[word2 == wordcode[2] , ]
            }
            else if (ngram == 4) {
                table <- table[word2 == wordcode[2] , ]
                table <- table[word3 == wordcode[3] , ]
            }   
            # merge with unigrams by wordcode
            table <- merge(table, ngram1, by="wordcode")
        }   
        # select fields of interest
        table <- subset(table, select = c("word", "POStag", "total"))
        # convert to data.frame for convenience
        table <- data.frame(table)  
        # add clauses with parameter answer and word.init
        if (length(answers) > 0) {         
            table <- table[table$word %in% answers, ]     
        }
        else if (word.init != "") {
            len <- nchar(word.init)
            table <- table[substr(table$word, 1, len) == word.init &
                             table$word != word.init, ] 
            
        } 
        if (expansion) {
            if (i == 1) {
                grand.table <- table
            }
            else if (nrow(table) > 0 && !is.na(table$word)) {
                grand.table <- rbind(grand.table, table)
                grand.table <- aggregate(total ~ word + POStag, grand.table, sum)
            }
        }
    }
    if (expansion) {
        table <- grand.table
    }      
    # order descending frequencies
    table <- table[order(-table$total),]
    # clean data.frame if it returns NA values
    if (nrow(table) == 1 && is.na(table$word)) {
        table <- data.frame()
    } 
    #print(head(table))
    return(table)   
}


select.contractions <- function(contractions, word) {   
    #
    # Select contractions
    #  
    # Args:
    #   contractions: contractions data frame
    #   word:  word to find
    #
    # Returns: equivalent words if they exist
    # 
    contractions <- contractions[contractions$contraction == word |
                                   contractions$word1== word | 
                                   contractions$word2== word |
                                   contractions$word3== word, ]
    return(contractions)  
}

