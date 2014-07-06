# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation 
# for each measurement. 

# Select mean and standard deviation columns of the X files 
features.lines <- readLines("features.txt")
mean.std.col <- grep("mean\\(\\)|std\\(\\)", features.lines, value = FALSE)

# Read the training files (X, y and subject variables) and create a dataset
X.train <- read.table("X_train.txt")
X.train.subset <- X.train[, mean.std.col]
y.train <- read.table("y_train.txt")
subject.train <- read.table("subject_train.txt")
data.set.train <- data.frame(X.train.subset, y.train, subject.train)

# Read the test files (X, y and subject variables) and create a dataset
X.test <- read.table("X_test.txt")
X.test.subset <- X.test[, mean.std.col]
y.test <- read.table("y_test.txt")
subject.test <- read.table("subject_test.txt")
data.set.test <-data.frame(X.test.subset, y.test, subject.test)

# Append the two dataset created
data.set <- rbind(data.set.train, data.set.test)

# Appropriately labels the data set with descriptive names. 
features <- read.table("features.txt")
label.mean.std.col <- gsub( "\\(|\\)|\\-", "", 
                            tolower(features[mean.std.col, 2]))
label.col <- c(label.mean.std.col, "idactivity", "subject")
colnames(data.set) <- label.col

# Uses descriptive activity names to name the activities in the data set
activity.labels <- read.table("activity_labels.txt")
colnames(activity.labels) <-  c("idactivity", "activity")
data.set <- merge(data.set, activity.labels, x.by = "idactivity", 
                  y.by = "idactivity", all = FALSE)
data.set <- data.set[, 2:69]

# Creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject. 
data.melt <- melt(data.set, id = c("activity", "subject"), 
                  measure.vars <- label.mean.std.col)
tidy.data <-dcast(data.melt, activity + subject ~ variable, mean)

# Write the tidy data set
write.table(tidy.data, file = "tidy_data.txt", quote = FALSE, row.names = FALSE)

