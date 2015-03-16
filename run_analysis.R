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
getActivityObservations = function (featToRetrieve, xFileName, yFileName, sFileName, obsKind="train", aFileName="activity_labels.txt", fFileName="features.txt"){
  
  # checkFileExistance: check if a file exist.
  #               input:
  #                   - fileName: string: name of the file to read from. If using file path, watch out file separator on Windows/Unix worlds
  #               output: 
  #                   - boolean: FALSE indicates the file does not exist (an error message is printed out)
  checkFileExistance = function(fileName){
    if (!file.exists(targetFileName)){
      cat("\t\tUnable to locate file '"+fileName+"'. Aborting analysis!\n")
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
      return(NULL)
    } 
    conn = file(targetFileName, open="r")
    tmpV = readLines(conn)
    close(conn)
    if (length(tmpV) == 0){
      cat("\t\t'"+fileName+"' does not contains any value. Aborting analysis!\n")
      return(NULL)     
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
  
  print(" Engineering '"+toupper(obsType)+"' observations.")
  
  
  # 1. Read involved individuals IDs (subject_[train|test].txt)
  cat("\t1.Reading individuals IDs from '"+sFileName+"' file.\n")
  subjectsID = getDataVectorFromTextFile(sFileName)
  if (is.null(subjectsID)) return(NULL) 
  nrSubjectObs = length(subjectsID)
  cat("\t\tNumbers of observations recorded: ", nrSubjectObs,"\n")
  cat("\n")
  
  
  # 2. Read performed activity id (Y_[train|test].txt) and Validate that 
  #    it holds the same number of observations as for Individual IDs
  cat("\t2.Reading activity IDs from '"+yFileName+"' file.\n")
  activitiesID = getDataVectorFromTextFile(yFileName)
  if (is.null(activitiesID)) return(NULL)
  nrYObs = length(activitiesID)
  cat("\t\t Numbers of observations recorded: ", nrYObs, "\n")
  if ( nrYObs != nrSubjectObs ){
    cat("\t\tObservations' length differs from '"+sFileName+"' to '"+yFileName+"'. Aborting Analysis!\n")
    return(NULL)
  }
  observedActIDLevels = order(as.numeric(levels(factor(activitiesID))))
  cat("\t\tObserved distinct activity IDs: ",observedActIDLevels,".\n")
  cat("\n")  

  
  # 3. Read activity labels (activity_labels.txt) and validate that observed
  #   activiy IDs are correctly registered within this set.
  cat("\t3.Reading activity labels from '"+aFileName+"' file.\n")
  if (!checkFileExistance(aFileName)) return(NULL)
  actLabels = read.table(aFileName, col.names=c("activityID","activityLabel"))
  if (is.null(actLabels)){
    cat("\t\t'"+aFileName+"' does not contains any value. Aborting analysis!\n")
    return(NULL)
  }
  actLabelsIDLevels = order(as.numeric(levels(factor(actLables$activityID)))) 
  cat("\t\tRegistered activities ID: ",actLabelsIDLevels,".\n")
  if (!any(observedActIDLevels != actLabelsIDLevels)){
    cat("\t\tThere is a mismatch between registred activity ID and observed activity ID. Aborting Analysis!\n")
    return(NULL)
  }
  cat("\n")  
  

  # 4. Read feature names (features.txt) 
  cat("\t4.Reading feature names from '"+fFileName+"' file.\n")
  if (!checkFileExistance(fFileName)) return(NULL)
  features = read.table(fFileName, col.names=c("idx","name"))
  if (is.null(features)){
    cat("\t\t'"+fFileName+"' does not contains any value. Aborting analysis!\n")
    return(NULL)
  }
  nrFeatures = nrow(features)
  cat("\t\t Numbers of named features: ", nrFeatures, "\n")
  cat("\n")
  
  
  # 5. Read measured features (X_[train|test].txt)
  #    then a. Clean them up
  #         b. Check that we have the same number of observation according to the number of features
  #         c. Transform the Vector to a data.frame
  cat("\t5.Reading observed features from '"+xFileName+"' file.\n")
  dirtyObservedFeatures = getDataVectorFromTextFile(xFileName)
  if (is.null(dirtyObservedFeatures)) return(NULL)
  # a. Clean the retrieved measured features
  cleanObservedFeatures = cleanFeaturesObs(dirtyObservedFeatures)
  rm(dirtyObservedFeatures) # save memory by removing dirtyMeasuresFeatures
  # b. Check that we have the same number of observation (according to the number of features)
  #     As a reminder, the total number (length of our vector) should be equal to the number
  #     of observations (either Subject set or Activity set) times the number of features
  if (length(cleanObservedFeatures)!=nrSubjectObs*nrFeatures){
    cat("\t\tFound ",length(cleanObservedFeatures)," measures, which does not equal ",nrSubjectObs,"x",nrFeatures,".")
    cat("Aborting Analysis!")
    return(NULL)
  }
  # c. Transform the Vector to a data.frame
  tmpDF = data.frame(matrix(as.numeric(cleanObservedFeatures), nrow=nrSubjectObs))
  # d. Retrieving desired feature names and indices
  filteredFeatures = featureNames[grepl(featToRetrieve,features$name),]
  # e. Building the tidy filtered dataframe and associate the variable names
  tidyDF = data.frame()
  for ( i in 1:nrow(filteredFeatures) ){
    tidyDF = cbind(tidyDF, tmpDF[,filteredFeatures[i]$idx])
  }
  colnames(tidyDF) = filteredFeatures$name
  
  
  
  return(tidyDF)
}
