##################################################
# SEPARATING SPAM FROM HAM
##################################################

# In goal of this exercises is to build and evaluate a spam filter using 
# a publicly available dataset first described in the 2006
# conference paper "Spam Filtering with Naive Bayes -- Which Naive Bayes?" 
# by V. Metsis, I. Androutsopoulos, and G. Paliouras. 
# The "ham" messages in this dataset come from the inbox of former Enron 
# Managing Director for Research Vincent Kaminski, one of the
# inboxes in the Enron Corpus. One source of spam messages in this dataset 
# is the SpamAssassin corpus, which contains hand-labeled
# spam messages contributed by Internet users. The remaining spam was 
# collected by Project Honey Pot, a project that collects spam
# messages and identifies spammers by publishing email address that humans 
# would know not to contact but that bots might target
# with spam. The full dataset we will use was constructed as roughly a 75/25 
# mix of the ham and spam messages.

# The dataset contains just two fields:
# - text: The text of the email.
# - spam: A binary variable indicating if the email was spam.

##################################################
# 1 -load the dataset
##################################################

emails <- read.csv("emails.csv", header = TRUE, sep = ",", 
                   stringsAsFactor = FALSE)
nrow(emails)  # 5728 observations
table(emails$spam)  # 1368 spams

# each email starts with the word "subject" but the frequency 
# with which it appears might help differentiate spam from ham. 
# a long email chain would have the word "subject" appear a number of times
# and this higher frequency might be indicative of a ham message

max(nchar(emails$text)) # 43952: number of characters in the longest email 
which.min(nchar(emails$text)) # 1992: row with the shortest email

##################################################
# 2 -create a corpus
##################################################

# load text mining packages
library(tm)
library(SnowballC)

# create corpus
corpus <- Corpus(VectorSource(emails$text))
# convert to lower-case
corpus <- tm_map(corpus, tolower)
# remove punctuation
corpus <- tm_map(corpus, removePunctuation)
# remove stopwords
corpus <- tm_map(corpus, removeWords, stopwords("english"))
# stem document
corpus <- tm_map(corpus, stemDocument)

# create matrix
dtm <- DocumentTermMatrix(corpus)
dtm # 28687 terms
# remove sparse terms
spdtm <- removeSparseTerms(dtm, 0.95)
spdtm # 330 terms
# convert to a data frame
emailsSparse <- as.data.frame(as.matrix(spdtm))
colnames(emailsSparse) <- make.names(colnames(emailsSparse))

which.max(colSums(emailsSparse))  # enron: most frequent word stem

# add dependent variable
emailsSparse$spam <- emails$spam

# most frequent terms in the ham dataset
which(colSums(subset(emailsSparse, spam == 0)) >= 5000)

# number of word stems at least 1000 times in the spam emails
which(colSums(subset(emailsSparse, spam == 1)) >= 1000) 

# conclusion: The lists of most common words are significantly 
# different between spam and ham emails so the frequencies of these
# most common words are likely to help differentiate between spam and ham

# note: the ham dataset is personalized to Vincent Kaminski,
# and therefore it might not generalize well to a general email user. 
# Caution is definitely necessary before applying the filters derived 
# in this problem to other email users, it would need to be further 
# tested before use as spam filters for other

##################################################
# 3 - build models
##################################################

#create factor variable
emailsSparse$spam <- as.factor(emailsSparse$spam)

# prepare training and test set
library(caTools)
set.seed(123)
split <- sample.split(emailsSparse$spam, 0.70)
emails.train <- subset(emailsSparse, split == TRUE)
emails.test <- subset(emailsSparse, split == FALSE)

##################################################
# 3 - logistic regression model
##################################################

# build a logistic regression model
spam.Log <- glm(spam ~ ., emails.train, family ="binomial")
summary(spam.Log)
# none of the variables are labeled as significant 
# a symptom of the logistic regression algorithm not converging

# predicted spam probabilities for the training set
spam.Log.pred <- predict(spam.Log ,type = "response")
table(spam.Log.pred < 0.00001)  # training set predicted probabilities < 0.00001
table(spam.Log.pred > 0.99999)  # training set predicted probabilities > 0.99999
# training set predicted probabilities between 0.00001 and 0.99999
table(spam.Log.pred >= 0.00001 & spam.Log.pred <= 0.99999) 

# training set accuracy
table(emails.train$spam, spam.Log.pred >= 0.5) 
(3052 + 954)/nrow(emails.train)  #  accuracy = 0.9990025

# calculate AUC
library(ROCR)
predROCR = prediction(spam.Log.pred, emails.train$spam)
performance(predROCR, "auc")@y.values  # AUC = 0.9999952

##################################################
# 3 - CART model
##################################################

# build a CART model
library(rpart)
library(rpart.plot)
spam.CART <- rpart(spam ~ ., emails.train, method ="class")
prp(spam.CART)

# predicted spam probabilities for the training set
spam.CART.pred <- predict(spam.CART)[,2]

# training set accuracy
table(emails.train$spam, spam.CART.pred >= 0.5)
(2459 + 957)/nrow(emails.train)  # accuracy = 0.8518703 ??????

# calculate AUC
predROCR = prediction(spam.CART.pred, emails.train$spam)
performance(predROCR, "auc")@y.values  # AUC = 0.966737?????

##################################################
# 3 - forest model
##################################################

# build a random forest model
library(randomForest)
set.seed(123)
spam.RF = randomForest(spam ~ ., emails.train, method ="class")

# RF model: predicted spam probabilities for the training set
spam.RF.pred = predict(spam.RF, type="prob")[,2] 

# training set accuracy
table(emails.train$spam, spam.RF.pred >= 0.5)
(3006 +  916)/nrow(emails.train)  # accuracy = 0.9780549

# calculate AUC
predROCR = prediction(spam.RF.pred, emails.train$spam)
performance(predROCR, "auc")@y.values  # AUC = 0.9976009


##################################################
# conclusion
##################################################
# In terms of both accuracy and AUC, # logistic regression is nearly perfect 
# and outperforms the other two models
##################################################


