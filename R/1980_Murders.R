# Programming Languages for Data Engineering - AC50002
# Author: Julia Gratsova
# R Programming Assignment
# Dataset: This is the excert of The Murder Accountability Project (the most complete database of homicides 
# in the United States currently available). I have taken the data for the year 1980, for three states: Hawaii,
# Iowa and Idaho. This dataset includes the age, race, sex, ethnicity of victims and perpetrators, in addition
# to the relationship between the victim and perpetrator and weapon used.

#############################################################################################

library(ggplot2)
library (dplyr)
library(mice)


# Load dataset into data frame
murders <- read.csv("murders1980.csv")


# Initial data preparation to remove some of the variables (administration-related)
murders$Agency.Code <- NULL
murders$Agency.Name <- NULL
murders$Agency.Type <- NULL
murders$Year <- NULL
murders$Source <- NULL

# Replacement of the '0' and 'Unknown' with NA
dt <- murders
dt[dt == 'Unknown'] <- NA
dt[dt == 0] <- NA

#Check descriptive statistics
str(dt)
summary (dt)

# Check the % of data missing in rows and columns
pMiss <- function(x){sum(is.na(x))/length(x)*100}
apply(dt,2,pMiss)
apply(dt,1,pMiss)

# Impute data
md.pattern(dt)
tempData <- mice(dt,m=5,maxit=50,meth='pmm',seed=500)
summary(tempData)
completedData <- complete(tempData,1)

# Check for missings in the imputed dataset
sapply(completedData, function(x) sum(is.na(x)))

# Inspect distribution of original and imputed data
xyplot(tempData,Victim.Age ~ Victim.Race+Victim.Sex,pch=20,cex=1)
xyplot(tempData,Perpetrator.Age ~ Perpetrator.Race+Perpetrator.Sex,pch=20,cex=1)
densityplot(tempData)
stripplot(tempData, pch = 20, cex = 1.2)

# encoding categorical data
completedData$Crime.Solved = factor(completedData$Crime.Solved,
                         levels = c('Yes', 'No'),
                         labels = c(1, 0))
completedData$Month = factor(completedData$Month,
                                    levels = c('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'),
                                    labels = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))


# summary() and sapply() functions used to provide basic descriptive statistics (mean,median,25th and 75th quartiles,min,max,sd)
summary(completedData)
sapply(completedData,sd, na.rm=F)

###########################################################
# Plot relationships in the data
# Minimal theme from the pre-set ggplot themes is applied

# Number of incidents by sex in each state
state_inc <- completedData %>%
  group_by(State) %>%
  summarise(Incident = sum(Incident, na.rm = TRUE)) %>%
  arrange(Victim.Age) %>%
  mutate(State = factor(State, levels = .$State))
ggplot(state_inc, aes(State, Incident)) +
  geom_bar(stat = "identity") +
  coord_flip()

state_gender_inc <- completedData %>%
  group_by(State, Victim.Sex) %>%
  summarise(Victim.Age = sum(Victim.Age, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(State = factor(State, levels = state_inc$State))

ggplot(state_gender_inc, aes(State, Victim.Age, fill = Victim.Sex)) +
  ggtitle("Incidents by state and victim sex") +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip()

# Victims by race and ethnicity across 3 states
vic_age <- completedData %>%
  group_by(Victim.Race) %>%
  summarise(Incident = sum(Incident, na.rm = TRUE)) %>%
  arrange(Incident) %>%
  mutate(Victim.Race = factor(Victim.Race, levels = .$Victim.Race))
ggplot(vic_age, aes(Victim.Race, Incident)) +
  geom_bar(stat = "identity") +
  coord_flip()

vic_race_eth <- completedData %>%
  group_by(Victim.Race, Victim.Ethnicity) %>%
  summarise(Incident = sum(Incident, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(Victim.Race = factor(Victim.Race, levels = vic_age$Victim.Race))

ggplot(vic_race_eth, aes(Victim.Race, Incident, fill = Victim.Ethnicity)) +
  ggtitle("Victims by race and ethnicity across 3 states") +
  geom_bar(stat = "identity") +
  coord_flip()

# Months that had most incidents across 3 states
month_plot <- ggplot(data=completedData, aes(x=Month, y=Incident,
                                    colour=Month))
month_plot + geom_jitter() + geom_boxplot(size=1.2, alpha=0.5) +
  xlab("Month") +
  ylab("Number of Incidents") +
  ggtitle("Incidents per month") +
  theme_minimal()

# Male vs Female age at the time of death
vic_age_plot <- ggplot(data=completedData, aes(x=Victim.Sex, y=Victim.Age,
                                      colour=Victim.Sex))
vic_age_plot + geom_jitter() + geom_boxplot(size=1.2, alpha=0.5) +
  xlab("Victim Sex") +
  ylab("Victim Age") +
  ggtitle("Male vs Female age at the time of death") +
  theme_minimal()

#### Relationship between a victim and a perpetraitor
rel_perp <- ggplot(completedData, aes(Perpetrator.Sex, Relationship))
rel_perp + geom_count(col="tomato3", show.legend=T) +
  theme_minimal() +
  labs(y="Relationship", 
       x="Perpetrator Sex", 
       title="Relationship between a victim and a perpetrator")

# Histogram of solved vs unsolved crimes by victim age
ggplot(completedData, aes(Victim.Age, colour = Crime.Solved)) +
  geom_freqpoly(binwidth = 3) +
  xlab("Victim age") +
  ylab("Count") +
  ggtitle("Solved vs Unsolved crimes") +
  theme_minimal()

#############################################################################
# Investigate if data follows a normal distribution

## Victim age distribution
vic <- ggplot(data=completedData, aes(x=Victim.Age))
vic + geom_histogram(binwidth = 10,
                        fill="White", colour="tomato3") +
  theme_minimal() +
  xlab("Victim Age") +
  ylab("Count") +
  ggtitle("Victim age distribution")

# Density plots
vic + geom_density(aes(fill=Victime.Age), position="stack") 
qqnorm(completedData$Victim.Age);qqline(completedData$Victim.Age, col=3)

## Perpetrator age distribution
perp <- ggplot(data=completedData, aes(x=Perpetrator.Age))
perp + geom_histogram(binwidth = 10,
                     fill="White", colour="blue3") +  # Norm distribution
  theme_minimal() +
  xlab("Perpetrator Age") +
  ylab("Count") +
  ggtitle("Perpetrator age distribution")

# Density plots
perp + geom_density(aes(fill=Perpetrator.Age), position="stack") 
qqnorm(completedData$Perpetrator.Age);qqline(completedData$Perpetrator.Age, col=3)

# Construct a normal distribution dataset and compare to original data
norm_dist <- rnorm(n=177, sd=18.516, mean=33.91)

# Plot normal distribution
gen_df <- data.frame(gen_vic_age=norm_dist)
norm_plot <- ggplot(data=gen_df, aes(x=gen_vic_age))
norm_plot + geom_histogram(binwidth = 10,
                           fill="White", colour="Blue") +  
  theme_minimal() +
  geom_density(aes(fill=gen_vic_age), position="stack") +
  xlab("Generated Victim Age") +
  ylab("Count") +
  ggtitle("Generated Victim Age distribution")

# Density plots
norm_plot + geom_density(aes(fill=gen_vic_age), position="stack")
qqnorm(norm_dist);qqline(norm_dist, col=2)

################################################################################
# Explore data with linear regression

model <- lm(Victim.Age~Perpetrator.Age, data=completedData)
vi <- ggplot(data=completedData, aes(x=Victim.Age, y=Perpetrator.Age))
vi + geom_point()+
  ggtitle("Victim age and Perp age")+
  geom_smooth(method='lm')
summary(model)
confint(model)
anova(model)











