##########################################
# UNDERSTANDING PEOPLE VOTE
##########################################

# In August 2006 three researchers (Alan Gerber and Donald Green of 
# Yale University, and Christopher Larimer of the University of
# Northern Iowa) carried out a large scale field experiment in Michigan, 
# USA to test the hypothesis that one of the reasons people vote is
# social, or extrinsic, pressure 
# see http://www.apsanet.org/imgtest/apsrfeb08gerberetal.pdf

# The goal of the exercise is to use both logistic regression and 
# classification trees to analyze the data they collected.

##########################################
# load data
##########################################
gerber <- read.csv("gerber.csv")
# proportion of people voted in this election
table(gerber$voting)/nrow(gerber)
# treatment group with the largest fraction of voters
hawthorne <- subset(gerber, gerber$hawthorne == 1)
civicduty <- subset(gerber, gerber$civicduty == 1)
neighbors <- subset(gerber, gerber$neighbors == 1)
self <- subset(gerber, gerber$self == 1)
table(hawthorne$voting)/nrow(hawthorne)
table(civicduty$voting)/nrow(civicduty)
table(neighbors$voting)/nrow(neighbors)
table(self$voting)/nrow(self)
# or
tapply(gerber$voting, gerber$hawthorne, mean)
tapply(gerber$voting, gerber$civicduty, mean)
tapply(gerber$voting, gerber$neighbors, mean)
tapply(gerber$voting, gerber$self, mean)

##########################################
# build a logistic regression model
##########################################
log.model <- glm(voting ~ hawthorne + civicduty + neighbors + self, 
                 gerber, family= "binomial")
summary(log.model)
# calculate model accuracy with 2 threshold 
log.pred <- predict(log.model, type="response")
table(gerber$voting, log.pred > 0.3)
accuracy <- (134513 + 51966)/nrow(gerber)
table(gerber$voting, log.pred > 0.5)
accuracy <- 235388/nrow(gerber)
# calculate baseline model accuracy
table(gerber$voting)
accuracy.baseline <- 235388/nrow(gerber)
# calculate AUC
install.packages("ROCR")
library(ROCR)
pred = prediction(log.pred, gerber$voting)
as.numeric(performance(pred, "auc")@y.values)
# Even though all of our variables are significant, 
# our model does not improve over the baseline model
# of just predicting that someone will not vote, 
# and the AUC is low. So while the treatment groups 
# do make a difference, this is a weak predictive model.

##########################################
# build a regression tree to explore the fraction of people who vote
##########################################
# Install rpart library
install.packages("rpart")
library(rpart)
install.packages("rpart.plot")
library(rpart.plot)
# build and plot the tree
CARTmodel = rpart(voting ~ civicduty + hawthorne + self + neighbors,
                  data=gerber)
prp(CARTmodel)
# There are no splits in the tree, because none of the variables
# make a big enough effect to be split on --> try with cp = 0.0
CARTmodel2 = rpart(voting ~ civicduty + hawthorne + self + neighbors, 
                   data=gerber, cp=0.0)
prp(CARTmodel2)
# add sex variable
CARTmodel3 = rpart(voting ~ civicduty + hawthorne + self + neighbors + sex, 
                   data=gerber, cp=0.0)
prp(CARTmodel3)

##########################################
# interaction term
##########################################
CARTmodel4 = rpart(voting ~ control, 
                   data=gerber, cp=0.0)
prp(CARTmodel4, digit = 6)
# add sex variable
CARTmodel5 = rpart(voting ~ control + sex, 
                   data=gerber, cp=0.0)
prp(CARTmodel5, digit = 6)
abs(0.296638 - 0.34)

woman <- 0,043023
man <- 0,04372
# logistic regression model with sex and control
log.model1 <- glm(voting ~ control + sex, gerber, family= "binomial")
summary(log.model1)
Possibilities = data.frame(sex=c(0,0,1,1),control=c(0,1,0,1))
log.pred1 <- predict(log.model1, Possibilities, type="response")
abs(0.2908065 - 0.290456)
# add a new variable woman+control
log.model2 = glm(voting ~ sex + control + sex:control, gerber, 
                 family="binomial")
summary(log.model2)
log.pred2 <- predict(log.model2, Possibilities, type="response")
abs(0.2904558 - 0.290456)


##########################################
# conclusion
##########################################

# trees can capture nonlinear relationships that logistic regression 
# can not, but that we can get around this sometimes by using variables 
# that are the combination of two variables

# We should not use all possible interaction terms in a 
# logistic regression model due to overfitting. Even in this simple problem, 
# we have four treatment groups and two values for sex.
# If we have an interaction term for every treatment variable with sex, 
# we will double the number of variables. 
# In smaller data sets, this could quickly lead to overfitting.
