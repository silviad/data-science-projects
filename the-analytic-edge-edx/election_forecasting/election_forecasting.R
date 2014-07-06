##########################################################
# ELECTION FORECASTING
##########################################################
# The goal of the exercise is to develop a logistic regression model 
# on polling data in order to forecast the 2012 US presidential election
# plotting the predictions output on a map of the United States

##########################################################
# draw a map of USA
##########################################################

# load packages
library(ggplot2)
library(maps)
library(ggmap)

# load the map
statesMap = map_data("state")
unique(statesMap$group)  # number of different groups

# draw the map
ggplot(statesMap, aes(x = long, y = lat, group = group)) + 
       geom_polygon(fill = "white", color = "black") + coord_map("mercator")

##########################################################
# create a logistic regression model and make predictions
##########################################################

# read poll data
poll <- read.csv("PollingImputed.csv", header = TRUE, sep =",")

# preapare training and test set
poll.train <- subset(poll, Year %in% c(2004, 2008))
poll.test <- subset(poll, Year == 2012)

# create logistic regression model
poll.lm <- glm(Republican ~ SurveyUSA + DiffCount, data = poll.train,
               family = "binomial")
summary(poll.lm)

# predict on test data (predicted probabilities)
poll.predict <- predict(poll.lm, poll.test, type = "response")
# vector of Republican/Democrat predictions
poll.predict.binary <- as.numeric(poll.predict > 0.5)

# create a data frame
poll.predict.df <- data.frame(poll.predict, poll.predict.binary, 
                              poll.test$State)
table(poll.predict.df$poll.predict.binary)
# 22 states is our binary prediction 1, corresponding to Republican
# 22/45 = 0.48 average predicted probability of our model

# merge the 2 data frame, map data e prediction poll
poll.predict.df$region <- tolower(poll.predict.df$poll.test.State)
map.predict <- merge(statesMap, poll.predict.df, by ="region")
map.predict = map.predict[order(map.predict$order),]
# 15034 observations are there in statesMap
# 15034 observations are there in map.predict

# draw the map with poll predictions
ggplot(map.predict, aes(x = long, y = lat, group = group,
       fill = poll.predict.binary)) + geom_polygon(color = "black")

# refine the map
ggplot(map.predict, aes(x = long, y = lat, group = group, 
       fill = poll.predict.binary)) + geom_polygon(color = "black") +
       scale_fill_gradient(low = "blue", high = "red", guide = "legend", 
       breaks= c(0,1), labels = c("Democrat", "Republican"), 
       name = "Prediction 2012")

# plot the probabilities instead of the binary prediction 
# the only state that appears purple is the state of Iowa
ggplot(map.predict, aes(x = long, y = lat, group = group, 
       fill = poll.predict)) + geom_polygon(color = "black") +
       scale_fill_gradient(low = "blue", high = "red", guide = "legend", 
       breaks= c(0,1), labels = c("Democrat", "Republican"), 
       name = "Prediction 2012") 

##########################################################
# conclusion
##########################################################
# the logistic regression classifier did classify each state 
# for which we have data. However, a state will only appear 
# bright red if the logistic regression probability was close to 1, 
# and will only appear bright blue if the logistic regression 
# probability was close to 0. An in-between color like purple signifies 
# less confidence in the prediction. This is a good way to visualize 
# uncertainty. Although Iowa, the state that appears purple here, 
# was a hard state for us to predict, we don't know whether or not 
# it was a close race in the 2012 election. The color only represents 
# what our model thought.

# In our prediction map, the state of Florida is colored red, meaning 
# that we predicted Republican. So we incorrectly predicted this state.
# We predicted Republican for the state of Florida with high probability, 
# meaning that we were very confident in our incorrect prediction! 
# Historically, Florida is usually a close race, but our model doesn't know this. 
# The model only uses polling results for the particular year. For Florida 
# in 2012, Survey USA predicted a tie, but other polls predicted Republican, 
# so our model predicted Republican.


