## Set the working directory
setwd("C:/Users/sarthak/Documents/Practice Questions/WPC")

## Read the input files
train_values <- read.csv("Train_values.csv")
train_labels <- read.csv("Train_labels.csv")
test <- read.csv("Test_values.csv")

str(train_values)
str(train_labels)
str(test)

## Merge train_labels and train_values to create one data frame
train <- merge(train_labels, train_values)

## Look at the number of pumps in each functional status group
table(train$status_group)
# as proportions
prop.table(table(train$status_group))
# 38.4% of water pumps are non-functional.

## Table of the quantity variable vs the status of the pumps
table(train$quantity, train$status_group)
# as row-wise proportions, margin = 1
prop.table(table(train$quantity, train$status_group), margin = 1)
# if the quantity variable is 'dry', the pump is not functional.

## Load the ggplot and googleVis package
library(ggplot2)
library(googleVis)

## Explore by different visualizations
qplot(quantity, data = train, geom = "bar", fill = status_group) + theme(legend.position = "top")

qplot(quality_group, data = train, geom = "bar", fill = status_group) + theme(legend.position = "top")

qplot(waterpoint_type, data = train, geom = "bar", fill = status_group) + theme(legend.position = "top") + theme(axis.text.x = element_text(angle = -20, hjust = 0))

# create histogram for `construction_year` grouped by `status_group`
ggplot(subset(train, construction_year > 0), aes(x = construction_year)) + geom_histogram(bins = 20) + facet_grid(~ status_group)

## Create scatter plot: latitude vs longitude with color as status_group
ggplot(subset(train[1 : 1000,], latitude < 0 & longitude > 0), aes(x = latitude, y = longitude, color = status_group)) + geom_point(shape = 1) + theme(legend.position = "top")

## Create a column 'latlong' to input into gvisGeoChart
train$latlong <- paste(round(train$latitude, 2), round(train$longitude, 2), sep = ":")

## Use gvisGeoChart to create an interactive map with well locations
wells_map <- gvisGeoChart(train[1 : 1000,], locationvar = "latlong", colorvar = "status_group", options = list(region = "TZ"))

## Plot wells_map
plot(wells_map)


### Make predictions

## Load the randomForest library
library(randomForest)

## Set seed and create a random forest classifier
set.seed(42)
model_forest <- randomForest(as.factor(status_group) ~ longitude + latitude + extraction_type_group + quality_group + quantity + waterpoint_type + construction_year, data = train, importance = TRUE, ntree = 5, nodesize = 2)

## Use random forest to predict the values in train
pred_forest_train <- predict(model_forest, train)

head(pred_forest_train)

## Load the caret library
library(caret)

## Confusion Matrix
confusionMatrix(pred_forest_train, train$status_group)

## Check the importance of variables
importance(model_forest)
varImpPlot(model_forest)


### Perform feature engineering on the `installer` variable

## Observe the installer variable
summary(train$installer)

## Make installer lowercase, take first 3 letters as a sub string
train$install_3 <- substr(tolower(train$installer), 1, 3)
train$install_3[train$install_3 %in% c(" ", "", "0", "_", "-")] <- "other"

## Take the top 15 substrings from above by occurance frequency
install_top_15 <- names(summary(as.factor(train$install_3)))[1:15]
train$install_3[!(train$install_3 %in% install_top_15)] <- "other"
train$install_3 <- as.factor(train$install_3)

## Table of the install_3 variable vs the status of the pumps
table(train$install_3, train$status_group)

## Create install_3 for the test set using same top 15 from above
test$install_3 <- substr(tolower(test$installer),1,3)
test$install_3[test$install_3 %in% c(" ", "", "0", "_", "-")] <- "other"
test$install_3[!(test$install_3 %in% install_top_15)] <- "other"
test$install_3 <- as.factor(test$install_3)

### Making second prediction

set.seed(42)
model_forest2 <- randomForest(as.factor(status_group) ~ longitude + latitude + extraction_type_group + quantity + waterpoint_type + construction_year + install_3, data = train, importance = TRUE, ntree = 5, nodesize = 2)

## Predict using the training values
pred_forest_train2 <- predict(model_forest2, train)
importance(model_forest)
confusionMatrix(pred_forest_train2, train$status_group)

## Predict using the test values
pred_forest_test <- predict(model_forest2, test)

## Create submission data frame
submission <- data.frame(test$id)
submission$status_group <- pred_forest_test
names(submission)[1] <- "id"

## Write to csv file
write.csv(submission, file = "submission.csv")
