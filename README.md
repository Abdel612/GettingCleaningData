Coursera Getting & Cleaning Data Project
-----------------------------------------------------------------
This project is meant to serve as the submission work to validate the Coursera "Getting and Cleaning Data" MOOC
 
#Requirements
## Directory structure
In order to correctly output the desire results, Samsung data file (*UCI HAR Dataset.zip*) should be located (unzipped) in the directory where **run_analysis.R** *R script* is located, hence we should have the following directory/file tree ([d]=directory):

```
- activity_labels.txt
- features.txt
- [test]   => Tests related observations
   [Inertial Signals] (optional)
   subject_test.txt => Individual for whom the measures are made 
   X_test.txt => Measured features
   Y_test.txt => Run activities
- [train]   => train related observations
   [Inertial Signals] (optional)
   subject_train.txt => Individual for whom the measures are made
   X_train.txt => Measured features
   Y_train.txt => Run activities
- run_analysis.R => the R script that runs the analysis
```

## R Packages
The following packages are required in your development environment in order to smoothly run the **run_analysis.R** script, so please make sure the are installed ( cmd: install.packages(c("gdata","utils","reshape2","stats","dplyr") ) :

* gdata      
* utils      
* reshape2   
* stats      
* dplyr      




# Running the analysis
To run the analysis script, simply source it in your development environement (in either R-Studio or in the console) ( cmd: source("your_directory_path_to'run_analysis'_script/run.analysis.R") ). This script contains a function called *getActivityObservations* which reads and cleans up data from a given set (either *test* or *train*). This function is called for each set type before computing the final tidy data set. 


The **run_analysis.R** *R script* output is made of one file located at the root of the working directory (the directory where this *R Script* is located), and named '**avgMeasureByActAndBySubject.txt**'. This file corresponds to the data set required by the assignement in question Nr.5.

As a bonus, the script outputs the step it is running and create 2 data.frames:

*tidyMeasures: a data.frame containing the whole data elements for the assignement, in a tidy way
*avgMeasureByActAndBySubject: The data.frame required by question 5 of the assignement, i.e: mean measures by activity and subject (individuals)

The provided script **run_analysis.R** is heavily commented so that it would be easy for you to bring any change you want.

Have fun!
