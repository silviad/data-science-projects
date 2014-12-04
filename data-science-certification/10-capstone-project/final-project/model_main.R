# linear interpolation ngram

ngram.model <- function(sentence, answers = vector(), style) {    
  
    #clean the sentence
    sentence <- clean.sentence(sentence)        
    # autocomplete
    last.char <- substr(sentence, nchar(sentence), nchar(sentence))
    autocomplete <- last.char != " " & sentence != ""    
    # split
    sentence.split <- unlist(strsplit(sentence, " "))
    len.sentence <- length(sentence.split)
    # last word to complete
    word.init <- ""
    if (autocomplete) {
        print("autocomplete")  
        word.init <- sentence.split[len.sentence]
        len.sentence <- len.sentence - 1
        sentence.split <- sentence.split[1:len.sentence]
    }    
    # get next words
    next.words <- get.next.words(sentence, sentence.split, len.sentence, word.init, 
                                 answers, style)
    # autocomplete
    if (autocomplete) {  
        next.words[4:6] <- gsub(word.init, "", next.words[1:3]) 
    }  
    else {  
        next.words[4:6] <- next.words[1:3]
    }  
    return(next.words)
} 

# clean the input sentence as done for the corpus

clean.sentence <- function (sentence) {
  
    # ltrim
    if (trim(sentence) == "") {
        sentence <- "" 
    } 
    # tolower
    sentence <- tolower(sentence)  
    # removeNumbers
    sentence <- gsub('[0-9]', '', sentence)
    # removePunctuation exept apostrophes and dots between words
    sentence <- gsub("(\\w)-(\\w)", "\\1\1\\2", sentence)
    sentence <- gsub("(?!['|\\r|\\n|\\t|.|,|;|:|\"|(|)|?|!])[[:punct:]]+", "", 
                     sentence, perl=TRUE)
    sentence <- gsub("\1", "-", sentence, fixed = TRUE)     
    # stripWhitespace
    sentence <- gsub("[[:space:]]+", " ", sentence)
    
    return(sentence)
} 


get.next.words <- function (sentence, sentence.split, len.sentence, word.init, 
                            answers, style) {
  
    # initialize parameters and variables
    n.choises <- 3
    maxgram <- 4
    lambda <- c(0.7,0.3) 
    count <- 0  
    #print(sentence)  
    
    # check if the last word is a contraction
    last.word.contraction <- word.init != "" && nrow(select.contractions(word.init)) > 0
    
    # loop back on n-grams models and combine the first two
    mtx1 <- matrix()
    mtx2 <- matrix()
    ngram.max <- min(maxgram, len.sentence + 1)  
    for (ngram in ngram.max:1) {
        #print(ngram)        
        words <- get.words(len.sentence, ngram, sentence.split, sentence, 
                              last.word.contraction, word.init)         
        word.list <- select.total(ngram, words, answers, style, word.init)
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
        mtx <- manage.tie(mtx, ngram, len.sentence, sentence.split, max.freq, 
                          style, lambda[count], mtx1, mtx2, word.init)     
    }   
    #print(head(mtx, 50))
    
    # return words
    next.words <- names(mtx[1:min(n.choises, ncol(mtx))])
    if (is.na(next.words[2])) next.words[2] <- ""
    if (is.na(next.words[3])) next.words[3] <- ""    
    
    return(next.words)
}


get.words <- function(len.sentence, ngram, sentence.split, sentence, 
                      last.word.contraction, word.init) {
    init <- len.sentence - ngram + 2      
    words <- ""  
    if (len.sentence >= init){
        words <- paste(sentence.split[init:len.sentence], collapse = " ")  
    }   
    # contractions
    if (sentence != "" && !last.word.contraction && ngram > 1) {
        words.appo <- manage.contractions(sentence, words, word.init, ngram)
        if (words.appo[1] != "") {
            words <- words.appo
        }
    } 
    return(words)
}

# expand contractions

manage.contractions <- function (sentence, words, word.init, ngram) {

    list.sentences <- expand.contractions(words)  
    words.appo <- ""
    if (length(list.sentences) > 0) {
        print("contractions")
        if (word.init != "") {
            list.sentences <- paste(list.sentences, word.init, sep =" ")
        }
        words.appo <- sapply(list.sentences, function(x) {  
            sentence.split <- unlist(strsplit(x, " "))
            len.sentence <- length(sentence.split)
            if (word.init != "") {
                len.sentence <- len.sentence - 1
            }      
            init <- len.sentence - ngram + 2
            words <- "" 
            if (len.sentence >= init){
                words <- paste(sentence.split[init:len.sentence], 
                               collapse = " ")
            }
          })
    }
    return(words.appo)
}

expand.contractions <- function (sentence) {

    sentence.split <- unlist(strsplit(sentence, " "))
    len.sentence <- length(sentence.split)  
    list.sentences <- vector()
    expansion <- get.expansion (len.sentence, sentence.split)    
    #print(expansion)
    if (length(expansion) > 0) {    
        first <- TRUE
        curr.pos <- 0
        for (i in 1:length(expansion)) {
            if (!is.null(expansion[[i]][1])) {
                if (first) {
                    sentence.init <- paste(head(sentence.split, n=i-1), 
                                           collapse = " ")
                    sentence.exp <- paste(sentence.init, expansion[[i]], 
                                          sep = " ")
                    #  sentence.tail <- paste(tail(sentence.split, n=len.sentence-i), 
                    #                               collapse = " ")
                    #  sentence.exp <- paste(sentence.exp, sentence.tail, sep = " ")
                    list.sentences <- c(list.sentences,sentence.exp)
                    first <- FALSE
                }
                else {             
                    init <- curr.pos + 1
                    end <- i - 1
                    sentence.init <- paste(sentence.split[init:end], 
                                           collapse = " ")
                    sentence.exp <- paste(sentence.init, expansion[[i]], 
                                          sep = " ")
                    list.sentences.appo <- vector()
                    for (s in sentence.exp) {
                        sentence.exp <- paste(list.sentences, s, sep = " ")
                        list.sentences.appo <- c(list.sentences.appo, 
                                                 sentence.exp)
                    }
                    list.sentences <- list.sentences.appo              
                }
                curr.pos <- i
            }
        }
        init <- curr.pos + 1
        end <- len.sentence
        sentence.tail <- paste(sentence.split[init:end], collapse = " ")
        sentence.exp <- paste(list.sentences, sentence.tail, sep = " ")
    }
    #print(list.sentences)
    return(list.sentences)
}


# list of expanded contractions in the sentence

get.expansion <- function (len.sentence, sentence.split) {
   
    expansion <- list()
    for (i in 1:len.sentence) {
        contractions <- select.contractions(sentence.split[i])
        expansion[[i]] <- NULL
        if (nrow(contractions) > 0) {
            expansion[[i]] <- contractions[contractions != ""]
#             word.contr <- contractions$word1
#             if (contractions$word2 != "") {
#                 word.contr <- c(word.contr, contractions$word2)
#             }
#             if (contractions$word3 != "") {
#                 word.contr <- c(word.contr, contractions$word3)
#             }
#            expansion[[i]] <- word.contr
        } 
        # sasson genitive
        else {
            word <- sentence.split[i]
            if (substr(word, nchar(word) - 1, nchar(word)) == "'s") {
                print("genitive")
                form.no.gen.sas <- substr(word, 1, nchar(word) - 2)
                expansion[[i]] <- c(word, form.no.gen.sas)
            }            
        }
    }      
    return(expansion)

}

# managing tie

manage.tie <- function (mtx, ngram, len.sentence, sentence.split, max.freq, 
                        style, lambda, mtx1, mtx2, word.init) {
  
    print("TIE")
    init <- len.sentence - ngram + 2
    words <- paste(sentence.split[init:len.sentence], collapse = " ")   
    answers <- names(mtx[mtx==max.freq])
    word.list <- select.total(ngram, words, answers, style, word.init)
    if (nrow(word.list) > 0) {
        print(ngram)
        if (ngram > 1) {
            word.list.appo <- POS.model(word.list)
        }    
        word.list <- word.list.appo
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
  
    next.words <- word.list$word    
    # get POS tag for the words
    tags <- word.list$POStag    
    tags[tags == "RBS"] <- "JJS"
    tags[tags == "RBR"] <- "JJR"
    #tags <- get.pos.tags(next.words)  

    freq.pos <- sort(table(tags), decreasing = TRUE)
    #print(freq.pos)    
    # create table frequencies
    freq.pos.perc <- c(rep(0,length(freq.pos)))
    names(freq.pos.perc) <- names(freq.pos)        
    grand.total <- sum(word.list$total)               
    for (i in 1:length(freq.pos)) {
        freq.tag <- names(freq.pos[i])                  
        next.words.appo <- next.words[tags==freq.tag]
        #print(freq.tag)
        total <- sum(word.list[word.list$word %in% next.words.appo,]$total)  
        #print(total)
        freq.pos.perc[i] <- total/grand.total
        #print(freq.pos.perc[i])
    }
    
    freq.pos.perc <- sort(freq.pos.perc, decreasing = TRUE)
    #print(freq.pos.perc)
    max.freq.tag <- names(freq.pos.perc[1])
    if (length(freq.pos.perc) > 1 & (freq.pos.perc[2] > freq.pos.perc[1]/2)) {
        max.freq.tag <- c(max.freq.tag, names(freq.pos.perc[2]))
    }     
    #print(max.freq.tag)
    word.list <- word.list[word.list$word %in% 
                             next.words[tags %in% max.freq.tag], ]    
    return(word.list)
}




