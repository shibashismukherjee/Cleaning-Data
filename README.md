# Cleaning-Data

The purpose of this project was to celan and create a tidy dataset from the data collected  from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The source data can be found here

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

This repo also contains a codebook that describes the source data and the elements that were extracted for creating the tidy dataset. 

This document describes the analysis performed on the source data to create the tidy dataset using the "run_analysis.R"" script.. The follwoing steps are performed by thethe ecript as described below.

1. Download and read the source Data.
2. Merge the training and the test sets to create one data set.
3. Extract only the measurements on the mean and standard deviation for each measurement.
4. Use descriptive activity names to name the activities in the data set
5. Appropriately label the data set with descriptive variable names.
6. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

## Source Data Information

The source files unizp to a folder called "UCI HAR Dataset". Following Files from the folder "UCI HAR Dataset"" were used for the analysis:

* SUBJECT FILES
    + ./test/subject_test.txt
    + ./train/subject_train.txt
* ACTIVITY FILES
    + ./test/X_test.txt
    + ./train/X_train.txt
* DATA FILES
    + ./test/y_test.txt
    + ./train/y_train.txt
* Feature Name File
    + features.txt - Names of the feature variables
    + activity_labels.txt - Links the class labels with their activity name.

## Step 1. Download and read the source Data

### Set file path and download file
```{r}
filesPath <- "C:/RData/Cleaning-Data/"
setwd(filesPath)
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./Dataset.zip")
```
### Unzip DataSet and set working directory
```{r}
unzip(zipfile="./Dataset.zip")
setwd("./UCI HAR Dataset")
```
### Read the Files
```{r}
features_train_data <- read.table("./train/X_train.txt")
activity_train_data <- read.table("./train/y_train.txt")
subject_train_data <- read.table("./train/subject_train.txt")
features_test_data <- read.table("./test/X_test.txt")
activity_test_data <- read.table("./test/y_test.txt") 
subject_test_data <- read.table("./test/subject_test.txt")
```
## Step 2. Merge the training and the test sets to create one data set.

### Concatenate the training and test data
```{r}
features_data <- rbind(features_train_data, features_test_data)
activity_data <- rbind(activity_train_data, activity_test_data)
subject_data <- rbind(subject_train_data, subject_test_data)
```
### Name the variables in the data frames
```{r}
names(activity_data) <- "Activity"
names(subject_data) <- "Subject"
```
### Read the features to name feature variables
```{r}
features <- read.table("features.txt")
names(features) <- c("featureNum", "featureName")
colnames(features_data) <- features$featureName
```
## Step 3. Extract only the measurements on the mean and standard deviation for each measurement.

### Select only the mean and standard deviation columns names
```{r}
featuresMeanStd <-  grep("mean\\(\\)|std\\(\\)",features$featureName,value=TRUE, ignore.case=TRUE)
```

### Extract only the Mean and Standard Deviation Data
```{r}
features_mean_sd_data <- subset(features_data, select=featuresMeanStd)
```

### Put subject, activty number and activity value columns together
```{r}
subact_data <- cbind(subject_data, activity_data)
all_data <- cbind(subact_data, features_mean_sd_data)
```

## Step 4. Use descriptive activity names to name the activities in the data set.

### Read the activity labels and repalce activity num with descriptive activity names
```{r}
activity_lbls <- read.table("activity_labels.txt")
names(activity_lbls) <- c("activityNum", "Activity")

all_data$Activity <- as.character(all_data$Activity)
for (i in 1:6){
  all_data$Activity[all_data$Activity == i] <- as.character(activity_lbls[i,2])
}
```

## Step 5. Appropriately label the data set with descriptive variable names.

### Replace the label abbreviations to create descriptive vAriable Names
```{r}
names(all_data)<-gsub("std()", "SD", names(all_data))
names(all_data)<-gsub("mean()", "MEAN", names(all_data))
names(all_data)<-gsub("^t", "time", names(all_data))
names(all_data)<-gsub("^f", "frequency", names(all_data))
names(all_data)<-gsub("Acc", "Accelerometer", names(all_data))
names(all_data)<-gsub("Gyro", "Gyroscope", names(all_data))
names(all_data)<-gsub("Mag", "Magnitude", names(all_data))
names(all_data)<-gsub("BodyBody", "Body", names(all_data))
```
## Step 6. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

### Calculate the average of each variable for each activity and each subject
```{r}
tidy_data <- aggregate(. ~Subject + Activity, all_data, mean)
tidy_data <- tidy_data[order(tidy_data$Subject,tidy_data$Activity),]
```
### Calculate the average of each variable for each activity and each subject
```{r}
write.table(tidy_data, file = "TidyData.txt", row.names = FALSE)
```
### Output Tidy Data File
The output tidy data set contains a set of variables for each activity and each subject. There are 66 mean and standard deviation features averaged for each Subject by activity. For 30 subjects and 6 activities the resulting file has 180 rows and 68 columns – 33 Mean variables + 33 Standard deviation variables and 1 Subject( 1 of of the 30 test subjects) and ActivityName. The  first row is the header containing the names for each column.

The file may be viewed using the followiing code.
```{r}
tidyData <- read.table("TidyData.txt", header=TRUE)
View(tidyData)
```
