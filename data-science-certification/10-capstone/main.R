# load libraries and functions
source("load.R")
load.libraries.functions()

# unit test
par(mar=c(5.1,4.1,4.1,2.1), mfrow=c(1,1))
tdf.list <- train.corpus("twitter.txt", 50, 10, "green")
str3 = "Hey sunshine, can you follow me and make me the"
ngram.model(str3, tdf.list)
tdf.list <- train.corpus("twitter.txt", 50, 10, "green", step = "ngram")

tdf.list <- train.corpus.one("twitter.txt", 500, "green")
str3 = "Hey sunshine, can you follow me and make me the"
ngram.model(str3, tdf.list)
tdf.list <- train.corpus.one("twitter.txt", 500, "green", step = "ngram")

# test
tdf.list <- train.corpus.one("twitter.txt", 100000, "green")
tdf.list <- train.corpus.one("blogs.txt", 100000, "blue")
tdf.list <- train.corpus.one("news.txt", 100000, "yellow")
tdf.list <- train.corpus("twitter.txt", 500000, 100000, "green")


file <- read.csv("unigram.csv")
unigram <- data.frame(file)
print(names(unigram))
file <- read.csv("bigram.csv")
bigram <- data.frame(file)
print(names(bigram))
file <- read.csv("trigram.csv")
trigram <- data.frame(file)
print(names(trigram))
file <- read.csv("fougram.csv")
fougram <- data.frame(file)
print(names(fougram))

