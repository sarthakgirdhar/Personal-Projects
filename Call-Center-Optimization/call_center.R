## Set the working directory
setwd("C:/Users/sarthak/Documents/AV/Call Center")

## Read the csv file
cc <- read.csv("CallCenter.csv")
summary(cc)

## Create a matrix where we store the maximum waiting time for each value of the number of callers
caller_opt <- matrix(0, 100, 2)

## Run loop for every number of callers possible. Here we take the range from 1 to 100
for (number_of_callers in (1:100)){
  # Initialize the available time for each caller
  caller <- rep(0, number_of_callers)
  
  # Index will be used to refer a caller
  index <- 1:number_of_callers
  
  # Store the difference of each callers availability from the time when the call was made
  caller_diff <- rep(0, number_of_callers)
  
  # Add two columns to the table : Caller assigned to the customer & Wait time for the customer
  cc$assigned <- 1
  cc$waittime <- 0
  
  for (i in 1:length(cc$Call))
  {
    caller_diff <- cc$Time[i] - caller
    best_caller_diff <- max(caller_diff)
    index1 <- index[min(index[caller_diff == best_caller_diff])]
    cc$assigned[i] <-  index1
    cc$waittime[i] <- max(-best_caller_diff, 0)
    caller[index1] <- caller[index1] + cc$Duration.of.calls[i] 
  }
  caller_opt[number_of_callers, 1] = number_of_callers
  caller_opt[number_of_callers, 2] = max(cc$waittime)
  print(caller_opt[number_of_callers, ])
}

# 48 callers are required to make sure we have no waiting time.
