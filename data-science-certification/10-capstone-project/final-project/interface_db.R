# load ngram RDS file on SQLite db

dbname = "D:/Edu/03 - Data science certification/10 - Capstone/Project/shiny_app/shiny.predictive.db"
#dbname = "C:/Users/Silvia/Downloads/predictive.model.db"
#dbname = "C:/Users/Silvia/Downloads/dbdiprova.db"

load.sqlite.from.rds <- function(dir = "sample") { 
  
    print(paste("load db", date(), sep = " "))
    # connect to the sqlite db
    con = dbConnect(dbDriver("SQLite"), dbname = dbname)
    # insert 
    df <- data.frame(readRDS(paste0(dir, "/sample", "gram1.rds")))
    dbWriteTable(conn = con, name = "unigram", value = df, 
                 overwrite=TRUE, row.names = FALSE)  
    df <- data.frame(readRDS(paste0(dir, "/sample", "gram2.rds")))
    dbWriteTable(conn = con, name = "bigram", value = df, 
                 overwrite=TRUE, row.names = FALSE)  
    df <- data.frame(readRDS(paste0(dir, "/sample", "gram3.rds")))
    dbWriteTable(conn = con, name = "trigram", value = df, 
                 overwrite=TRUE, row.names = FALSE)
    df <- data.frame(readRDS(paste0(dir, "/sample", "gram4.rds")))
    dbWriteTable(conn = con, name = "fourgram", value = df, 
                 overwrite=TRUE, row.names = FALSE)
  
}

write.RDS <- function (tdm.df, ngram) {
    # write save file
    print(paste("rds writing", date()))
    name.file <- paste0("sample/sample", "gram", ngram, ".rds")
    saveRDS(tdm.df, name.file)
}

# select next word from SQLite db

select.unigrams <- function(style) {   
    # connect to the sqlite db
    con = dbConnect(dbDriver("SQLite"), dbname = dbname)
    # create query string
    sql <- "select word from unigram where style=?"    
    df <- data.frame(style=style)
    res <- dbGetPreparedQuery(con, sql, bind.data = df)
    return(res)  
}

# update POS tag field in unigram table

update.POStag <- function(POStag, word, style) {   
    # connect to the sqlite db
    con = dbConnect(dbDriver("SQLite"), dbname = dbname)
    # create query string
    sql <- "update unigram set POStag=? where word=? and style=?"    
    df <- data.frame(POStag=POStag, word=word, style=style) 
    res <- dbGetPreparedQuery(con, sql, bind.data = df)
    return(res)  
}

select.total <- function(ngram, sentence, answers = vector(), style, word.init="") {   
  
    # connect to the sqlite db
    con = dbConnect(dbDriver("SQLite"), dbname = dbname)
    
    # create query string
    if (ngram == 1) {
        table_name <- "unigram"    
    }
    else if (ngram == 2) {    
        table_name <- "bigram"
    }
    else if (ngram == 3) {
        table_name <- "trigram"
    }
    else if (ngram == 4) {
        table_name <- "fourgram"  
    } 
    if (ngram == 1) {
        sql <- paste("select * from", table_name, "gram where style=?", 
                     sep = " ")    
    }
    else {    
        sql <- paste("select gram.*, POStag from", table_name, 
                     "gram INNER JOIN unigram_final", sep = " ")
        sql <- paste(sql, "on gram.word=unigram_final.word where", sep = " ")
        sql <- paste(sql, "gram.style=? and unigram_final.style=? and first=?",
                     sep = " ")  
    }
    len.answer <- length(answers)
    if (len.answer != 0) {         
        sql <- paste(sql, "and gram.word=?", sep = " ")    
    }
    else if (word.init != "") {
        sql <- paste(sql, "and gram.word like ?", sep = " ")  
    }
    sql <- paste(sql, "order by gram.total desc", sep = " ")   
 
    if (ngram == 1) {
        if (len.answer == 0 & word.init == "") {
            df <- data.frame(style=style)
        }      
        else if (len.answer > 0) {
            df <- data.frame(style=style, word=answers)
        }
        else if (word.init != "") {
            df <- data.frame(style=style, word=paste(word.init,"%", sep=""))
        }
    }
    else {
        if (len.answer == 0 & word.init == "") {
            df <- data.frame(style=style, style=style, first=sentence)
        }      
        else if (len.answer > 0) {
            df <- data.frame(style=style, style=style, first=sentence, 
                             word=answers)
        }
        else if (word.init != "") {
            df <- data.frame(style=style, style=style, first=sentence, 
                             word=paste(word.init,"%", sep=""))
        }
    }      
    res <- dbGetPreparedQuery(con, sql, bind.data = df)
    #print(sql)
    #print(df)
    if (word.init != "") {
        res <- res[res$word != word.init,]
    }  
    #print(res)
    return(res)  
  
}


# select contractions

# select.contractions.old <- function(words) {   
#     # connect to the sqlite db
#     con = dbConnect(dbDriver("SQLite"), dbname = dbname)
#     # create query string
#     sql <- "select * from contractions where contraction=?"    
#     df <- data.frame(contraction=words)
#     res <- dbGetPreparedQuery(con, sql, bind.data = df)
#     #print(df)
#     return(res)  
# }

select.contractions <- function(words) {   
    # connect to the sqlite db
    con = dbConnect(dbDriver("SQLite"), dbname = dbname)
    # create query string
    sql <- "select * from contractions where contraction=?"
    sql <- paste(sql,"or word1=? or word2=? or word3=?", sep =" ")  
    df <- data.frame(contraction=words, word1=words, word2=words, word3=words)
    res <- dbGetPreparedQuery(con, sql, bind.data = df)
    #print("SELECT")
    #print(df)
    #print(sql)
    #print(res)
    return(res)  
}

# select.total.ok <- function(ngram, sentence, answers = vector(), style, word.init="") {   
#   
#   # connect to the sqlite db
#   con = dbConnect(dbDriver("SQLite"), dbname = dbname)
#   # create query string
#   if (ngram == 1) {
#     sql <- "select * from unigram_final where style=?"    
#   }
#   else if (ngram == 2) {    
#     sql <- "select bigram_final.*, POStag from bigram_final INNER JOIN unigram_final" 
#     sql <- paste(sql, "on bigram_final.word=unigram_final.word", sep = " ")
#     sql <- paste(sql, "where bigram_final.style=? and unigram_final.style=? and first=?", sep = " ")  
#   }
#   else if (ngram == 3) {
#     sql <- "select trigram_final.*, POStag from trigram_final INNER JOIN unigram_final" 
#     sql <- paste(sql, "on trigram_final.word=unigram_final.word", sep = " ")
#     sql <- paste(sql, "where trigram_final.style=? and unigram_final.style=? and first=?", sep = " ")  
#   }
#   else if (ngram == 4) {
#     sql <- "select fourgram_final.*, POStag from fourgram_final INNER JOIN unigram_final" 
#     sql <- paste(sql, "on fourgram_final.word=unigram_final.word", sep = " ")
#     sql <- paste(sql, "where fourgram_final.style=? and unigram_final.style=? and first=?", sep = " ")  
#   }    
#   len.answer <- length(answers)
#   if (len.answer != 0) {         
#     if (ngram == 1) {
#       sql <- paste(sql, "and word=?", sep = " ")    
#     }
#     else if (ngram == 2) {    
#       sql <- paste(sql, "and bigram_final.word=?", sep = " ")  
#     }
#     else if (ngram == 3) {
#       sql <- paste(sql, "and trigram_final.word=?", sep = " ")  
#     }
#     else if (ngram == 4) {
#       sql <- paste(sql, "and fourgram_final.word=?", sep = " ")         
#     }    
#   }
#   else if (word.init != "") {
#     if (ngram == 1) {
#       sql <- paste(sql, "and word like ?", sep = " ")    
#     }
#     else if (ngram == 2) {    
#       sql <- paste(sql, "and bigram_final.word like ?", sep = " ")  
#     }
#     else if (ngram == 3) {
#       sql <- paste(sql, "and trigram_final.word like ?", sep = " ")  
#     }
#     else if (ngram == 4) {
#       sql <- paste(sql, "and fourgram_final.word like ?", sep = " ")         
#     } 
#   }
#   if (ngram == 1) {
#     sql <- paste(sql, "order by total desc", sep = " ")   
#   }
#   else if (ngram == 2) {    
#     sql <- paste(sql, "order by bigram_final.total desc", sep = " ")
#   }
#   else if (ngram == 3) {
#     sql <- paste(sql, "order by trigram_final.total desc", sep = " ")
#   }
#   else if (ngram == 4) {
#     sql <- paste(sql, "order by fourgram_final.total desc", sep = " ")
#   }       
#   if (ngram == 1) {
#     if (len.answer == 0 & word.init == "") {
#       df <- data.frame(style=style)
#     }      
#     else if (len.answer > 0) {
#       df <- data.frame(style=style, word=answers)
#     }
#     else if (word.init != "") {
#       df <- data.frame(style=style, word=paste(word.init,"%", sep=""))
#     }
#   }
#   else {
#     if (len.answer == 0 & word.init == "") {
#       df <- data.frame(style=style, style=style, first=sentence)
#     }      
#     else if (len.answer > 0) {
#       df <- data.frame(style=style, style=style, first=sentence, 
#                        word=answers)
#     }
#     else if (word.init != "") {
#       df <- data.frame(style=style, style=style, first=sentence, 
#                        word=paste(word.init,"%", sep=""))
#     }
#   }      
#   res <- dbGetPreparedQuery(con, sql, bind.data = df)
#   #print(sql)
#   #print(df)
#   if (word.init != "") {
#     res <- res[res$word != word.init,]
#   }  
#   #print(res)
#   return(res)  
#   
# }

# select.total.old <- function(ngram, sentence, answers = vector(), style) {   
#   
#     # connect to the sqlite db
#     con = dbConnect(dbDriver("SQLite"), dbname = dbname)
#     # create query string
#     if (ngram == 1) {
#         sql <- "select * from unigram_final where style=? order by total desc"    
#     }
#     else if (ngram == 2) {    
#         sql <- "select bigram_final.*, POStag from bigram_final INNER JOIN unigram_final" 
#         sql <- paste(sql, "on bigram_final.word=unigram_final.word", sep = " ")
#         sql <- paste(sql, "where bigram_final.style=? and unigram_final.style=? and first=?", sep = " ")  
#         sql <- paste(sql, "order by bigram_final.total desc", sep = " ")
#     }
#     else if (ngram == 3) {
#         sql <- "select trigram_final.*, POStag from trigram_final INNER JOIN unigram_final" 
#         sql <- paste(sql, "on trigram_final.word=unigram_final.word", sep = " ")
#         sql <- paste(sql, "where trigram_final.style=? and unigram_final.style=? and first=?", sep = " ")  
#         sql <- paste(sql, "order by trigram_final.total desc", sep = " ")
#     }
#     else if (ngram == 4) {
#         sql <- "select fourgram_final.*, POStag from fourgram_final INNER JOIN unigram_final" 
#         sql <- paste(sql, "on fourgram_final.word=unigram_final.word", sep = " ")
#         sql <- paste(sql, "where fourgram_final.style=? and unigram_final.style=? and first=?", sep = " ")  
#         sql <- paste(sql, "order by fourgram_final.total desc", sep = " ")
#     }    
#     # select
#     if (ngram == 1) {
#         df <- data.frame(style=style)
#     }
#     else {
#         df <- data.frame(style=style, style=style, first=sentence)      
#     }      
#     res <- dbGetPreparedQuery(con, sql, bind.data = df)
#     return(res)  
#   
# }

