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
# Given a kind of wanted observation return a data frame with tid data
#
getActivityObservation = function (kind="test"){
  
  readTxtFile = function(fileName=""){
    if (fileName=="") return(NULL)
      conn = file(file.path(kind,fileName), open="r")
    
  }
  
}
