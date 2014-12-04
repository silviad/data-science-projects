# update POS tag

add.POStag <- function(style) {
 
    list.annotator <- list(Maxent_Sent_Token_Annotator(), 
                           Maxent_Word_Token_Annotator(), 
                           Maxent_POS_Tag_Annotator())    
    words <- select.unigrams(style)$word
    for (i in 1:length(words)) {
        if(i%%100==0) print(paste(i, date()))
        s <- as.String(words[i])        
        annot.words <- subset(annotate(s, list.annotator), type == "word")
        tag <- sapply(annot.words$features, `[[`, "POS")
        update.POStag(tag, words[i], style)
    }    
}

# get POS tag

get.pos.tags.sentence <- function(words) {
  
    list.tag <- c("JJ", "JJR", "JJS", "NN", "NNS", "NNP", "NNPS")
    list.annotator <- list(Maxent_Sent_Token_Annotator(), 
                           Maxent_Word_Token_Annotator(), 
                           Maxent_POS_Tag_Annotator())    
    tag.vector <- vector()
    s <- as.String(words)
    annot.words <- subset(annotate(s, list.annotator), type == "word")
    tags <- sapply(annot.words$features, `[[`, "POS")
    tag.clean <- tags[tags %in% list.tag]
    #print(tags)
    #print(tag.clean)
    words <- s[annot.words]
    words.clean <- words[tags %in% list.tag]
    #print(words.clean)
    words.unique <- unique(words.clean)
    return (words.unique)
  
} 
