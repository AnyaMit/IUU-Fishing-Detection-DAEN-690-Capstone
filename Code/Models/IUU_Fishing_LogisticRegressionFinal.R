#Author: Anna (Anya) Mityushina - mityushina.a@gmail.com
#Purpose: DAEN & SEOR Capstone - LM Stargazer IUU Detection
#Program: Data Analytics Engineering at George Mason University
#Date: March 3, 2018
   # R version 3.4.1 (2017-06-30) -- "Single Candle"
   # Copyright (C) 2017 The R Foundation for Statistical Computing
   # Platform: x86_64-w64-mingw32/x64 (64-bit)

    ## Other: Prior teams build a version of this model in Python. New code uses GBM and logit instead.
    ## Chosen methods: We chose to use GBM as it is an ensamble method with short learners and is known to 
          # outperform other algorithms for dichotomous datasets. The final is a logit (1 or 0).
          # The team also considered Anamolie detection, PCA, Random Forest, and Linear Regression.


## NOTE: During this code we check the system time to advise the next users of time consuming operations for future.
## you can use system.time (yourfunction) to test time of system and user

## NOTE: The lorenz.chart function cannot be shared. The next team can use the ROC curve, or write their own code to depict the lorenz graph.
        ## A sample of a lorenz graph code is displayed at the end of the code.

##############################
##### Load the packages ######
##############################

#Libraries
install.packages("gbm")     # GBM Models
library(gbm)  
install.packages("caret")
library(caret)
install.packages("corrplot")
library(corrplot)			# plot correlations
install.packages("doParallel")
library(doParallel)		# parallel processing
install.packages("dplyr")
library(dplyr)        # Used by caret
install.packages("pROC")
library(pROC)				  # plot the ROC curve
install.packages("VIF")
library(VIF)          # Used to calculate variance inflation factor (VIF) from the result of lm


#install.packages("H")
#install.packages("H")


##############################
####### Load the data ########
##############################

## This section takes 15 MINUTES for all datasets ##

#Read the data (5 Minutes / dataset) (Each set is approximately 1 GB with 1.5 million observations)
##   user  system elapsed 
##   237.43    3.02  242.67 

LL <- read.csv(file="C:/Users/Anutka/Documents/kr_LL_all.csv", header=TRUE, sep=",")
PS <- read.csv(file="C:/Users/Anutka/Documents/kr_ps_all.csv", header=TRUE, sep=",")
TR <- read.csv(file="C:/Users/Anutka/Documents/kr_tr_all.csv", header=TRUE, sep=",")

##How complete is our data?
sum(is.na(LL))/prod(dim(LL))
sum(is.na(PS))/prod(dim(PS))
sum(is.na(TR))/prod(dim(TR))

##############################
##### Transform the data #####
##############################

# Adding a variable for geartype. This will come important at a later time when we incorporate
# this model into other datasets. This way the model won't break if we encounter something other than these 
# fishing types.

LL$geartype <- "drifting_longlines"          #Adding a variable for geartype
PS$geartype <- "purse_seines"                # Adding a variable for geartype
TR$geartype <- "trawlers"                    # Adding a variable for geartype
LL$geartype_code <- 1       # 1 for drifting_longlines    #Adding a variable for geartype
PS$geartype_code <- 2       # 2 for purse_seines    # Adding a variable for geartype
TR$geartype_code <- 3       # 3 for trawlers    # Adding a variable for geartype

#NOTE: Master dataset will have many more types of vessels but we only have training data for these 3 types.
#When writing this back to the DB, we need to make sure we 'clean' up all data to have numeric geartype.


# #Create a single file to analyze if we want to re-analyze the populations. 

all_data <- rbind(LL,PS) ## About 2 seconds
all_data <- rbind(all_data,TR)## About 20 seconds

#Set Working directory
setwd("C:/Users/Anutka/Documents/DAEN690-Data Analytics Project/Model2")

# Create a text file containing all the descriptions of the variables in the dataset 
sink("variable_list.txt"); cat(names(LL), sep="\n + "); sink() # Only need to do this once, /
                                                              # / as our variables are the same for each set


# From prior work, have classification for when a vessel is fishing or not fishing. -1 is unknown.
    # This work was done by Dollhouse Univeristy in Canada. We are using their dataset to train our model.

# To train / test our model, we need to remove the -1 population and look at it later.
 

LL_bin <- subset(LL,classification != -1)               # Removing 'unknowns' for LL
PS_bin <- subset(PS,classification != -1)               # Removing 'unknowns' for PS
TR_bin <- subset(TR,classification != -1)               # Removing 'unknowns' for TR
LL_miss <- subset(LL,classification == -1)               # Saving 'unknowns' for LL
PS_miss <- subset(PS,classification == -1)               # Saving 'unknowns' for PS
TR_miss <- subset(TR,classification == -1)               # Saving 'unknowns' for TR

LL_bin$geartype <- NA         
PS_bin$geartype <- NA                
TR_bin$geartype <- NA                    
LL_bin$geartype_code <- NA       
PS_bin$geartype_code <- NA       
TR_bin$geartype_code <- NA   
#Set a seed and randomize the dataset
set.seed(234)

LL_bin <- LL_bin[sample(nrow(LL_bin)),] 
PS_bin <- PS_bin[sample(nrow(PS_bin)),]
TR_bin <- TR_bin[sample(nrow(TR_bin)),]
all_data <- all_data[sample(nrow(all_data)),] #25 sec

##############################
##### Variable Reduction #####
######### Longliners #########
##############################

set.seed(234)

# Shuffle the dataset, call the result shuffled 
n <- nrow(LL_bin)
shuffled <- LL_bin[sample(n),]

# Split the data in train and test
train.LL <- shuffled[1:round(0.7 * n),]
test.LL <- shuffled[(round(0.7 * n) + 1):n,]

# Print the structure of train and test
sink("structure of train LL"); str(train.LL); sink()
sink("structure of train LL"); str(test.LL); sink()

# Run GBM to get important variables for LL first

#### This part takes 16 MINUTES ####
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
model.LL <- gbm(classification ~ 1
                + measure_coursestddev_1800_log
                + measure_courseavg_43200
                + course
                + measure_sin_course
                + measure_daylightavg_900
                + measure_speedstddev_10800
                + speed
                + measure_pos_86400
                + measure_daylightavg_43200
                + measure_latavg_86400
                + distance_from_port
                + measure_lonavg_3600
                + measure_lonavg_1800
                + measure_courseavg_10800
                + distance_from_shore
                + measure_courseavg_1800
                + measure_speedstddev_86400
                + timestamp
                + measure_coursestddev_86400
                + measure_speedstddev_21600
                + measure_daylightavg_3600
                + measure_courseavg_86400
                + measure_speedstddev_3600_log
                + measure_coursestddev_900
                + measure_coursestddev_10800
                + measure_coursestddev_43200
                + measure_daylightavg_1800
                + measure_coursestddev_3600_log
                + measure_lonavg_900
                + measure_distance_from_port
                + measure_coursestddev_10800_log
                + measure_coursestddev_900_log
                + measure_latavg_21600
             #   + mmsi
                + measure_course
                + measure_lonavg_21600
                + measure_daylight
                + measure_pos_10800
                + measure_count_10800
                + measure_coursestddev_1800
                + measure_speedstddev_43200
                + measure_daylightavg_21600
                + measure_courseavg_21600
                + measure_speedavg_86400
                + measure_pos_900
                + measure_coursestddev_21600
                + measure_count_1800
                + measure_speed
                + measure_latavg_43200
                + measure_latavg_10800
                + measure_speedavg_1800
                + measure_count_3600
                + lon
                + measure_speedavg_10800
                + measure_speedavg_900
                + measure_daylightavg_10800
                + measure_count_21600
                + measure_courseavg_900
                + measure_speedstddev_3600
                + measure_pos_43200
                + measure_latavg_3600
                + measure_coursestddev_21600_log
                + measure_speedavg_43200
                + measure_courseavg_3600
                + measure_latavg_900
                + measure_daylightavg_86400
                + measure_count_43200
                + measure_coursestddev_3600
                + measure_lonavg_86400
                + measure_lonavg_43200
                + measure_cos_course
                + measure_pos_3600
                + measure_speedstddev_900
                + measure_speedstddev_21600_log
                + measure_count_86400
                + measure_pos_1800
                + measure_coursestddev_86400_log
                + measure_speedavg_3600
                + measure_speedstddev_1800
                + measure_coursestddev_43200_log
                + measure_latavg_1800
                + measure_speedavg_21600
                + measure_count_900
                + measure_speedstddev_86400_log
                + measure_lonavg_10800
                + measure_speedstddev_10800_log
                + lat
                + measure_speedstddev_43200_log
                + measure_pos_21600
                + measure_speedstddev_900_log
                + measure_speedstddev_1800_log,
                
                data=train.LL
                , distribution="bernoulli"
                , n.trees=800
                , shrinkage=0.05      ## Step Size
                , interaction.depth=2
                , n.minobsinnode = 10
                , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                , cv.folds=5         # We are using 6 cross validation folds
                , keep.data=FALSE
                , verbose=TRUE)

)
#Check if the model is overfitting? And optimal number of trees
best.iter <- gbm.perf(model.LL, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter)

# best.iter.LL <- 700 #From observing gbm model performance as it came in, we see that at 700 trees our Improve column becomse zero

#summarize the model
summary.LL<-summary(model.LL, n.trees=(best.iter.LL+0))
print(summary.LL)
sink("summary.ModelLL.txt"); print(summary.LL); sink()
# Predict
train.LL$pred01<-predict.gbm(model.LL,train.LL,best.iter.LL,type="response") *-1
test.LL$pred01 <-predict.gbm(model.LL,test.LL,best.iter.LL,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.LL,"classification", "pred01", title="Lift Chart Train LL")
lorenz.chart(test.LL,"classification", "pred01", title="Lift Chart Test LL")


#Draw the ROC curve 
head(train.LL$pred01)

gbm.ROC <- roc(predictor=train.LL$pred01,
               response=train.LL$classification)

gbm.ROC$auc #Area under the curve: 0.998
plot(gbm.ROC,main="GBM ROC LL")

predLL <-rbind(train.LL, test.LL)
# Plot the propability of poor segmentation
histogram(~predLL$classification|predLL$pred01,xlab="Probability of Poor Segmentation")

###Performance with 9 variables:
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
  model.LL2 <- gbm(classification ~ 1
                  + measure_coursestddev_43200
                  + measure_pos_86400
                  + distance_from_port
                  + measure_coursestddev_86400
                  + measure_pos_43200
                  + measure_coursestddev_21600
                  + distance_from_shore
                  + measure_pos_21600
                  + measure_speedavg_21600
                  ,
                  
                  data=train.LL
                  , distribution="bernoulli"
                  , n.trees=800
                  , shrinkage=0.05      ## Step Size
                  , interaction.depth=2
                  , n.minobsinnode = 10
                  , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                  , cv.folds=5         # We are using 6 cross validation folds
                  , keep.data=FALSE
                  , verbose=TRUE)
  )
#Check if the model is overfitting? And optimal number of trees
best.iter <- gbm.perf(model.LL2, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter)

# best.iter.LL <- 700 #From observing gbm model performance as it came in, we see that at 700 trees our Improve column becomse zero

#summarize the model
summary.LL2<-summary(model.LL2, n.trees=(best.iter.LL+0))
print(summary.LL2)
sink("summary.ModelLL2.txt"); print(summary.LL2); sink()
# Predict
train.LL$pred02<-predict.gbm(model.LL2,train.LL,best.iter.LL,type="response") *-1
test.LL$pred02 <-predict.gbm(model.LL2,test.LL,best.iter.LL,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.LL,"classification", "pred01", title="Lift Chart Train LL")
lorenz.chart(test.LL,"classification", "pred01", title="Lift Chart Test LL")


#Draw the ROC curve 
head(LL_bin$pred02)

gbm.ROC2 <- roc(predictor=LL_bin$pred02,
               response=LL_bin$classification)

gbm.ROC$auc #Area under the curve: 0.998
plot(gbm.ROC,main="GBM ROC LL")

predLL <-rbind(train.LL, test.LL)
# Plot the propability of poor segmentation
histogram(~predLL$classification|predLL$pred02,xlab="Probability of Poor Segmentation")


##***********************************************************************

# library(Hmisc)
# par(mfrow=c(1,1))
# #measure_coursestddev_43200	
# plsmo(LL_bin$measure_coursestddev_43200, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_coursestddev_43200', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_coursestddev_43200, LL_bin$classification)
# 
# #distance_from_port
# plsmo(LL_bin$distance_from_port, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'distance_from_port', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$distance_from_port, LL_bin$classification)
# 
# #measure_pos_86400
# plsmo(LL_bin$measure_pos_86400, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_pos_86400', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_pos_86400, LL_bin$classification)
# 
# #measure_coursestddev_86400
# plsmo(LL_bin$measure_coursestddev_86400, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_coursestddev_86400', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_coursestddev_86400, LL_bin$classification)
# 
# #measure_pos_43200
# plsmo(LL_bin$measure_pos_43200, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_pos_43200', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_pos_43200, LL_bin$classification)
# 
# #distance_from_shore
# plsmo(LL_bin$distance_from_shore, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'distance_from_shore', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$distance_from_shore, LL_bin$classification)
# 
# #measure_speedavg_21600
# plsmo(LL_bin$measure_speedavg_21600, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_speedavg_21600', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_speedavg_21600, LL_bin$classification)
# 
# #measure_pos_21600
# plsmo(LL_bin$measure_pos_21600, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_pos_21600', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_pos_21600, LL_bin$classification)
# 
# #measure_speedavg_10800
# plsmo(LL_bin$measure_speedavg_10800, LL_bin$classification, LL_bin = T, 
#       col=c('black', 'red','tan'), xlab = 'measure_speedavg_10800', ylab ='Classification',
#       ylim = c(0,1))
# histogram(LL_bin$measure_speedavg_10800, LL_bin$classification)
# 

##############################
##### Variable Reduction #####
######## Purse Seine #########
##############################
set.seed(234)

# Shuffle the dataset, call the result shuffled 
n <- nrow(PS_bin)
shuffled <- PS_bin[sample(n),]

# Split the data in train and test
train.PS <- shuffled[1:round(0.7 * n),]
test.PS <- shuffled[(round(0.7 * n) + 1):n,]

# Print the structure of train and test
sink("structure of train LL"); str(train.PS); sink()
sink("structure of train LL"); str(test.PS); sink()


registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
model.PS <- gbm(classification ~ 1
                  + measure_coursestddev_1800_log
                  + measure_courseavg_43200
                  + course
                  + measure_sin_course
                  + measure_daylightavg_900
                  + measure_speedstddev_10800
                  + speed
                  + measure_pos_86400
                  + measure_daylightavg_43200
                  + measure_latavg_86400
                  + distance_from_port
                  + measure_lonavg_3600
                  + measure_lonavg_1800
                  + measure_courseavg_10800
                  + distance_from_shore
                  + measure_courseavg_1800
                  + measure_speedstddev_86400
                  + timestamp
                  + measure_coursestddev_86400
                  + measure_speedstddev_21600
                  + measure_daylightavg_3600
                  + measure_courseavg_86400
                  + measure_speedstddev_3600_log
                  + measure_coursestddev_900
                  + measure_coursestddev_10800
                  + measure_coursestddev_43200
                  + measure_daylightavg_1800
                  + measure_coursestddev_3600_log
                  + measure_lonavg_900
                  + measure_distance_from_port
                  + measure_coursestddev_10800_log
                  + measure_coursestddev_900_log
                  + measure_latavg_21600
                  #   + mmsi
                  + measure_course
                  + measure_lonavg_21600
                  + measure_daylight
                  + measure_pos_10800
                  + measure_count_10800
                  + measure_coursestddev_1800
                  + measure_speedstddev_43200
                  + measure_daylightavg_21600
                  + measure_courseavg_21600
                  + measure_speedavg_86400
                  + measure_pos_900
                  + measure_coursestddev_21600
                  + measure_count_1800
                  + measure_speed
                  + measure_latavg_43200
                  + measure_latavg_10800
                  + measure_speedavg_1800
                  + measure_count_3600
                  + lon
                  + measure_speedavg_10800
                  + measure_speedavg_900
                  + measure_daylightavg_10800
                  + measure_count_21600
                  + measure_courseavg_900
                  + measure_speedstddev_3600
                  + measure_pos_43200
                  + measure_latavg_3600
                  + measure_coursestddev_21600_log
                  + measure_speedavg_43200
                  + measure_courseavg_3600
                  + measure_latavg_900
                  + measure_daylightavg_86400
                  + measure_count_43200
                  + measure_coursestddev_3600
                  + measure_lonavg_86400
                  + measure_lonavg_43200
                  + measure_cos_course
                  + measure_pos_3600
                  + measure_speedstddev_900
                  + measure_speedstddev_21600_log
                  + measure_count_86400
                  + measure_pos_1800
                  + measure_coursestddev_86400_log
                  + measure_speedavg_3600
                  + measure_speedstddev_1800
                  + measure_coursestddev_43200_log
                  + measure_latavg_1800
                  + measure_speedavg_21600
                  + measure_count_900
                  + measure_speedstddev_86400_log
                  + measure_lonavg_10800
                  + measure_speedstddev_10800_log
                  + lat
                  + measure_speedstddev_43200_log
                  + measure_pos_21600
                  + measure_speedstddev_900_log
                  + measure_speedstddev_1800_log,
                  
                  data=train.PS
                  , distribution="bernoulli"
                  , n.trees=25
                  , shrinkage=0.05      ## Step Size
                  , interaction.depth=2
                  , n.minobsinnode = 10
                  , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                  , cv.folds=5         # We are using 6 cross validation folds
                  , keep.data=FALSE
                  , verbose=TRUE)
  
)
#Check if the model is overfitting? And optimal number of trees
best.iter.PS <- gbm.perf(model.PS, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter.PS)

# best.iter.LL <- 700 #From observing gbm model performance as it came in, we see that at 700 trees our Improve column becomse zero

#summarize the model
summary.PS<-summary(model.PS, n.trees=(best.iter.LL+0))
print(summary.PS)
sink("summary.ModelPS2.txt"); print(summary.PS); sink()
# Predict
train.PS$pred01<-predict.gbm(model.PS,train.PS,best.iter,type="response") *-1
test.PS$pred01 <-predict.gbm(model.PS,test.PS,best.iter,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.PS,"classification", "pred01", title="Lift Chart Train PS")
lorenz.chart(test.PS,"classification", "pred01", title="Lift Chart Test PS")


#Draw the ROC curve 
head(train.PS$pred01)

gbm.ROC1PS <- roc(predictor=train.PS$pred01,
                  response=train.PS$classification)

gbm.ROC1PS$auc #Area under the curve: 0.998
plot(gbm.ROC,main="GBM ROC PS")

predPS <-rbind(train.PS,test.PS)
# Plot the propability of poor segmentation
x11();dev.off()
histogram(~predPS$classification|predPS$pred01,xlab="Probability of Poor Segmentation")

#memory.limit()
##***********************************************************************
#### This part takes 40 MINUTES ####
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
  model.PS2 <- gbm(classification ~ 1
                  + measure_daylightavg_3600
                  + speed
                  + measure_speedavg_1800
                  + measure_speed
                  + distance_from_shore
                  + measure_speedavg_43200
                  + timestamp
                  + measure_speedstddev_10800
                  + measure_daylightavg_10800
                  + distance_from_port
                  ,
                  
                  data=train.PS
                  , distribution="bernoulli"
                  , n.trees=800
                  , shrinkage=0.05      ## Step Size
                  , interaction.depth=2
                  , n.minobsinnode = 10
                  , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                  , cv.folds=5         # We are using 6 cross validation folds
                  , keep.data=FALSE
                  , verbose=TRUE)
  
)
#Check if the model is overfitting? And optimal number of trees
best.iter.PS2 <- gbm.perf(model.PS2, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter.PS2)

# best.iter.LL <- 700 #From observing gbm model performance as it came in, we see that at 700 trees our Improve column becomse zero

#summarize the model
summary.PS2<-summary(model.PS2, n.trees=(best.iter.PS2+0))
print(summary.PS2)
sink("summary.ModelPS2.txt"); print(summary.PS2); sink()
# Predict
train.PS$pred02<-predict.gbm(model.PS2,train.PS,best.iter,type="response") *-1
test.PS$pred02 <-predict.gbm(model.PS2,test.PS,best.iter,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.PS,"classification", "pred02", title="Lift Chart Train PS")
lorenz.chart(test.PS,"classification", "pred02", title="Lift Chart Test PS")


#Draw the ROC curve 
head(train.PS$pred02)

gbm.ROC1PS <- roc(predictor=train.PS$pred02,
                  response=train.PS$classification)

gbm.ROC1PS$auc #Area under the curve: 0.9949
plot(gbm.ROC,main="GBM ROC PS")

predPS <-rbind(train.PS,test.PS)
# Plot the propability of poor segmentation
histogram(~predPS$classification|predPS$pred02,xlab="Probability of Poor Segmentation")

##############################
##### Variable Reduction #####
########## Trawlers  #########
##############################

set.seed(234)

# Shuffle the dataset, call the result shuffled 
n <- nrow(TR_bin)
shuffled <- TR_bin[sample(n),]

# Split the data in train and test
train.TR <- shuffled[1:round(0.7 * n),]
test.TR <- shuffled[(round(0.7 * n) + 1):n,]

# Print the structure of train and test
sink("structure of train LL"); str(train.TR); sink()
sink("structure of train LL"); str(test.TR); sink()

# Run GBM to get important variables for LL first

#### This part takes 16 MINUTES ####
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
model.TR <- gbm(classification ~ 1
                  + measure_coursestddev_1800_log
                  + measure_courseavg_43200
                  + course
                  + measure_sin_course
                  + measure_daylightavg_900
                  + measure_speedstddev_10800
                  + speed
                  + measure_pos_86400
                  + measure_daylightavg_43200
                  + measure_latavg_86400
                  + distance_from_port
                  + measure_lonavg_3600
                  + measure_lonavg_1800
                  + measure_courseavg_10800
                  + distance_from_shore
                  + measure_courseavg_1800
                  + measure_speedstddev_86400
                  + timestamp
                  + measure_coursestddev_86400
                  + measure_speedstddev_21600
                  + measure_daylightavg_3600
                  + measure_courseavg_86400
                  + measure_speedstddev_3600_log
                  + measure_coursestddev_900
                  + measure_coursestddev_10800
                  + measure_coursestddev_43200
                  + measure_daylightavg_1800
                  + measure_coursestddev_3600_log
                  + measure_lonavg_900
                  + measure_distance_from_port
                  + measure_coursestddev_10800_log
                  + measure_coursestddev_900_log
                  + measure_latavg_21600
                  #   + mmsi
                  + measure_course
                  + measure_lonavg_21600
                  + measure_daylight
                  + measure_pos_10800
                  + measure_count_10800
                  + measure_coursestddev_1800
                  + measure_speedstddev_43200
                  + measure_daylightavg_21600
                  + measure_courseavg_21600
                  + measure_speedavg_86400
                  + measure_pos_900
                  + measure_coursestddev_21600
                  + measure_count_1800
                  + measure_speed
                  + measure_latavg_43200
                  + measure_latavg_10800
                  + measure_speedavg_1800
                  + measure_count_3600
                  + lon
                  + measure_speedavg_10800
                  + measure_speedavg_900
                  + measure_daylightavg_10800
                  + measure_count_21600
                  + measure_courseavg_900
                  + measure_speedstddev_3600
                  + measure_pos_43200
                  + measure_latavg_3600
                  + measure_coursestddev_21600_log
                  + measure_speedavg_43200
                  + measure_courseavg_3600
                  + measure_latavg_900
                  + measure_daylightavg_86400
                  + measure_count_43200
                  + measure_coursestddev_3600
                  + measure_lonavg_86400
                  + measure_lonavg_43200
                  + measure_cos_course
                  + measure_pos_3600
                  + measure_speedstddev_900
                  + measure_speedstddev_21600_log
                  + measure_count_86400
                  + measure_pos_1800
                  + measure_coursestddev_86400_log
                  + measure_speedavg_3600
                  + measure_speedstddev_1800
                  + measure_coursestddev_43200_log
                  + measure_latavg_1800
                  + measure_speedavg_21600
                  + measure_count_900
                  + measure_speedstddev_86400_log
                  + measure_lonavg_10800
                  + measure_speedstddev_10800_log
                  + lat
                  + measure_speedstddev_43200_log
                  + measure_pos_21600
                  + measure_speedstddev_900_log
                  + measure_speedstddev_1800_log,
                  
                  data=train.TR
                  , distribution="bernoulli"
                  , n.trees=800
                  , shrinkage=0.05      ## Step Size
                  , interaction.depth=2
                  , n.minobsinnode = 10
                  , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                  , cv.folds=5         # We are using 6 cross validation folds
                  , keep.data=FALSE
                  , verbose=TRUE)
  
)
#Check if the model is overfitting? And optimal number of trees
best.iter.TR <- gbm.perf(model.TR, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter.TR)

#summarize the model
summary.TR<-summary(model.TR, n.trees=(best.iter.TR+0))
print(summary.TR)
sink("summary.ModelTR.txt"); print(summary.TR); sink()
# Predict
train.TR$pred01<-predict.gbm(model.TR,train.TR,best.iter.TR,type="response") *-1
test.TR$pred01<-predict.gbm(model.TR,test.TR,best.iter.TR,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.TR,"classification", "pred01", title="Lift Chart Train TR")
lorenz.chart(test.TR,"classification", "pred01", title="Lift Chart Test TR")

#Draw the ROC curve 
head(test.TR$pred01)

gbm.ROC <- roc(predictor=test.TR$pred01,
               response=test.TR$classification)

gbm.ROC$auc #Area under the curve: 0.998
plot(gbm.ROC,main="GBM ROC TR")
predTR <-rbind(test.TR,train.TR)
# Plot the propability of poor segmentation
histogram(~predTR$pred01|predTR$classification,xlab="Probability of Poor Segmentation")

##***********************************************************************

###############
###Model on reduced 

#### This part takes 16 MINUTES ####
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
  model.TR2 <- gbm(classification ~ 1
                  + distance_from_shore
                  + measure_speedavg_3600
                  + measure_speedavg_10800
                  + measure_speedavg_1800
                  + measure_speedavg_21600
                  + measure_speedavg_900
                  + measure_coursestddev_86400
                  + measure_latavg_900,
                  
                  data=train.TR
                  , distribution="bernoulli"
                  , n.trees=800
                  , shrinkage=0.05      ## Step Size
                  , interaction.depth=2
                  , n.minobsinnode = 10
                  , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                  , cv.folds=5         # We are using 6 cross validation folds
                  , keep.data=FALSE
                  , verbose=TRUE)
  
)
#Check if the model is overfitting? And optimal number of trees
best.iter.TR2 <- gbm.perf(model.TR2, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter.TR2)

#summarize the model
summary.TR2<-summary(model.TR2, n.trees=(best.iter.TR2+0))
print(summary.TR2)
sink("summary.ModelTR2.txt"); print(summary.TR2); sink()
# Predict
train.TR$pred02<-predict.gbm(model.TR2,train.TR,best.iter.TR2,type="response") *-1
test.TR$pred02<-predict.gbm(model.TR2,test.TR,best.iter.TR2,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.TR,"classification", "pred02", title="Lift Chart Train TR2")
lorenz.chart(test.TR,"classification", "pred02", title="Lift Chart Test TR2")

#Draw the ROC curve 
head(test.TR$pred02)

gbm.ROC <- roc(predictor=test.TR$pred02,
               response=test.TR$classification)

gbm.ROC$auc #Area under the curve: 0.998
plot(gbm.ROC,main="GBM ROC TR")
predTR <-rbind(test.TR,train.TR)
# Plot the propability of poor segmentation
histogram(~predTR$pred02|predTR$classification,xlab="Probability of Poor Segmentation")



### TO DO ### 

### Re-run all of the code below
### re-run all of the histograms
## re run all of the 'validation code for TR 2' with lift charts
## Build the last model with iterations.


#########################################
##### Final Variable Transformation #####
#########################################

## Create a combined dataset with all observations and predictions
## Input the new final and flag variables



predLL$geartype <- "drifting_longlines"          #Adding a variable for geartype
predPS$geartype <- "purse_seines"                # Adding a variable for geartype
predTR$geartype <- "trawlers"                    # Adding a variable for geartype
predLL$geartype_code <- 1       # 1 for drifting_longlines    #Adding a variable for geartype
PS_bin$geartype_code <- 2       # 2 for purse_seines    # Adding a variable for geartype
predPS$geartype_code <- 3       # 3 for trawlers    # Adding a variable for geartype


all_data_bin <- rbind(predLL,predPS) ## About 2 seconds
all_data_bin <- rbind(all_data_bin,predTR)## About 20 seconds

# Create a text file containing all the descriptions of the variables in the dataset 
sink("variable_list.txt"); cat(names(all_data_bin), sep="\n + "); sink() # Only need to do this once, /
# / as our variables are the same for each set

all_data_bin <- all_data_bin[sample(nrow(all_data_bin)),] #25 sec


LL$geartype <- "drifting_longlines"          #Adding a variable for geartype
PS$geartype <- "purse_seines"                # Adding a variable for geartype
TR_bin$geartype <- "trawlers"                    # Adding a variable for geartype
LL$geartype_code <- 1       # 1 for drifting_longlines    #Adding a variable for geartype
PS$geartype_code <- 2       # 2 for purse_seines    # Adding a variable for geartype
TR$geartype_code <- 3       # 3 for trawlers    # Adding a variable for geartype


all_data_bin$geartype_code_flag_LL[all_data_bin$geartype_code == 1] <- 1
all_data_bin$geartype_code_flag_LL[all_data_bin$geartype_code != 1] <- 0
all_data_bin$geartype_code_flag_PS[all_data_bin$geartype_code == 2] <- 1
all_data_bin$geartype_code_flag_PS[all_data_bin$geartype_code != 2] <- 0
all_data_bin$geartype_code_flag_TR[all_data_bin$geartype_code == 3] <- 1
all_data_bin$geartype_code_flag_TR[all_data_bin$geartype_code != 3] <- 0

x<-all_data_bin$geartype_code_flag_TR
#########################################
############## Final Model ##############
#########################################


#### This part takes 16 MINUTES ####
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()
## Final Fishing Model
set.seed(234)
system.time(
model.ff <- glm(classification ~ 1
                  + distance_from_shore
                  + measure_speedavg_1800
                  + measure_speedavg_21600
                  + measure_coursestddev_86400
                  + distance_from_port
                  + measure_daylightavg_3600
                  + measure_speedavg_1800
                  + measure_speed
                  + measure_speedstddev_10800
                  + distance_from_shore
                  + measure_daylightavg_10800
                  + measure_speedavg_900
                  + measure_speedstddev_1800
                  + geartype_code_flag_LL * distance_from_port
                  + geartype_code_flag_LL * measure_coursestddev_86400
                  + geartype_code_flag_LL * distance_from_shore
                  + geartype_code_flag_LL * measure_speedavg_21600
                  + geartype_code_flag_LL * measure_coursestddev_43200
                  + geartype_code_flag_LL * measure_pos_86400
                  + geartype_code_flag_LL * measure_pos_43200
                  + geartype_code_flag_LL * measure_coursestddev_21600
                  + geartype_code_flag_LL * measure_pos_21600
                  + geartype_code_flag_TR * measure_speedavg_1800
                  + geartype_code_flag_TR * measure_speedavg_3600
                  + geartype_code_flag_TR * measure_speedavg_10800
                  + geartype_code_flag_TR * measure_speedavg_900
                  + geartype_code_flag_TR * measure_latavg_900
                  

                                ,
                  data=all_data_bin, 
                  family = "binomial"(link="logit"))
   )             


summary(model.ff)
sink("SummaryModel.ff.a.text")
summary(model.ff); sink()

exp(model.ff$coefficients)
all_data_bin$pred_final<- predict(model.ff, type = "response")* -1


# Remove all the N/A variables from GLM and run again

#########################################################
######################Final GLM##########################
#########################################################


#### This part takes 16 MINUTES ####
registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()
## Final Fishing Model
set.seed(234)
system.time(
  model.Final <- glm(classification ~ 1
                     + distance_from_shore
                     + measure_speedavg_1800
                     + measure_speedavg_21600
                     + measure_coursestddev_86400
                     + distance_from_port
                     + measure_daylightavg_3600
                     + measure_speedavg_1800
                     + measure_speed
                     + measure_speedstddev_10800
                     + distance_from_shore
                     + measure_daylightavg_10800
                     + measure_speedavg_900
                     + measure_speedstddev_1800
                     + geartype_code_flag_LL * distance_from_port
                     + geartype_code_flag_LL * measure_coursestddev_86400
                     + geartype_code_flag_LL * distance_from_shore
                     + geartype_code_flag_LL * measure_speedavg_21600
                     + geartype_code_flag_LL * measure_coursestddev_43200
                     + geartype_code_flag_LL * measure_pos_86400
                     + geartype_code_flag_LL * measure_pos_43200
                     + geartype_code_flag_LL * measure_coursestddev_21600
                     + geartype_code_flag_LL * measure_pos_21600
                     + geartype_code_flag_TR * measure_speedavg_1800
                     + geartype_code_flag_TR * measure_speedavg_3600
                     + geartype_code_flag_TR * measure_speedavg_10800
                     + geartype_code_flag_TR * measure_speedavg_900
                     + geartype_code_flag_TR * measure_latavg_900
                  data=all_data_bin, 
                  family = "binomial"(link="logit"))
)             


summary(model.Final)
sink("SummaryModel.Final.a.text")
summary(model.Final); sink()

all_data_bin$pred_final_glm <- predict(model.Final,all_data_bin) *-1
lorenz.chart(all_data_bin,"classification","pred_final_glm", title="Lift Graph Final GLM")
histogram(~all_data_bin$pred_final_glm | all_data_bin$classification,xlab="Probability of Poor Segmentation")


#We also remember that we had missing classifications for some vessels.
#We can now take this model and predict on the 'unknowns'
# We cannot validate this prediction, but if we trust our model buld we should be able
      # to add value by predicting the unknowns.

all_data_missing <- subset(all_data,classification == -1)
all_data_missing$X.1 <-NULL
all_data_missing$pred01 <- 0
all_data_missing$pred02 <- 0 
all_data_missing$geartype_code_flag_LL[all_data_missing$geartype_code == 1] <- 1
all_data_missing$geartype_code_flag_LL[all_data_missing$geartype_code != 1] <- 0
all_data_missing$geartype_code_flag_PS[all_data_missing$geartype_code == 2] <- 1
all_data_missing$geartype_code_flag_PS[all_data_missing$geartype_code != 2] <- 0
all_data_missing$geartype_code_flag_TR[all_data_missing$geartype_code == 3] <- 1
all_data_missing$geartype_code_flag_TR[all_data_missing$geartype_code != 3] <- 0
all_data_missing$pred_final_2 <- 0 
all_data_missing$pred_final_glm <- predict(model.Final,all_data_missing) *-1

scored <-rbind(all_data_missing,all_data_bin)

# sink("variable_list_missing.txt"); cat(names(all_data_missing), sep="\n + "); sink()
# sink("variable_list_bin.txt"); cat(names(all_data_bin), sep="\n + "); sink()



#We can also do a quick GBM on all data to get an additoinal model:

#Train/Test Split
set.seed(234)

# Shuffle the dataset, call the result shuffled 
n <- nrow(all_data_bin)
shuffled <- all_data_bin[sample(n),]

# Split the data in train and test
train.all_bin <- shuffled[1:round(0.7 * n),]
test.all_bin <- shuffled[(round(0.7 * n) + 1):n,]

# Print the structure of train and test
sink("structure of train.all_bin"); str(train.all_bin); sink()
sink("structure of test.all_bin"); str(test.all_bin); sink()

registerDoParallel(4)		# Registrer a parallel backend for train
getDoParWorkers()

set.seed(234) 
system.time(
  model.all_bin <- gbm(classification ~ 1
                   + measure_coursestddev_1800_log
                   + measure_courseavg_43200
                   + course
                   + measure_sin_course
                   + measure_daylightavg_900
                   + measure_speedstddev_10800
                   + speed
                   + measure_pos_86400
                   + measure_daylightavg_43200
                   + measure_latavg_86400
                   + distance_from_port
                   + measure_lonavg_3600
                   + measure_lonavg_1800
                   + measure_courseavg_10800
                   + distance_from_shore
                   + measure_courseavg_1800
                   + measure_speedstddev_86400
                   + timestamp
                   + measure_coursestddev_86400
                   + measure_speedstddev_21600
                   + measure_daylightavg_3600
                   + measure_courseavg_86400
                   + measure_speedstddev_3600_log
                   + measure_coursestddev_900
                   + measure_coursestddev_10800
                   + measure_coursestddev_43200
                   + measure_daylightavg_1800
                   + measure_coursestddev_3600_log
                   + measure_lonavg_900
                   + measure_distance_from_port
                   + measure_coursestddev_10800_log
                   + measure_coursestddev_900_log
                   + measure_latavg_21600
                   + mmsi
                   + measure_course
                   + measure_lonavg_21600
                   + measure_daylight
                   + measure_pos_10800
                   + measure_count_10800
                   + measure_coursestddev_1800
                   + measure_speedstddev_43200
                   + measure_daylightavg_21600
                   + measure_courseavg_21600
                   + measure_speedavg_86400
                   + measure_pos_900
                   + measure_coursestddev_21600
                   + measure_count_1800
                   + measure_speed
                   + measure_latavg_43200
                   + measure_latavg_10800
                   + measure_speedavg_1800
                   + measure_count_3600
                   + lon
                   + measure_speedavg_10800
                   + measure_speedavg_900
                   + measure_daylightavg_10800
                   + measure_count_21600
                   + measure_courseavg_900
                   + measure_speedstddev_3600
                   + measure_pos_43200
                   + measure_latavg_3600
                   + measure_coursestddev_21600_log
                   + measure_speedavg_43200
                   + measure_courseavg_3600
                   + measure_latavg_900
                   + measure_daylightavg_86400
                   + measure_count_43200
                   + measure_coursestddev_3600
                   + measure_lonavg_86400
                   + measure_lonavg_43200
                   + measure_cos_course
                   + measure_pos_3600
                   + measure_speedstddev_900
                   + measure_speedstddev_21600_log
                   + measure_count_86400
                   + measure_pos_1800
                   + measure_coursestddev_86400_log
                   + measure_speedavg_3600
                   + measure_speedstddev_1800
                   + measure_coursestddev_43200_log
                   + measure_latavg_1800
                   + measure_speedavg_21600
                   + measure_count_900
                   + measure_speedstddev_86400_log
                   + measure_lonavg_10800
                   + measure_speedstddev_10800_log
                   + lat
                   + measure_speedstddev_43200_log
                   + measure_pos_21600
                   + measure_speedstddev_900_log
                   + measure_speedstddev_1800_log
                   + geartype_code
                   + geartype_code_flag_LL
                   + geartype_code_flag_PS
                   + geartype_code_flag_TR
                   ,
                   
                   data=train.all_bin
                   , distribution="bernoulli"
                   , n.trees=800
                   , shrinkage=0.05      ## Step Size
                   , interaction.depth=2
                   , n.minobsinnode = 10
                   , train.fraction=0.8    # This model includes a train fraction option, so we do not need to set a train/test
                   , cv.folds=5         # We are using 6 cross validation folds
                   , keep.data=FALSE
                   , verbose=TRUE)
  
)
#Check if the model is overfitting? And optimal number of trees
best.iter.ab <- gbm.perf(model.all_bin, method="OOB", plot.it=TRUE, oobag.curve=TRUE, overlay=TRUE)
print(best.iter.ab) #733

#summarize the model
summary.ab<-summary(model.all_bin, n.trees=(best.iter.ab+0))
print(summary.ab)
sink("summary.ModelAllBin.txt"); print(summary.ab); sink()
# Predict
train.all_bin$pred.ab<-predict.gbm(model.all_bin,train.all_bin,best.iter.ab,type="response") *-1
test.all_bin$pred.ab<-predict.gbm(model.all_bin,test.all_bin,best.iter.ab,type="response") *-1

#Draw Lift Chart
lorenz.chart(train.all_bin,"classification", "pred.ab", title="Lift Chart Train All Bin")
lorenz.chart(test.all_bin,"classification", "pred.ab", title="Lift Chart Test All Bin")

#Draw the ROC curve 
head(train.all_bin$pred.ab)

# Plot the propability of poor segmentation
histogram(~train.all_bin$pred.ab|train.all_bin$classification,xlab="Probability of Poor Segmentation")






##***********************************************************************







##Lets examine the data further in excel to see where we need to cut the dataset.
write.csv(train.LL, "gbmoutput.trainLL.csv")
write.csv(test.LL, "gbmoutput.testLL.csv")




#################################################3
##################################################
##################################################
#### Functions
# R Code to plot Lorenz curves and calculate the associated statistics with examples
# Hannah Buckley, Ecology Department, Lincoln University, New Zealand
# Hannah.Buckley@lincoln.ac.nz
# July, 2012

######################################################################################################
## This code writes the function to plot the Lorenz curves and calculate the following statistics
## Biased and unbiased forms of the Gini coefficient and the Lorenz asymmetry coeffcient as described
## by Damgaard, C. and Weiner, J. 2000. Describing inequality in plant size or fecundity. Ecology 81, 1139-1142.
## It requires a vector of abundances for one sample or a matrix (or data frame) of 
## abundances for a set of species from a range of samples (samples must be rows and 
## species are columns)
######################################################################################################

lorenz <- function(g.dat){   
  
  if(class(g.dat)=="numeric") { g.dat <- t(matrix(g.dat)) }  # converts vectors into the right format for code
  
  # Plot Lorenz curves
  # y = cumulative percent abundance
  # x = cumulative percent individuals
  plot(0,0,ylim=c(0,100),xlim=c(0,100),type="n",xlab="Cumulative percent species",ylab="Cumulative percent abundance")     # plots an empty graph
  abline(1,1)
  for (i in 1:length(g.dat[,1])) {
    x <- as.numeric(g.dat[i,])
    x <- x[x>0]                      # Cuts out species that were absent from the sample
    ox <- x[order(x,decreasing=T)]
    ab <- c(0,cumsum(ox/sum(ox)*100))
    sp <- numeric(length=length(ox))
    for (j in 1: length(ox)) {
      sp[j] <- (j/length(ox))*100
    }
    sp <- c(0,sp)
    lines(ab~sp,type="b")
  }
  
  # Gini coefficient from equations in the Damgaard and Weiner (2000) paper
  gini.coef.biased <- numeric(length = length(g.dat[,1])) # empty vector to put the coefficient in
  gini.coef.unbiased <- gini.coef.biased                  # second empty vector for unbiased version
  for (i in 1:length(g.dat[,1])) {                        # open loop to go through each OTU (species)
    x <- as.numeric(g.dat[i,])                            # put species data in a vector, x
    x <- x[x>0]                                           # remove all absent species
    ox <- x[order(x)]                                     # sort species by abundance value
    a <- numeric(length = length(ox))                     # a = total number of species
    for (j in 1:length(ox)) {                           # within each sample loop through each abundance value
      a[j] <- (2*j-length(ox)-1)*ox[j]                  # inside brackets of eqn 3 in Damgaard and Weiner 2000
    }
    gini.coef.biased[i] <- sum(a)/((length(ox)^2)*mean(ox))                   # biased
    gini.coef.unbiased[i] <- gini.coef.biased[i]*(length(ox)/(length(ox)-1))  # unbiased
  }
  
  # Asymmetry coefficient
  lac <- numeric(length = length(g.dat[,1]))
  for (i in 1:length(g.dat[,1])) {
    y <- g.dat[i,]
    vec <- sort(y[y>0])
    n <- length(vec)
    mu <- mean(vec)
    red <- vec[vec<mean(vec)]                 # generate reduced vector of abundances less than the mean
    m <- length(red)                          # number of abundances less than the mean
    delta <- (mu - vec[m])/(vec[m+1]-vec[m])  # calculate delta from Damgaard and Weiner (2000)
    f <- (m + delta)/n                        # calculate F(mu)
    Lm <- sum(red)
    Ln <- sum(vec)
    L <- (Lm+delta*vec[m+1])/Ln               # calculate L(mu)
    lac[i] <- f+L
  } # end of lac loop
  results <- cbind(gini.coef.biased,gini.coef.unbiased,lac)
  return(results)
} # end of function
########################################################################################################

##########################################################################
## Examples
##########################################################################
# library(MASS) # required for the rnegbin function and the waders dataset
# 
# ####### Example vector
# vec1 <- rnegbin(20,mu=3,theta=0.5) # generate a vector of random abundances from a negative binomial distribution
# 
# ####### Example matrices
# mat1 <- matrix(c(1,1,2,1,1,1,1,1,2,3,4,5),nrow=2,ncol=6,byrow=T) # test data
# mat2 <- matrix(rep(c(0.678707,0.678707,2.06314,0.443171,197.766,0.121475,0.678707,0.000243745,0.626015,0.734366,129.633,70.9617,8.10685,0.059587,0.00652025,40.1964,0.0203569),2),nrow=2,ncol=34,byrow=T)
# 
# ####### Example data frame
# data(waders) # load dataset with counts of waders at 15 sites in South Africa from the MASS package
# dat1 <- waders
# 
# ###### Run the function
# lorenz(vec1)
# lorenz(mat1)
# lorenz(mat2)
# lorenz(dat1)
# 
# ###### Save the results of the function
# a <- as.data.frame(lorenz(dat1))
# 
# plot(a$gini.coef.biased~a$gini.coef.unbiased)   # examine differences between biased and unbiased coefficients
# abline(0,1)
# 
# write.table(a,"Lorenz_results.txt",row.names=F,sep="\t") # write out to tab-delimited text file
################################









