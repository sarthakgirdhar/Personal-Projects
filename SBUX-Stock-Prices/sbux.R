## Set the working directory
setwd("C:/Users/sarthak/Documents/Computational Finance")

## Read the csv file
sbux_df <- read.csv("sbuxPrices.csv", header=TRUE, stringsAsFactors=FALSE)

## Structure
str(sbux_df)
head(sbux_df)

closing_prices <- sbux_df[ , "Adj.Close", drop=FALSE]

## Create a new data frame that contains the price data with the dates as the row names
sbux_prices_df <- sbux_df[, "Adj.Close", drop=FALSE]
rownames(sbux_prices_df) <- sbux_df$Date
head(sbux_prices_df)

## Plot
plot(sbux_df$Adj.Close, type="l", col="blue", lwd=2, ylab="Adjusted close", main="Monthly closing price of SBUX")
legend(x='topleft', legend='SBUX', lty=1, lwd=2, col='blue')

## Calculate simple returns ((P(t) - P(t-1)) / P(t-1))
n <- nrow(sbux_prices_df)
sbux_ret <- (sbux_prices_df[2:n, 1] - sbux_prices_df[1:(n-1), 1]) / sbux_prices_df[1:(n-1), 1]

## Add dates as names to the vector 'sbux_ret'
names(sbux_ret) <- sbux_df$Date[2:n]
head(sbux_ret)

## Compute 1-month continuous compounded returns
# Return = ln(1 + Simple return) = ln(P(t) / P(t-1)) = ln(P(t)) - ln(P(t-1))
sbux_ccret <- log(sbux_prices_df[2:n, 1]) - log(sbux_prices_df[1:(n-1), 1])
names(sbux_ccret) <- sbux_df$Date[2:n]
head(sbux_ccret)

## Compare simple and cc returns
ret <- cbind(sbux_ret, sbux_ccret)
head(ret)

## Graphically compare simple and cc returns
plot(sbux_ret, type="l", col="blue", lwd=2, ylab="Return", main="Monthly Returns on SBUX")
abline(h=0)
legend(x="bottomright", legend=c("Simple", "CC"), lty=1, lwd=2, col=c("blue","red"))
lines(sbux_ccret, col="red", lwd=2)

## Calculate growth of $1 invested in SBUX

# Compute future values
sbux_fv <- cumprod(sbux_ret + 1)

## Plot the evolution of the $1 invested in SBUX as a function of time
plot(sbux_fv, type="l", col="blue", lwd=2, ylab="Dollars", main="FV of $1 invested in SBUX")
