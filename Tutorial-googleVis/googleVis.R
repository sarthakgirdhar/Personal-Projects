## Set the working directory
setwd("C:/Users/sarthak/Documents/Practice Questions/googleVis")

## Load rdatamarket and initialize client
library(rdatamarket)
dminit(NULL)

## Pull in life expectancy and population data
life_expectancy <- dmlist("15r2!hrp")
population <- dmlist("1cfl!r3d")

## Load in the yearly GDP data frame for each country as gdp
gdp <- dmlist("15c9!hd1")

## Inspect the above data frames
head(life_expectancy)
head(population)
tail(gdp)

## Load in the plyr package
library(plyr)

## Rename the value for each dataset
names(gdp)[3] <- "GDP"
names(population)[3] <- "Population"
names(life_expectancy)[3] <- "LifeExpectancy"

## Use plyr to join your three data frames into one: development
gdp_life_exp <- join(gdp, life_expectancy)
development <- join(gdp_life_exp, population)

## The data is complete only till 2008
development_complete <- subset(development, Year <= 2008)

## Load in the googleVis package
library(googleVis)

## Create the interactive motion chart
motion_graph <- gvisMotionChart(development_complete, idvar = "Country", timevar = "Year")

## Plot motion_graph
plot(motion_graph)

## Update the interactive motion chart to include labels for x & y axis and size of the bubbles
motion_graph <- gvisMotionChart(development_complete, idvar = "Country", timevar = "Year", xvar = "GDP", yvar = "LifeExpectancy", sizevar = "Population")

plot(motion_graph)

## Try to make the relationship linear between country's GDP per capita and life expectancy.

# Create a new column that corresponds to the log of the GDP column
development_complete$logGDP <- log(development_complete$GDP)

motion_graph <- gvisMotionChart(development_complete, idvar = "Country", timevar = "Year", xvar = "logGDP", yvar = "LifeExpectancy", sizevar = "Population")

plot(motion_graph)
