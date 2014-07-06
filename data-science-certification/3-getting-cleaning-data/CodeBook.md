# Codebook

## Variables
========================================================
### Activity.
- Description of the activity performed by volunteers
- Data type = categorical
- Values = WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING

### Subject.
- Volunteer id
- Data type = categorical
- Values = 1:30

### Averages.
- The following variables are the average values calculated on the previous activity and subject variables of the means and standard deviations contained in the files X_train.txt and X_test.txt. 

- Description of the original variables contained in the files X_train.txt and X_test.txt. [Excerpted from the file features_info.txt in the zip https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip]

  The features selected for this database come from the accelerometer and gyroscope 3-axial       
  raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time)   
  were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and 
  a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. 
  Similarly, the acceleration signal was then separated into body and gravity acceleration   
  signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a 
  corner frequency of 0.3 Hz. 

  Subsequently, the body linear acceleration and angular velocity were derived in time to 
  obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these 
  three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAcc
  Mag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

  Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing 
  fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkM
  ag. (Note the 'f' to indicate frequency domain signals). 

  These signals were used to estimate variables of the feature vector for each pattern:  
  '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

- Data type: numerical, continuous
- Complete list of the averages variables:
  - tbodyaccmeanx (also y and z), tbodyaccstdx (also y and z)
  -	tgravityaccmeanx (also y and z), tgravityaccstdx (also y and z)
  -	tbodyaccjerkmeanx (also y and z), tbodyaccjerkstdx (also y and z)
  -	tbodygyromeanx (also y and z), tbodygyrostdx (also y and z) 
  -	tbodygyrojerkmeanx (also y and z), tbodygyrojerkstdx (also y and z) 
  -	tbodyaccmagmean, tbodyaccmagstd 
  -	tgravityaccmagmean, tgravityaccmagstd 
  -	tbodyaccjerkmagmean, tbodyaccjerkmagstd 
  -	tbodygyromagmean, tbodygyromagstd 
  -	tbodygyrojerkmagmean, tbodygyrojerkmagstd 
  -	fbodyaccmeanx (also y and z), fbodyaccstdx (also y and z)
  -	fbodyaccjerkmeanx (also y and z), fbodyaccjerkstdx (also y and z)
  -	fbodygyromeanx (also y and z), fbodygyrostdx (also y and z)
  -	fbodyaccmagmean, fbodyaccmagstd 
  -	fbodybodyaccjerkmagmean, fbodybodyaccjerkmagstd 
  - fbodybodygyromagmean, fbodybodygyromagstd 
  -	fbodybodygyrojerkmagmean, fbodybodygyrojerkmagstd

## Transformation and summary choices
The following steps have been executed to get tidy data from the original raw data:
- 1.Creation of a unique data set containing the three training files X_train.txt, y_train.txt, subject_train.txt. 
  Extracted only the measurements on the mean and standard deviation for each measurement from    
  the file X_train.txt.
- 2.Execution of the step 2 for the three test files X_test.txt, y_test.txt, subject_test.txt.
- 3.Creation of a unique data set appending the file produced at step 1 to the produced at step 2.
- 4.Columns renaming of the data set obtained at step 3 applying best practices for variables name (descriptive, all lowercase, not duplicated, without dots, underscores and spaces).
- 5.Merge of the data set obtained at step 4 with file activity_labels.txt containing the description of the activities. Deletion of the column with the id of the activity.
- 6.Creation of a tidy data set with the average of each variable (mean and standard deviation for each measurement) for each activity and each subject using the functions melt e dcast of the package reshape2.

## Study design
The original raw data are the result of an experiment on wearable computing and are available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip. 

For more details about the original experiment, see the README.txt file of the zip.

