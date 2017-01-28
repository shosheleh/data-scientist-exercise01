
#############################################################
#############################################################
##  Use US Census data to build a model to predict income  ##
#############################################################
#############################################################
library(Amelia)
library(caret)
library(gmodels)
library(nortest)
library(plyr)
#############################################################
##### Pt. 3 Create and clean Census data for processing #####
##### Use pythoned_csv that rectifies difficulties in   #####
##### the original SQL-created data set                 #####
#############################################################

# read in csv and append column names
colNames = c ("age", "workclass", "education_level",
              "education_num", "marital_status", "occupation",
              "relationship", "race", "sex", "capital_gain",
              "capital_loss", "hours_week", "country",
              "over_50k")

Data <- read.csv(file="pythoned_census.csv", header=FALSE, sep=",",
                 strip.white = TRUE, col.names=colNames,
                 na.strings = "?", stringsAsFactors = TRUE)

# examine the data and structure to be sure import was successful
# head(Data)
str(Data)

# since there aren't too many missing values,remove
Data <- na.omit(Data)

# bin capital gains and losses into none, low, and high
Data[["capital_gain"]] <- ordered(cut(Data$capital_gain,c(-Inf, 0, 
                                                          median(Data[["capital_gain"]][Data[["capital_gain"]] >0]), 
                                                          Inf)),labels = c("None", "Low", "High"))
Data[["capital_loss"]] <- ordered(cut(Data$capital_loss,c(-Inf, 0, 
                                                          median(Data[["capital_loss"]][Data[["capital_loss"]] >0]), 
                                                          Inf)), labels = c("None", "Low", "High"))

# change education_num to ordered
Data$education_num <- ordered(Data$education_num)
Data$capital_loss

# change target to factor
Data$over_50k <- as.factor(Data$over_50k)

#####################################################################
#######    Pt. 4: Split into train, validation, and test     ########
#####################################################################
set.seed(72256)
spec = c(train = .65, test = .2, validate = .15)

g = sample(cut(
  seq(nrow(Data)), 
  nrow(Data)*cumsum(c(0,spec)),
  labels = names(spec)
))

Partition = split(Data, g)



#####################################################################
#######################   Pt. 5: Modeling   #########################
#####################################################################
#### Was unable to validate and compare accuracy. Kept receiving 
#### errors about unequal number of levels. Tried to correct many 
#### different ways from stackoverflow, but no break-throughs.

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", number=10)
metric <- "Accuracy"

###########################################################################################
###########################   LOGISTIC REGRESSION   #######################################
###########################################################################################

#### null model
set.seed (72256)
logistic_null <- glm(over_50k ~ 1, data=Partition$train, family=binomial(link="logit"))

#### full model, but minus education_level, as it is completely collinear with education_num
#### AIC 18989
set.seed (72256)
logistic <- glm(over_50k ~ age + workclass + education_level +
                  marital_status + occupation + relationship + race + sex +
                  capital_gain + capital_loss + hours_week + country,
                data=Partition$train, family=binomial(link="logit"))
summary(logistic)

# AIC 18990
logistic_back <- step(logistic, scope = list(lower=logistic_null), data=Partition$train, direction="backward")
logistic_back

#AIC 18990
logistic_step <- step(logistic_null, scope = list(upper=logistic), data=Partition$train, direction="both")
logistic_step

# difference between the two models is significant
# select the full logistic model
anova(logistic_null,logistic, test="Chisq")

# estimate skill of logistic on the test dataset
predictions <- predict(logistic, Partition$test$over_50k)
predictions

###########################################################################################
###########################        VARIOUS          #######################################
###########################################################################################

# CART
set.seed(72256)
fit.cart <- train(over_50k~., data=Partition$train, method="rpart", trControl=trCtrl)
summary(fit.cart)

# estimate skill of fit.cart on the test dataset
predictions_cart <- predict(fit.cart, Partition$test$over_50k)
predictions



# SVM
set.seed(72256)
fit.svm <- train(over_50k~., data=Partition$train, method="svmRadial", metric=metric, trControl=control)
fit.svm

#####################################################################################
##############################       Plot      ######################################
#####################################################################################
library(shiny)
library("ggplot2")



 
 df <- Data
 df$sex <- as.factor( df$sex )
 df$relationship <- factor( df$relationship, labels=c(  "Husband", 
                                                        "Wife", "Not-in-family", 
                                                        "Other-relative", "Own-child", 
                                                        "Unmarried"  ) )
 df <- df[ order( df$relationship ), ]
 ggplot( df, aes( x=sex, y="", fill=relationship ) ) + 
   geom_bar( stat="identity" ) + ylab( "Breakdown by Relationship" ) + 
  scale_fill_brewer(palette = 12) +
   ggtitle( "Survey Participants by Gender and Relationship Type")
 
 
