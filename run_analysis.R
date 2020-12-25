## Get the Data
## 1. Download the file
if(!file.exists("./Desktop")){dir.create("./Desktop")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./Desktop/Dataset.zip",method="curl")
## 2. Unzip the file
unzip(zipfile="./Desktop/Dataset.zip",exdir="./Desktop")
## 3. Get the list of unzipped files
path_rf <- file.path("./Desktop" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

## Read Data
## 1. Read data from the files into the variables
## 1a. Read the Activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
## 1b. Read the Subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
## 1c. Read the Features files
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

## Check the Properties of the Variables
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

## Merge the Training And the Test Sets to Create One Data Set
## 1. Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
## 2. Name the variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
## 3. Merge columns to get the data frame "Data" for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## Extract only the measurements on the mean and standard deviation for each measurement
## 1. Subset name of features by measurements 
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
## 2. Subset the data frame "Data" by selected names of features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
## 3. Check the structures of the data frame "Data"
str(Data)

## Use descriptive activity names to name the activities in the data set
## 1. Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
## 2. Factorize variable "activity" in the data frame "Data" using descriptive activity names
## 3. Check
head(Data$activity,30)

## Label the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)

##Create a second,independent tidy data set and ouput it
library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

## Generate codebook
library(knitr)
knit2html("CodeBook.md")

