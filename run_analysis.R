# Getting and Cleaning Data Project John Hopkins Coursera
# Author: tfvip2008

setwd("C:/Users/user/Desktop/Coursera/03.DataScienceFoundationsusingRSpecialization/3.GettingandCleaningData/CourseProject")

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Load packages and get the data
# install.packages("reshape2")

library(reshape2)

path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "HAR.zip"))
unzip(zipfile = "HAR.zip") # the folder name is UCI HAR Dataset

# 4. Appropriately labels the data set with descriptive variable names.
# Load activity labels + features
activityLabels <- read.table(file.path(path, "UCI HAR Dataset/activity_labels.txt"),
                        col.names = c("classLabels", "activityName"))
features <- read.table(file.path(path, "UCI HAR Dataset/features.txt"),
                  col.names = c("index", "featureNames"))

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
features_sub <- grep("mean|std", features[, "featureNames"])
col_sub <- features[features_sub, "featureNames"]
col_sub <- gsub("[()]", "", col_sub)

# 4. Appropriately labels the data set with descriptive variable names.
# Load train datasets
x_train <- read.table(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, features_sub]
colnames(x_train) <- col_sub

y_train <- read.table(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))

sub_train <- read.table(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectID"))

train <- cbind(sub_train, y_train, x_train)

# Load test datasets
x_test <- read.table(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, features_sub]
colnames(x_test) <- col_sub

y_test <- read.table(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))

sub_test <- read.table(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectID"))

test <- cbind(sub_test, y_test, x_test)

# 1. Merges the training and the test sets to create one data set.
mrg <- rbind(train, test)

# 3. Uses descriptive activity names to name the activities in the data set
mrg$Activity <- factor(mrg$Activity
                       , levels = activityLabels$classLabels
                       , labels = activityLabels$activityName)

mrg$SubjectID <- as.factor(mrg$SubjectID)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
meltedData <- melt(mrg, id = c("SubjectID", "Activity"))
tidyData <- dcast(meltedData, SubjectID + Activity ~ variable, mean)

# write data to .txt file
write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

