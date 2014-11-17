# Basic summaries files

basic.summaries <- function(dir = "document") {  
  
    files <- list.files(dir)
    res <- lapply(files, function(x) {
        basic.summaries.file(x)
    })
  
}

basic.summaries.file <- function(file, dir = "document") {  

      # read the file
      file.name <- paste(dir, file, sep = "/")
      # print statistics  
      res <- system(paste("wc -l", file.name, sep = " "), intern = TRUE)
      res <- unlist(strsplit(res, " "))
      line.count <- res[1]
      res <- system(paste("wc -w", file.name, sep = " "), intern = TRUE)
      res <- unlist(strsplit(res, " "))
      word.count <- res[1]
      print(paste("Lines count: ", line.count, sep = ""))
      print(paste("Words count: ", word.count, sep = ""))
      print("")
      lines <- readLines(file.name, 5)
      if (file == "twitter.txt") {
          lines <- lines[1:2]
      }
      else if (file == "blogs.txt") {
          lines <- c(lines[3], lines[5])
      }
      else if (file == "news.txt") {
          lines <- lines[3:4]
      }
      print(lines)
  
}

# File sample extraction
extract.sample.files <- function(file.pattern = "*.*", size, chunck = size, 
                                 dirin = "document", dirout = "sample") {
    
    #print(paste("extract.sample.files", date()))
    set.seed(5305)
    
    # remove old files
    files.out <- list.files(dirout)
    if (length(files.out) != 0) {
        files.out <- paste(dirout, files.out, sep = "/")
        res <- lapply(files.out, function(x) {file.remove(x)})      
    }
    
    # exctract sample
    files <- list.files(dirin, pattern = file.pattern)    
    res <- lapply(files, function(x) {      
        # read the file
        file.name <- paste(dirin, x, sep = "/")
        res <- system(paste("wc -l", file.name, sep = " "), intern = TRUE)
        line.count <- unlist(strsplit(res, " "))[1]
        #print(paste("Lines count: ", line.count, sep = ""))
        data.file <- readLines(file.name)
        data.file <- data.file[sample(1:line.count, size, replace = FALSE)]  
        write.files(dirout, x, data.file, size, chunck) 
  })
  
  # copy archive
  files.out <- list.files(dirout)
  files.out <- paste(dirout, files.out, sep = "/")
  file.copy(files.out, "sample_archive")    

}

# Write a single file or a file divided in chunks

write.files <- function(dirout, file, data.file, size, chunck) {
  
    #print(paste("write.files", date()))
    if (chunck == size) {
        #print(paste("single file", date()))
        output.file <- paste(dirout, paste("sample", file, sep ="."), sep ="/")           
        write(data.file, output.file)          
    }
    else {
        #print(paste("chunks", date()))
        ini <- 1
        end <- ini + chunck - 1
        while (end <= size) {
            # write the file in the output directory
            output.file <- paste(dirout, paste("sample", ini, file, sep = "."),
                                 sep = "/")  
            write(data.file[ini:end], output.file)
            ini <- end + 1
            end <- ini + chunck - 1
        }         
    }
}

# Clean bad characters of all files in a directory

clean.bad.char <- function(dir = "sample", file.pattern = "*.*") {

    #print(paste("clean.bad.char", date()))
    files <- list.files(dir, pattern = file.pattern)
    res <- lapply(files, function(x) {
        # read the file
        name.file <- paste(dir, x, sep = "/")
        con <- file(name.file, "r") 
        data.file <- readLines(con)
        close(con)  
        # clean
        data.file <- stri_trans_general(data.file, "en_US")
        data.file <- gsub('[])(;:#%$^*\\~{}[&+=@/"`|<>_]+', " ", data.file)
        data.file <- gsub("[¤º-»«Ã¢â¬Å¥¡Â¿°£·©Ë¦¼¹¸±???ð\u201E\u201F\u0097\u0083\u0082\u0080\u0081\u0090\u0095\u009f\u0098\u008d\u008b\u0089\u0087\u008a?????????.]+", " ", data.file)
        data.file <- gsub("[\002\020\023\177\003]", "", data.file)
        data.file <- sent_detect(data.file, language = "en", model = NULL)        
        # save update
        write(data.file, name.file)
  })
  
}
