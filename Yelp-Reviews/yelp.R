## Set the working directory
setwd("C:/Users/sarthak/Documents/Practice Questions/Yelp Reviews")

## Read the input files
reviews <- read.csv("yelp_academic_dataset_review.csv", header = FALSE)
users <- read.csv("yelp_academic_dataset_user.csv", header = FALSE)
businesses <- read.csv("yelp_academic_dataset_business.csv", header = FALSE)

## Add names to the fields
colnames(reviews)[1] = "user_id"
colnames(reviews)[2] = "business_id"
colnames(reviews)[3] = "stars"
colnames(users)[1] = "user_id"
colnames(users)[2] = "user_name"
colnames(businesses)[1] = "business_id"
colnames(businesses)[2] = "city"
colnames(businesses)[3] = "business_name"
colnames(businesses)[4] = "categories"
colnames(businesses)[5] = "review_count"
colnames(businesses)[6] = "avg_stars"

## Load the dplyr library
library(dplyr)

## Join the files
ru <- inner_join(reviews, users)
rub <- inner_join(ru, businesses)

### Isolate Indian restaurants

# Add `is_Indian` field for any review that has "Indian" in `categories`
rub$is_indian <- grepl("Indian", rub$categories) == TRUE

## Make a dataframe of just reviews of Indian restaurants
indian <- subset(rub, is_indian == TRUE)

## Generate a new data frame with the number of reviews by each reviewer
number_reviews_Indian <- indian %>% select(user_id, user_name, is_indian) %>% 
  group_by(user_id) %>% 
  summarise(total_reviews = sum(is_indian))

## Print the table, show the total number of entries, and find the average number of reviews per user
table(number_reviews_Indian$total_reviews)
count(number_reviews_Indian)
mean(number_reviews_Indian$total_reviews)


### Method 1

## Combine number of Indian reviews with original data frame of Indian restaurant reviews
indian_plus_number <- inner_join(indian, number_reviews_Indian)

## Generate `weighted_stars` variable 
indian_plus_number$weighted_stars <- indian_plus_number$stars * indian_plus_number$total_reviews

## Create a new weighted review for each restaurant
new_review_indian <- indian_plus_number %>% 
  select(city, business_name, avg_stars, stars, total_reviews, weighted_stars) %>%
  group_by(city, business_name, avg_stars) %>%
  summarise(count = n(),
            avg = sum(stars) / count,
            new = sum(weighted_stars) / sum(total_reviews),
            diff = new - avg)

summary(new_review_indian)



### Method 2

## Read Indian names into a list
indian_names <- scan("indian_names.txt", what = character())

head(indian_names, 10)

## Subset the `indian` data set to just the users with native Indian names
authentic_users <- subset(indian, indian$user_name %in% indian_names)

## Find the number of users in each city
number_authentic_city <- authentic_users %>%
  select(city, user_name) %>%
  group_by(city) %>%
  summarise(users = n())

## Generate new "Indian" review
avg_review_indian <- authentic_users %>% 
  select(business_id, business_name, city, stars, avg_stars, is_indian, user_name) %>%
  group_by(city, business_name, avg_stars) %>%
  summarise(count = n(), new_stars = sum(stars) / count) %>%
  mutate(diff = new_stars - avg_stars)

summary(avg_review_indian)
