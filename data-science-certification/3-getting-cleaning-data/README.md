# Introduction

An experiment on wearable computing has been carried out by Smartlab - Non Linear Complex Systems Laboratory.  30 volunteers performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Measurements like acceleration and angular velocity were collected from the accelerometer of the smartphones. The data were randomly partitioned into a training set and a test set to apply machine learning algorithm. For more details about the experiment, see the web site http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

I have prepared a script to transform the raw data of this experiment in tidy data to perform later analysis. This repo contains also the following files:
- CodeBook.md: a document that describe the data, the variables, and the transformations performed to clean up the raw data to obtain tidy data 
-	run_analysis.R: a script that produces the tidy data from the raw data 

Below, there is the instruction list.

# Instruction list
========================================================
Note. I have used Windows as operating system and I have tried the script more than once to confirm it gave the same results.

Step 1. Download the file zip https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and extract the following files in the working directory:
- X_train.txt
- y_train.txt
- subject_train.txt
- X_train.txt
- y_train.txt
- subject_train.txt
- activity_labels.txt
- features.txt

Step 2. Download the script run_analysis.R from the github repo https://github.com/silviad/gettingandcleaningdataproject in the working directory.

Step 3. Open Rstudio.

Step 4. If you have not already done, install and load package reshape2 with the instructions:
- install.packages("reshape2")
- library(reshape2)

Step 5. Run the  R script run_analysis.R with the instruction:
- source("run_analysis.R")

and wait until the execution of script finishes.

The script executes the following steps:
- Merges the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive names. 
- Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

Step 6. The file tidy_data.txt produced in the working directory is the tidy data set. You can read it with the instruction:
- read.table("tidy_data.txt", header=TRUE)

