##########################################################
# DETECTING VANDALISM
##########################################################
# Wikipedia (http://en.wikipedia.org/wiki/Wikipedia) is a free online 
# encyclopedia that anyone can edit and contribute to. One of the consequences 
# of being editable by anyone is that some people vandalize pages.
# In this assignment we will attempt to develop a vandalism detector that 
# uses machine learning to distinguish between a valid edit and vandalism.
# The data for the problem is based on the revision history of the page Language.

##########################################################
# read the data
##########################################################
wiki <- read.csv("wiki.csv", header = TRUE, sep = ",", stringsAsFactor = FALSE)
wiki$Vandal <- as.factor(wiki$Vandal)
table(wiki$Vandal)

# install text mining package
install.packages("tm")
library(tm)
install.packages("SnowballC")
library(SnowballC)

##########################################################
# create an Added bag-of-words dataframe
##########################################################

# create corpus
corpusAdded <- Corpus(VectorSource(wiki$Added))
# remove stopwords
corpusAdded <- tm_map(corpusAdded, removeWords, stopwords("english"))
# stem document 
corpusAdded <- tm_map(corpusAdded, stemDocument)

# create matrix
dtmAdded <- DocumentTermMatrix(corpusAdded)
dtmAdded
# remove sparse terms
sparseAdded <- removeSparseTerms(dtmAdded, 0.997)
sparseAdded

# convert to a data frame
wordsAdded <- as.data.frame(as.matrix(sparseAdded))
colnames(wordsAdded) <- paste("A", colnames(wordsAdded))

##########################################################
# create a Removed bag-of-words dataframe
##########################################################

# create corpus
corpusRemoved <- Corpus(VectorSource(wiki$Removed))
# remove stopwords
corpusRemoved <- tm_map(corpusRemoved, removeWords, stopwords("english"))
# stem document 
corpusRemoved <- tm_map(corpusRemoved, stemDocument)

# create matrix
dtmRemoved <- DocumentTermMatrix(corpusRemoved)
dtmRemoved
# remove sparse terms
sparseRemoved <- removeSparseTerms(dtmRemoved, 0.997)
sparseRemoved

# convert to a data frame
wordsRemoved <- as.data.frame(as.matrix(sparseRemoved))
colnames(wordsRemoved) <- paste("R", colnames(wordsRemoved))

##########################################################
# build a CART model
##########################################################

# combine dataframes
wikiWords <- cbind(wordsAdded, wordsRemoved)
wikiWords$Vandal <- wiki$Vandal

# prepare training and test set
library(caTools)
set.seed(123)
split <- sample.split(wikiWords$Vandal, 0.7)
wiki.train <- subset(wikiWords, split == TRUE)
wiki.test <- subset(wikiWords, split == FALSE)

# baseline accuracy
table(wiki.test$Vandal)
618/(618 + 545)  # 0.5313844

# build a CART model
library(rpart)
library(rpart.plot)
wiki.CART <- rpart(Vandal ~ ., wiki.train, method = "class")
prp(wiki.CART) #the tree uses two stem words: "R arbitr" and "R thousa"

# Evaluate the performance of the model
wiki.pred <- predict(wiki.CART, wiki.test, type = "class")
table(wiki.test$Vandal, wiki.pred)
# model accuracy
(618 + 12)/nrow(wiki.test)  # 0.5417025

# Conclusion: although it beats the baseline, 
# bag of words is not very predictive for this problem

##########################################################
# problem-specific knowledge - Key class of words 
##########################################################

# create a copy of the first data set
wikiWords2 <- wikiWords

# label revision with link
wikiWords2$HTTP <- ifelse(grepl("http", wiki$Added, fixed = TRUE), 1, 0)
table(wikiWords2$HTTP)

# prepare training and test set
wiki.train2 <- subset(wikiWords2, split == TRUE)
wiki.test2 <- subset(wikiWords2, split == FALSE)

# build a CART model
wiki.CART2 <- rpart(Vandal ~ ., wiki.train2, method = "class")
prp(wiki.CART2)
  
# Evaluate the performance of the model
wiki.pred2 <- predict(wiki.CART2, wiki.test2, type = "class")
table(wiki.test2$Vandal, wiki.pred2)

# model accuracy
(609 + 57)/nrow(wiki.test2)  # 0.5726569

##########################################################
# problem-specific knowledge - counting words 
##########################################################

# sum the rows of dtmAdded and dtmRemoved and add them as new variables
wikiWords2$NumWordsAdded <- rowSums(as.matrix(dtmAdded))
wikiWords2$NumWordsRemoved <- rowSums(as.matrix(dtmRemoved))

# average number of words added
mean(wikiWords2$NumWordsAdded)

# prepare training and test set
wiki.train3 <- subset(wikiWords2, split == TRUE)
wiki.test3 <- subset(wikiWords2, split == FALSE)

# build a CART model
wiki.CART3 <- rpart(Vandal ~ ., wiki.train3, method = "class")
prp(wiki.CART3)

# Evaluate the performance of the model
wiki.pred3 <- predict(wiki.CART3, wiki.test3, type = "class")
table(wiki.test3$Vandal, wiki.pred3)

# model accuracy
(514 + 248)/nrow(wiki.test3)  # 0.6552021

##########################################################
# using not textual data (metadata) 
##########################################################

# create a copy of the second data set
wikiWords3 <- wikiWords2

# add metadata column
wikiWords3$Minor <- wiki$Minor
wikiWords3$Loggedin <- wiki$Loggedin

# prepare training and test set
wiki.train4 <- subset(wikiWords3, split == TRUE)
wiki.test4 <- subset(wikiWords3, split == FALSE)

# build a CART model
wiki.CART4 <- rpart(Vandal ~ ., wiki.train4, method = "class")
prp(wiki.CART4)

# Evaluate the performance of the model
wiki.pred4 <- predict(wiki.CART4 , wiki.test4, type = "class")
table(wiki.test4$Vandal, wiki.pred4)

# model accuracy
(595 + 241)/nrow(wiki.test4)  # 0.7188306

##########################################################
# conclusion
##########################################################
# By adding new independent variables, we were able
# to significantly improve our accuracy without making the model 
# more complicated!
