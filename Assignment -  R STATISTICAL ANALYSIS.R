## Hypothesis Tests - 2 Sample Test
#Two sample Student’s t-test 
# t-Test to compare the means of two groups under the assumption that both samples are random, independent, and come from normally distributed population with unknow but equal variances

# The data are given below:

a = c(175, 168, 168, 190, 156, 181, 182, 175, 174, 179)
b = c(185, 169, 173, 173, 188, 186, 175, 174, 179, 180)

var.test(a,b)

#We obtained p-value greater than 0.05, then we can assume that the two variances are homogeneous. Indeed we can compare the value of F obtained with the tabulated value of F for alpha = 0.05, degrees of freedom of numerator = 9, and degrees of freedom of denominator = 9, using the function qf(p, df.num, df.den):

qf(0.95, 9, 9)

#Note that the value of F computed is less than the tabulated value of F, which leads us to accept the null hypothesis of homogeneity of variances.
#NOTE: The F distribution has only one tail, so with a confidence level of 95%, p = 0.95. Conversely, the t-distribution has two tails, and in the R’s function qt(p, df) we insert a value p = 0975 when you’re testing a two-tailed alternative hypothesis.

#Then call the function t.test for homogeneous variances (var.equal = TRUE) and independent samples (paired = FALSE: you can omit this because the function works on independent samples by default) in this way:

t.test(a,b, var.equal=TRUE, paired=FALSE)

#We obtained p-value greater than 0.05, then we can conclude that the averages of two groups are significantly similar. Indeed the value of t-computed is less than the tabulated t-value for 18 degrees of freedom, which in R we can calculate:
  
qt(0.975, 18)

# This confirms that we can accept the null hypothesis H0 of equality of the means.
  
  
  
#  Chi-squared Test of Independence
  
#  Two random variables x and y are called independent if the probability distribution of one variable is not affected by the presence of another.
  
#  Assume fij is the observed frequency count of events belonging to both i-th category of x and j-th category of y. Also assume eij to be the corresponding expected count if x and y are independent. The null hypothesis of the independence assumption is to be rejected if the p-value of the following Chi-squared test statistics is less than a given significance level α.
  
  
#  χ2 = ∑  (fij --eij)-
#      i, j   eij
  
#  Example
#  In the built-in data set survey, the Smoke column records the students smoking habit, while the Exer column records their exercise level. The allowed values in Smoke are "Heavy", "Regul" (regularly), "Occas" (occasionally) and "Never". As for Exer, they are "Freq" (frequently), "Some" and "None".
  
#We can tally the students smoking habit against the exercise level with the table function in R. The result is called the contingency table of the two variables.
  
library(MASS)       # load the MASS package 
tbl = table(survey$Smoke, survey$Exer) 
tbl                 # the contingency table 
  
  
#  Problem
##  Test the hypothesis whether the students smoking habit is independent of their exercise level at .05 significance level.
  
#  Solution
## apply the chisq.test function to the contingency table tbl, and found the p-value to be 0.4828.

chisq.test(tbl) 
  
# Answer
## As the p-value 0.4828 is greater than the .05 significance level, we do not reject the null hypothesis that the smoking habit is independent of the exercise level of the students.
  
#  Enhanced Solution
##  The warning message found in the solution above is due to the small cell values in the contingency table. To avoid such warning, we combine the second and third columns of tbl, and save it in a new table named ctbl. Then we apply the chisq.test function against ctbl instead.
  
ctbl = cbind(tbl[,"Freq"], tbl[,"None"] + tbl[,"Some"]) 
ctbl 

chisq.test(ctbl) 
  
# Exercise
##  Conduct the Chi-squared independence test of the smoking and exercise survey by computing the p-value with the textbook formula.






















# Linear Regression, Tests of Assumptions

library(boot) 
library(car)
library(QuantPsyc)
library(lmtest)
library(sandwich)
library(vars)
library(nortest)
library(MASS)

setwd("C:\\Users\\Gagan\\Desktop\\MUIT\\R - Dhiraj Upadhya\\IVY\\Linear Model")

data<- read.csv("Data.csv")
str(data)
summary(data)

nrow(data)
## 932 Rows

boxplot(data$Price_house)
quantile(data$Price_house, c(0,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.99,0.995,0.998,0.999,1))

data2 <- data[data$Price_house <10669146, ]
boxplot(data2$Price_house)
nrow(data)-nrow(data2)
## 2 row outliers deleted
quantile(data$Price_house, c(0,0.0001,0.001,0.01,0.02,0.05,0.1,0.25,0.5,0.75,0.90,0.95,0.99,0.995,0.998,0.999,1))



data3 <- data2[data2$Price_house >= 166112.2, ]
boxplot(data3$Price_house)

nrow(data)-nrow(data3)
## 3 rows outliers deleted

data <- data3


## Check the missing value (if any)
sapply(data, function(x) sum(is.na(x)))

data <- na.omit(data)

nrow(data)
names(data)


fit<- lm(Price_house ~ Taxi_dist + Market_dist + Hospital_dist + Carpet_area +  
           Builtup_area + Parking_type + City_type + Rainfall, data=data)

summary(fit)



fit<- lm(Price_house ~ Market_dist + Hospital_dist + Carpet_area +  
           Builtup_area + Parking_type + City_type + Rainfall, data=data)

summary(fit)


fit<- lm(Price_house ~  Hospital_dist + Carpet_area +  
           Builtup_area + Parking_type + City_type + Rainfall, data=data)

summary(fit)



fit<- lm(Price_house ~  Hospital_dist +  
           Builtup_area + Parking_type + City_type + Rainfall, data=data)

summary(fit)


##Final model 
fit<- lm(Price_house ~  Hospital_dist +  
           Builtup_area + Parking_type + City_type, data=data)

summary(fit)


#Check Vif, vif>2 means presence of multicollinearity
vif(fit)


## Get the predicted or fitted values
fitted(fit)

## MAPE
data$pred <- fitted(fit)

edit(data)
dataresult <- data
edit(dataresult)

write.csv(dataresult, file="dataresult.csv")


#Calculating MAPE
attach(data)
(sum((abs(Price_house-pred))/Price_house))/nrow(data)


##################################### Checking of Assumption ############################################

# residuals should be uncorrelated ##Autocorrelation
# Null H0: residuals from a linear regression are uncorrelated. Value should be close to 2. 
#Less than 1 and greater than 3 -> concern
## Should get a high p value

dwt(fit)

# Checking multicollinearity
vif(fit) # should be within 2. If it is greater than 10 then serious problem

################ Constant error variance ##########Heteroscedasticity


# Breusch-Pagan test -- Its checking for variance
bptest(fit)  # Null hypothesis -> error is homogenious (p value should be more than 0.05)



## Normality testing Null hypothesis is data is normal.

resids <- fit$residuals
ad.test(resids) #get Anderson-Darling test for normality 











# Graphs - Plots  Box, Histogram, Pie

## Using faithful data frame as a source for Graphs which is a default in R
faithful

duration <- faithful$eruptions
waiting <- faithful$waiting

head(cbind(faithful))

par(mfrow=c(2,2))

plot(duration,waiting,xlab = "Eruption", ylab = "Time waited")

hist(duration, right = FALSE,col = c("red","blue","yellow","red","blue","yellow","red","blue"))

boxplot(duration)

durationspie<- head(duration,4)
pie(durationspie)


## Creating a frequency distribution table from data faithful

faithful
names(faithful)
head(faithful)
duration = faithful$eruptions
duration
range(duration)
seq(1.5,5.5,by=0.5)
breaks = seq(1.5,5.5,by=0.5)
durations.cut=cut(duration,breaks,right=FALSE)
duration.freq = table(durations.cut)
duration.freq
cbind(duration.freq)
plot(duration.freq)
hist(duration.freq)
pie(duration.freq)
boxplot(duration,names = "Test001")


summary(duration)
































# Time Series 
## http://a-little-book-of-r-for-time-series.readthedocs.io/en/latest/src/timeseries.html
kings <- scan("http://robjhyndman.com/tsdldata/misc/kings.dat",skip=3)
#Read 42 items
kings
#To store the data in a time series object, we use the ts() function in R.

kingstimeseries <- ts(kings)
kingstimeseries
# Sometimes the time series data set that you have may have been collected at regular intervals that were less than one year, 
#for example, monthly or quarterly. In this case, you can specify the number of times that data was collected per year by using 
#the ‘frequency’ parameter in the ts() function. For monthly time series data, you set frequency=12, while for quarterly time series data, 
#you set frequency=4.

#You can also specify the first year that the data was collected, and the first interval in that year by using the ‘start’ parameter 
#in the ts() function. For example, if the first data point corresponds to the second quarter of 1986, you would set start=c(1986,2).

plot.ts(kingstimeseries)



# Sec2 --------------------------------------------------------------------
#example is a data set of the number of births per month in New York city, from January 1946 to December 1959

births <- scan("http://robjhyndman.com/tsdldata/data/nybirths.dat")
#Read 168 items
birthstimeseries <- ts(births, frequency=12, start=c(1946,1))
birthstimeseries
plot.ts(birthstimeseries)

# Sec3 --------------------------------------------------------------------

souvenir <- scan("http://robjhyndman.com/tsdldata/data/fancy.dat")
#Read 84 items
souvenirtimeseries <- ts(souvenir, frequency=12, start=c(1987,1))
souvenirtimeseries
plot.ts(souvenirtimeseries)
#In this case, it appears that an additive model is not appropriate for describing this time series, since the size of the seasonal fluctuations and random fluctuations seem to increase with the level of the time series. Thus, we may need to transform the time series in order to get a transformed time series that can be described using an additive model. For example, we can transform the time series by calculating the natural log of the original data:
logsouvenirtimeseries <- log(souvenirtimeseries)
plot.ts(logsouvenirtimeseries)
# size of the seasonal fluctuations and random fluctuations in the log-transformed time series seem to be roughly constant over time, and do not depend on the level of the time series. Thus, the log-transformed time series can probably be described using an additive model.



# Decomposing Time Series -------------------------------------------------

# Decomposing a time series means separating it into its constituent components, which are usually a trend component and an irregular component, and if it is a seasonal time series, a seasonal component.
# http://a-little-book-of-r-for-time-series.readthedocs.io/en/latest/src/timeseries.html#decomposing-time-series
library("TTR")
kingstimeseriesSMA3 <- SMA(kingstimeseries,n=3)
plot.ts(kingstimeseriesSMA3)

kingstimeseriesSMA8 <- SMA(kingstimeseries,n=8)
plot.ts(kingstimeseriesSMA8)


birthstimeseriescomponents <- decompose(birthstimeseries)
birthstimeseriescomponents$seasonal # get the estimated values of the seasonal component
plot(birthstimeseriescomponents)

# Seasonal Adjusting
birthstimeseriescomponents <- decompose(birthstimeseries)
birthstimeseriesseasonallyadjusted <- birthstimeseries - birthstimeseriescomponents$seasonal

plot(birthstimeseriesseasonallyadjusted)


# Forecasts using Exponential Smoothing - make short-term forecasts for time series data.----------------------------------

rain <- scan("http://robjhyndman.com/tsdldata/hurst/precip1.dat",skip=1)
#Read 100 items

rainseries <- ts(rain,start=c(1813))
plot.ts(rainseries)

rainseriesforecasts <- HoltWinters(rainseries, beta=FALSE, gamma=FALSE)
rainseriesforecasts
rainseriesforecasts$fitted
plot(rainseriesforecasts)
rainseriesforecasts$SSE
HoltWinters(rainseries, beta=FALSE, gamma=FALSE, l.start=23.56)

library("forecast")
rainseriesforecasts2 <- forecast.HoltWinters(rainseriesforecasts, h=8)
rainseriesforecasts2
plot.forecast(rainseriesforecasts2)
acf(rainseriesforecasts2$residuals, lag.max=20)
#Box.test(rainseriesforecasts2$residuals, lag=20, type="Ljung-Box")
plot.ts(rainseriesforecasts2$residuals)












