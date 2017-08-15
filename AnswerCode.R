#Downlading data and reading data
if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile = "./data/dataset.zip",method = "curl")

unzip(zipfile = "./data/dataset.zip",exdir = "./data")


path <- file.path("./data","UCI HAR Dataset")
files <- list.files(path, recursive = TRUE)
files

ActivityTest <- read.table(file.path(path,"test","y_test.txt"),header = FALSE)
SubjectTest   <- read.table(file.path(path,"test","subject_test.txt"),header = FALSE)
FeaturesTest <- read.table(file.path(path,"test","X_test.txt"),header = FALSE)

ActivityTrain <- read.table(file.path(path,"train","y_train.txt"),header = FALSE)
SubjectTrain  <- read.table(file.path(path,"train","subject_train.txt"),header = FALSE)
FeaturesTrain <- read.table(file.path(path,"train","x_train.txt"),header = FALSE)

#Merge the training and the test sets to create one data set
DataSubject <- rbind(SubjectTrain,SubjectTest)
DataActivity <- rbind(ActivityTrain,ActivityTest)
DataFeatures <- rbind(FeaturesTrain,FeaturesTest)
names(DataSubject) <- c("subject")
names(DataActivity) <- c("activity")
FeaturesNames <- read.table(file.path(path,"features.txt"),header = FALSE)
names(DataFeatures) <- FeaturesNames$V2
mergeData <- cbind(DataFeatures,DataSubject,DataActivity)

#Extract only the measurements on the mean and standard deviation for each measurement
FeaturesNames <- read.table(file.path(path, "features.txt"),header=FALSE)
names(DataFeatures)<- FeaturesNames$V2
FeaturesIndex <- FeaturesNames$V2[grep(("mean\\(\\)|std\\(\\)"),FeaturesNames$V2)]
selectedNames <- c(as.character(FeaturesIndex),"subject","activity")
mergeData <- subset(mergeData,select = selectedNames)


#Uses descriptive activity names to name the activities in the data set
ActivityLabels <- read.table(file.path(path,"activity_labels.txt"),header = FALSE)
ActivityLabels <- as.character(ActivityLabels[,2])
mergeData$activity <- ActivityLabels[mergeData$activity]

# Appropriately labels the data set with descriptive variable names
names(mergeData) <- gsub("^t","time",names(mergeData))
names(mergeData) <- gsub("^f","frequency",names(mergeData))
names(mergeData) <- gsub("Acc","Accelerometer",names(mergeData))
names(mergeData) <- gsub("Gyro","Gyroscope",names(mergeData))
names(mergeData) <- gsub("Mag","Magnitude",names(mergeData))
names(mergeData) <- gsub("BodyBody","Body",names(mergeData))

#From the data set in step 4, creates a second, independent tidy data set with the average of 
#each variable for each activity and each subject.
library(plyr)
tidyData<-aggregate(. ~subject + activity, mergeData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)