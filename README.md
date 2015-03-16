Coursera Getting & Cleaning Data Project
-----------------------------------------------------------------
This project is meant to serve as the submission work to validate the Coursera "Getting and Cleaning Data" MOOC

#Requirements
## Directory structure
In order to correctly output the desire results, Samsung data (*UCI HAR Dataset.zip*) should be located (unzipped) in the directory where **run_analysis.R** *R script* is located, hence we should have the following directory/file tree ([d]=directory):

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
   Y_train.txt  => Run activities
```

The **run_analysis.R** *R script* output is made of two file located at the root of the working directory (the directory where this *R Script* is located), and are the following:
````
First
Second
````