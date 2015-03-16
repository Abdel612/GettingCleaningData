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


# Loading library handling string trim function
library(gdata)

#
# Given a kind of wanted observation return a data frame with tidy data
#             input: 
#                 - features : vector of string variable names (regexp) to be output 
#                 - kind of activity (train/test): string - default=train
#             output: 
#                 - tidy data frame composed of matching features variables names as columns: data.frame 
#
#   This function reads:
#         - features in X_[train|test].txt file
#         - performed activities in Y_[train|test].txt file
#         - individuals id in subject_[train|test].txt file
getActivityObservations = function (features, kind="train"){
  
  # readTextFile: read a text file and 
  #               input: 
  #                   - string: name of the file to read from
  #               output: 
  #                   - chr vector: read lines 
  readTxtFile = function(fileName=""){
    if (fileName=="") return(NULL)
    conn = file(file.path(kind,fileName), open="r")
    tmpDF = readLines(conn)
    if ( nrow(tmpDF) == 0 ) return(NULL)
    close(conn)
    return (tmpDF)  
  }

  # cleanFeaturesObs: Transform a  characteres vector into a clean data.frame
  #               input: 
  #                   - chr Vector: Vector to clean
  #               output: 
  #                   - data frame
  cleanFeaturesObs = function(obsV){
    
  }
}
