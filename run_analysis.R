run_analysis <- function() {
  
  ###Set file path and download file
  filesPath <- "C:/RData/Cleaning-Data/"
  setwd(filesPath)
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./Dataset.zip")
  
  ###Unzip DataSet and set working directory
  unzip(zipfile="./Dataset.zip")
  setwd("./UCI HAR Dataset")
  
  ### Read the Files
  features_train_data <- read.table("./train/X_train.txt")
  activity_train_data <- read.table("./train/y_train.txt")
  subject_train_data <- read.table("./train/subject_train.txt")
  features_test_data <- read.table("./test/X_test.txt")
  activity_test_data <- read.table("./test/y_test.txt") 
  subject_test_data <- read.table("./test/subject_test.txt")
  
  ### Concatenate the training and test data
  features_data <- rbind(features_train_data, features_test_data)
  activity_data <- rbind(activity_train_data, activity_test_data)
  subject_data <- rbind(subject_train_data, subject_test_data)
  
  ### Name the variables in the data frames
  names(activity_data) <- "Activity"
  names(subject_data) <- "Subject"
  
  ### Read the features to name feature variables
  features <- read.table("features.txt")
  names(features) <- c("featureNum", "featureName")
  colnames(features_data) <- features$featureName
  
  ### select only the mean and standard deviation columns names
  featuresMeanStd <-  grep("mean\\(\\)|std\\(\\)",features$featureName,value=TRUE, ignore.case=TRUE)
  ##featuresMeanStd <-  grep(".*Mean.*|.*Std.*",features$featureName,value=TRUE, ignore.case=TRUE)
  
  ### Extract only the Mean and Standard Deviation Data
  features_mean_sd_data <- subset(features_data, select=featuresMeanStd)
  
  ### Put subject, activty number and activity value columns together
  subact_data <- cbind(subject_data, activity_data)
  all_data <- cbind(subact_data, features_mean_sd_data)
  
  ### Read the activity labels and repalce activity num with descriptive activity names
  activity_lbls <- read.table("activity_labels.txt")
  names(activity_lbls) <- c("activityNum", "Activity")
  
  all_data$Activity <- as.character(all_data$Activity)
  for (i in 1:6){
    all_data$Activity[all_data$Activity == i] <- as.character(activity_lbls[i,2])
  }
  
  ### Label the dataset with descriptive vAriable Names
  names(all_data)<-gsub("std()", "SD", names(all_data))
  names(all_data)<-gsub("mean()", "MEAN", names(all_data))
  names(all_data)<-gsub("^t", "time", names(all_data))
  names(all_data)<-gsub("^f", "frequency", names(all_data))
  names(all_data)<-gsub("Acc", "Accelerometer", names(all_data))
  names(all_data)<-gsub("Gyro", "Gyroscope", names(all_data))
  names(all_data)<-gsub("Mag", "Magnitude", names(all_data))
  names(all_data)<-gsub("BodyBody", "Body", names(all_data))
  
  ### Calculate the average of each variable for each activity and each subject
  tidy_data <- aggregate(. ~Subject + Activity, all_data, mean)
  tidy_data <- tidy_data[order(tidy_data$Subject,tidy_data$Activity),]
  write.table(tidy_data, file = "TidyData.txt", row.names = FALSE)
  
}
