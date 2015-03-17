#Code book

This document explains the steps followed up to obtain the tidy data set as expected by the Coursera **Getting and Cleaning Data** course assignement. Assumption is made that the reader has full knownledge of the provided data and the meaning of every variables: Lone newly created varaible will therefore be described in this document.


##Design strategy

The strategy chosen for this analysis script relies on a function *getActivityObservations* to retrieve *pseudo*tidy data from files embedded in the *UCI HAR Dataset.zip* tar ball ( url: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip - (C)[SmartLab](http://www.smartlab.ws) ): **getActivityObservations** *= function (featToRetrieve, xFileName, yFileName, sFileName, obsType="train", aFileName="activity_labels.txt", fFileName="features.txt")*

```
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
```

The steps followed to obtain those *pseudo*tidy data sets are the following:

1. Read involved individuals IDs (subject_[train|test].txt)
2. Read performed activity id (Y_[train|test].txt) and Validate that it holds the same number of observations as for Individual IDs
3. Read activity labels (activity_labels.txt) and validate that observed activiy IDs are correctly registered within this set.
4. Read feature names (features.txt) 
5. Read measured features (X_[train|test].txt), then:

+  a. Clean them up
+  b. Check that we have the same number of observation according to the number of features
+  c. Transform the Vector to a data.frame
+  d. Retrieving desired feature names and indices
+  e. Building the tidy filtered dataframe and associate the variable names
+  f. Set the tidy data.frame column names for each feature
+  g. Add descriptive activity names column
+  h. Add Individuals ID column



The above function is call twice: once for reading the train set, and a second time to read the test set.**Note:** although this function makes some simple checks (file existing, file containing data), please make sure to read the `Readme.md` file before proceeding.

To finish up, we just have to append the `test` set at the end of the `train` set. The function outputs 2 data.frames:

'**tidyMeasures**': `data.frame`: The final tidy data set embedding both test and test observations for mean and standard deviation values of observed items.

'**avgMeasureByActAndBySubject**': `data.frame`: The expected data set for question Nr. 5 of this assignement. It embeds mean values by activity and subject (individual) for each observed items of interest (mean and std measurements). This data set is also output in a file named `avgMeasureByActAndBySubject.txt` in the working directory

##Newly created variables

Lone 2 news variable has been created:

+  subject: `character`: identify the individual that performs the measured activity
+  activity: `character` : State the observed activity name.
