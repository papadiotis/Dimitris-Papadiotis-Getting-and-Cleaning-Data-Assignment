library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename))
{
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(url, filename)
}  
if (!file.exists("UCI HAR Dataset")) 
{ 
  unzip(filename) 
}

# Load activity labels and features
# f = features and al = activity Labels

al <- read.table("UCI HAR Dataset/activity_labels.txt")
al[,2] <- as.character(al[,2])
f <- read.table("UCI HAR Dataset/features.txt")
f[,2] <- as.character(f[,2])

# Extract only the data on average and standard deviation
# fw = features Wanted
fw <- grep(".*mean.*|.*std.*", f[,2])
fw.names <- f[fw,2]
fw.names = gsub('-mean', 'Mean', fw.names)
fw.names = gsub('-std', 'Std', fw.names)
fw.names <- gsub('[-()]', '', fw.names)

# Load the datasets
# t = train
t <- read.table("UCI HAR Dataset/train/X_train.txt")[fw]
tActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
tSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
t <- cbind(tSubjects, tActivities, t)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[fw]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels

allData <- rbind(t, test)
colnames(allData) <- c("subject", "activity", fw.names)

# turn activities & subjects into factors

allData$activity <- factor(allData$activity, levels = al[,1], labels = al[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "TidyData.txt", row.names = FALSE, quote = FALSE)
