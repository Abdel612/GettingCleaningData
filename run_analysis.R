###
#
# run_analysis.R:
#    script getting and cleaning Samsung experiment data
# 
# Date: March 16th of 2015
#
# Author: Abdel612
#
##


# Loading helpful libraries
library(gdata)      # trim function
library(utils)      # read.table function
library(reshape2)   # Reshaping data.frame functions
library(stats)      # xtabs function
library(dplyr)      # melting function

#
# Given a kind of wanted observation return a data frame with tidy data
#             input: 
#                 - featToRetrieve : string vector: variable names (regexp) to be output
#                 - xFileName : string: file name of the observed activity features X_[train|test].txt
#                 - yFileName : string: file name of the performed activities Y_[train|test].txt
#                 - sFileName : string: file name of the subject (individual id) performing the activities subject_[train|test].txt
#                 - obsType: string: type of observation (train/test) - default="train"
#                 - aFileName: string: file name of the activity labels - default="activity_labels.txt"
#                 - fFileName: string: file name of the feature names - default="features.txt"
#             output: 
#                 - tidy data frame composed of matching features variables names as columns: data.frame 
#
#   This function reads:
#         - activity labels activity_labels.txt file
#         - features names features.txt file
#         - features in X_[train|test].txt file
#         - performed activities in Y_[train|test].txt file
#         - individuals id in subject_[train|test].txt file
getActivityObservations = function (featToRetrieve, xFileName, yFileName, sFileName, obsType="train", aFileName="activity_labels.txt", fFileName="features.txt"){
  
  # checkFileExistance: check if a file exist.
  #               input:
  #                   - fileName: string: name of the file to read from. If using file path, watch out file separator on Windows/Unix worlds
  #               output: 
  #                   - boolean: FALSE indicates the file does not exist (an error message is printed out)
  checkFileExistance = function(fileName){
    if (!file.exists(fileName)){
      cat("\t\tUnable to locate file '",fileName,"'. Aborting analysis!\n")
      return(FALSE)
    }
    return(TRUE)
  }
  
  
  # getDataVectorFromTextFile: extract a valued vector from a text file 
  #               input:
  #                   - fileName: string: name of the file to read from. If using file path, watch out file separator on Windows/Unix worlds
  #               output: 
  #                   - chr vector: read lines 
  getDataVectorFromTextFile = function(fileName=""){
    if (!checkFileExistance(fileName)){
      stop()
    } 
    conn = file(fileName, open="r")
    tmpV = readLines(conn)
    close(conn)
    if (length(tmpV) == 0){
      cat("\t\t'",fileName,"' does not contains any value. Aborting analysis!\n")
      stop()     
    }
    return(tmpV)  
  }

  # cleanFeaturesObs: Transform a  characteres vector into a clean data.frame
  #               input: 
  #                   - chr Vector: Vector to clean
  #               output: 
  #                   - data frame
  cleanFeaturesObs = function(obsV){
    return(unlist(strsplit(trim(obsV),"\\s+")))
  }
  
  
  
  #
  # Main routine
  #
  
  cat("*** Engineering '",toupper(obsType),"' observations. ***\n")
  
  
  # 1. Read involved individuals IDs (subject_[train|test].txt)
  cat("\t1.Reading individuals IDs from '",sFileName,"' file.\n")
  subjectsID = getDataVectorFromTextFile(sFileName)
  if (is.null(subjectsID)) stop() 
  nrSubjectObs = length(subjectsID)
  cat("\t\tNumbers of observations recorded: ", nrSubjectObs,"\n")
  cat("\n")
  
  
  # 2. Read performed activity id (Y_[train|test].txt) and Validate that 
  #    it holds the same number of observations as for Individual IDs
  cat("\t2.Reading activity IDs from '",yFileName,"' file.\n")
  activitiesID = getDataVectorFromTextFile(yFileName)
  if (is.null(activitiesID)) stop()
  activitiesID=as.numeric(activitiesID)
  nrYObs = length(activitiesID)
  cat("\t\tNumbers of observations recorded: ", nrYObs, "\n")
  if ( nrYObs != nrSubjectObs ){
    cat("\t\tObservations' length differs from '",sFileName+"' to '",yFileName,"'. Aborting Analysis!\n")
    stop()
  }
  observedActIDLevels = order(as.numeric(levels(factor(activitiesID))))
  cat("\t\tObserved distinct activity IDs: ",observedActIDLevels,".\n")
  cat("\n")  

  
  # 3. Read activity labels (activity_labels.txt) and validate that observed
  #   activiy IDs are correctly registered within this set.
  cat("\t3.Reading activity labels from '",aFileName,"' file.\n")
  if (!checkFileExistance(aFileName)) stop()
  actLabels = read.table(aFileName, col.names=c("activityID","activityLabel"))
  if (is.null(actLabels)){
    cat("\t\t'",aFileName,"' does not contains any value. Aborting analysis!\n")
    stop()
  }
  actLabelsIDLevels = order(as.numeric(levels(factor(actLabels$activityID)))) 
  cat("\t\tRegistered activity IDs: ",actLabelsIDLevels,".\n")
  if (any(observedActIDLevels != actLabelsIDLevels)){
    cat("\t\tThere is a mismatch between registred activity ID and observed activity ID. Aborting Analysis!\n")
    stop()
  }
  cat("\n")  
  

  # 4. Read feature names (features.txt) 
  cat("\t4.Reading feature names from '",fFileName,"' file.\n")
  if (!checkFileExistance(fFileName)) stop()
  features = read.table(fFileName, col.names=c("idx","name"), as.is=c(TRUE,TRUE), colClasses=c("integer", "character"))
  if (is.null(features)){
    cat("\t\t'",fFileName,"' does not contains any value. Aborting analysis!\n")
    stop()
  }
  nrFeatures = nrow(features)
  cat("\t\t Numbers of named features: ", nrFeatures, "\n")
  cat("\n")
  
  
  # 5. Read measured features (X_[train|test].txt)
  #    then a. Clean them up
  #         b. Check that we have the same number of observation according to the number of features
  #         c. Transform the Vector to a data.frame
  #         d. Retrieving desired feature names and indices
  #         e. Building the tidy filtered dataframe and associate the variable names
  #         f. Set the tidy data.frame column names for each feature
  #         g. Add descriptive activity names column
  #         h. Add Individuals ID column
  cat("\t5.Reading observed features from '",xFileName,"' file.\n")
  dirtyObservedFeatures = getDataVectorFromTextFile(xFileName)
  if (is.null(dirtyObservedFeatures)) stop()
  # a. Clean the retrieved measured features
  cleanObservedFeatures = cleanFeaturesObs(dirtyObservedFeatures)
  cat("\t\tNumber of measures retrieved after cleaning:",length(cleanObservedFeatures),"\n")
  rm(dirtyObservedFeatures) # save memory by removing dirtyMeasuresFeatures
  # b. Check that we have the same number of observation (according to the number of features)
  #     As a reminder, the total number (length of our vector) should be equal to the number
  #     of observations (either Subject set or Activity set) times the number of features
  if (length(cleanObservedFeatures)!=nrSubjectObs*nrFeatures){
    cat("\t\tFound ",length(cleanObservedFeatures)," measures, which does not equal ",nrSubjectObs,"x",nrFeatures,".")
    cat("Aborting Analysis!")
    stop()
  }
  # c. Transform the Vector to a data.frame
  cat("\t\tCreating a temporary data.frame( ncol=",nrFeatures,", nrow=",nrSubjectObs,") to hold measures\n")
  tmpDF = data.frame(matrix(as.numeric(cleanObservedFeatures), ncol=nrFeatures, byrow=TRUE))  
  # d. Retrieving desired feature names and indices
  cat("\t\tFiltering measured features against '",featToRetrieve,"' regexp pattern: ")
  filteredFeatures = features[grepl(featToRetrieve, features$name, ignore.case=FALSE),]
  cat(nrow(filteredFeatures)," features selected.\n")
  # e. Building the tidy filtered dataframe and associate the variable names
  cat("\t\tCreating and populating the tidy data.frame with relevant measures\n")
  tidyDF = data.frame(tmpDF[,filteredFeatures[1,]$idx])
  for ( i in 2:nrow(filteredFeatures) ){
    tidyDF = cbind(tidyDF, tmpDF[,filteredFeatures[i,]$idx])
  }
  # f. Add descriptive activity names column
  cat("\t\tLeft inserting descriptive activity names column\n")
  tidyDF = cbind(actLabels$activityLabel[activitiesID], tidyDF)
  # g. Add Individuals ID column
  cat("\t\tLeft inserting Individuals ID column\n")
  tidyDF = cbind(subjectsID, tidyDF)
  # h. Set the tidy data.frame column names for each feature
  cat("\t\tSetting the tidy data.frame column names for each feature\n")
  colnames(tidyDF) = c("subject","activity",filteredFeatures$name)
  cat("\n*** End of engineering '",toupper(obsType),"' observations.***\n\n")
  return(tidyDF)
}

##
#
# Let's rock! The script execution starts here
#
##

cat("\n\t****** Compute project's final tidy data sets. ******\n\n")
# Get a tidy data set from train observations
trainDF=getActivityObservations("-mean|-std","train/X_train.txt","train/y_train.txt","train/subject_train.txt")
# Get a tidy data set from test observations
testDF=getActivityObservations("-mean|-std","test/X_test.txt","test/y_test.txt","test/subject_test.txt", obsType="test")
# Compute the final
tidyMeasures=rbind(trainDF,testDF)
cat("\tThe final tidy data set is called 'tidyMeasures' and has",ncol(tidyMeasures),"columns and",nrow(tidyMeasures),"cols.\n")
# Get ride of temporary variables
rm(testDF, trainDF)

# Compute the data set handling the average of each variable for each activity and each subject 
tmpMelt=melt(tidyMeasures, id.vars=c("subject","activity"), measures.vars=names(tidyMeasures)[-c(1,2)])
avgMeasureByActAndBySubject=dcast(tmpMelt, subject + activity ~ variable, mean)
cat("\tThe data set handling mean values by subject and by activity is called 'avgMeasureByActAndBySubject'.\n")
# Get ride of temporary variables
rm(tmpMelt)

# Finally, write the avgMeasureByActAndBySubject to a file named 'avgMeasureByActAndBySubject.txt' in the current working directory
write.table(avgMeasureByActAndBySubject,file="avgMeasureByActAndBySubject.txt",row.name=FALSE)

cat("\n\t****** End of analysis ******\n\n")
