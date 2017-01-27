
#############################################################
#############################################################
##  Explore Census data to discover cleaning requirements  ##
#############################################################
#############################################################
library(Amelia)
library(caret)
library(gmodels)
library(nortest)
library(plyr)
#############################################################
#######   Pt. 1 Create Census data for exploration   ########
#############################################################

# read in csv and append column names
colNames = c ("age", "workclass", "education_level",
            "education_num", "marital_status", "occupation",
            "relationship", "race", "sex", "capital_gain",
            "capital_loss", "hours_week", "country",
            "over_50k")

Data <- read.csv(file="census_modified.csv", header=FALSE, sep=",",
                 strip.white = TRUE, col.names=colNames,
                 na.strings = "?", stringsAsFactors = TRUE)

# examine the data and structure to be sure import was successful
# head(Data)
str(Data)

# check for complete cases
# 92.59% complete cases, 7.41% missing
table (complete.cases (Data))

# examine missing values
summary  (Data [!complete.cases(Data),])

# plot missing values
# most in occupation and workclass, a few in country
#looks like occupation and workclass line up completely
missmap(Data, main = "Missing values vs observed")

# since there aren't too many missing values, exclude
Data$workclass <- factor(Data$workclass, exclude=NULL)
Data$occupation <- factor(Data$occupation, exclude=NULL)
Data$country <- factor(Data$country, exclude=NULL)

# double-check -- no NAs remain
which(is.na(Data))

#####################################################################
################# Pt. 2: Explore distributions, etc. ################
#####################################################################

##### Pt. 2A: Distribution of Target

attach(Data)

# 76.1% no, 23.9% yes
# this is more or less consistent with official US Census estimates for HOUSEHOLD
# where mean of 4th quintile is $52,429. However, for INDIVIDUALS, mean was ~$23,423
# and only approximately 9.01% made over $50k. 
# the data appears to be heavily oversampled
tbl <- table(over_50k)
cbind(tbl,prop.table(tbl))
plot(tbl)


##### Pt. 2B: Categorical Variables

# very high cell chi-sq -- over 600 for self-emp-inc making over 50k
# very high cell chi-sq -- over 600 for self-emp-inc making over 50k
# only 29 Unemployed??? AKA without pay or never worked?
# no yeses for without pay and never worked
# must fix sparsity, but also non-representational data
CrossTable(workclass, over_50k)

# cell chi-sq over 1000 for BA
# note: one person with only a preschool level of edu makes over 50k
# Also no difference in yes vs no proportion in the 2 associates
# degree categories
# porportions of yeses and nos similar within elementary grades
# middle school, high school,  high school grad/some college,
# the two different assoc degree levels, and prof-school/doctorate.
# Collapse all these bins.
CrossTable(education_level, over_50k)

# married to a civilian spouse is best
CrossTable(marital_status, over_50k)

# self-employed incorporated fare better than not incorporated
CrossTable(occupation, over_50k)

# almost 10x as many husbands as wives. ***Weird***
# also 1.46% of own-children make over 50k
CrossTable(relationship, over_50k)


# sidebar, explore relationshipXgsex
# 3.28 times as many unmaried females as unmarried males
relationshipXsex <- table(relationship, sex)
cbind(relationshipXsex,prop.table(relationshipXsex))
relationshipXsex
summary(sex)

# the relationship between sex and over_50k is highly significant p-value < 2.2e-16
CrossTable(sex, over_50k)
chisq.test(sex, over_50k)

# this breakdown is in line with official census estimates
CrossTable(race, over_50k)

# overwhelmingly US. things look good for Euro and Asian immigrants
# but numbers are small
# collapse "sparse" countries into regions to address these problems
CrossTable(country, over_50k)




###### Pt. 2C: Continuous Variables

# none of the continuous predictor variables are strongly correlated with one another
# highest is hours_week with education_num at 0.14
# so all can be kept
cor(Data[, c(1, 4, 10:12)])

# none of the continuous predictors look normal
# right-skewed / different means
hist(age)

boxplot (age ~ over_50k, data = Data, 
         main = "Age distribution for different income levels",
         xlab = "Income Levels", ylab = "Age", col = "lightblue")


# spiky and not technically even continuous
# also question the validity of this ordinalization --
# is the diff between 9th grade (5) and 10th grade (6) really the same as 
# between BA and MA? Also why is academic associates' degree higher than vocational?
# prof-school actually has more yeses than doctorate, but is ordered lower
# re-order this var in python
# different means. over_50k has higher variation
hist(education_num)
d <- density(education_num)
plot(d)

boxplot (education_num ~ over_50k, data = Data, 
         main = "Education distribution for different income levels",
         xlab = "Income Levels", ylab = "Years of Education", col = "lightblue")


# very extremely right-skewed
# means are about the same, lots of zero values. maybe some zeros are actually missings?
hist(capital_gain)

boxplot (capital_gain ~ over_50k, data = Data, 
         main = "Capital Gain distribution for different income levels",
         xlab = "Income Levels", ylab = "Capital Gain", col = "lightblue")


# also right-skewed
# similar to capital_gain
hist(capital_loss)

boxplot (capital_loss ~ over_50k, data = Data, 
         main = "Capital Loss distribution for different income levels",
         xlab = "Income Levels", ylab = "Capital Loss", col = "lightblue")

# huge spike around 40 hours, not much in the tails
hist(hours_week)

boxplot (hours_week ~ over_50k, data = Data, 
         main = "Hours Worked Per Week distribution for different income levels",
         xlab = "Income Levels", ylab = "Hours Per Week", col = "lightblue")

##### Pt. 2D: Data Integrity Double-Check

# several data issues above make it seem like this may not be a representative sample
# looked up historical US Census data to perform basic checks. 9.1% of official Census sample had income > 50K
# quick t test to compare proportions between sample data and reported 1994 Census data
# p-value < 2.2e-16 that the two proportions are the same

# create vector of successes and failures
x <- c(11687, 37155)

# run test
binom.test(x, 0.091, alternative="two.sided")


#####################################################################
#####################################################################
#####################################################################
#####################################################################

# since several vars need to be re-binned, i have decided to use python
# to create a new, reformatted csv file. The actual modeling script,
# src_4_census_predict will use the pythoned csv instead of the original.



