#
# Interface functions to the temporary SQLite db and RDS files.
#  

# Set constants
db.name = "C:/Users/Silvia/Downloads/shiny.temp.db"   # db name
maxngram <- 4   # max ngrams
dir.file = "sample"  # temporary working directory


load.sqlite.from.rds <- function() { 
    #  
    # Load temporary ngram RDS files into SQLite db.
    #  
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)
    table.names <- c("unigram", "bigram", "trigram", "fourgram")
    for (ngram in 1:maxngram) {
        df <- data.frame(readRDS(paste0(dir.file, "/samplegram", ngram, ".rds")))
        dbWriteTable(conn = con, name = table.names[ngram], value = df, 
                    overwrite=TRUE, row.names = FALSE) 
    }  
}


profanity.filter <- function() {   
    #
    # Apply profanity filter to ngrams.
    #  
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)   
    sql <- "delete from unigram where word in (select word from profanity)"
    res <- dbGetQuery(con, sql)    
    sql <- "delete from bigram where word in (select word from profanity)"
    res <- dbGetQuery(con, sql)    
    sql <- "delete from trigram where word in (select word from profanity)"
    res <- dbGetQuery(con, sql)    
    sql <- "delete from fourgram where word in (select word from profanity)"
    res <- dbGetQuery(con, sql) 
}


prune.unigrams <- function () {
    #
    # Prune unigrams with frequencies 1.
    #
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)
    # prune unigrams
    sql <- "delete from unigram where total = 1"
    res <- dbGetQuery(con, sql)    
    # prune orphan bigrams
    sql <- "delete from bigram where word not in (select word from unigram)"
    sql <- paste(sql, "or first not in (select word from unigram)")
    res <- dbGetQuery(con, sql)           
    # prune orphan trigrams
    sql <- "delete from trigram where word not in (select word from unigram)"
    sql <- paste(sql, "or word1str not in (select word from unigram)")
    sql <- paste(sql, "or word2str not in (select word from unigram)")
    res <- dbGetQuery(con, sql)  
    # prune orphan fourgrams
    sql <- "delete from fourgram where word not in (select word from unigram)"
    sql <- paste(sql, "or word1str not in (select word from unigram)")
    sql <- paste(sql, "or word2str not in (select word from unigram)")
    sql <- paste(sql, "or word3str not in (select word from unigram)")
    res <- dbGetQuery(con, sql)  
}


add.POStag <- function() {
    #
    # Update POS tag for unigrams
    # 
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)
    # create annotator
    list.annotator <- list(Maxent_Sent_Token_Annotator(), 
                           Maxent_Word_Token_Annotator(), 
                           Maxent_POS_Tag_Annotator())    
    # select unigrams
    sql <- "select word from unigram"    
    res <- dbGetQuery(con, sql)  
    words <- res$word
    for (i in 1:length(words)) {
        if(i%%1000==0) print(paste(i, date()))
        s <- as.String(words[i])        
        annot.words <- subset(annotate(s, list.annotator), type == "word")
        tag <- sapply(annot.words$features, `[[`, "POS")
        # update POStag field of unigrams
        sql <- "update unigram set POStag=? where word=?"  
        df <- data.frame(POStag=tag, word=words[i]) 
        res <- dbGetPreparedQuery(con, sql, bind.data = df)
    }          
    # update RBS and RBR      
    sql <- "update unigram set POStag = 'JJS' where POStag = 'RBS'"
    res <- dbGetQuery(con, sql)
    sql <- "update unigram set POStag = 'JJR' where POStag = 'RBR'"
    res <- dbGetQuery(con, sql)
}


prune.ngrams <- function () {
    #
    # Prune ngrams: unigrams with frequencies 1 and the other grams
    # with frequencies 1 and in POS tag categories under a threashold
    #    
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)   
    table.names <- c("unigram", "bigram", "trigram", "fourgram")
    # prune other ngrams
    for (ngram in 2:maxngram) {
        print(paste(ngram, date()))
        sql <- paste("delete from", table.names[ngram], "where id in (select")
        sql <- paste(sql, "t.id from", table.names[ngram], "t, unigram u,")
        sql <- paste(sql, table.names[ngram], "_under_threshold s", sep = "")
        sql <- paste(sql,"where t.first = s.first and t.word = u.word") 
        sql <- paste(sql, "and u.POStag = s.POStag and t.total = 1)")
        res <- dbGetQuery(con, sql)
    }  
}


update.word.numbers <- function () {
    #
    # Generate numbers code for words in order to substitute strings with numbers.
    #  
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)     
    # update bigram
    print(paste("bigram", date()))
    sql <- "update bigram set word1 = (select u.wordcode from unigram u"
    sql <- paste(sql, "where bigram.first=u.word)")
    res <- dbGetQuery(con, sql)  
    sql <- "update bigram set wordcode = (select u.wordcode from unigram u"
    sql <- paste(sql, "where bigram.word=u.word)")
    res <- dbGetQuery(con, sql)    
    # update trigram
    print(paste("trigram", date()))
    sql <- "update trigram set word1 = (select u.wordcode from unigram u"
    sql <- paste(sql, "where trigram.word1str=u.word)")
    res <- dbGetQuery(con, sql)
    sql <- "update trigram set word2 = (select u.wordcode from unigram u"
    sql <- paste(sql, "where trigram.word2str=u.word)")
    res <- dbGetQuery(con, sql)
    sql <- "update trigram set wordcode = (select u.wordcode from unigram u"
    sql <- paste(sql, "where trigram.word=u.word)")
    dbGetQuery(con, sql)  
    # update fourgram
    print(paste("fourgram", date()))
    sql <- "update fourgram set word1 = (select u.wordcode from unigram u"
    sql <- paste(sql, "where fourgram.word1str=u.word)")
    res <- dbGetQuery(con, sql)
    sql <- "update fourgram set word2 = (select u.wordcode from unigram u"
    sql <- paste(sql, "where fourgram.word2str=u.word)")
    res <- dbGetQuery(con, sql)
    sql <- "update fourgram set word3 = (select u.wordcode from unigram u"
    sql <- paste(sql, "where fourgram.word3str=u.word)")
    res <- dbGetQuery(con, sql)
    sql <- "update fourgram set wordcode = (select u.wordcode from unigram u"
    sql <- paste(sql, "where fourgram.word=u.word)")
    res <- dbGetQuery(con, sql)
    # prune errors
    sql <- "delete from bigram where word1 is null or wordcode is null"
    res <- dbGetQuery(con, sql)
    sql <- "delete from trigram where word1 is null or word2 is null"
    sql <- paste(sql, "or wordcode is null")
    res <- dbGetQuery(con, sql)
    sql <- "delete from fourgram where word1 is null or word2 is null"
    sql <- paste(sql, "or word3 is null or wordcode is null")
    res <- dbGetQuery(con, sql)

}


write.file.from.sqlite <- function() { 
    #
    # Load data from SQLite tables to final RDS files 
    # 
    con = dbConnect(dbDriver("SQLite"), dbname = db.name)    
    sql <- "select * from unigram"
    write.file(con, sql, paste0(dir.file, "/sampleprunegram1.rds"))    
    sql <- "select total, word1, wordcode from bigram"
    write.file(con, sql, paste0(dir.file, "/sampleprunegram2.rds"))    
    sql <- "select total, word1, word2, wordcode from trigram"
    write.file(con, sql, paste0(dir.file, "/sampleprunegram3.rds"))    
    sql <- "select total, word1, word2, word3, wordcode from fourgram"
    write.file(con, sql, paste0(dir.file, "/sampleprunegram4.rds"))    
    sql <- "select * from contractions"
    write.file(con, sql, paste0(dir.file, "/contractions.rds"))  
}


write.file <- function (con, sql, file.name) {
    #
    # Utility function to write a RDS files from a table
    # 
    res <- dbGetQuery(con, sql)
    saveRDS(data.frame(res), file.name)
}
